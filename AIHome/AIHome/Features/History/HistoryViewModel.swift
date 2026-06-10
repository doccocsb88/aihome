import Foundation
import Observation

@Observable
final class HistoryViewModel {
    var projects: [LocalProject] = []
    private let storage: LocalProjectStorageProtocol
    
    init(storage: LocalProjectStorageProtocol = MockLocalProjectStorage()) {
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
    
    var filter = InspirationFilterViewModel()
    
    var filteredProjects: [LocalProject] {
        projects.filter { project in
            if filter.showLikedOnly && !project.isFavorite { return false }
            
            let isInteriorFiltering = filter.selectedInteriorSpace != "All"
            let isExteriorFiltering = filter.selectedExteriorSpace != "All"
            let isGardenFiltering = filter.selectedGardenSpace != "All"
            
            if !isInteriorFiltering && !isExteriorFiltering && !isGardenFiltering {
                return true
            }
            
            switch project.type {
            case .interior:
                return isInteriorFiltering && project.roomType?.lowercased() == filter.selectedInteriorSpace.lowercased()
            case .exterior:
                return isExteriorFiltering && project.roomType?.lowercased() == filter.selectedExteriorSpace.lowercased()
            case .garden:
                return isGardenFiltering && project.roomType?.lowercased() == filter.selectedGardenSpace.lowercased()
            default:
                return false
            }
        }
    }
}
