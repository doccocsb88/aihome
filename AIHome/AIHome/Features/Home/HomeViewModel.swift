import Foundation
import Observation

@Observable
final class HomeViewModel {
    let primaryTools: [HomeToolItem] = [
        HomeToolItem(id: "interior", title: "Interior AI", subtitle: "Redesign your room", iconName: "sofa", projectType: .interior, isPro: false),
        HomeToolItem(id: "exterior", title: "Exterior AI", subtitle: "Reimagine your facade", iconName: "house", projectType: .exterior, isPro: false),
        HomeToolItem(id: "garden", title: "Garden Redesign", subtitle: "Refresh your garden", iconName: "leaf", projectType: .garden, isPro: false)
    ]
    
    let advancedTools: [HomeToolItem] = [
        HomeToolItem(id: "ref_style", title: "Reference Style", subtitle: "Copy style from image", iconName: "photo.on.rectangle", projectType: .referenceStyle, isPro: true),
        HomeToolItem(id: "remove_obj", title: "Remove Objects", subtitle: "Erase unwanted items", iconName: "eraser", projectType: .removeObjects, isPro: true),
        HomeToolItem(id: "replace_obj", title: "Replace Objects", subtitle: "Change specific items", iconName: "arrow.2.squarepath", projectType: .replaceObjects, isPro: true),
        HomeToolItem(id: "new_flooring", title: "New Flooring", subtitle: "Change floor materials", iconName: "squareshape.split.2x2", projectType: .newFlooring, isPro: true),
        HomeToolItem(id: "new_walls", title: "New Walls", subtitle: "Paint or change wallpaper", iconName: "paintpalette", projectType: .newWalls, isPro: true)
    ]
    
    func handleToolSelection(_ tool: HomeToolItem) {
        // We will delegate to Coordinator to navigate in future steps
        print("Selected tool: \(tool.title)")
    }
}
