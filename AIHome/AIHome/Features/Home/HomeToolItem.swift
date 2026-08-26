import Foundation

struct HomeToolItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let imageName: String
    let projectType: ProjectType
    let isPro: Bool
}
