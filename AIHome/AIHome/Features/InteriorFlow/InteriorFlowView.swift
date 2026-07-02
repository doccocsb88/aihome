import SwiftUI

struct InteriorFlowView: View {
    @State private var viewModel = InteriorFlowViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showingPhotoTips = false
    @State private var showingCustomStyleOverlay = false
    @State private var customStyleText = ""

    var initialImage: UIImage?
    var onGenerate: (InteriorDraft) -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                progressHeader

                // Content
                Group {
                    switch viewModel.currentStep {
                    case .photoSelection:
                        photoSelectionStep()

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

            if showingCustomStyleOverlay {
                CustomStylePopupView(
                    text: $customStyleText,
                    onClose: {
                        showingCustomStyleOverlay = false
                    },
                    onApply: { customStyle in
                        viewModel.draft.designStyle = .noStyle
                        viewModel.draft.customStyle = customStyle
                        showingCustomStyleOverlay = false
                    }
                )
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: showingCustomStyleOverlay)
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            if let initialImage {
                viewModel.applyInitialSourceImage(initialImage)
            }
        }
        .sheet(isPresented: $showingPhotoTips) {
            PhotoTipsView()
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

                Text(L10n.Flow.step(viewModel.currentStep.rawValue, 4))
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
                    .foregroundColor(.DesignSystem.textPrimary)

                Spacer()

                Button(action: {
                    if viewModel.currentStep != .photoSelection {
                        dismiss()
                    } else {
                        showingPhotoTips = true
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
    private func photoSelectionStep() -> some View {
        VStack(spacing: 24) {
            PhotoSourcePickerView(
                viewModel: viewModel.photoPickerViewModel,
                hideCTA: true
            )

            if viewModel.photoPickerViewModel.allowsSample,
               viewModel.photoPickerViewModel.selectedImage == nil,
               !viewModel.photoPickerViewModel.sampleImages.isEmpty {
                TrySampleView(
                    title: viewModel.photoPickerViewModel.sampleTitle,
                    imageNames: viewModel.photoPickerViewModel.sampleImages,
                    onSelect: { sample in
                        viewModel.photoPickerViewModel.selectSample(sample)
                    }
                )
                .padding(.top, 8)
            }

            Spacer()

            InteriorCTAButton(
                title: viewModel.photoPickerViewModel.ctaTitle,
                isEnabled: viewModel.canContinue,
                action: {
                    guard let image = viewModel.photoPickerViewModel.selectedImage else { return }
                    viewModel.draft.sourceImage = image
                    viewModel.nextStep()
                }
            )
            .padding(.horizontal, 32)
            .padding(.bottom, 36)
        }
    }

    @ViewBuilder
    private func roomTypeStep() -> some View {
        VStack(spacing: 24) {
            Text(L10n.InteriorFlow.pickRoomType)
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
                            Text(room.rawValue)
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

            InteriorCTAButton(
                title: L10n.Flow.getStarted,
                isEnabled: viewModel.canContinue,
                action: { viewModel.nextStep() }
            )
            .padding(.horizontal, 32)
            .padding(.bottom, 36)
        }
    }

    @ViewBuilder
    private func designStyleStep() -> some View {
        VStack(spacing: 0) {
            Text(L10n.InteriorFlow.pickDesignStyle)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                .foregroundColor(.DesignSystem.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(viewModel.designStyles, id: \.self) { style in
                        Button(action: {
                            if style == .noStyle {
                                customStyleText = viewModel.draft.customStyle ?? ""
                                showingCustomStyleOverlay = true
                            } else {
                                viewModel.draft.designStyle = style
                                viewModel.draft.customStyle = nil
                            }
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

                                Text(style.rawValue.uppercased())
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
            }

            InteriorCTAButton(
                title: L10n.Flow.continue,
                isEnabled: viewModel.canContinue,
                action: { viewModel.nextStep() }
            )
            .padding(.horizontal, 32)
            .padding(.bottom, 36)
        }
    }

    private func designStyleImageName(for style: InteriorDesignStyle) -> String? {
        switch style {
        case .noStyle: return "ic_interior_style_custom"
        case .transitional: return "interior_style_01"
        case .traditional: return "interior_style_02"
        case .scandinavian: return "interior_style_03"
        case .organicModern: return "interior_style_04"
        case .modernFarmHouse: return "interior_style_05"
        case .modern: return "interior_style_06"
        case .minimalist: return "interior_style_07"
        case .japandi: return "interior_style_08"
        case .vintageEclectic: return "interior_style_09"
        case .tropical: return "interior_style_10"
        case .rustic: return "interior_style_11"
        case .quietLuxury: return "interior_style_12"
        case .maximalist: return "interior_style_13"
        case .luxurious: return "interior_style_14"
        case .industrial: return "interior_style_15"
        case .midcenturyModern: return "interior_style_16"
        case .contemporary: return "interior_style_17"
        case .coastal: return "interior_style_18"
        case .biophilic: return "interior_style_19"
        case .scandiBoho: return "interior_style_20"
        case .retro: return "interior_style_21"
        case .neon: return "interior_style_22"
        case .modernArabic: return "interior_style_23"
        case .mediterranean: return "interior_style_24"
        case .kidsRoom: return "interior_style_25"
        case .desertModernism: return "interior_style_26"
        case .christmas: return "interior_style_27"
        case .candyLand: return "interior_style_28"
        case .brutalist: return "interior_style_29"
        case .artDeco: return "interior_style_30"
        default: return nil
        }
    }

    @ViewBuilder
    private func interventionStep() -> some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Intervention.title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                    .foregroundColor(.DesignSystem.textPrimary)

                Text(L10n.Intervention.subtitle)
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
                        interventionOption(level: .high, title: L10n.Intervention.High.title, description: L10n.Intervention.High.description, iconName: "ic_interior_Intervention_high")
                        interventionOption(level: .medium, title: L10n.Intervention.Medium.title, description: L10n.Intervention.Medium.description, iconName: "ic_interior_Intervention_meidum")
                        interventionOption(level: .light, title: L10n.Intervention.Light.title, description: L10n.Intervention.Light.description, iconName: "ic_interior_Intervention_light")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 0)
            }


            InteriorCTAButton(
                title: L10n.Flow.generate,
                isEnabled: viewModel.canContinue,
                action: { onGenerate(viewModel.draft) }
            )
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

struct InteriorCTAButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                .foregroundColor(isEnabled ? Color.DesignSystem.background : .white)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(isEnabled ? Color.DesignSystem.textPrimary : Color.gray.opacity(0.3))
                .cornerRadius(16)
        }
        .disabled(!isEnabled)
    }
}
