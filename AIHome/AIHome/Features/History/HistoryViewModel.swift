import Foundation
import Observation

@Observable
final class HistoryViewModel {
    var projects: [LocalProject] = []
    private let storage: LocalProjectStorageProtocol
    
    init(storage: LocalProjectStorageProtocol = LocalProjectFileStorage.shared) {
        self.storage = storage
        fetchProjects()
    }
    
    func fetchProjects() {
        projects = storage.getProjects()
    }
    
    func deleteProject(at offsets: IndexSet) {
        for index in offsets {
            let project = projects[index]
            storage.deleteProject(id: project.id)
        }
        fetchProjects()
    }

    func deleteProjects(ids: Set<String>) {
        ids.forEach { id in
            storage.deleteProject(id: id)
        }
        fetchProjects()
    }
    
    var filter = InspirationFilterViewModel()
    
    var filteredProjects: [LocalProject] {
        projects.filter { project in
            if filter.showLikedOnly && !project.isFavorite { return false }

            guard let selectedFeature = filter.selectedFeature else { return true }
            return project.type == selectedFeature
        }
    }
}
