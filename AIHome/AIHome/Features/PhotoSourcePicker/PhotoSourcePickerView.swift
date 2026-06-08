import SwiftUI
import PhotosUI

struct PhotoSourcePickerView: View {
    @Bindable var viewModel: PhotoSourcePickerViewModel
    var hideCTA: Bool = false
    var onContinue: ((UIImage) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                if !viewModel.title.isEmpty {
                    Text(viewModel.title)
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                        .foregroundColor(.DesignSystem.textPrimary)
                }
                
                if let subtitle = viewModel.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .cornerRadius(12)
                    .overlay(
                        Button(action: { viewModel.selectedImage = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title)
                        }
                        .padding(8),
                        alignment: .topTrailing
                    )
            } else {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image("ic_picker_image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 51)
                        
                        Text("Choose your photo.\nFor better results, use a horizontal\ndirection.")
                            .font(FontFamily.Inter24pt.regular.swiftUIFont(size: 14))
                            .foregroundColor(Color.DesignSystem.coolGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                            HStack {
                                Image("ic_picker_gallery")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text("Gallery")
                                    .font(FontFamily.Inter24pt.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.white)

                            }
                            .foregroundColor(.DesignSystem.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.DesignSystem.textPrimary)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            viewModel.showCamera = true
                        }) {
                            HStack {
                                Image("ic_picker_camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text("Camera")
                                    .font(FontFamily.Inter24pt.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.DesignSystem.slateGray)
                            }
                            .foregroundColor(.DesignSystem.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.DesignSystem.background)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.DesignSystem.platinum, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(24)
                .background(Color.DesignSystem.background)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        .foregroundColor(Color.gray.opacity(0.3))
                )
                .padding(.horizontal, 24)
            }
            
            if viewModel.allowsSample && viewModel.selectedImage == nil && !viewModel.sampleImages.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.sampleTitle)
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 11))
                        .foregroundColor(.gray)
                        .kerning(1.2)
                        .padding(.horizontal, 24)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.sampleImages, id: \.self) { sample in
                                Button(action: {
                                    viewModel.selectSample(sample)
                                }) {
                                    Image(sample)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 72, height: 72)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 8)
            }
            
            Spacer()
            
            if !hideCTA {
                InteriorCTAButton(
                    title: viewModel.ctaTitle,
                    isEnabled: viewModel.canContinue,
                    action: {
                        if let image = viewModel.selectedImage {
                            onContinue?(image)
                        }
                    }
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
            }
        }
        .sheet(isPresented: $viewModel.showCamera) {
            Text("Camera View Placeholder")
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 17))
        }
    }
}
