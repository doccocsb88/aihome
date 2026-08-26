import SwiftUI

struct RemoveObjectsFlowView: View {
    @State private var viewModel = RemoveObjectsFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var initialImage: UIImage?
    var onGenerate: (RemoveObjectsDraft) -> Void
    
    var body: some View {
        SharedObjectModificationView(
            title: "Remove Objects",
            promptPlaceholder: "What would you like to remove?",
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
