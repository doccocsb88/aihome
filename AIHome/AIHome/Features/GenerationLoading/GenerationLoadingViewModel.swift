import Foundation

@Observable
class GenerationLoadingViewModel {
    var projectType: ProjectType
    var status: JobStatus
    var progressText: String
    var canCancel: Bool
    
    init(projectType: ProjectType, status: JobStatus = .generating, progressText: String = "Generating...", canCancel: Bool = false) {
        self.projectType = projectType
        self.status = status
        self.progressText = progressText
        self.canCancel = canCancel
    }
}
