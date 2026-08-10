import Foundation
import SwiftUI
import PhotosUI

enum PhotoSampleAssets {
    static let interior = [
        "20_sample_01_interior_living_room",
        "21_sample_02_interior_kitchen",
        "22_sample_03_interior_bedroom",
        "23_sample_04_interior_bathroom"
    ]

    static let exterior = [
        "24_sample_05_exterior_modern_farmhouse",
        "25_sample_06_exterior_european_townhouse",
        "26_sample_07_exterior_coastal_villa",
        "27_sample_08_exterior_brick_suburban"
    ]

    static let garden = [
        "28_sample_09_garden_backyard_patio",
        "29_sample_10_garden_english_cottage",
        "30_sample_11_garden_poolyard",
        "31_sample_12_garden_rooftop_terrace"
    ]
}

@Observable
class PhotoSourcePickerViewModel {
    enum SelectionSource {
        case gallery
        case camera
        case sample
    }

    var title: String
    var subtitle: String?
    var selectedImage: UIImage?
    var allowsSample: Bool
    var sampleImages: [String] // Asset names
    var sampleTitle: String
    var ctaTitle: String
    var onSourceSelected: ((SelectionSource) -> Void)?
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
    
    init(
        title: String,
        subtitle: String? = nil,
        selectedImage: UIImage? = nil,
        allowsSample: Bool = true,
        sampleImages: [String] = [],
        sampleTitle: String = L10n.PhotoSource.orTryASample,
        ctaTitle: String = L10n.PhotoSource.getStarted
    ) {
        self.title = title
        self.subtitle = subtitle
        self.selectedImage = selectedImage
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
                self.onSourceSelected?(.gallery)
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
    
    func selectSample(_ imageName: String) {
        if let image = UIImage(named: imageName) {
            self.selectedImage = image
            onSourceSelected?(.sample)
        }
    }
}

extension PhotoSourcePickerViewModel.SelectionSource {
    var trackingSource: TrackingManager.PhotoSource {
        switch self {
        case .gallery:
            return .gallery
        case .camera:
            return .camera
        case .sample:
            return .sample
        }
    }
}
