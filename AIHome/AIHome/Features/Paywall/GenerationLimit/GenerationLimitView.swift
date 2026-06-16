import SwiftUI

struct GenerationLimitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GenerationLimitViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("\(viewModel.freeGenerationsRemaining)/\(viewModel.freeGenerationLimit) Free Generations Left")
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 22))
                .multilineTextAlignment(.center)
            
            Text("Unlock unlimited features, faster processing, and premium designs with Pro.")
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("Upgrade Now")
                    .font(FontFamily.Roboto.medium.swiftUIFont(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .task {
            await viewModel.refreshPremiumStatus()
        }
    }
}

#Preview {
    GenerationLimitView()
}
