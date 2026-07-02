import Foundation
import Observation

@Observable
final class HomeViewModel {
    let primaryTools: [HomeToolItem] = [
        HomeToolItem(id: "interior", title: L10n.Home.Tool.Interior.title, subtitle: L10n.Home.Tool.Interior.subtitle, iconName: "sofa", imageName: "ic_home_interior", projectType: .interior, isPro: false),
        HomeToolItem(id: "exterior", title: L10n.Home.Tool.Exterior.title, subtitle: L10n.Home.Tool.Exterior.subtitle, iconName: "house", imageName: "ic_home_exterior", projectType: .exterior, isPro: false),
        HomeToolItem(id: "garden", title: L10n.Home.Tool.Garden.title, subtitle: L10n.Home.Tool.Garden.subtitle, iconName: "leaf", imageName: "ic_home_garden", projectType: .garden, isPro: false)
    ]
    
    let advancedTools: [HomeToolItem] = [
        HomeToolItem(id: "ref_style", title: L10n.Home.Tool.ReferenceStyle.title, subtitle: L10n.Home.Tool.ReferenceStyle.subtitle, iconName: "photo.on.rectangle", imageName: "ic_home_reference", projectType: .referenceStyle, isPro: true),
        HomeToolItem(id: "remove_obj", title: L10n.Home.Tool.RemoveObjects.title, subtitle: L10n.Home.Tool.RemoveObjects.subtitle, iconName: "eraser", imageName: "ic_home_remove_object", projectType: .removeObjects, isPro: true),
        HomeToolItem(id: "replace_obj", title: L10n.Home.Tool.ReplaceObjects.title, subtitle: L10n.Home.Tool.ReplaceObjects.subtitle, iconName: "arrow.2.squarepath", imageName: "ic_home_replace_object", projectType: .replaceObjects, isPro: true),
        HomeToolItem(id: "new_flooring", title: L10n.Home.Tool.NewFlooring.title, subtitle: L10n.Home.Tool.NewFlooring.subtitle, iconName: "squareshape.split.2x2", imageName: "ic_home_new_flooring", projectType: .newFlooring, isPro: true),
        HomeToolItem(id: "new_walls", title: L10n.Home.Tool.NewWalls.title, subtitle: L10n.Home.Tool.NewWalls.subtitle, iconName: "paintpalette", imageName: "ic_home_newwall", projectType: .newWalls, isPro: true)
    ]
    
    func handleToolSelection(_ tool: HomeToolItem) {
        // We will delegate to Coordinator to navigate in future steps
        print("Selected tool: \(tool.title)")
    }
}
