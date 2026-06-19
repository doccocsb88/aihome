import Foundation
import SwiftData
import UIKit

protocol LocalProjectStorageProtocol {
    func getProjects() -> [LocalProject]
    func saveProject(_ project: LocalProject)
    func deleteProject(id: String)
}

@Model
final class LocalProjectRecord {
    @Attribute(.unique) var id: String
    var typeRawValue: String
    var title: String
    var styleName: String?
    var roomType: String?
    var createdAt: Date
    var originalImagePath: String
    var generatedImagePathsValue: String
    var selectedGeneratedImagePath: String?
    var isFavorite: Bool

    init(project: LocalProject) {
        self.id = project.id
        self.typeRawValue = project.type.rawValue
        self.title = project.title
        self.styleName = project.styleName
        self.roomType = project.roomType
        self.createdAt = project.createdAt
        self.originalImagePath = project.originalImagePath
        self.generatedImagePathsValue = project.generatedImagePaths.joined(separator: "\n")
        self.selectedGeneratedImagePath = project.selectedGeneratedImagePath
        self.isFavorite = project.isFavorite
    }

    func update(with project: LocalProject) {
        typeRawValue = project.type.rawValue
        title = project.title
        styleName = project.styleName
        roomType = project.roomType
        createdAt = project.createdAt
        originalImagePath = project.originalImagePath
        generatedImagePathsValue = project.generatedImagePaths.joined(separator: "\n")
        selectedGeneratedImagePath = project.selectedGeneratedImagePath
        isFavorite = project.isFavorite
    }

    var project: LocalProject? {
        guard let type = ProjectType(rawValue: typeRawValue) else { return nil }

        return LocalProject(
            id: id,
            type: type,
            title: title,
            styleName: styleName,
            roomType: roomType,
            createdAt: createdAt,
            originalImagePath: originalImagePath,
            generatedImagePaths: generatedImagePaths,
            selectedGeneratedImagePath: selectedGeneratedImagePath,
            isFavorite: isFavorite
        )
    }

    private var generatedImagePaths: [String] {
        generatedImagePathsValue
            .split(separator: "\n")
            .map(String.init)
    }
}

final class LocalProjectFileStorage: LocalProjectStorageProtocol {
    static let shared = LocalProjectFileStorage()

    private let fileManager: FileManager
    private let modelContainer: ModelContainer

    init(
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager

        do {
            modelContainer = try ModelContainer(for: LocalProjectRecord.self)
        } catch {
            fatalError("Could not create LocalProjectRecord ModelContainer: \(error)")
        }
    }

    func getProjects() -> [LocalProject] {
        let descriptor = FetchDescriptor<LocalProjectRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        guard let records = try? modelContainer.mainContext.fetch(descriptor) else {
            return []
        }

        return records.compactMap(\.project)
    }

    func saveProject(_ project: LocalProject) {
        let id = project.id
        var descriptor = FetchDescriptor<LocalProjectRecord>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        if let existing = try? modelContainer.mainContext.fetch(descriptor).first {
            existing.update(with: project)
        } else {
            modelContainer.mainContext.insert(LocalProjectRecord(project: project))
        }

        try? modelContainer.mainContext.save()
    }

    func saveProject(
        _ project: LocalProject,
        originalImage: UIImage,
        generatedImages: [UIImage]
    ) throws -> LocalProject {
        let directory = try projectDirectory(for: project.id)
        let originalPath = relativePath(projectID: project.id, filename: "original.jpg")
        try write(originalImage, to: directory.appendingPathComponent("original.jpg"))

        let generatedPaths = try generatedImages.enumerated().map { index, image in
            let filename = "generated_\(index).jpg"
            try write(image, to: directory.appendingPathComponent(filename))
            return relativePath(projectID: project.id, filename: filename)
        }

        let savedProject = LocalProject(
            id: project.id,
            type: project.type,
            title: project.title,
            styleName: project.styleName,
            roomType: project.roomType,
            createdAt: project.createdAt,
            originalImagePath: originalPath,
            generatedImagePaths: generatedPaths,
            selectedGeneratedImagePath: generatedPaths.first,
            isFavorite: project.isFavorite
        )

        saveProject(savedProject)
        return savedProject
    }

    func deleteProject(id: String) {
        var descriptor = FetchDescriptor<LocalProjectRecord>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        if let record = try? modelContainer.mainContext.fetch(descriptor).first {
            modelContainer.mainContext.delete(record)
            try? modelContainer.mainContext.save()
        }

        let directory = projectsDirectory.appendingPathComponent(id, isDirectory: true)
        try? fileManager.removeItem(at: directory)
    }

    func image(for path: String?) -> UIImage? {
        guard let path, !path.isEmpty else { return nil }
        let url = documentsDirectory.appendingPathComponent(path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func images(for paths: [String]) -> [UIImage] {
        paths.compactMap { image(for: $0) }
    }

    private func projectDirectory(for projectID: String) throws -> URL {
        let directory = projectsDirectory.appendingPathComponent(projectID, isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func write(_ image: UIImage, to url: URL) throws {
        guard let data = GenerationImageEncoder.jpegData(image, compressionQuality: 0.9) else {
            throw CocoaError(.fileWriteUnknown)
        }

        try data.write(to: url, options: .atomic)
    }

    private func relativePath(projectID: String, filename: String) -> String {
        "HistoryProjects/\(projectID)/\(filename)"
    }

    private var projectsDirectory: URL {
        documentsDirectory.appendingPathComponent("HistoryProjects", isDirectory: true)
    }

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
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
