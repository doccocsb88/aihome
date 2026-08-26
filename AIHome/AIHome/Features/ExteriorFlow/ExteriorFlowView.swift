import SwiftUI

struct ExteriorFlowView: View {
    @State private var viewModel = ExteriorFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var initialImage: UIImage?
    var onGenerate: (ExteriorDraft) -> Void
    
    var body: some View {
        SharedObjectModificationView(
            title: L10n.ExteriorFlow.title,
            promptPlaceholder: L10n.ExteriorFlow.promptPlaceholder,
            prompt: $viewModel.draft.prompt,
            photoPickerViewModel: viewModel.photoPickerViewModel,
            canGenerate: viewModel.canGenerate,
            photoTipsStyle: .exterior,
            onBack: {
                AdsManager.shared.showInterstitialCloseEdit {
                    dismiss()
                }
            },
            onGenerate: {
                viewModel.draft.sourceImage = viewModel.photoPickerViewModel.selectedImage
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
