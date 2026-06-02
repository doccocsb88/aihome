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
        .overlay {
            if viewModel.status == .failed {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1, green: 0.92, blue: 0.92))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                        
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                            .background(Circle().fill(.white))
                            .offset(x: 24, y: -24)
                    }
                    .padding(.top, 16)
                    
                    Text("Generation Failed")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text(viewModel.errorMessage ?? "We couldn't process your redesign request this time. Please check your photo or instructions and try again.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            onCancel?()
                        }) {
                            Text("TRY AGAIN")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            onCancel?()
                        }) {
                            Text("BACK TO DESIGN")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(Color.white)
                .cornerRadius(24)
                .padding(.horizontal, 40)
            }
        }
    }
}
