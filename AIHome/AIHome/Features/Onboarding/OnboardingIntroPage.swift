import SwiftUI

struct OnboardingIntroPage: View {
    let imageName: String
    var beforeImageName: String?
    let title: String
    let subtitle: String
    let activeIndex: Int
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.DesignSystem.background
                    .ignoresSafeArea()

                headerImage(width: geometry.size.width, height: geometry.size.height)

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

                    Button(action: onContinue) {
                        Text(L10n.Onboarding.continue)
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
                    .padding(.top, 32)

                    pageIndicator
                        .padding(.top, 24)
                }
                .padding(.bottom, 8)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden()
    }

    private func headerImage(width: CGFloat, height: CGFloat) -> some View {
        let imageHeight = max(height * 0.68, 560)

        return OnboardingBeforeAfterHeroView(
            beforeImageName: beforeImageName ?? imageName,
            afterImageName: imageName,
            height: imageHeight
        )
        .frame(width: width, height: imageHeight)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                if index == activeIndex {
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
    }
}

private struct OnboardingBeforeAfterHeroView: View {
    let beforeImageName: String
    let afterImageName: String
    let height: CGFloat
    var showsRevealAnimation = true

    @State private var splitProgress: CGFloat = 0.38

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let splitX = width * splitProgress

            ZStack(alignment: .topLeading) {
                heroImage(beforeImageName, width: width)

                heroImage(afterImageName, width: width)
                    .mask {
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            Rectangle()
                                .frame(width: width - splitX)
                        }
                    }

                Rectangle()
                    .fill(Color.white.opacity(0.86))
                    .frame(width: 1, height: height * 0.56)
                    .offset(x: splitX)
                    .opacity(0.72)

                afterBadge
                    .padding(.top, 56)
                    .padding(.trailing, 16)
                    .frame(width: width, alignment: .trailing)

                bottomGradient
            }
            .clipped()
            .onAppear {
                guard showsRevealAnimation else { return }
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    splitProgress = 0.68
                }
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
}

#Preview {
    OnboardingIntroPage(
        imageName: "onboarding_page1",
        title: L10n.Onboarding.Interior.title,
        subtitle: L10n.Onboarding.Interior.subtitle,
        activeIndex: 0,
        onContinue: {}
    )
}
