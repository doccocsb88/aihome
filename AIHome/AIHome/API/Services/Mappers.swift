import Foundation

public struct PromptMaskLabelMapper {
    public static func labels(for prompt: String) -> [String] {
        let normalizedPrompt = normalize(prompt)
        let promptRange = NSRange(normalizedPrompt.startIndex..., in: normalizedPrompt)

        let match = MaskObjectLabelCatalog.entries.compactMap { entry -> (label: String, range: NSRange)? in
            let searchTerms = [entry.label] + entry.aliases
            let ranges = searchTerms.compactMap { term -> NSRange? in
                let escapedTerm = NSRegularExpression.escapedPattern(for: normalize(term))
                let pattern = "(?<![a-z0-9])\(escapedTerm)(?:s|es)?(?![a-z0-9])"
                return try? NSRegularExpression(pattern: pattern)
                    .firstMatch(in: normalizedPrompt, range: promptRange)?
                    .range
            }

            guard let firstRange = ranges.min(by: isEarlierMatch) else { return nil }
            return (entry.label, firstRange)
        }
        .min { lhs, rhs in
            isEarlierMatch(lhs.range, rhs.range)
        }

        return match.map { [$0.label] } ?? []
    }

    private static func normalize(_ value: String) -> String {
        value.folding(
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
        .lowercased()
    }

    private static func isEarlierMatch(_ lhs: NSRange, _ rhs: NSRange) -> Bool {
        if lhs.location != rhs.location {
            return lhs.location < rhs.location
        }
        return lhs.length > rhs.length
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
