import SwiftUI

extension Color {
    struct DesignSystem {
        static let primary = Color(red: 26/255, green: 26/255, blue: 26/255) // #1A1A1A
        static let background = Color(UIColor.systemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let surface = Color(UIColor.secondarySystemBackground)
        static let accent = Color.orange
    }
}

extension Font {
    struct DesignSystem {
        static let title1 = Font.system(size: 32, weight: .bold, design: .default)
        static let title2 = Font.title.weight(.semibold)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let caption = Font.caption
    }
}
