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
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.DesignSystem.textPrimary)
                }
                
                if let subtitle = viewModel.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
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
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .frame(width: 56, height: 56)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("Choose your photo.\nFor better results, use a horizontal\ndirection.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                            HStack {
                                Image(systemName: "photo")
                                Text("Gallery")
                                    .fontWeight(.semibold)
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
                                Image(systemName: "camera")
                                Text("Camera")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.DesignSystem.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.DesignSystem.background)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                        .font(.system(size: 11, weight: .bold))
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
            
            if !hideCTA {
                Spacer()
                
                Button(action: {
                    if let image = viewModel.selectedImage {
                        onContinue?(image)
                    }
                }) {
                    Text(viewModel.ctaTitle)
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
        .padding(.vertical)
        .sheet(isPresented: $viewModel.showCamera) {
            Text("Camera View Placeholder")
        }
    }
}
