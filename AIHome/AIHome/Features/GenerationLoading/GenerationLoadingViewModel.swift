import Foundation
import UIKit

@Observable
class GenerationLoadingViewModel {
    var projectType: ProjectType
    var status: JobStatus
    var progressText: String
    var canCancel: Bool
    var canRetry: Bool
    var inputImage: UIImage?
    var errorMessage: String?
    
    init(projectType: ProjectType, status: JobStatus = .generating, progressText: String = "Generating...", canCancel: Bool = false, canRetry: Bool = true, inputImage: UIImage? = nil, errorMessage: String? = nil) {
        self.projectType = projectType
        self.status = status
        self.progressText = progressText
        self.canCancel = canCancel
        self.canRetry = canRetry
        self.inputImage = inputImage
        self.errorMessage = errorMessage
    }
}
