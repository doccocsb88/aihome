import SwiftUI

struct FurnitureFinderView: View {
    @State private var viewModel = FurnitureFinderViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
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
                                        .font(.headline)
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
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.draft.sourceImage == nil ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(viewModel.draft.sourceImage == nil || viewModel.isGenerating)
                .padding()
                
                if viewModel.isGenerating {
                    ProgressView("Searching...")
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
                                    .font(.headline)
                                Text(product.sourceName ?? "Unknown source")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let price = product.priceText {
                                Text(price)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Furniture Finder")
        }
    }
}

#Preview {
    FurnitureFinderView()
}
