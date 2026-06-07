import SwiftUI

struct InteriorFlowView: View {
    @State private var viewModel = InteriorFlowViewModel()
    @Environment(\.dismiss) var dismiss
    
    var initialImage: UIImage?
    var onGenerate: (InteriorDraft) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            
            // Content
            Group {
                switch viewModel.currentStep {
                case .photoSelection:
                    PhotoSourcePickerView(
                        viewModel: viewModel.photoPickerViewModel,
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
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 24)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            if let initialImage {
                viewModel.applyInitialSourceImage(initialImage)
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    if viewModel.currentStep == .photoSelection {
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
                
                Text("Step \(viewModel.currentStep.rawValue)/4")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
                    .foregroundColor(.DesignSystem.textPrimary)
                
                Spacer()
                
                Button(action: {
                    if viewModel.currentStep != .photoSelection {
                        dismiss()
                    }
                }) {
                    Image(systemName: viewModel.currentStep == .photoSelection ? "info.circle" : "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)
            
            // Progress Bar
            HStack(spacing: 4) {
                ForEach(1...4, id: \.self) { step in
                    Rectangle()
                        .fill(step <= viewModel.currentStep.rawValue ? Color.DesignSystem.textPrimary : Color.gray.opacity(0.2))
                        .frame(height: 2)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Steps Views
    
    @ViewBuilder
    private func roomTypeStep() -> some View {
        VStack(spacing: 24) {
            Text("Pick a room type")
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                .foregroundColor(.DesignSystem.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(viewModel.roomTypes, id: \.self) { room in
                        Button(action: {
                            viewModel.draft.roomType = room
                        }) {
                            Text(room)
                                .font(FontFamily.Roboto.medium.swiftUIFont(size: 14))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(.DesignSystem.textPrimary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(viewModel.draft.roomType == room ? Color.DesignSystem.folly : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            
            Spacer()
            
            Button(action: { viewModel.nextStep() }) {
                Text("GET STARTED")
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
    private func designStyleStep() -> some View {
        VStack(spacing: 24) {
            Text("Pick a design style")
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                .foregroundColor(.DesignSystem.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(viewModel.designStyles, id: \.self) { style in
                        Button(action: {
                            viewModel.draft.designStyle = style
                        }) {
                            VStack(spacing: 0) {
                                if let imgName = designStyleImageName(for: style) {
                                    Image(imgName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 160)
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 160)
                                }
                                
                                Text(style.uppercased())
                                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 11))
                                    .foregroundColor(.DesignSystem.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(UIColor.systemBackground))
                            }
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(viewModel.draft.designStyle == style ? Color.DesignSystem.folly : Color.gray.opacity(0.2), lineWidth: viewModel.draft.designStyle == style ? 2 : 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                if viewModel.draft.designStyle == "Custom style" {
                    TextField("Enter custom style...", text: Binding(
                        get: { viewModel.draft.customStyle ?? "" },
                        set: { viewModel.draft.customStyle = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            
            Spacer()
            
            Button(action: { viewModel.nextStep() }) {
                Text("CONTINUE")
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
    
    private func designStyleImageName(for style: String) -> String? {
        switch style {
        case "Custom style": return "ic_interior_style_custom"
        case "Contemporary": return "ic_interior_style_contemporaty"
        case "Luxurious": return "ic_interior_style_luxe"
        case "St. Valentines": return "ic_interior_style_st_valentines"
        default: return nil
        }
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
