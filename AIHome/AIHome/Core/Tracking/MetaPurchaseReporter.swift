import Foundation
import StoreKit

@MainActor
final class MetaPurchaseReporter {
    static let shared = MetaPurchaseReporter()

    private enum Defaults {
        static let didSeedHistoricalTransactionsKey = "meta_purchase_reporter_did_seed_historical_transactions"
        static let processedTransactionIDsKey = "meta_purchase_reporter_processed_transaction_ids"
    }

    private let userDefaults: UserDefaults
    private var listenerTask: Task<Void, Never>?

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func start() {
        guard listenerTask == nil else { return }

        listenerTask = Task { [weak self] in
            guard let self else { return }
            await seedHistoricalTransactionsIfNeeded()
            await reportUnprocessedTransactions()
            await listenForTransactionUpdates()
        }
    }

    private func seedHistoricalTransactionsIfNeeded() async {
        guard !userDefaults.bool(forKey: Defaults.didSeedHistoricalTransactionsKey) else { return }

        var processedTransactionIDs = loadProcessedTransactionIDs()
        for await result in Transaction.all {
            guard case let .verified(transaction) = result else { continue }
            processedTransactionIDs.insert(transaction.analyticsID)
        }

        saveProcessedTransactionIDs(processedTransactionIDs)
        userDefaults.set(true, forKey: Defaults.didSeedHistoricalTransactionsKey)
        AppLogger.logAction(
            "Meta Purchase Reporter Seeded",
            details: "processed_transactions=\(processedTransactionIDs.count)"
        )
    }

    private func reportUnprocessedTransactions() async {
        for await result in Transaction.all {
            await process(result, source: "transaction_history")
        }
    }

    private func listenForTransactionUpdates() async {
        for await result in Transaction.updates {
            await process(result, source: "transaction_update")
        }
    }

    private func process(_ result: VerificationResult<Transaction>, source: String) async {
        guard case let .verified(transaction) = result else {
            AppLogger.logError("Meta Purchase Event skipped: unverified StoreKit transaction")
            return
        }

        var processedTransactionIDs = loadProcessedTransactionIDs()
        guard !processedTransactionIDs.contains(transaction.analyticsID) else { return }

        defer {
            processedTransactionIDs.insert(transaction.analyticsID)
            saveProcessedTransactionIDs(processedTransactionIDs)
        }

        guard transaction.productType == .autoRenewable else {
            logSkipped(transaction, source: source, reason: "not_auto_renewable")
            return
        }

        guard transaction.revocationDate == nil else {
            logSkipped(transaction, source: source, reason: "revoked")
            return
        }

        guard !isIntroductoryOffer(transaction) else {
            logSkipped(transaction, source: source, reason: "introductory_offer")
            return
        }

        guard let price = transaction.price,
              price > 0,
              let currency = transaction.currency?.identifier,
              !currency.isEmpty else {
            logSkipped(transaction, source: source, reason: "missing_real_charge")
            return
        }

        TrackingManager.shared.trackMetaPurchase(
            productID: transaction.productID,
            amount: NSDecimalNumber(decimal: price).doubleValue,
            currency: currency,
            source: source,
            transactionID: transaction.analyticsID,
            originalTransactionID: String(transaction.originalID)
        )
    }

    private func logSkipped(_ transaction: Transaction, source: String, reason: String) {
        AppLogger.logAction(
            "Meta Purchase Event Skipped",
            details: "reason=\(reason) source=\(source) product_id=\(transaction.productID) transaction_id=\(transaction.analyticsID)"
        )
    }

    private func isIntroductoryOffer(_ transaction: Transaction) -> Bool {
        if #available(iOS 17.2, *) {
            return transaction.offer?.type == .introductory
        }

        guard let paymentMode = transaction.offerPaymentModeStringRepresentation?.lowercased() else {
            return false
        }

        return paymentMode.contains("free") && paymentMode.contains("trial")
    }

    private func loadProcessedTransactionIDs() -> Set<String> {
        Set(userDefaults.stringArray(forKey: Defaults.processedTransactionIDsKey) ?? [])
    }

    private func saveProcessedTransactionIDs(_ transactionIDs: Set<String>) {
        userDefaults.set(Array(transactionIDs), forKey: Defaults.processedTransactionIDsKey)
    }
}

private extension Transaction {
    var analyticsID: String {
        String(id)
    }
}
