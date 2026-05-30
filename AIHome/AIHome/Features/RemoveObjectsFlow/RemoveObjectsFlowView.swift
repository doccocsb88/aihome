import SwiftUI

struct RemoveObjectsFlowView: View {
    @State private var viewModel = RemoveObjectsFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var initialImage: UIImage?
    var onGenerate: (RemoveObjectsDraft) -> Void
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: 24) {
                    PhotoSourcePickerView(
                        viewModel: viewModel.photoPickerViewModel,
                        hideCTA: true
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)
                        
                        TextField("What would you like to remove?", text: $viewModel.draft.prompt, axis: .vertical)
                            .lineLimit(3...6)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.prepareDraft()
                        onGenerate(viewModel.draft)
                    }) {
                        Text("Generate")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canGenerate ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.canGenerate)
                    .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .onAppear {
                if let img = initialImage {
                    viewModel.photoPickerViewModel.selectedImage = img
                }
            }
        }
    }
}
