import Foundation
import Observation

@Observable
final class InspirationFilterViewModel {
    var showLikedOnly: Bool = false
    var selectedInteriorSpace: String = "All"
    var selectedExteriorSpace: String = "All"
    
    let interiorSpaces = ["All", "Living room", "Bathroom", "Bedroom", "Toilet", "Kitchen"]
    let exteriorSpaces = ["All", "Garden", "Villa", "Backyard", "Pool"]
    
    func reset() {
        showLikedOnly = false
        selectedInteriorSpace = "All"
        selectedExteriorSpace = "All"
    }
}
