import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if viewModel.projects.isEmpty {
                emptyState
            } else {
                projectList
            }
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Text("History")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.DesignSystem.textPrimary)
            
            Spacer()
            
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(red: 255/255, green: 45/255, blue: 85/255))
                    Text("3/3")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.DesignSystem.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                
                Text("PRO")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 255/255, green: 45/255, blue: 85/255))
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("ic_history_start_project")
                .resizable()
                .scaledToFit()
                .frame(height: 260)
            
            VStack(spacing: 8) {
                Text("Start your first project")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.DesignSystem.textPrimary)
                
                Text("Create a new space and watch your\nideas come to life.")
                    .font(.body)
                    .foregroundColor(Color(UIColor.systemGray))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                // Route to Create New Project
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 18))
                    Text("Create New Project")
                        .font(.headline)
                }
                .foregroundColor(.DesignSystem.background)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.DesignSystem.textPrimary)
                .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            Spacer()
            Spacer()
        }
    }
    
    private var projectList: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(viewModel.projects) { project in
                        projectCard(for: project)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            
            Button(action: {
                // Filter action
            }) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(red: 255/255, green: 45/255, blue: 85/255))
                    .clipShape(Circle())
                    .shadow(color: Color(red: 255/255, green: 45/255, blue: 85/255).opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
    }
    
    private func projectCard(for project: LocalProject) -> some View {
        ZStack {
            Group {
                if let path = project.selectedGeneratedImagePath, let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if let uiImage = UIImage(contentsOfFile: project.originalImagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(project.title.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.DesignSystem.textPrimary)
                            .lineLimit(1)
                        
                        if let style = project.styleName {
                            Text(style)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Toggle favorite
                    }) {
                        Image(systemName: project.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 12))
                            .foregroundColor(project.isFavorite ? Color(red: 255/255, green: 45/255, blue: 85/255) : .secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(8)
            }
        }
        .aspectRatio(0.85, contentMode: .fit)
        .cornerRadius(24)
        .clipped()
    }
}

#Preview {
    HistoryView()
}
