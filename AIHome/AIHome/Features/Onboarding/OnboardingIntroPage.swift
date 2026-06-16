import SwiftUI

struct OnboardingIntroPage: View {
    let imageName: String
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
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height * 0.34, alignment: .top)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.DesignSystem.background.opacity(0.1),
                        Color.DesignSystem.background.opacity(0.72),
                        Color.DesignSystem.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
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

#Preview {
    OnboardingIntroPage(
        imageName: "onboarding_page1",
        title: L10n.Onboarding.Interior.title,
        subtitle: L10n.Onboarding.Interior.subtitle,
        activeIndex: 0,
        onContinue: {}
    )
}
