import UIKit

enum GenerationHistoryRecorder {
    static func save(
        project: LocalProject,
        originalImage: UIImage,
        generatedImages: [UIImage]
    ) throws -> LocalProject {
        try LocalProjectFileStorage.shared.saveProject(
            project,
            originalImage: originalImage,
            generatedImages: generatedImages
        )
    }
}
