import Foundation
import Observation

enum MainTab: CaseIterable {
    case home
    case inspiration
    case history
    case settings
}

@Observable
final class MainTabViewModel {
    func refreshPremiumStatus() async {
        await UserManager.shared.refreshPremiumStatus()
    }
}
