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
        Image(item.imageNameOrURL)
            .resizable()
            .scaledToFill()
            .frame(height: 480)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        Text(item.title.uppercased())
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.DesignSystem.textPrimary)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleLike(for: item)
                        }) {
                            Image(item.isLiked ? "ic_Inspiration_heart_02" : "ic_Inspiration_heart_01")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                        }
                    }
                    
                    Text(item.subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .lineLimit(3)
                        
                    HStack(spacing: 8) {
                        Text(item.styleTag.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(UIColor.darkGray))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray6).opacity(0.8))
                            .cornerRadius(16)
                        
                        Text(item.spaceType.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(UIColor.darkGray))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray6).opacity(0.8))
                            .cornerRadius(16)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(UIColor.systemBackground).opacity(0.85))
                        .background(.ultraThinMaterial)
                        .cornerRadius(32)
                )
                .padding(16)
            }
            .cornerRadius(40)
    }
}

#Preview {
    InspirationView()
}
