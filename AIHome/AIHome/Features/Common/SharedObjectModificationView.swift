import SwiftUI

struct SharedObjectModificationView: View {
    let title: String
    let promptPlaceholder: String
    
    @Binding var prompt: String
    @Bindable var photoPickerViewModel: PhotoSourcePickerViewModel
    let canGenerate: Bool
    
    @State private var showingPhotoTips = false
    
    let onBack: () -> Void
    let onGenerate: () -> Void
    
    let sampleImages = [
        "ic_interior_sample_01",
        "ic_interior_sample_02",
        "ic_interior_sample_03",
        "ic_interior_sample_04"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    onBack()
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
                
                Text(title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                    .foregroundColor(.DesignSystem.textPrimary)
                
                Spacer()
                
                Button(action: {
                    showingPhotoTips = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    PhotoSourcePickerView(
                        viewModel: photoPickerViewModel,
                        hideCTA: true
                    )
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(promptPlaceholder, text: $prompt, axis: .vertical)
                            .font(FontFamily.Roboto.regular.swiftUIFont(size: 14))
                            .foregroundColor(.primary)
                            .lineLimit(4...6)
                            .padding(20)
                            .background(Color.DesignSystem.background)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    // Try a sample
                    if photoPickerViewModel.selectedImage == nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Try a sample")
                                .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                                .foregroundColor(.DesignSystem.textPrimary)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(sampleImages, id: \.self) { sample in
                                        Button(action: {
                                            photoPickerViewModel.selectSample(sample)
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
                    }
                }
                .padding(.bottom, 24)
            }
            
            // CTA
            Button(action: {
                onGenerate()
            }) {
                Text("GENERATE")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                    .kerning(1.2)
                    .foregroundColor(canGenerate ? Color.DesignSystem.background : .white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(canGenerate ? Color.DesignSystem.textPrimary : Color.gray.opacity(0.3))
                    .cornerRadius(16)
            }
            .disabled(!canGenerate)
            .padding(.horizontal, 32)
            .padding(.bottom, 36)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.container, edges: .bottom)
        .sheet(isPresented: $showingPhotoTips) {
            PhotoTipsView()
        }
    }
}
