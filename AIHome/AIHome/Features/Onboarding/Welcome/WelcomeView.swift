import SwiftUI

struct WelcomeView: View {
    @State private var webPageToOpen: AppWebPage?

    var body: some View {
        ZStack(alignment: .top) {
            OnboardingContentPage(
                title: L10n.Onboarding.Welcome.title,
                subtitle: L10n.Onboarding.Welcome.subtitle
            ) {
                WelcomeImageMarqueeView()
                    .overlay {
                        OnboardingBottomGradient()
                    }
                    .padding(.top, 8)
            }

            welcomeTerms
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, OnboardingLayout.termsBottomSpacing)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.all)
        .sheet(item: $webPageToOpen) { webPage in
            AppWebView(title: webPage.title, url: webPage.url)
        }
    }

    private var welcomeTerms: some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                termsText("By continuing, you agree with ")
                termsButton(
                    "Terms of Use",
                    title: "Terms of Use",
                    urlString: "https://sites.google.com/billionx.co/homegpt-tos"
                )
                termsText(" and ")
                termsButton(
                    "Privacy Policy",
                    title: "Privacy Policy",
                    urlString: "https://sites.google.com/billionx.co/homegpt-privacy-policy"
                )
                termsText(",")
            }

            termsText("along with our use of third-party tools for app functionality.")
        }
        .multilineTextAlignment(.center)
        .frame(height: OnboardingLayout.termsHeight)
    }

    private func termsText(_ text: String) -> some View {
        Text(text)
            .font(FontFamily.Roboto.regular.swiftUIFont(size: 9))
            .foregroundColor(Color.DesignSystem.gray)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    private func termsButton(_ text: String, title: String, urlString: String) -> some View {
        Button {
            guard let url = URL(string: urlString) else { return }
            webPageToOpen = AppWebPage(title: title, url: url)
        } label: {
            Text(text)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 9))
                .foregroundColor(Color.DesignSystem.eerieBlack)
                .underline()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .buttonStyle(.plain)
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
