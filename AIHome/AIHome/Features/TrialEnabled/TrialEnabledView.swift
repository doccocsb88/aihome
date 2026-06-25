import Lottie
import SwiftUI

struct TrialEnabledView: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: max(130, proxy.size.height * 0.18))

                LottieAnimationPlayer(name: "Toggle-trial-anim")
                    .frame(width: 154, height: 114)
                    .shadow(color: Color.DesignSystem.emerald.opacity(0.25), radius: 42, x: 0, y: 12)

                titleText
                    .padding(.top, 90)

                Text(L10n.Onboarding.TrialEnabled.subtitle)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                    .foregroundColor(Color.DesignSystem.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(14)
                    .padding(.top, 26)
                    .padding(.horizontal, 58)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.DesignSystem.ghostWhite.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }

    private var titleText: some View {
        VStack(spacing: 8) {
            Text(L10n.Onboarding.TrialEnabled.titleLine1)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 32))
                .foregroundStyle(.black)

            Text(L10n.Onboarding.TrialEnabled.titleLine2)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 32))
                .foregroundStyle(Color.DesignSystem.emerald)
        }
        .multilineTextAlignment(.center)
    }
}

private struct LottieAnimationPlayer: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        animationView.play()
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    TrialEnabledView()
}
