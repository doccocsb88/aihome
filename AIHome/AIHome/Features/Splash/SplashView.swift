import SwiftUI

struct SplashView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            Color.DesignSystem.background.ignoresSafeArea()
            
            Text("HomeGPT")
                .font(.DesignSystem.title1)
                .foregroundColor(.DesignSystem.primary)
        }
        .navigationBarBackButtonHidden()
        .task {
            // Simulate a brief delay or minimal loading
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            let nextRoute = viewModel.determineNextRoute()
            coordinator.push(nextRoute)
        }
        .onAppear {
            AppLogger.logScreen("SplashView")
        }
    }
}

#Preview {
    SplashView()
        .environment(AppCoordinator())
}
