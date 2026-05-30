import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    
    var body: some View {
        Group {
            Group {
                if viewModel.projects.isEmpty {
                    emptyState
                } else {
                    projectList
                }
            }
            .navigationTitle("History")
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Start your first project")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a new space and watch your ideas come to life.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                // Route to Create New Project
            }) {
                Text("Create New Project")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
        }
    }
    
    private var projectList: some View {
        List {
            ForEach(viewModel.projects) { project in
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.title)
                            .font(.headline)
                        
                        if let style = project.styleName {
                            Text(style)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: viewModel.deleteProject)
        }
        .listStyle(.plain)
    }
}

#Preview {
    HistoryView()
}
