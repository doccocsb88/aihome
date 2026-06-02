import SwiftUI

struct GenerationLoadingView: View {
    let viewModel: GenerationLoadingViewModel
    var onCancel: (() -> Void)?
    
    @State private var progress: CGFloat = 0.1
    @State private var bracketScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Image with blur and scanner
            ZStack {
                if let inputImage = viewModel.inputImage {
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(uiImage: inputImage)
                                .resizable()
                                .scaledToFill()
                                .blur(radius: 20)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.systemGray5))
                        .aspectRatio(1, contentMode: .fit)
                }
                
                // Scanner brackets (mock animation)
                Image(systemName: "viewfinder")
                    .font(.system(size: 60, weight: .thin))
                    .foregroundColor(.primary)
                    .scaleEffect(bracketScale)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: bracketScale)
            }
            .padding(.horizontal, 32)
            .onAppear {
                bracketScale = 1.2
            }
            
            // Mock Progress Bar
            HStack(spacing: 16) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary)
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.linear(duration: 15), value: progress)
                    }
                }
                .frame(height: 6)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(width: 40, alignment: .trailing)
            }
            .padding(.horizontal, 32)
            
            Text(viewModel.progressText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            progress = 0.9 // Animate to 90% over 15 seconds
        }
    }
}
