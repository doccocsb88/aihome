import SwiftUI

extension Color {
    struct DesignSystem {
        static let eerieBlack = Color(hex: "#1A1A1A")
        static let darkKnight = Color(hex: "#111827")
        static let white = Color(hex: "#FFFFFF")
        static let black = Color(hex: "#000000")
        static let folly = Color(hex: "#FF2D55")
        static let amaranth = Color(hex: "#FF2D5B")
        static let ghostWhite = Color(hex: "#F2F2F7")
        static let brightGray = Color(hex: "#F3F4F6")
        static let cultured = Color(hex: "#F4F4F6")
        static let alabaster = Color(hex: "#F9FAFB")
        static let snow = Color(hex: "#FAFAFB")
        static let mistyRose = Color(hex: "#FEF2F2")
        static let lavenderBlush = Color(hex: "#FFEEF3")
        static let platinum = Color(hex: "#E5E7EB")
        static let coolGray = Color(hex: "#9CA3AF")
        static let silverSand = Color(hex: "#AEAEB2")
        static let mountainMist = Color(hex: "#959595")
        static let gray = Color(hex: "#8E8E93")
        static let slateGray = Color(hex: "#6B7280")
        static let darkSlate = Color(hex: "#4B5563")
        static let royalBlue = Color(hex: "#2563EB")
        static let emerald = Color(hex: "#22C55E")
        static let cyberYellow = Color(hex: "#FFCC00")

        static let primary = eerieBlack
        static let background = Color(UIColor.systemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
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
