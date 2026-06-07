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
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 36))
                .foregroundColor(.DesignSystem.textPrimary)
            
            Spacer()
            
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.DesignSystem.folly)
                    Text("3/3")
                        .font(FontFamily.Roboto.medium.swiftUIFont(size: 15))
                        .foregroundColor(.DesignSystem.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.DesignSystem.ghostWhite)
                .cornerRadius(20)
                
                Text("PRO")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.DesignSystem.folly)
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
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 22))
                    .foregroundColor(.DesignSystem.textPrimary)
                
                Text("Create a new space and watch your\nideas come to life.")
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 17))
                    .foregroundColor(.DesignSystem.gray)
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
                        .font(FontFamily.Roboto.medium.swiftUIFont(size: 17))
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
                    .background(Color.DesignSystem.folly)
                    .clipShape(Circle())
                    .shadow(color: Color.DesignSystem.folly.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
    }
    
    private func projectCard(for project: LocalProject) -> some View {
        ZStack {
            Image("history_thumb_default")
                .resizable()
                .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(project.title.uppercased())
                            .font(FontFamily.Roboto.bold.swiftUIFont(size: 9))
                            .foregroundColor(.DesignSystem.darkKnight)
                            .lineLimit(1)
                        
                        if let style = project.styleName {
                            Text(style)
                                .font(FontFamily.Roboto.regular.swiftUIFont(size: 8))
                                .foregroundColor(.DesignSystem.slateGray)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Toggle favorite
                    }) {
                        Image(systemName: project.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 12))
                            .foregroundColor(project.isFavorite ? Color.DesignSystem.folly : .secondary)
                    }
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.white.opacity(0.7))
                        }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(24)
        .clipped()
    }
}

#Preview {
    HistoryView()
}
