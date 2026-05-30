import SwiftUI

struct ExteriorFlowView: View {
    @State private var viewModel = ExteriorFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var onGenerate: (ExteriorDraft) -> Void
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: 24) {
                    PhotoSourcePickerView(
                        viewModel: viewModel.photoPickerViewModel,
                        hideCTA: true
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Instructions")
                            .font(.headline)
                        
                        TextField("Tailor the prompt with your own instructions to get the exact design you want.", text: $viewModel.draft.prompt, axis: .vertical)
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
        }
    }
}
