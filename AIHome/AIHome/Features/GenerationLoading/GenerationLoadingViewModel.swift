import Foundation
import UIKit

@Observable
class GenerationLoadingViewModel {
    var projectType: ProjectType
    var status: JobStatus
    var progressText: String
    var canCancel: Bool
    var inputImage: UIImage?
    
    init(projectType: ProjectType, status: JobStatus = .generating, progressText: String = "Generating...", canCancel: Bool = false, inputImage: UIImage? = nil) {
        self.projectType = projectType
        self.status = status
        self.progressText = progressText
        self.canCancel = canCancel
        self.inputImage = inputImage
    }
}
