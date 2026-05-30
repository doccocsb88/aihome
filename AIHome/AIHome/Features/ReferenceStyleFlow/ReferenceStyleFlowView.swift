import SwiftUI

struct ReferenceStyleFlowView: View {
    @State private var viewModel = ReferenceStyleFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var onGenerate: (ReferenceStyleDraft) -> Void
    
    var body: some View {
        Group {
            VStack {
                Text("Step \(viewModel.currentStep.rawValue)/3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                Group {
                    switch viewModel.currentStep {
                    case .sourceImage:
                        PhotoSourcePickerView(
                            viewModel: PhotoSourcePickerViewModel(
                                title: "Upload your room",
                                subtitle: "Choose a photo of your current space",
                                allowsSample: true,
                                sampleImages: [],
                                ctaTitle: "Continue"
                            ),
                            onContinue: { image in
                                viewModel.draft.sourceImage = image
                                viewModel.nextStep()
                            }
                        )
                    case .referenceImage:
                        PhotoSourcePickerView(
                            viewModel: PhotoSourcePickerViewModel(
                                title: "Upload reference style",
                                subtitle: "Choose an image with the style you want to apply",
                                allowsSample: true,
                                sampleImages: [],
                                ctaTitle: "Continue"
                            ),
                            onContinue: { image in
                                viewModel.draft.referenceImage = image
                                viewModel.nextStep()
                            }
                        )
                    case .intervention:
                        interventionStep()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if viewModel.currentStep == .sourceImage {
                            dismiss()
                        } else {
                            viewModel.previousStep()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func interventionStep() -> some View {
        VStack(spacing: 20) {
            Text("AI Intervention")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(spacing: 16) {
                    interventionOption(level: .high, title: "HIGH", description: "Creative redesign with high innovation, low preservation.")
                    interventionOption(level: .medium, title: "MEDIUM", description: "Balanced redesign with key room elements preserved.")
                    interventionOption(level: .light, title: "LIGHT", description: "Layout decoration with only textures and furniture updates.")
                }
                .padding()
            }
            
            Button(action: {
                onGenerate(viewModel.draft)
            }) {
                Text("Generate")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canContinue ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.canContinue)
            .padding()
        }
    }
    
    @ViewBuilder
    private func interventionOption(level: UIInterventionLevel, title: String, description: String) -> some View {
        Button(action: {
            viewModel.draft.intervention = level
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(viewModel.draft.intervention == level ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(viewModel.draft.intervention == level ? Color.blue : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}
