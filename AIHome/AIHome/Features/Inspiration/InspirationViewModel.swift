import Foundation
import Observation

@Observable
final class InspirationViewModel {
    var items: [InspirationItem] = []
    var selectedCategory: InspirationCategory = .interior
    
    private let service: InspirationServiceProtocol
    
    init(service: InspirationServiceProtocol = MockInspirationService()) {
        self.service = service
        fetchItems()
    }
    
    func fetchItems() {
        items = service.getInspirations()
    }
    
    func toggleLike(for item: InspirationItem) {
        service.toggleLike(for: item.id)
        fetchItems()
    }

    func selectCategory(_ category: InspirationCategory) {
        guard selectedCategory != category else { return }
        selectedCategory = category
    }
    
    var filter = InspirationFilterViewModel()
    
    var filteredItems: [InspirationItem] {
        items.filter { item in
            guard item.category == selectedCategory else { return false }
            
            if filter.showLikedOnly && !item.isLiked { return false }
            
            if selectedCategory == .interior && filter.selectedInteriorSpace != "All" {
                if item.spaceType.lowercased() != filter.selectedInteriorSpace.lowercased() {
                    return false
                }
            }
            
            if selectedCategory == .exterior && filter.selectedExteriorSpace != "All" {
                if item.spaceType.lowercased() != filter.selectedExteriorSpace.lowercased() {
                    return false
                }
            }
            
            if selectedCategory == .garden && filter.selectedGardenSpace != "All" {
                if item.spaceType.lowercased() != filter.selectedGardenSpace.lowercased() {
                    return false
                }
            }
            
            return true
        }
    }
}
