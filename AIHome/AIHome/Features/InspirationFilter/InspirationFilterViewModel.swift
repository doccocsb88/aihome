import Foundation
import Observation

@Observable
final class InspirationFilterViewModel {
    var showLikedOnly: Bool = false
    var selectedInteriorSpace: String = "All"
    var selectedExteriorSpace: String = "All"
    var selectedGardenSpace: String = "All"
    var selectedOtherSpace: String = "All"
    
    let interiorSpaces = ["All", "Living room", "Bathroom", "Bedroom", "Toilet", "Kitchen"]
    let exteriorSpaces = ["All", "Garden", "Villa", "Backyard", "Pool"]
    let gardenSpaces = ["All", "Backyard", "Courtyard"]
    let otherSpaces = ["All", "Reference Style", "Replace Objects", "Remove Objects", "New Flooring", "New Walls", "Furniture Finder", "Edit"]
    
    func reset() {
        showLikedOnly = false
        selectedInteriorSpace = "All"
        selectedExteriorSpace = "All"
        selectedGardenSpace = "All"
        selectedOtherSpace = "All"
    }
}
