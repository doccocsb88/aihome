import SwiftUI

struct InspirationView: View {
    @State private var viewModel = InspirationViewModel()
    @State private var showingFilter = false
    
    var body: some View {
        Group {
            VStack {
                categoryPicker
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredItems) { item in
                            NavigationLink {
                                InspirationDetailView(viewModel: InspirationDetailViewModel(item: item))
                            } label: {
                                inspirationCard(for: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Inspiration")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilter = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                InspirationFilterView()
            }
        }
    }
    
    private var categoryPicker: some View {
        Picker("Category", selection: $viewModel.selectedCategory) {
            Text("Interior").tag(InspirationCategory.interior)
            Text("Exterior").tag(InspirationCategory.exterior)
            Text("Garden").tag(InspirationCategory.garden)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private func inspirationCard(for item: InspirationItem) -> some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .overlay {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
                .overlay(alignment: .topTrailing) {
                    Button(action: {
                        viewModel.toggleLike(for: item)
                    }) {
                        Image(systemName: item.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(item.isLiked ? .red : .white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.4)).padding(8))
                    }
                }
            
            Text(item.title)
                .font(.headline)
                .padding(.top, 8)
            
            Text(item.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    InspirationView()
}
