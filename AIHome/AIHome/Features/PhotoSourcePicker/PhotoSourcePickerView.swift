import SwiftUI
import PhotosUI

struct PhotoSourcePickerView: View {
    @Bindable var viewModel: PhotoSourcePickerViewModel
    var hideCTA: Bool = false
    var onContinue: ((UIImage) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Text(viewModel.title)
                .font(.title)
                .fontWeight(.bold)
            
            if let subtitle = viewModel.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
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
                VStack(spacing: 16) {
                    PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Gallery")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // In a real app we would use a camera view here
                        viewModel.showCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Camera")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 32)
            }
            
            if viewModel.allowsSample && viewModel.selectedImage == nil && !viewModel.sampleImages.isEmpty {
                VStack(alignment: .leading) {
                    Text("Try a sample")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.sampleImages, id: \.self) { sample in
                                Button(action: {
                                    viewModel.selectSample(sample)
                                }) {
                                    Image(sample)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            if !hideCTA {
                Spacer()
                
                Button(action: {
                    if let image = viewModel.selectedImage {
                        onContinue?(image)
                    }
                }) {
                    Text(viewModel.ctaTitle)
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
        .padding(.vertical)
        .sheet(isPresented: $viewModel.showCamera) {
            // Placeholder for camera view
            Text("Camera View Placeholder")
        }
    }
}
