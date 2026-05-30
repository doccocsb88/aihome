import SwiftUI

struct NewWallsFlowView: View {
    @State private var viewModel = NewWallsFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var initialImage: UIImage?
    var onGenerate: (NewWallsDraft) -> Void
    
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
                        
                        TextField("Describe the new walls you want...", text: $viewModel.draft.prompt, axis: .vertical)
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
