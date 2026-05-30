import SwiftUI

struct InteriorIntroView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Image("onboarding_page1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.55, alignment: .top)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color.DesignSystem.background],
                            startPoint: UnitPoint(x: 0.5, y: 0.7),
                            endPoint: .bottom
                        )
                    )
                
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    Text("Interior Design")
                        .font(.DesignSystem.title1)
                        .foregroundColor(.DesignSystem.textPrimary)
                        .padding(.bottom, 8)
                    
                    Text("Redesign your space instantly")
                        .font(.DesignSystem.body)
                        .foregroundColor(.DesignSystem.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
                    
                    Button(action: {
                        coordinator.push(.onboardingExterior)
                    }) {
                        Text("Continue")
                            .font(.DesignSystem.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.DesignSystem.primary)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    
                    // Page indicator
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(Color.DesignSystem.primary)
                            .frame(width: 24, height: 6)
                        Circle()
                            .fill(Color(UIColor.systemGray4))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color(UIColor.systemGray4))
                            .frame(width: 6, height: 6)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    InteriorIntroView()
        .environment(AppCoordinator())
}
