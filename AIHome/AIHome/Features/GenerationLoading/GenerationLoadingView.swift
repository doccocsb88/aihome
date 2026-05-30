import SwiftUI

struct GenerationLoadingView: View {
    let viewModel: GenerationLoadingViewModel
    var onCancel: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ProgressView()
                .controlSize(.large)
                .scaleEffect(1.5)
            
            Text(viewModel.progressText)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Tip: " + tip(for: viewModel.projectType))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            if viewModel.canCancel {
                Button(action: {
                    onCancel?()
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
    }
    
    private func tip(for type: ProjectType) -> String {
        switch type {
        case .interior: return "Make sure the room is well-lit for better results."
        case .exterior: return "Clear the view of large obstructions like cars if possible."
        case .garden: return "Landscape changes work best when the whole yard is visible."
        default: return "AI is analyzing your image."
        }
    }
}
