import Foundation

enum InspirationCategory: String, Codable, CaseIterable, Identifiable {
    case interior = "Interior"
    case exterior = "Exterior"
    case garden = "Garden"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .interior:
            L10n.Inspiration.Category.interior
        case .exterior:
            L10n.Inspiration.Category.exterior
        case .garden:
            L10n.Inspiration.Category.garden
        }
    }
}

enum InspirationInterventionLevel: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct InspirationItem: Codable, Identifiable, Equatable {
    let id: String
    let category: InspirationCategory
    let spaceType: String
    let styleTag: String
    let beforeImageName: String
    let afterImageName: String
    let title: String
    let subtitle: String
    let interventionLevel: InspirationInterventionLevel
    var isLiked: Bool

    var localizedTitle: String {
        InspirationItemLocalizer.localized(
            key: "inspiration.item.\(id).title",
            fallback: title
        )
    }

    var localizedSubtitle: String {
        InspirationItemLocalizer.localized(
            key: "inspiration.item.\(id).subtitle",
            fallback: subtitle
        )
    }

    var localizedStyleTag: String {
        InspirationItemLocalizer.localizedStyleTag(styleTag)
    }

    var localizedSpaceType: String {
        InspirationItemLocalizer.localizedSpaceType(spaceType)
    }
}

private enum InspirationItemLocalizer {
    static func localized(key: String, fallback: String) -> String {
        LanguageManager.shared.currentBundle.localizedString(
            forKey: key,
            value: fallback,
            table: "Localizable"
        )
    }

    static func localizedStyleTag(_ styleTag: String) -> String {
        let normalizedTag = styleTag
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "electic", with: "eclectic")

        return localized(
            key: "interior.design_style.\(normalizedTag)",
            fallback: styleTag
        )
    }

    static func localizedSpaceType(_ spaceType: String) -> String {
        let normalizedSpace = spaceType
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")

        return localized(
            key: "interior.room_type.\(normalizedSpace)",
            fallback: spaceType
        )
    }
}
