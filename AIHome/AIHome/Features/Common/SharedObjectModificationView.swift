import SwiftUI

struct SharedObjectModificationView: View {
    let title: String
    let promptPlaceholder: String
    
    @Binding var prompt: String
    @Bindable var photoPickerViewModel: PhotoSourcePickerViewModel
    let canGenerate: Bool
    var photoTipsStyle: PhotoTipsStyle = .interior
    
    @State private var showingPhotoTips = false
    
    let onBack: () -> Void
    let onGenerate: () -> Void
    
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
                    
                    if photoPickerViewModel.allowsSample,
                       photoPickerViewModel.selectedImage == nil,
                       !photoPickerViewModel.sampleImages.isEmpty {
                        TrySampleView(
                            title: "Try a sample",
                            imageNames: photoPickerViewModel.sampleImages,
                            titleStyle: .section,
                            onSelect: { sample in
                                photoPickerViewModel.selectSample(sample)
                            }
                        )
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
            PhotoTipsView(style: photoTipsStyle)
        }
    }
}
