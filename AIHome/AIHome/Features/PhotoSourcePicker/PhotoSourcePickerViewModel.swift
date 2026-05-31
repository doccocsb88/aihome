import Foundation
import SwiftUI
import PhotosUI

@Observable
class PhotoSourcePickerViewModel {
    var title: String
    var subtitle: String?
    var selectedImage: UIImage?
    var allowsSample: Bool
    var sampleImages: [String] // Asset names
    var sampleTitle: String
    var ctaTitle: String
    var canContinue: Bool { selectedImage != nil }
    
    var showCamera: Bool = false
    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                Task {
                    await loadTransferable(from: imageSelection)
                }
            }
        }
    }
    
    init(title: String, subtitle: String? = nil, allowsSample: Bool = true, sampleImages: [String] = [], sampleTitle: String = "OR TRY A SAMPLE", ctaTitle: String = "Get Started") {
        self.title = title
        self.subtitle = subtitle
        self.allowsSample = allowsSample
        self.sampleImages = sampleImages
        self.sampleTitle = sampleTitle
        self.ctaTitle = ctaTitle
    }
    
    @MainActor
    func loadTransferable(from imageSelection: PhotosPickerItem) async {
        do {
            if let data = try await imageSelection.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                self.selectedImage = image
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
    
    func selectSample(_ imageName: String) {
        if let image = UIImage(named: imageName) {
            self.selectedImage = image
        }
    }
}
