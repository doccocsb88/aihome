import AppTrackingTransparency
import SwiftUI

struct OnboardingIntroPagerView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var selectedIndex = 0
    @State private var isShowingOnboardingPaywall = false
    
    private let pages = OnboardingIntroPageContent.all
    private var trialPageIndex: Int { pages.count + 1 }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedIndex) {
                WelcomeView()
                    .tag(0)
                
                ForEach(pages) { page in
                    OnboardingIntroPage(
                        beforeImageName: page.beforeImageName,
                        afterImageName: page.afterImageName,
                        secondAfterImageName: page.secondAfterImageName,
                        title: page.title,
                        subtitle: page.subtitle
                    )
                    .tag(page.index)
                }
                
                TrialEnabledView()
                    .tag(trialPageIndex)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if selectedIndex != trialPageIndex {
                bottomControls
                    .padding(.bottom, 26)
                    .transition(.opacity)
            }
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
            guard selectedIndex == trialPageIndex else { return }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard selectedIndex == trialPageIndex else { return }
            isShowingOnboardingPaywall = true
        }
        .adaptyPaywall(
            isPresented: $isShowingOnboardingPaywall,
            placement: .onboarding,
            onClose: completeOnboarding,
            onPurchaseCompleted: completeOnboarding,
            onRestoreCompleted: completeOnboarding
        )
    }
    
    private func continueFromCurrentPage() {
        guard selectedIndex == trialPageIndex else {
            withAnimation(.easeInOut(duration: 0.28)) {
                selectedIndex = min(selectedIndex + 1, trialPageIndex)
            }
            return
        }
        
        isShowingOnboardingPaywall = true
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        coordinator.replaceRoot(with: .mainTab)
    }

    @MainActor
    private func requestTrackingAuthorizationOnFirstPage() async {
        guard selectedIndex == 0 else { return }
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }

        try? await Task.sleep(nanoseconds: 600_000_000)
        guard selectedIndex == 0 else { return }
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            ATTrackingManager.requestTrackingAuthorization { status in
                AppLogger.logAction("ATT Authorization Requested", details: "\(status.rawValue)")
                continuation.resume()
            }
        }
    }

    private func trackCurrentScreen() {
        switch selectedIndex {
        case 0:
            TrackingManager.shared.trackScreen(.welcome)
        case 1:
            TrackingManager.shared.trackScreen(.onboarding1)
        case 2:
            TrackingManager.shared.trackScreen(.onboarding2)
        case 3:
            TrackingManager.shared.trackScreen(.onboarding3)
        case trialPageIndex:
            TrackingManager.shared.trackScreen(.trialEnabled)
        default:
            break
        }
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
        
        if selectedIndex == trialPageIndex {
            return L10n.Onboarding.TrialEnabled.startDesigning
        }
        
        return L10n.Onboarding.continue
    }
    
    private var showsPageIndicator: Bool {
        selectedIndex > 0 && selectedIndex < trialPageIndex
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                if page.index == selectedIndex {
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
