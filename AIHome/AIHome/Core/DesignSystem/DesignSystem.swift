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
        static let flowSelectionAccent = Color(hex: "#FF2D55")
        static let historyAccent = Color(hex: "#FF2D55")
        static let historyQuotaBackground = Color(hex: "#F2F2F7")
        static let historyEmptyMessage = Color(hex: "#8E8E93")
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
        static let settingsRowBorder = Color(hex: "#F3F4F6")
        static let filterSheetBackground = Color(hex: "#FAFAFB")
        static let filterTextSecondary = Color(hex: "#6B7280")
        static let filterChipBackground = Color(hex: "#F9FAFB")
        static let filterBorder = Color(hex: "#E5E7EB")
        static let popupRatingIconBackground = Color(hex: "#FEF2F2")
        static let popupRatingStar = Color(hex: "#FFCC00")
        static let inspirationAccent = Color(hex: "#FF2D5B")
        static let inspirationTabInactive = Color(hex: "#9CA3AF")
        static let inspirationPillBackground = Color(hex: "#F4F4F6")
        static let inspirationTextSecondary = Color(hex: "#4B5563")
        static let inspirationBody = Color(hex: "#6B7280")
        static let inspirationTagBackground = Color(hex: "#F3F4F6")
        static let inspirationProminentTagBackground = Color(hex: "#FFEEF3")
        static let inspirationBorder = Color(hex: "#E5E7EB")
        static let surface = Color(UIColor.secondarySystemBackground)
        static let accent = Color.orange
    }
}

extension Font {
    struct DesignSystem {
        static let title1 = FontFamily.Roboto.bold.swiftUIFont(size: 32)
        static let title2 = FontFamily.Roboto.medium.swiftUIFont(size: 22)
        static let headline = FontFamily.Roboto.medium.swiftUIFont(size: 17)
        static let body = FontFamily.Roboto.regular.swiftUIFont(size: 17)
        static let caption = FontFamily.Roboto.regular.swiftUIFont(size: 12)
    }
}
