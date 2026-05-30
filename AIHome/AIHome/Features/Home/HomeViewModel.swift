import Foundation
import Observation

@Observable
final class HomeViewModel {
    let primaryTools: [HomeToolItem] = [
        HomeToolItem(id: "interior", title: "Interior AI", subtitle: "Instant room styling transformations.", iconName: "sofa", imageName: "ic_home_interior", projectType: .interior, isPro: false),
        HomeToolItem(id: "exterior", title: "Exterior AI", subtitle: "Stunning facade and garden renders.", iconName: "house", imageName: "ic_home_exterior", projectType: .exterior, isPro: false),
        HomeToolItem(id: "garden", title: "Garden Redesign", subtitle: "Transform outdoor spaces instantly.", iconName: "leaf", imageName: "ic_home_garden", projectType: .garden, isPro: false)
    ]
    
    let advancedTools: [HomeToolItem] = [
        HomeToolItem(id: "ref_style", title: "Reference Style", subtitle: "Replicate any design look instantly.", iconName: "photo.on.rectangle", imageName: "ic_home_reference", projectType: .referenceStyle, isPro: true),
        HomeToolItem(id: "remove_obj", title: "Remove Objects", subtitle: "Instantly erase clutter and items.", iconName: "eraser", imageName: "ic_home_remove_object", projectType: .removeObjects, isPro: true),
        HomeToolItem(id: "replace_obj", title: "Replace Objects", subtitle: "Swap furniture and decor easily.", iconName: "arrow.2.squarepath", imageName: "ic_home_replace_object", projectType: .replaceObjects, isPro: true),
        HomeToolItem(id: "new_flooring", title: "New Flooring", subtitle: "Transform your floors instantly.", iconName: "squareshape.split.2x2", imageName: "ic_home_new_flooring", projectType: .newFlooring, isPro: true),
        HomeToolItem(id: "new_walls", title: "New Walls", subtitle: "Refresh walls with new color & textures.", iconName: "paintpalette", imageName: "ic_home_newwall", projectType: .newWalls, isPro: true)
    ]
    
    func handleToolSelection(_ tool: HomeToolItem) {
        // We will delegate to Coordinator to navigate in future steps
        print("Selected tool: \(tool.title)")
    }
}
