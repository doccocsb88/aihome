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
    
    var filteredItems: [InspirationItem] {
        items.filter { $0.category == selectedCategory }
    }
}
