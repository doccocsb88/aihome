import Foundation
import Observation

@Observable
final class InspirationFilterViewModel {
    var showLikedOnly: Bool = false
    var selectedFeature: ProjectType?
    var selectedInteriorSpace: String = "All"
    var selectedExteriorSpace: String = "All"
    var selectedGardenSpace: String = "All"
    var selectedOtherSpace: String = "All"
    
    let interiorSpaces = ["All", "Living room", "Bathroom", "Bedroom", "Toilet", "Kitchen"]
    let exteriorSpaces = ["All", "Garden", "Villa", "Backyard", "Pool"]
    let gardenSpaces = ["All", "Backyard", "Courtyard"]
    let otherSpaces = ["All", "Reference Style", "Replace Objects", "Remove Objects", "New Flooring", "New Walls", "Furniture Finder", "Edit"]
    let historyFeatures: [ProjectType] = [
        .interior,
        .exterior,
        .garden,
        .referenceStyle,
        .replaceObjects,
        .removeObjects,
        .newFlooring,
        .newWalls
    ]

    func makeDraft() -> InspirationFilterViewModel {
        let draft = InspirationFilterViewModel()
        draft.copyValues(from: self)
        return draft
    }

    func copyValues(from source: InspirationFilterViewModel) {
        showLikedOnly = source.showLikedOnly
        selectedFeature = source.selectedFeature
        selectedInteriorSpace = source.selectedInteriorSpace
        selectedExteriorSpace = source.selectedExteriorSpace
        selectedGardenSpace = source.selectedGardenSpace
        selectedOtherSpace = source.selectedOtherSpace
    }
    
    func reset() {
        showLikedOnly = false
        selectedFeature = nil
        selectedInteriorSpace = "All"
        selectedExteriorSpace = "All"
        selectedGardenSpace = "All"
        selectedOtherSpace = "All"
    }
}
