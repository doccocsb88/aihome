import SwiftUI

struct OnboardingIntroPage: View {
    let beforeImageName: String
    let afterImageName: String
    let secondAfterImageName: String
    let title: String
    let subtitle: String

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.DesignSystem.background
                    .ignoresSafeArea()

                headerImage(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    topSafeArea: geometry.safeAreaInsets.top
                )
                .ignoresSafeArea(edges: .top)

                VStack(spacing: 0) {
                    Spacer()

                    Text(title)
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 32))
                        .foregroundColor(.DesignSystem.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(subtitle)
                        .font(FontFamily.Roboto.regular.swiftUIFont(size: 17))
                        .foregroundColor(.DesignSystem.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.top, 10)

                    Spacer()
                        .frame(height: OnboardingLayout.contentBottomReserve)
                }
                .padding(.bottom, 8)
            }
        }
        .ignoresSafeArea(edges: .all)
        .navigationBarBackButtonHidden()
    }

    private func headerImage(width: CGFloat, height: CGFloat, topSafeArea: CGFloat) -> some View {
        let imageHeight = max(height * 0.68 + topSafeArea, 560 + topSafeArea)

        return OnboardingBeforeAfterHeroView(
            beforeImageName: beforeImageName,
            afterImageName: afterImageName,
            secondAfterImageName: secondAfterImageName,
            height: imageHeight
        )
        .frame(width: width, height: imageHeight)
    }

}

private struct OnboardingBeforeAfterHeroView: View {
    let beforeImageName: String
    let afterImageName: String
    let secondAfterImageName: String
    let height: CGFloat
    var showsRevealAnimation = true

    @State private var afterOneSplitProgress: CGFloat = 1
    @State private var afterTwoSplitProgress: CGFloat = 1
    @State private var dividerProgress: CGFloat = 1
    @State private var overlayOpacity: Double = 1
    @State private var showsDivider = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let dividerX = width * dividerProgress

            ZStack(alignment: .topLeading) {
                heroImage(beforeImageName, width: width)

                heroImage(afterImageName, width: width)
                    .revealMask(splitProgress: afterOneSplitProgress, width: width)
                    .opacity(overlayOpacity)

                heroImage(secondAfterImageName, width: width)
                    .revealMask(splitProgress: afterTwoSplitProgress, width: width)
                    .opacity(overlayOpacity)

                if showsDivider {
                    Rectangle()
                        .fill(Color.white.opacity(0.86))
                        .frame(width: 1, height: height * 0.56)
                        .offset(x: dividerX)
                        .opacity(dividerProgress > 0.02 ? 0.72 : 0)
                }

                afterBadge
                    .padding(.top, 56)
                    .padding(.trailing, 16)
                    .frame(width: width, alignment: .trailing)

                bottomGradient
            }
            .clipped()
            .task(id: animationIdentity) {
                await runRevealLoop()
            }
        }
    }

    private func heroImage(_ name: String, width: CGFloat) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height, alignment: .top)
            .clipped()
    }

    private var afterBadge: some View {
        Text("After")
            .font(FontFamily.Roboto.bold.swiftUIFont(size: 11))
            .foregroundColor(.white)
            .padding(.horizontal, 13)
            .frame(height: 30)
            .background(Color.black.opacity(0.58), in: Capsule())
    }

    private var bottomGradient: some View {
        LinearGradient(
            stops: [
                .init(color: Color.DesignSystem.background.opacity(0), location: 0.44),
                .init(color: Color.DesignSystem.background.opacity(0.9), location: 0.73),
                .init(color: Color.DesignSystem.background, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }

    private var animationIdentity: String {
        "\(beforeImageName)-\(afterImageName)-\(secondAfterImageName)-\(showsRevealAnimation)"
    }

    private func runRevealLoop() async {
        await MainActor.run {
            afterOneSplitProgress = showsRevealAnimation ? 1 : 0
            afterTwoSplitProgress = 1
            dividerProgress = 1
            overlayOpacity = 1
            showsDivider = false
        }

        guard showsRevealAnimation else { return }

        while !Task.isCancelled {
            await revealAfterOne()
            try? await Task.sleep(nanoseconds: 650_000_000)
            await revealAfterTwo()
            try? await Task.sleep(nanoseconds: 850_000_000)
            await resetToBefore()
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
    }

    private func revealAfterOne() async {
        await MainActor.run {
            afterOneSplitProgress = 1
            afterTwoSplitProgress = 1
            dividerProgress = 1
            overlayOpacity = 1
            showsDivider = true
        }

        await MainActor.run {
            withAnimation(.easeInOut(duration: 1.35)) {
                afterOneSplitProgress = 0
                dividerProgress = 0
            }
        }

        try? await Task.sleep(nanoseconds: 1_350_000_000)
        await MainActor.run {
            showsDivider = false
        }
    }

    private func revealAfterTwo() async {
        await MainActor.run {
            afterTwoSplitProgress = 1
            dividerProgress = 1
            showsDivider = true
        }

        await MainActor.run {
            withAnimation(.easeInOut(duration: 1.35)) {
                afterTwoSplitProgress = 0
                dividerProgress = 0
            }
        }

        try? await Task.sleep(nanoseconds: 1_350_000_000)
        await MainActor.run {
            showsDivider = false
        }
    }

    private func resetToBefore() async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.22)) {
                overlayOpacity = 0
            }
        }

        try? await Task.sleep(nanoseconds: 220_000_000)
        await MainActor.run {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                afterOneSplitProgress = 1
                afterTwoSplitProgress = 1
                dividerProgress = 1
                showsDivider = false
            }
            overlayOpacity = 1
        }
    }
}

private extension View {
    func revealMask(splitProgress: CGFloat, width: CGFloat) -> some View {
        let visibleWidth = max(0, width - (width * splitProgress))

        return mask {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                Rectangle()
                    .frame(width: visibleWidth)
            }
        }
    }
}

#Preview {
    OnboardingIntroPage(
        beforeImageName: "onboarding_page1_before",
        afterImageName: "onboarding_page1_after1",
        secondAfterImageName: "onboarding_page1_after2",
        title: L10n.Onboarding.Interior.title,
        subtitle: L10n.Onboarding.Interior.subtitle
    )
}
