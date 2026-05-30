import SwiftUI

struct InteriorFlowView: View {
    @State private var viewModel = InteriorFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var onGenerate: (InteriorDraft) -> Void
    
    var body: some View {
        Group {
            VStack {
                // Progress Header
                Text("Step \\(viewModel.currentStep.rawValue)/4")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                // Content
                Group {
                    switch viewModel.currentStep {
                    case .photoSelection:
                        PhotoSourcePickerView(
                            viewModel: PhotoSourcePickerViewModel(
                                title: "Start with a photo",
                                subtitle: "Upload or select from template to try",
                                allowsSample: true,
                                sampleImages: [], // Add actual sample images here
                                ctaTitle: "Continue"
                            ),
                            onContinue: { image in
                                viewModel.draft.sourceImage = image
                                viewModel.nextStep()
                            }
                        )
                        
                    case .roomType:
                        roomTypeStep()
                        
                    case .designStyle:
                        designStyleStep()
                        
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
                        if viewModel.currentStep == .photoSelection {
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
    
    // MARK: - Steps Views
    
    @ViewBuilder
    private func roomTypeStep() -> some View {
        VStack(spacing: 20) {
            Text("Pick Room Type")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                    ForEach(viewModel.roomTypes, id: \.self) { room in
                        Button(action: {
                            viewModel.draft.roomType = room
                        }) {
                            Text(room)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.draft.roomType == room ? Color.blue : Color(UIColor.secondarySystemBackground))
                                .foregroundColor(viewModel.draft.roomType == room ? .white : .primary)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            
            Button(action: { viewModel.nextStep() }) {
                Text("Continue")
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
    private func designStyleStep() -> some View {
        VStack(spacing: 20) {
            Text("Pick Design Style")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                    ForEach(viewModel.designStyles, id: \.self) { style in
                        Button(action: {
                            viewModel.draft.designStyle = style
                        }) {
                            Text(style)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.draft.designStyle == style ? Color.blue : Color(UIColor.secondarySystemBackground))
                                .foregroundColor(viewModel.draft.designStyle == style ? .white : .primary)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                
                if viewModel.draft.designStyle == "Custom style" {
                    TextField("Enter custom style...", text: Binding(
                        get: { viewModel.draft.customStyle ?? "" },
                        set: { viewModel.draft.customStyle = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                }
            }
            
            Button(action: { viewModel.nextStep() }) {
                Text("Continue")
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
