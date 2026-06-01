import Foundation

enum HomeDesignsEndpoint {
    case perfectRedesign
    case perfectRedesignStatus(queueId: String)
    case designTransfer
    case createMaskImage
    case furnitureRemoval
    case changeColorTextures
    case materialSwap
    case floorEditor
    case paintVisualizer
    case furnitureFinder
    case fullHD

    var path: String {
        switch self {
        case .perfectRedesign: return "/perfect_redesign"
        case .perfectRedesignStatus(let queueId): return "/perfect_redesign/status_check/\(queueId)"
        case .designTransfer: return "/design_transfer"
        case .createMaskImage: return "/create_maskimage"
        case .furnitureRemoval: return "/furniture_removal"
        case .changeColorTextures: return "/change_color_textures"
        case .materialSwap: return "/material_swap"
        case .floorEditor: return "/floor_editor"
        case .paintVisualizer: return "/paint_visualizer"
        case .furnitureFinder: return "/furniture_finder"
        case .fullHD: return "/full_hd"
        }
    }

    var method: String {
        switch self {
        case .perfectRedesignStatus: return "GET"
        default: return "POST"
        }
    }
}
