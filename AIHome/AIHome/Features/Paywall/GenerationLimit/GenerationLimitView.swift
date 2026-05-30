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
            
            Text("\(viewModel.freeGenerationsRemaining)/3 Free Generations Left")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Unlock unlimited features, faster processing, and premium designs with Pro.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: {
                viewModel.upgradeNow()
                dismiss()
            }) {
                Text("Upgrade Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    GenerationLimitView()
}
