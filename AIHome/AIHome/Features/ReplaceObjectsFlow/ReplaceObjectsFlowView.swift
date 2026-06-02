import SwiftUI

struct ReplaceObjectsFlowView: View {
    @State private var viewModel = ReplaceObjectsFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var initialImage: UIImage?
    var onGenerate: (ReplaceObjectsDraft) -> Void
    
    var body: some View {
        SharedObjectModificationView(
            title: "Replace Objects",
            promptPlaceholder: "Tailor the prompt with your own instructions to get the exact design you want.",
            prompt: $viewModel.draft.prompt,
            photoPickerViewModel: viewModel.photoPickerViewModel,
            canGenerate: viewModel.canGenerate,
            onBack: {
                dismiss()
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
