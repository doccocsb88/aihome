import SwiftUI

extension Color {
    struct DesignSystem {
        static let primary = Color(hex: "#1A1A1A")
        static let background = Color(UIColor.systemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let homeAccent = Color(hex: "#FF2D55")
        static let homeQuotaBackground = Color(hex: "#F2F2F7")
        static let homeSectionTitle = Color(hex: "#AEAEB2")
        static let historyAccent = Color(hex: "#FF2D55")
        static let historyCardTitle = Color(hex: "#111827")
        static let historyCardStyle = Color(hex: "#6B7280")
        static let popupLimitButtonShadow = Color(hex: "#2563EB")
        static let photoTipsBackground = Color(hex: "#FFFFFF")
        static let photoTipsTitle = Color(hex: "#111827")
        static let photoTipsBody = Color(hex: "#4B5563")
        static let photoTipsSectionBackground = Color(hex: "#F9FAFB")
        static let photoTipsSeparator = Color(hex: "#F3F4F6")
        static let photoTipsCloseBackground = Color(hex: "#F3F4F6")
        static let photoTipsCloseIcon = Color(hex: "#6B7280")
        static let photoTipsDanger = Color(hex: "#FF2D55")
        static let photoTipsSuccess = Color(hex: "#22C55E")
        static let photoTipsButtonBackground = Color(hex: "#000000")
        static let photoTipsButtonShadow = Color(hex: "#000000")
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
