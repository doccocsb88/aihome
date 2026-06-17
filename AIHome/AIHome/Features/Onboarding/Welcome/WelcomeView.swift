import SwiftUI

struct WelcomeView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.DesignSystem.background
                    .ignoresSafeArea()

                WelcomeImageMarqueeView()
                    .frame(height: max(geometry.size.height * 0.52, 380))
                    .padding(.top, 8)

                VStack(spacing: 0) {
                    Spacer()

                    Text(L10n.Onboarding.Welcome.title)
                        .font(.DesignSystem.title1)
                        .multilineTextAlignment(.center)

                    Text(L10n.Onboarding.Welcome.subtitle)
                        .font(.DesignSystem.body)
                        .foregroundColor(.DesignSystem.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: OnboardingLayout.contentBottomReserve)
                }
                .padding(.bottom, 8)

                welcomeTerms
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, OnboardingLayout.termsBottomSpacing)
            }
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.all)
    }

    private var welcomeTerms: some View {
        HStack(spacing: 16) {
            Link(L10n.Onboarding.Welcome.termsOfUse, destination: URL(string: "https://example.com/terms")!)
            Link(L10n.Onboarding.Welcome.subscriptionTerms, destination: URL(string: "https://example.com/subscription")!)
            Link(L10n.Onboarding.Welcome.privacyPolicy, destination: URL(string: "https://example.com/privacy")!)
        }
        .font(.DesignSystem.caption)
        .foregroundColor(.DesignSystem.textSecondary)
        .frame(height: OnboardingLayout.termsHeight)
    }
}

private struct WelcomeImageMarqueeView: View {
    @State private var isAnimating = false

    private let leftImages = [
        "01_welcome_01_interior_scandi_living",
        "02_welcome_02_interior_contemporary_kitchen",
        "03_welcome_03_interior_serene_bedroom",
        "04_welcome_04_interior_spa_bathroom",
        "05_welcome_05_interior_open_plan_loft"
    ]
    private let rightImages = [
        "06_welcome_06_exterior_modern_farmhouse",
        "07_welcome_07_exterior_contemporary_european",
        "08_welcome_08_garden_cozy_patio",
        "09_welcome_09_garden_formal_path",
        "10_welcome_10_garden_poolyard"
    ]

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 8
            let horizontalPadding: CGFloat = 8
            let columnWidth = (geometry.size.width - horizontalPadding * 2 - spacing) / 2
            let itemHeight = columnWidth * 1.25
            let cycleHeight = CGFloat(leftImages.count) * itemHeight + CGFloat(leftImages.count) * spacing

            HStack(alignment: .top, spacing: spacing) {
                marqueeColumn(
                    imageNames: leftImages,
                    width: columnWidth,
                    itemHeight: itemHeight,
                    spacing: spacing,
                    cycleHeight: cycleHeight,
                    direction: .up
                )

                marqueeColumn(
                    imageNames: rightImages,
                    width: columnWidth,
                    itemHeight: itemHeight,
                    spacing: spacing,
                    cycleHeight: cycleHeight,
                    direction: .down
                )
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
        }
        .clipped()
    }

    private func marqueeColumn(
        imageNames: [String],
        width: CGFloat,
        itemHeight: CGFloat,
        spacing: CGFloat,
        cycleHeight: CGFloat,
        direction: MarqueeDirection
    ) -> some View {
        let repeatedImages = imageNames + imageNames

        return VStack(spacing: spacing) {
            ForEach(repeatedImages.indices, id: \.self) { index in
                let imageName = repeatedImages[index]

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: itemHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .frame(width: width, alignment: .top)
        .offset(y: offset(for: direction, cycleHeight: cycleHeight))
    }

    private func offset(for direction: MarqueeDirection, cycleHeight: CGFloat) -> CGFloat {
        switch direction {
        case .up:
            return isAnimating ? -cycleHeight : 0
        case .down:
            return isAnimating ? 0 : -cycleHeight
        }
    }
}

private enum MarqueeDirection {
    case up
    case down
}

#Preview {
    WelcomeView()
}
