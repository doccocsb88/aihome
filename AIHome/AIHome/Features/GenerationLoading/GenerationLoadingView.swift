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
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .clipped()
                        .cornerRadius(24)
                        .blur(radius: 20)
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: 300, height: 300)
                }
                
                // Scanner brackets (mock animation)
                Image(systemName: "viewfinder")
                    .font(.system(size: 60, weight: .thin))
                    .foregroundColor(.primary)
                    .scaleEffect(bracketScale)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: bracketScale)
            }
            .onAppear {
                bracketScale = 1.2
            }
            
            // Mock Progress Bar
            HStack(spacing: 16) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(Color.primary)
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.linear(duration: 15), value: progress)
                    }
                }
                .frame(width: 150, height: 6)
                
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
            }
            
            Text(viewModel.progressText)
                .font(.headline)
                .foregroundColor(.primary)
            
            if viewModel.canCancel {
                Button(action: {
                    onCancel?()
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            
            Spacer()
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            progress = 0.9 // Animate to 90% over 15 seconds
        }
    }
}
