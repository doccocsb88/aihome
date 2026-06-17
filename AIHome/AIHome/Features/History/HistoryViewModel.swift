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
            
            let isInteriorFiltering = filter.selectedInteriorSpace != "All"
            let isExteriorFiltering = filter.selectedExteriorSpace != "All"
            let isGardenFiltering = filter.selectedGardenSpace != "All"
            let isOtherFiltering = filter.selectedOtherSpace != "All"
            
            if !isInteriorFiltering && !isExteriorFiltering && !isGardenFiltering && !isOtherFiltering {
                return true
            }
            
            switch project.type {
            case .interior:
                return isInteriorFiltering && project.roomType?.lowercased() == filter.selectedInteriorSpace.lowercased()
            case .exterior:
                return isExteriorFiltering && project.roomType?.lowercased() == filter.selectedExteriorSpace.lowercased()
            case .garden:
                return isGardenFiltering && project.roomType?.lowercased() == filter.selectedGardenSpace.lowercased()
            case .referenceStyle, .replaceObjects, .removeObjects, .newFlooring, .newWalls, .furnitureFinder, .edit:
                return isOtherFiltering && project.type.historyFilterTitle == filter.selectedOtherSpace
            }
        }
    }
}

private extension ProjectType {
    var historyFilterTitle: String {
        switch self {
        case .referenceStyle:
            "Reference Style"
        case .replaceObjects:
            "Replace Objects"
        case .removeObjects:
            "Remove Objects"
        case .newFlooring:
            "New Flooring"
        case .newWalls:
            "New Walls"
        case .furnitureFinder:
            "Furniture Finder"
        case .edit:
            "Edit"
        case .interior:
            "Interior"
        case .exterior:
            "Exterior"
        case .garden:
            "Garden"
        }
    }
}
