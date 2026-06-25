import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    @State private var isShowingFilter = false
    @State private var isEditing = false
    @State private var selectedProjectIDs: Set<String> = []
    @State private var isShowingDeleteConfirm = false
    @State private var resultPresentation: HistoryResultPresentation?
    @Environment(AppCoordinator.self) private var coordinator

    private let onFilterPresentationChanged: (Bool) -> Void

    init(onFilterPresentationChanged: @escaping (Bool) -> Void = { _ in }) {
        self.onFilterPresentationChanged = onFilterPresentationChanged
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                headerView

                if viewModel.projects.isEmpty {
                    emptyState
                } else {
                    projectList
                }
            }

            if isShowingFilter {
                InspirationFilterOverlay(
                    viewModel: viewModel.filter,
                    contentStyle: .historyFeatures,
                    isPresented: $isShowingFilter
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
                .onAppear {
                    onFilterPresentationChanged(true)
                }
                .onDisappear {
                    onFilterPresentationChanged(false)
                }
            }
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .fullScreenCover(item: $resultPresentation) { presentation in
            ResultView(
                viewModel: presentation.viewModel,
                onRegenerate: {
                    openFlow(for: presentation.project.type)
                },
                onDownload: { _ in },
                onShare: { _ in },
                onSaveArchive: { },
                onRemoveWatermark: { },
                onToolSelected: { _, _ in
                    resultPresentation = nil
                },
                onClose: {
                    resultPresentation = nil
                }
            )
        }
        .alert(L10n.History.DeleteConfirmation.title, isPresented: $isShowingDeleteConfirm) {
            Button(L10n.Common.cancel, role: .cancel) {}
            Button(L10n.Common.delete, role: .destructive) {
                viewModel.deleteProjects(ids: selectedProjectIDs)
                exitEditMode()
            }
        } message: {
            Text(L10n.History.DeleteConfirmation.message)
        }
        .onDisappear {
            onFilterPresentationChanged(false)
        }
    }
    
    private var headerView: some View {
        MainTabHeaderView(title: L10n.History.title)
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
                Text(L10n.History.Empty.title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 22))
                    .foregroundColor(.DesignSystem.textPrimary)
                
                Text(L10n.History.Empty.message)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 17))
                    .foregroundColor(.DesignSystem.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                startNewProject()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 18))
                    Text(L10n.History.Empty.createProject)
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
        ZStack(alignment: .bottom) {
            if viewModel.filteredProjects.isEmpty {
                filterEmptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(viewModel.filteredProjects) { project in
                            projectCard(for: project)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            
            if !isEditing {
                HStack {
                    Spacer()

                    FloatingFilterButton {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                            isShowingFilter = true
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 80)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isEditing {
                editBottomBar
            }
        }
    }

    private var filterEmptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("ic_history_start_project")
                .resizable()
                .scaledToFit()
                .frame(height: 220)

            VStack(spacing: 8) {
                Text(L10n.History.FilterEmpty.title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 22))
                    .foregroundStyle(Color.DesignSystem.textPrimary)

                Text(L10n.History.FilterEmpty.message)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 17))
                    .foregroundStyle(Color.DesignSystem.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(L10n.History.FilterEmpty.resetFilters) {
                viewModel.filter.reset()
            }
            .font(FontFamily.Roboto.medium.swiftUIFont(size: 17))
            .foregroundStyle(Color.DesignSystem.background)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.DesignSystem.textPrimary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 32)
            .padding(.top, 8)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }
    
    private func projectCard(for project: LocalProject) -> some View {
        let isSelected = selectedProjectIDs.contains(project.id)

        return ZStack {
            projectThumbnail(for: project)
            
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

            if isEditing {
                VStack {
                    HStack {
                        Spacer()

                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(isSelected ? .DesignSystem.folly : .white)
                            .background(Circle().fill(Color.black.opacity(0.35)))
                            .padding(10)
                    }

                    Spacer()
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(24)
        .clipped()
        .overlay {
            if isEditing && isSelected {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.DesignSystem.folly, lineWidth: 2)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture {
            if isEditing {
                toggleSelection(for: project.id)
            } else {
                openResult(for: project)
            }
        }
        .onLongPressGesture {
            isEditing = true
            selectedProjectIDs = [project.id]
        }
    }

    @ViewBuilder
    private func projectThumbnail(for project: LocalProject) -> some View {
        if let image = LocalProjectFileStorage.shared.image(for: project.selectedGeneratedImagePath ?? project.generatedImagePaths.first) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        } else {
            Image("history_thumb_default")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }

    private var editBottomBar: some View {
        HStack(spacing: 12) {
            Button(action: exitEditMode) {
                Text(L10n.Common.cancel)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                    .foregroundColor(.DesignSystem.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.DesignSystem.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.DesignSystem.platinum, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Button(action: {
                isShowingDeleteConfirm = true
            }) {
                Text(L10n.History.deleteSelected(selectedProjectIDs.count))
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(selectedProjectIDs.isEmpty ? Color.gray.opacity(0.35) : Color.DesignSystem.folly)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(selectedProjectIDs.isEmpty)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 80)
        .background(.ultraThinMaterial)
    }

    private func toggleSelection(for projectID: String) {
        if selectedProjectIDs.contains(projectID) {
            selectedProjectIDs.remove(projectID)
        } else {
            selectedProjectIDs.insert(projectID)
        }
    }

    private func exitEditMode() {
        isEditing = false
        selectedProjectIDs.removeAll()
    }

    private func startNewProject() {
        coordinator.popToRoot()
        coordinator.openFlow(.interior)
    }

    private func openResult(for project: LocalProject) {
        guard let presentation = HistoryResultPresentation(project: project) else {
            AppLogger.logError("Missing history project images for project \(project.id)")
            return
        }

        resultPresentation = presentation
    }

    private func openFlow(for projectType: ProjectType) {
        resultPresentation = nil
        coordinator.openFlow(projectType, popToRootFirst: true)
    }
}

private struct HistoryResultPresentation: Identifiable {
    let id: String
    let project: LocalProject
    let viewModel: ResultViewModel

    init?(project: LocalProject) {
        let storage = LocalProjectFileStorage.shared
        guard let originalImage = storage.image(for: project.originalImagePath) else {
            return nil
        }

        let generatedImages = storage.images(for: project.generatedImagePaths)
        guard !generatedImages.isEmpty else {
            return nil
        }

        let resultViewModel = ResultViewModel(
            project: project,
            originalImage: originalImage,
            generatedImages: generatedImages,
            availableAdvancedTools: ProjectType.resultAdvancedTools,
            isPro: true,
            hasWatermark: false
        )

        if let selectedPath = project.selectedGeneratedImagePath,
           let selectedIndex = project.generatedImagePaths.firstIndex(of: selectedPath),
           selectedIndex < generatedImages.count {
            resultViewModel.selectedIndex = selectedIndex
        }

        self.id = project.id
        self.project = project
        self.viewModel = resultViewModel
    }
}

#Preview {
    HistoryView()
}
