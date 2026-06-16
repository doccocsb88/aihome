import SwiftUI

struct SplashView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = SplashViewModel()
    @State private var progress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: max(geometry.size.height * 0.37, 260))

                appIcon
                    .frame(width: 128, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                Text("HomeGPT")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 34))
                    .foregroundColor(Color.DesignSystem.eerieBlack)
                    .padding(.top, 28)

                progressBar
                    .frame(width: 250, height: 6)
                    .padding(.top, 40)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .task {
            withAnimation(.easeInOut(duration: 1.0)) {
                progress = 1
            }

            try? await Task.sleep(nanoseconds: 1_000_000_000)
            let nextRoute = viewModel.determineNextRoute()
            coordinator.push(nextRoute)
        }
        .onAppear {
            AppLogger.logScreen("SplashView")
        }
    }

    private var appIcon: some View {
        Group {
            if let image = UIImage.appIcon {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.DesignSystem.platinum)
                    .overlay(
                        Text("HG")
                            .font(FontFamily.Roboto.bold.swiftUIFont(size: 34))
                            .foregroundColor(Color.DesignSystem.eerieBlack)
                    )
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.DesignSystem.platinum)

                Capsule()
                    .fill(Color.DesignSystem.eerieBlack)
                    .frame(width: max(proxy.size.height, proxy.size.width * progress))
            }
        }
    }
}

private extension UIImage {
    static var appIcon: UIImage? {
        let primaryIcon = Bundle.main.infoDictionary?["CFBundleIcons"]
            .flatMap { $0 as? [String: Any] }?["CFBundlePrimaryIcon"] as? [String: Any]
        let iconFiles = primaryIcon?["CFBundleIconFiles"] as? [String]
        let iconName = iconFiles?.last

        return iconName.flatMap { UIImage(named: $0) }
            ?? UIImage(named: "AppIcon")
            ?? UIImage(named: "1024")
    }
}

#Preview {
    SplashView()
        .environment(AppCoordinator())
}
