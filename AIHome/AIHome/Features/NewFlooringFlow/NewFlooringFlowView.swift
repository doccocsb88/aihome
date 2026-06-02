import SwiftUI

struct NewFlooringFlowView: View {
    @State private var viewModel = NewFlooringFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var initialImage: UIImage?
    var onGenerate: (NewFlooringDraft) -> Void
    
    var body: some View {
        SharedObjectModificationView(
            title: "New Flooring",
            promptPlaceholder: "Describe the new flooring you want...",
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
