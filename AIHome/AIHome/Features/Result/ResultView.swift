import SwiftUI

struct ResultView: View {
    @Bindable var viewModel: ResultViewModel
    
    var onRegenerate: () -> Void
    var onDownload: (UIImage) -> Void
    var onShare: (UIImage) -> Void
    var onSaveArchive: () -> Void
    var onRemoveWatermark: () -> Void
    var onToolSelected: (AdvancedTool, UIImage) -> Void
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if viewModel.isPro {
                    Text("PRO")
                        .font(FontFamily.Roboto.black.swiftUIFont(size: 11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.pink)
                        .clipShape(Capsule())
                        .shadow(color: Color.pink.opacity(0.5), radius: 5, x: 0, y: 3)
                } else {
                    Spacer().frame(width: 40)
                }
                
                Spacer()
                Text("Result")
                    .font(FontFamily.Roboto.medium.swiftUIFont(size: 17))
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Image Section
                    if let selectedImage = viewModel.selectedImage {
                        ZStack {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(24)
                            
                            // Top left overlay
                            VStack {
                                HStack {
                                    Button(action: {}) {
                                        Image(systemName: "square.split.2x1")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(Color.black.opacity(0.4))
                                            .clipShape(Circle())
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            .padding(16)
                            
                            // Bottom overlays
                            VStack {
                                Spacer()
                                HStack(alignment: .bottom) {
                                    HStack(spacing: 8) {
                                        Button(action: {}) {
                                            Image(systemName: "hand.thumbsup.fill")
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(Color.black.opacity(0.4))
                                                .clipShape(Circle())
                                        }
                                        Button(action: {}) {
                                            Image(systemName: "hand.thumbsdown.fill")
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(Color.black.opacity(0.4))
                                                .clipShape(Circle())
                                        }
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text("HomeGPT")
                                            .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                                            .foregroundColor(.white.opacity(0.9))
                                            
                                        if viewModel.hasWatermark {
                                            Button(action: onRemoveWatermark) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "bolt.fill")
                                                        .font(.system(size: 10))
                                                    Text("REMOVE WATERMARK")
                                                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 10))
                                                }
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.white.opacity(0.3))
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
                    }
                    
                    // Advanced Tools
                    if !viewModel.availableAdvancedTools.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Advanced Tools")
                                .font(FontFamily.Roboto.bold.swiftUIFont(size: 22))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.availableAdvancedTools) { tool in
                                        Button(action: {
                                            if let image = viewModel.selectedImage {
                                                onToolSelected(tool, image)
                                            }
                                        }) {
                                            HStack {
                                                Image("ic_result_\(tool.rawValue.lowercased())")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.primary)
                                                Text(tool.rawValue)
                                                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 15))
                                                    .foregroundColor(.primary)
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(RoundedRectangle(cornerRadius: 16).stroke(Color(UIColor.systemGray4), lineWidth: 1))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Action Buttons (Regenerate, Download, Share)
                    HStack(spacing: 0) {
                        actionCircleButton(title: "REGENERATE", icon: "ic_result_regenerate", action: onRegenerate)
                        Spacer()
                        actionCircleButton(title: "DOWNLOAD", icon: "ic_result_download", action: {
                            if let img = viewModel.selectedImage { onDownload(img) }
                        })
                        Spacer()
                        actionCircleButton(title: "SHARE", icon: "ic_result_share", action: {
                            if let img = viewModel.selectedImage { onShare(img) }
                        })
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    
                    // Save to Archive Button
                    Button(action: onSaveArchive) {
                        Text("SAVE TO ARCHIVE")
                            .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
    
    @ViewBuilder
    private func actionCircleButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Button(action: action) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.primary)
                    .padding(24)
                    .background(Circle().fill(Color(UIColor.systemGray6)))
            }
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 10))
                .kerning(0.5)
                .foregroundColor(Color(UIColor.systemGray2))
        }
    }
}
