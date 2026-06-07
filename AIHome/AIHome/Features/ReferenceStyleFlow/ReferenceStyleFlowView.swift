import SwiftUI

struct ReferenceStyleFlowView: View {
    @State private var viewModel = ReferenceStyleFlowViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showingPhotoTips = false
    
    var onGenerate: (ReferenceStyleDraft) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            
            Group {
                switch viewModel.currentStep {
                case .sourceImage:
                    PhotoSourcePickerView(
                        viewModel: viewModel.sourcePhotoPickerViewModel,
                        onContinue: { image in
                            viewModel.draft.sourceImage = image
                            viewModel.nextStep()
                        }
                    )
                case .referenceImage:
                    PhotoSourcePickerView(
                        viewModel: viewModel.referencePhotoPickerViewModel,
                        onContinue: { image in
                            viewModel.draft.referenceImage = image
                            viewModel.nextStep()
                        }
                    )
                case .intervention:
                    interventionStep()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 24)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.container, edges: .bottom)
        .sheet(isPresented: $showingPhotoTips) {
            PhotoTipsView()
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    if viewModel.currentStep == .sourceImage {
                        dismiss()
                    } else {
                        viewModel.previousStep()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.DesignSystem.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(Color.DesignSystem.background)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                Text("Step \(viewModel.currentStep.rawValue)/3")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
                    .foregroundColor(.DesignSystem.textPrimary)
                
                Spacer()
                
                Button(action: {
                    if viewModel.currentStep != .sourceImage {
                        dismiss()
                    } else {
                        showingPhotoTips = true
                    }
                }) {
                    Image(systemName: viewModel.currentStep == .sourceImage ? "info.circle" : "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 24)
            
            // Progress Bar
            HStack(spacing: 4) {
                ForEach(1...3, id: \.self) { step in
                    Rectangle()
                        .fill(step <= viewModel.currentStep.rawValue ? Color.DesignSystem.textPrimary : Color.gray.opacity(0.2))
                        .frame(height: 2)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func interventionStep() -> some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("AI Intervention")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                    .foregroundColor(.DesignSystem.textPrimary)
                
                Text("How much of the original layout should we keep?")
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Image("ic_interior_Intervention_preview")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                    
                    VStack(spacing: 16) {
                        interventionOption(level: .high, title: "HIGH", description: "Creative redesign with high innovation, low preservation.", iconName: "ic_interior_Intervention_high")
                        interventionOption(level: .medium, title: "MEIDUM", description: "Balanced redesign with key room elements preserved.", iconName: "ic_interior_Intervention_meidum")
                        interventionOption(level: .light, title: "LIGHT", description: "Layout decoration with only textures and furniture updates.", iconName: "ic_interior_Intervention_light")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            
            Spacer()
            
            Button(action: {
                onGenerate(viewModel.draft)
            }) {
                Text("GENERATE")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                    .foregroundColor(viewModel.canContinue ? Color.DesignSystem.background : .white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(viewModel.canContinue ? Color.DesignSystem.textPrimary : Color.gray.opacity(0.3))
                    .cornerRadius(16)
            }
            .disabled(!viewModel.canContinue)
            .padding(.horizontal, 32)
            .padding(.bottom, 36)
        }
    }
    
    @ViewBuilder
    private func interventionOption(level: UIInterventionLevel, title: String, description: String, iconName: String) -> some View {
        Button(action: {
            viewModel.draft.intervention = level
        }) {
            HStack(spacing: 16) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                        .foregroundColor(.DesignSystem.textPrimary)
                    Text(description)
                        .font(FontFamily.Roboto.regular.swiftUIFont(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(viewModel.draft.intervention == level ? Color.DesignSystem.folly : Color.gray.opacity(0.2), lineWidth: viewModel.draft.intervention == level ? 2 : 1)
            )
        }
    }
}
