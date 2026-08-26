import Foundation
import Observation

@Observable
final class InspirationDetailViewModel {
    let item: InspirationItem
    
    init(item: InspirationItem) {
        self.item = item
    }
}
