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
}
