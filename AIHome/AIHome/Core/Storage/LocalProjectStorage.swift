import Foundation

protocol LocalProjectStorageProtocol {
    func getProjects() -> [LocalProject]
    func saveProject(_ project: LocalProject)
    func deleteProject(id: String)
}

final class MockLocalProjectStorage: LocalProjectStorageProtocol {
    private var projects: [LocalProject] = [
        LocalProject(
            id: "1",
            type: .interior,
            title: "Living Room",
            styleName: "Minimalist",
            roomType: "Living Room",
            createdAt: Date(),
            originalImagePath: "dummy_orig_1",
            generatedImagePaths: ["dummy_gen_1"],
            selectedGeneratedImagePath: nil,
            isFavorite: false
        ),
        LocalProject(
            id: "2",
            type: .exterior,
            title: "Villa Facade",
            styleName: "Modern",
            roomType: nil,
            createdAt: Date(),
            originalImagePath: "dummy_orig_2",
            generatedImagePaths: ["dummy_gen_2"],
            selectedGeneratedImagePath: nil,
            isFavorite: true
        ),
        LocalProject(
            id: "3",
            type: .interior,
            title: "Kitchen",
            styleName: "Marble",
            roomType: "Kitchen",
            createdAt: Date(),
            originalImagePath: "dummy_orig_3",
            generatedImagePaths: ["dummy_gen_3"],
            selectedGeneratedImagePath: nil,
            isFavorite: false
        )
    ]
    
    func getProjects() -> [LocalProject] {
        return projects
    }
    
    func saveProject(_ project: LocalProject) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.append(project)
        }
    }
    
    func deleteProject(id: String) {
        projects.removeAll { $0.id == id }
    }
}
