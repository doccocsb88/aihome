import Adapty
import Foundation

final class NewsBreakAttributionService {
    static let shared = NewsBreakAttributionService()

    private enum Keys {
        static let installationId = "nb.installation_id"
        static let firstOpenAt = "nb.first_open_at"
        static let isNewInstall = "nb.is_new_install"
        static let pendingBody = "nb.pending_body"
        static let pendingPayload = "nb.pending_payload"
        static let sent = "nb.sent"
    }

    private enum LegacyKeys {
        static let keys = [
            "hasSeenOnboarding",
            "isProCached",
            "freeUsageCount",
            "popupRating.appSessionCount",
        ]
    }

    private enum InstallState: String {
        case fresh = "true"
        case hold
        case existing = "false"
    }

    private let userDefaults: UserDefaults
    private let isoFormatter = ISO8601DateFormatter()
    private var isFlushInFlight = false

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func markLaunch() {
        ensureInstallMarkerIfNeeded()
        Task {
            await preparePendingBodyIfPossible()
            await flush()
        }
    }

    func handleInstallationDetails(_ details: AdaptyInstallationDetails) {
        ensureInstallMarkerIfNeeded()

        guard !userDefaults.bool(forKey: Keys.sent),
              userDefaults.data(forKey: Keys.pendingBody) == nil,
              let payload = details.payload?.dictionary,
              let clickId = payload["deferred_data_sub1"] as? String,
              isValidClickId(clickId) else {
            return
        }

        storePendingPayloadIfNeeded(details.payload)

        Task {
            await preparePendingBodyIfPossible(payload: payload)
            await flush()
        }
    }

    func flush(attempt: Int = 0) async {
        guard !isFlushInFlight else { return }
        isFlushInFlight = true
        defer { isFlushInFlight = false }

        await performFlush(attempt: attempt)
    }

    func preparePendingBodyAndFlush() async {
        await preparePendingBodyIfPossible()
        await flush()
    }

    private func performFlush(attempt: Int = 0) async {
        guard let body = userDefaults.data(forKey: Keys.pendingBody) else { return }

        var request = URLRequest(url: endpoint, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = await FirebaseAppCheckService.shared.token(forcingRefresh: attempt > 0) {
            request.setValue(token, forHTTPHeaderField: "X-Firebase-AppCheck")
        }

        request.httpBody = body

        let statusCode: Int
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        } catch {
            AppLogger.logError("NewsBreak attribution request failed", error: error)
            statusCode = -1
        }

        switch statusCode {
        case 200, 202:
            userDefaults.removeObject(forKey: Keys.pendingBody)
            userDefaults.removeObject(forKey: Keys.pendingPayload)
            userDefaults.set(true, forKey: Keys.sent)
            AppLogger.logAction("NewsBreak Attribution Sent", details: "\(statusCode)")
        case 400, 403, 409, 422:
            userDefaults.removeObject(forKey: Keys.pendingBody)
            userDefaults.removeObject(forKey: Keys.pendingPayload)
            userDefaults.set(true, forKey: Keys.sent)
            AppLogger.logAction("NewsBreak Attribution Rejected", details: "\(statusCode)")
        default:
            guard attempt < 5 else {
                AppLogger.logAction("NewsBreak Attribution Pending", details: "status \(statusCode)")
                return
            }

            let delaySeconds = min(32, 2 * (1 << attempt))
            try? await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)
            await performFlush(attempt: attempt + 1)
        }
    }

    private func preparePendingBodyIfPossible(payload: [String: Any]? = nil) async {
        guard !userDefaults.bool(forKey: Keys.sent),
              userDefaults.data(forKey: Keys.pendingBody) == nil else {
            return
        }

        let payload = payload ?? storedPendingPayload()
        guard let payload,
              let clickId = payload["deferred_data_sub1"] as? String,
              isValidClickId(clickId) else {
            return
        }

        do {
            let profile = try await Adapty.getProfile()
            let body = makeRequestBody(payload: payload, clickId: clickId, profile: profile)
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            userDefaults.set(data, forKey: Keys.pendingBody)
        } catch {
            AppLogger.logError("NewsBreak attribution body preparation failed", error: error)
        }
    }

    private func makeRequestBody(
        payload: [String: Any],
        clickId: String,
        profile: AdaptyProfile
    ) -> [String: Any] {
        [
            "schema_version": 1,
            "request_id": UUID().uuidString.lowercased(),
            "installation_id": installationId,
            "app_id": Bundle.main.bundleIdentifier ?? "",
            "platform": "ios",
            "environment": isSandbox ? "Sandbox" : "Production",
            "profile_id": profile.profileId.lowercased(),
            "customer_user_id": profile.customerUserId.map { $0 as Any } ?? NSNull(),
            "newsbreak_click_id": clickId,
            "first_open_at": firstOpenAt,
            "attribution_received_at": isoFormatter.string(from: Date()),
            "is_new_install": isNewInstallValue,
            "campaign": [
                "channel": "newsbreak",
                "campaign_id": sanitizedCampaignValue(payload["deferred_data_sub2"] as? String),
                "adset_id": sanitizedCampaignValue(payload["deferred_data_sub3"] as? String),
                "ad_id": sanitizedCampaignValue(payload["deferred_data_sub4"] as? String),
            ],
        ]
    }

    private func ensureInstallMarkerIfNeeded() {
        guard userDefaults.string(forKey: Keys.installationId) == nil else { return }

        let state: InstallState = hasLegacyAppData ? .hold : .fresh
        userDefaults.set(UUID().uuidString.lowercased(), forKey: Keys.installationId)
        userDefaults.set(isoFormatter.string(from: Date()), forKey: Keys.firstOpenAt)
        userDefaults.set(state.rawValue, forKey: Keys.isNewInstall)
    }

    private func storePendingPayloadIfNeeded(_ payload: AdaptyInstallationDetails.Payload?) {
        guard userDefaults.data(forKey: Keys.pendingPayload) == nil,
              let data = payload?.jsonString.data(using: .utf8) else {
            return
        }

        userDefaults.set(data, forKey: Keys.pendingPayload)
    }

    private func storedPendingPayload() -> [String: Any]? {
        guard let data = userDefaults.data(forKey: Keys.pendingPayload),
              let payload = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }

        return payload
    }

    private var installationId: String {
        ensureInstallMarkerIfNeeded()
        return userDefaults.string(forKey: Keys.installationId) ?? ""
    }

    private var firstOpenAt: String {
        ensureInstallMarkerIfNeeded()
        return userDefaults.string(forKey: Keys.firstOpenAt) ?? isoFormatter.string(from: Date())
    }

    private var isNewInstallValue: Any {
        switch InstallState(rawValue: userDefaults.string(forKey: Keys.isNewInstall) ?? "") {
        case .fresh:
            return true
        case .hold:
            return "hold"
        case .existing, .none:
            return false
        }
    }

    private var hasLegacyAppData: Bool {
        LegacyKeys.keys.contains { userDefaults.object(forKey: $0) != nil }
    }

    private var endpoint: URL {
        let path = isSandbox ? "/sandbox/v1/newsbreak/attribution" : "/v1/newsbreak/attribution"
        return URL(string: "https://aiart.billionx.co\(path)")!
    }

    private var isSandbox: Bool {
        AppEnvironmentService.shared.isDebug || AppEnvironmentService.shared.isTestFlight
    }

    private func isValidClickId(_ clickId: String) -> Bool {
        let trimmedClickId = clickId.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedClickId.isEmpty &&
            !trimmedClickId.contains("__") &&
            !trimmedClickId.contains("{")
    }

    private func sanitizedCampaignValue(_ value: String?) -> String {
        guard let value else { return "" }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.contains("__"), !trimmedValue.contains("{") else { return "" }
        return trimmedValue
    }
}

final class NewsBreakAdaptyDelegate: AdaptyDelegate {
    static let shared = NewsBreakAdaptyDelegate()

    private init() {}

    nonisolated func didLoadLatestProfile(_ profile: AdaptyProfile) {}

    nonisolated func onInstallationDetailsSuccess(_ details: AdaptyInstallationDetails) {
        Task { @MainActor in
            NewsBreakAttributionService.shared.handleInstallationDetails(details)
        }
    }

    nonisolated func onInstallationDetailsFail(error: AdaptyError) {
        Task { @MainActor in
            AppLogger.logError("NewsBreak installation details failed", error: error)
        }
    }
}
