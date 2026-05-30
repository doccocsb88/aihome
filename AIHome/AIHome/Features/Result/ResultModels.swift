import Foundation

enum AdvancedTool: String, CaseIterable, Identifiable {
    case edit = "Edit"
    case replace = "Replace"
    case remove = "Remove"
    case newWall = "New Wall"
    case newFlooring = "New Flooring"
    case furnitureFinder = "Furniture Finder"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .edit: return "pencil"
        case .replace: return "arrow.triangle.2.circlepath"
        case .remove: return "eraser"
        case .newWall: return "squareshape.split.2x2"
        case .newFlooring: return "square.grid.3x3.bottommiddle.fill"
        case .furnitureFinder: return "magnifyingglass"
        }
    }
}
