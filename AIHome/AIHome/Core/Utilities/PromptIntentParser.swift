import Foundation

struct RGBColor: Equatable {
    let r: Int
    let g: Int
    let b: Int
}

struct PromptIntent: Equatable {
    let objectLabel: String?
    let color: RGBColor?
    let materialKeyword: String?
    let textureAssetName: String?
}

final class PromptIntentParser {
    func parse(_ prompt: String, projectType: ProjectType) -> PromptIntent {
        let lowercasedPrompt = prompt.lowercased()
        
        var objectLabel: String?
        var color: RGBColor?
        var materialKeyword: String?
        var textureAssetName: String?
        
        // Parse Object Label
        let objectMappings: [String: String] = [
            "tv": "tv", "television": "tv", "sofa": "sofa", "couch": "sofa",
            "chair": "chair", "table": "table", "bed": "bed", "lamp": "lamp",
            "carpet": "carpet", "rug": "rug", "cabinet": "cabinet",
            "wall": "wall", "floor": "floor"
        ]
        
        for (key, value) in objectMappings {
            if lowercasedPrompt.contains(key) {
                objectLabel = value
                break
            }
        }
        
        // Parse Color
        let colorMappings: [String: RGBColor] = [
            "white": RGBColor(r: 255, g: 255, b: 255),
            "warm white": RGBColor(r: 245, g: 241, b: 232),
            "beige": RGBColor(r: 222, g: 204, b: 177),
            "gray": RGBColor(r: 128, g: 128, b: 128),
            "concrete gray": RGBColor(r: 139, g: 140, b: 135),
            "sage green": RGBColor(r: 156, g: 175, b: 136),
            "navy": RGBColor(r: 20, g: 40, b: 80),
            "cream": RGBColor(r: 245, g: 235, b: 210)
        ]
        
        // Sort by length descending to match longest first
        let sortedColorKeys = colorMappings.keys.sorted { $0.count > $1.count }
        for key in sortedColorKeys {
            if lowercasedPrompt.contains(key) {
                color = colorMappings[key]
                break
            }
        }
        
        // Parse Material
        let materialMappings: [String: String] = [
            "oak wood": "floor_oak_wood.jpg",
            "walnut wood": "floor_walnut_wood.jpg",
            "marble": "material_marble.jpg",
            "beige marble": "floor_beige_marble.jpg",
            "concrete": "wall_concrete.jpg",
            "terrazzo": "floor_terrazzo.jpg",
            "tile": "floor_tile.jpg"
        ]
        
        let sortedMaterialKeys = materialMappings.keys.sorted { $0.count > $1.count }
        for key in sortedMaterialKeys {
            if lowercasedPrompt.contains(key) {
                materialKeyword = key
                textureAssetName = materialMappings[key]
                break
            }
        }
        
        return PromptIntent(
            objectLabel: objectLabel,
            color: color,
            materialKeyword: materialKeyword,
            textureAssetName: textureAssetName
        )
    }
}
