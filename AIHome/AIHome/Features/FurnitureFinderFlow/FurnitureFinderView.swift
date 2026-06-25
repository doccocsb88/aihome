import SwiftUI

struct FurnitureFinderView: View {
    @State private var viewModel = FurnitureFinderViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var didApplyInitialImage = false

    var initialImage: UIImage?

    var body: some View {
        Group {
            VStack {
                if let image = viewModel.draft.sourceImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding()
                } else {
                    Button(action: {
                        // Mocking image selection for now
                        viewModel.selectImage(UIImage(systemName: "photo")!)
                    }) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay {
                                VStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.largeTitle)
                                    Text("Tap to select image")
                                        .font(FontFamily.Roboto.medium.swiftUIFont(size: 17))
                                }
                                .foregroundColor(.secondary)
                            }
                            .padding()
                    }
                }

                TextField("Optional: Describe the furniture", text: Binding(
                    get: { viewModel.draft.prompt ?? "" },
                    set: { viewModel.draft.prompt = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

                Button(action: {
                    viewModel.findFurniture()
                }) {
                    Text("Find Furniture")
                        .font(FontFamily.Roboto.medium.swiftUIFont(size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.draft.sourceImage == nil ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(viewModel.draft.sourceImage == nil || viewModel.isGenerating)
                .padding()

                if viewModel.isGenerating {
                    ProgressView {
                        Text("Searching...")
                            .font(FontFamily.Roboto.regular.swiftUIFont(size: 17))
                    }
                        .padding()
                } else {
                    List(viewModel.products) { product in
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Image(systemName: "chair.lounge.fill")
                                        .foregroundColor(.secondary)
                                }

                            VStack(alignment: .leading) {
                                Text(product.title)
                                    .font(FontFamily.Roboto.medium.swiftUIFont(size: 17))
                                Text(product.sourceName ?? "Unknown source")
                                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if let price = product.priceText {
                                Text(price)
                                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Furniture Finder")
        }
        .onAppear {
            applyInitialImageIfNeeded()
        }
    }

    private func applyInitialImageIfNeeded() {
        guard !didApplyInitialImage,
              let initialImage,
              viewModel.draft.sourceImage == nil else {
            return
        }

        didApplyInitialImage = true
        viewModel.selectImage(initialImage)
    }
}

#Preview {
    FurnitureFinderView()
}
