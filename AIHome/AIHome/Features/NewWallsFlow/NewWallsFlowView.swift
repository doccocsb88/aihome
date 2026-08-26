import SwiftUI

struct NewWallsFlowView: View {
    @State private var viewModel = NewWallsFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var initialImage: UIImage?
    var onGenerate: (NewWallsDraft) -> Void
    
    var body: some View {
        SharedObjectModificationView(
            title: "New Walls",
            promptPlaceholder: "Describe the new walls you want...",
            prompt: $viewModel.draft.prompt,
            photoPickerViewModel: viewModel.photoPickerViewModel,
            canGenerate: viewModel.canGenerate,
            onBack: {
                AdsManager.shared.showInterstitialCloseEdit {
                    dismiss()
                }
            },
            onGenerate: {
                viewModel.prepareDraft()
                onGenerate(viewModel.draft)
            }
        )
        .onAppear {
            if let img = initialImage {
                viewModel.photoPickerViewModel.selectedImage = img
            }
        }
    }
}
