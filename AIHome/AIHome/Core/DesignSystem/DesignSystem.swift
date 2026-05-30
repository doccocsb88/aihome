import SwiftUI

extension Color {
    struct DesignSystem {
        static let primary = Color.blue // Replace with exact color from Figma later
        static let background = Color(UIColor.systemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let surface = Color(UIColor.secondarySystemBackground)
        static let accent = Color.orange
    }
}

extension Font {
    struct DesignSystem {
        static let title1 = Font.largeTitle.weight(.bold)
        static let title2 = Font.title.weight(.semibold)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let caption = Font.caption
    }
}
