import AppTrackingTransparency
import SwiftUI

struct OnboardingIntroPagerView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var selectedIndex = 0
    @State private var isShowingOnboardingPaywall = false
    @State private var remoteConfigManager = RemoteConfigManager.shared
    @State private var trialScreenShownAt: Date?
    @State private var hasShownOnboardingPaywall = false
    
    private var pages: [OnboardingIntroPageContent] {
        if remoteConfigManager.onboardingScreens {
            return OnboardingIntroPageContent.all
        }
        
        return []
    }

    private var lastContentIndex: Int { pages.count }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedIndex) {
                WelcomeView()
                    .tag(0)
                
                ForEach(Array(pages.enumerated()), id: \.element.id) { offset, page in
                    OnboardingIntroPage(
                        beforeImageName: page.beforeImageName,
                        afterImageName: page.afterImageName,
                        secondAfterImageName: page.secondAfterImageName,
                        title: page.title,
                        subtitle: page.subtitle
                    )
                    .tag(offset + 1)
                }
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            bottomControls
                .padding(.bottom, 26)
                .transition(.opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.28), value: selectedIndex)
        .ignoresSafeArea(edges: .all)
        .navigationBarBackButtonHidden()
        .task {
            await requestTrackingAuthorizationOnFirstPage()
        }
        .task {
            trackCurrentScreen()
        }
        .task(id: selectedIndex) {
            trackCurrentScreen()
        }
        .adaptyPaywall(
            isPresented: $isShowingOnboardingPaywall,
            placement: .onboarding,
            onClose: {
                trackTrialAction(.skip)
                continueAfterPaywallDismiss()
            },
            onPurchaseCompleted: completeOnboarding,
            onRestoreCompleted: completeOnboarding
        )
    }
    
    private func continueFromCurrentPage() {
        if shouldShowPaywallAfterCurrentPage {
            hasShownOnboardingPaywall = true
            trialScreenShownAt = Date()
            TrackingManager.shared.trackScreen(.trialEnabled)
            trackTrialAction(.continue)
            isShowingOnboardingPaywall = true
            return
        }

        guard selectedIndex < lastContentIndex else {
            isShowingOnboardingPaywall = true
            return
        }

        withAnimation(.easeInOut(duration: 0.28)) {
            selectedIndex = min(selectedIndex + 1, lastContentIndex)
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        coordinator.replaceRoot(with: .mainTab)
    }

    private var shouldShowPaywallAfterCurrentPage: Bool {
        guard !hasShownOnboardingPaywall else { return false }
        guard selectedIndex > 0, selectedIndex <= pages.count else { return false }
        return pages[selectedIndex - 1].index == 3
    }

    private func continueAfterPaywallDismiss() {
        guard selectedIndex < lastContentIndex else {
            completeOnboarding()
            return
        }

        withAnimation(.easeInOut(duration: 0.28)) {
            selectedIndex = min(selectedIndex + 1, lastContentIndex)
        }
    }

    @MainActor
    private func requestTrackingAuthorizationOnFirstPage() async {
        guard selectedIndex == 0 else { return }
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }

        try? await Task.sleep(nanoseconds: 600_000_000)
        guard selectedIndex == 0 else { return }
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            TrackingManager.shared.trackATTPromptShown()
            ATTrackingManager.requestTrackingAuthorization { status in
                AppLogger.logAction("ATT Authorization Requested", details: "\(status.rawValue)")
                Task { @MainActor in
                    TrackingManager.shared.trackATTResult(status: .init(attStatus: status))
                }
                continuation.resume()
            }
        }
    }

    private func trackCurrentScreen() {
        switch selectedIndex {
        case 0:
            TrackingManager.shared.trackScreen(.welcome)
        case 1...pages.count:
            trackOnboardingScreen(pages[selectedIndex - 1].index)
        default:
            break
        }
    }

    private func trackOnboardingScreen(_ index: Int) {
        switch index {
        case 1:
            TrackingManager.shared.trackScreen(.onboarding1)
        case 2:
            TrackingManager.shared.trackScreen(.onboarding2)
        case 3:
            TrackingManager.shared.trackScreen(.onboarding3)
        default:
            break
        }
    }

    private func trackTrialAction(_ action: TrackingManager.TrialScreenAction) {
        guard let trialScreenShownAt else { return }
        let durationMs = Int(Date().timeIntervalSince(trialScreenShownAt) * 1000)
        TrackingManager.shared.trackTrialEnabled(action: action, timeOnScreenMs: max(durationMs, 0))
    }
    
    private var bottomControls: some View {
        VStack(spacing: 0) {
            Button(action: continueFromCurrentPage) {
                Text(continueButtonTitle)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.DesignSystem.eerieBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.14), radius: 22, x: 0, y: 16)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            
            pageIndicator
                .padding(.top, OnboardingLayout.indicatorTopSpacing)
                .opacity(showsPageIndicator ? 1 : 0)
                .frame(height: OnboardingLayout.bottomAccessoryHeight)
        }
        .frame(height: OnboardingLayout.bottomControlsHeight, alignment: .top)
    }
    
    private var continueButtonTitle: String {
        if selectedIndex == 0 {
            return L10n.Onboarding.Welcome.getStarted
        }

        return L10n.Onboarding.continue
    }
    
    private var showsPageIndicator: Bool {
        selectedIndex > 0 && selectedIndex <= lastContentIndex
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Array(pages.enumerated()), id: \.element.id) { offset, _ in
                if offset + 1 == selectedIndex {
                    Capsule()
                        .fill(Color.DesignSystem.eerieBlack)
                        .frame(width: 24, height: 6)
                } else {
                    Circle()
                        .fill(Color.DesignSystem.platinum)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(height: OnboardingLayout.indicatorHeight)
    }
    
}

private extension TrackingManager.ATTStatus {
    init(attStatus: ATTrackingManager.AuthorizationStatus) {
        switch attStatus {
        case .authorized:
            self = .authorized
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        case .notDetermined:
            self = .notDetermined
        @unknown default:
            self = .notDetermined
        }
    }
}

enum OnboardingLayout {
    static let indicatorHeight: CGFloat = 6
    static let termsHeight: CGFloat = 24
    static let indicatorTopSpacing: CGFloat = 16
    static let termsBottomSpacing: CGFloat = 20
    static let bottomAccessoryHeight: CGFloat = 44
    static let bottomControlsHeight: CGFloat = 104
    static let contentBottomReserve: CGFloat = 150
}

private struct OnboardingIntroPageContent: Identifiable {
    let index: Int
    let beforeImageName: String
    let afterImageName: String
    let secondAfterImageName: String
    let title: String
    let subtitle: String
    
    var id: Int { index }
    
    static let all: [OnboardingIntroPageContent] = [
        .init(
            index: 1,
            beforeImageName: "onboarding_page1_before",
            afterImageName: "onboarding_page1_after1",
            secondAfterImageName: "onboarding_page1_after2",
            title: L10n.Onboarding.Interior.title,
            subtitle: L10n.Onboarding.Interior.subtitle
        ),
        .init(
            index: 2,
            beforeImageName: "onboarding_page2_before",
            afterImageName: "onboarding_page2_after1",
            secondAfterImageName: "onboarding_page2_after2",
            title: L10n.Onboarding.Exterior.title,
            subtitle: L10n.Onboarding.Exterior.subtitle
        ),
        .init(
            index: 3,
            beforeImageName: "onboarding_page3_before",
            afterImageName: "onboarding_page3_after1",
            secondAfterImageName: "onboarding_page3_after2",
            title: L10n.Onboarding.Landscape.title,
            subtitle: L10n.Onboarding.Landscape.subtitle
        )
    ]

}

#Preview {
    OnboardingIntroPagerView()
        .environment(AppCoordinator())
}
