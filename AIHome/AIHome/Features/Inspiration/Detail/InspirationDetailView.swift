import SwiftUI

struct InspirationDetailView: View {
    @State var viewModel: InspirationDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                    }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.item.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(viewModel.item.subtitle)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Text("Advanced Tools")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        toolChip(title: "Reference")
                        toolChip(title: "Replace")
                        toolChip(title: "Remove")
                        toolChip(title: "New Wall")
                        toolChip(title: "New Flooring")
                        toolChip(title: "Furniture Finder")
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    // Start REDESIGN flow
                }) {
                    Text("REDESIGN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toolChip(title: String) -> some View {
        Button(action: {
            // Handle tool action
        }) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .foregroundColor(.primary)
        }
    }
}
