import Foundation
import SwiftUI

struct GenerationLoadingView: View {
    let viewModel: GenerationLoadingViewModel
    var onRetry: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    
    @State private var progress: CGFloat = 0
    @State private var bracketScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 47
            let imageSide = min(geometry.size.width - horizontalPadding * 2, 321)
            let topPadding = max(88, geometry.size.height * 0.145)

            VStack(spacing: 0) {
                loadingImage(size: imageSide)
                    .padding(.top, topPadding)

                progressSection
                    .frame(width: imageSide)
                    .padding(.top, 48)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            bracketScale = 1.14
        }
        .task {
            await runFakeProgress()
        }
        .overlay {
            if viewModel.status == .failed {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image("ic_generate_failed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.top, 16)
                    
                    Text(L10n.GenerationLoading.Failure.title)
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 20))
                    
                    Text(viewModel.errorMessage ?? L10n.GenerationLoading.Failure.message)
                        .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 16) {
                        if viewModel.canRetry {
                            Button(action: {
                                if let onRetry = onRetry {
                                    onRetry()
                                } else {
                                    onCancel?()
                                }
                            }) {
                                Text(L10n.GenerationLoading.Failure.tryAgain)
                                    .font(FontFamily.Roboto.medium.swiftUIFont(size: 14))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.black)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            onCancel?()
                        }) {
                            Text(L10n.GenerationLoading.Failure.backToDesign)
                                .font(FontFamily.Roboto.medium.swiftUIFont(size: 12))
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

    private func loadingImage(size: CGFloat) -> some View {
        ZStack {
            if let inputImage = viewModel.inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .blur(radius: 18)
                    .clipped()
            } else {
                Color(UIColor.systemGray5)
                    .frame(width: size, height: size)
            }

            ScannerBrackets()
                .scaleEffect(bracketScale)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: bracketScale)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(alignment: .center, spacing: 0) {
                progressBar

                Spacer(minLength: 16)

                Text("\(Int((progress * 100).rounded()))%")
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 14))
                    .foregroundColor(Color.DesignSystem.silverSand)
                    .monospacedDigit()
            }

            Text(viewModel.progressText)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                .foregroundColor(Color.DesignSystem.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(UIColor.systemGray5))

                Capsule()
                    .fill(Color.DesignSystem.textPrimary)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(width: 216, height: 6)
    }

    private func runFakeProgress() async {
        let cap: CGFloat = 0.94
        let tickNanoseconds: UInt64 = 80_000_000
        var elapsed: TimeInterval = 0

        while !Task.isCancelled && viewModel.status == .generating {
            let easedProgress = cap * (1 - CGFloat(exp(-elapsed / 7.0)))
            await MainActor.run {
                progress = min(max(easedProgress, progress), cap)
            }

            try? await Task.sleep(nanoseconds: tickNanoseconds)
            elapsed += 0.08
        }
    }
}

struct ScannerBrackets: View {
    var body: some View {
        Path { path in
            let length: CGFloat = 16
            let w: CGFloat = 48
            let h: CGFloat = 48
            
            // Top Left
            path.move(to: CGPoint(x: 0, y: length))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: length, y: 0))
            
            // Top Right
            path.move(to: CGPoint(x: w - length, y: 0))
            path.addLine(to: CGPoint(x: w, y: 0))
            path.addLine(to: CGPoint(x: w, y: length))
            
            // Bottom Right
            path.move(to: CGPoint(x: w, y: h - length))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: w - length, y: h))
            
            // Bottom Left
            path.move(to: CGPoint(x: length, y: h))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: 0, y: h - length))
        }
        .stroke(Color.primary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
        .frame(width: 48, height: 48)
    }
}
