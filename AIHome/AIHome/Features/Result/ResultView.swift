import SwiftUI

struct ResultView: View {
    @Bindable var viewModel: ResultViewModel
    
    var onRegenerate: () -> Void
    var onDownload: (UIImage) -> Void
    var onShare: (UIImage) -> Void
    var onSaveArchive: () -> Void
    var onRemoveWatermark: () -> Void
    var onToolSelected: (AdvancedTool, UIImage) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text(viewModel.isPro ? "Pro Result" : "Result")
                    .font(.headline)
                    .padding(.top)
                
                // Image Pager
                if let selectedImage = viewModel.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Thumbnail Picker
                if viewModel.generatedImages.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<viewModel.generatedImages.count, id: \.self) { index in
                                Image(uiImage: viewModel.generatedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(viewModel.selectedIndex == index ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        viewModel.selectedIndex = index
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                if viewModel.hasWatermark {
                    Button(action: onRemoveWatermark) {
                        Text("Remove Watermark")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
                
                // Advanced Tools
                if !viewModel.availableAdvancedTools.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Advanced Tools")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.availableAdvancedTools) { tool in
                                    Button(action: {
                                        if let image = viewModel.selectedImage {
                                            onToolSelected(tool, image)
                                        }
                                    }) {
                                        VStack {
                                            Image(systemName: tool.iconName)
                                                .font(.title2)
                                                .frame(height: 30)
                                            Text(tool.rawValue)
                                                .font(.caption)
                                        }
                                        .frame(width: 80, height: 80)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Bottom Actions
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Button(action: onRegenerate) {
                            actionButtonLabel(title: "Regenerate", icon: "arrow.clockwise")
                        }
                        Button(action: {
                            if let img = viewModel.selectedImage {
                                onDownload(img)
                            }
                        }) {
                            actionButtonLabel(title: "Download", icon: "arrow.down.to.line")
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            if let img = viewModel.selectedImage {
                                onShare(img)
                            }
                        }) {
                            actionButtonLabel(title: "Share", icon: "square.and.arrow.up")
                        }
                        Button(action: onSaveArchive) {
                            actionButtonLabel(title: "Save to Archive", icon: "archivebox")
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private func actionButtonLabel(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .foregroundColor(.primary)
    }
}
