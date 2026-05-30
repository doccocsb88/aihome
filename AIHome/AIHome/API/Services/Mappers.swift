import Foundation

public struct PromptMaskLabelMapper {
    public static func labels(for prompt: String) -> [String] {
        let lower = prompt.lowercased()
        if lower.contains("tv") || lower.contains("television") { return ["television receiver"] }
        if lower.contains("sofa") || lower.contains("couch") { return ["sofa"] }
        if lower.contains("dining table") || lower.contains("table") { return ["table"] }
        if lower.contains("wall") { return ["wall"] }
        if lower.contains("floor") || lower.contains("flooring") { return ["floor"] }
        if lower.contains("cabinet") { return ["cabinet"] }
        if lower.contains("chair") { return ["chair"] }
        // Default generic
        return []
    }
}

public struct ColorPromptMapper {
    public static func rgb(for prompt: String) -> String? {
        let lower = prompt.lowercased()
        if lower.contains("warm white") { return "245,240,230" }
        if lower.contains("beige") { return "221,196,170" }
        if lower.contains("light gray") { return "211,211,211" }
        if lower.contains("sage green") { return "156,175,136" }
        if lower.contains("blue") { return "0,0,255" }
        if lower.contains("white") { return "255,255,255" }
        return nil
    }
}

public struct TexturePromptMapper {
    public static func matchesTexture(_ prompt: String) -> Bool {
        let lower = prompt.lowercased()
        return lower.contains("wood") || lower.contains("wooden") || lower.contains("texture")
    }
}
