import SwiftUI

enum PhotoTipsStyle {
    case interior
    case exterior

    var badExamples: [String] {
        switch self {
        case .interior:
            [
                "33_photo_tips_02_interior_no_well_lit_bad",
                "35_photo_tips_04_interior_blur_bad"
            ]
        case .exterior:
            [
                "37_photo_tips_06_exterior_unbright_bad",
                "39_photo_tips_08_exterior_narrow_bad"
            ]
        }
    }

    var goodExamples: [String] {
        switch self {
        case .interior:
            [
                "32_photo_tips_01_interior_well_lit_good",
                "34_photo_tips_03_interior_steady_good"
            ]
        case .exterior:
            [
                "36_photo_tips_05_exterior_bright_good",
                "38_photo_tips_07_exterior_wide_good"
            ]
        }
    }
}

struct PhotoTipsView: View {
    @Environment(\.dismiss) private var dismiss

    var style: PhotoTipsStyle = .interior
    var onClose: (() -> Void)?
    var onGotIt: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    PhotoTipsSection(title: L10n.PhotoTips.requirements) {
                        VStack(alignment: .leading, spacing: 8) {
                            PhotoTipsBullet(L10n.PhotoTips.fileDimensions)
                            PhotoTipsBullet(L10n.PhotoTips.fileSize)
                        }
                    }

                    PhotoTipsSection(title: L10n.PhotoTips.optimalResults) {
                        VStack(alignment: .leading, spacing: 8) {
                            PhotoTipsBullet(L10n.PhotoTips.landscapeMode)
                            PhotoTipsBullet(L10n.PhotoTips.brightLighting)
                            PhotoTipsBullet(L10n.PhotoTips.wideFraming)
                            PhotoTipsBullet(L10n.PhotoTips.staySteady)
                        }
                    }

                    exampleSection(
                        title: L10n.PhotoTips.badExamples,
                        iconName: "ic_tips_bad",
                        examples: style.badExamples,
                        isBadExample: true
                    )

                    exampleSection(
                        title: L10n.PhotoTips.goodExamples,
                        iconName: "ic_tips_good",
                        examples: style.goodExamples,
                        isBadExample: false
                    )
                }
                .padding(.horizontal, 30)
                .padding(.top, 28)
                .padding(.bottom, 24)
            }

            gotItButton
                .padding(.horizontal, 40)
                .padding(.top, 16)
                .padding(.bottom, 0)
        }
        .background(Color.DesignSystem.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 34,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 34,
                style: .continuous
            )
        )
    }

    private var headerView: some View {
        ZStack {
            Text(L10n.PhotoTips.title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 22))
                .foregroundStyle(Color.DesignSystem.darkKnight)

            HStack {
                Spacer()

                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.DesignSystem.slateGray)
                        .frame(width: 40, height: 40)
                        .background(Color.DesignSystem.brightGray, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.PhotoTips.close)
            }
            .padding(.horizontal, 28)
        }
        .frame(height: 96)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.DesignSystem.brightGray)
                .frame(height: 1)
        }
    }

    private var gotItButton: some View {
        Button(action: gotIt) {
            Text(L10n.PhotoTips.gotIt)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                .tracking(4)
                .foregroundStyle(Color.DesignSystem.white)
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.DesignSystem.black)
                )
                .shadow(color: Color.DesignSystem.black.opacity(0.18), radius: 22, x: 0, y: 12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Got it")
    }

    private func exampleSection(
        title: String,
        iconName: String,
        examples: [String],
        isBadExample: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(iconName)
                    .frame(width: 16, height: 16)

                Text(title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 16))
                    .tracking(1)
                    .foregroundStyle(Color.DesignSystem.darkKnight)
            }

            GeometryReader { proxy in
                let spacing: CGFloat = 14
                let itemWidth = max((proxy.size.width - spacing) / 2, 0)
                let itemHeight = itemWidth * 124 / 166

                HStack(spacing: spacing) {
                    ForEach(examples, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
//                            .saturation(isBadExample ? 0 : 1)
//                            .opacity(isBadExample ? 0.55 : 1)
                            .frame(width: itemWidth, height: itemHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .clipped()
                    }
                }
            }
            .frame(height: exampleImageHeight)
        }
    }

    private var exampleImageHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding: CGFloat = 60
        let spacing: CGFloat = 14
        let itemWidth = max((screenWidth - horizontalPadding - spacing) / 2, 0)
        return itemWidth * 124 / 166
    }

    private func close() {
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }

    private func gotIt() {
        if let onGotIt {
            onGotIt()
        } else {
            dismiss()
        }
    }
}

private struct PhotoTipsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 16))
                .tracking(1)
                .foregroundStyle(Color.DesignSystem.darkKnight)

            content
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .foregroundStyle(Color.DesignSystem.darkSlate)
                .lineSpacing(6)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.DesignSystem.alabaster)
                )
        }
    }
}

private struct PhotoTipsBullet: View {
    private let text: LocalizedStringKey

    init(_ text: String) {
        self.text = LocalizedStringKey(text)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("•")
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))

            Text(text)
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    ZStack {
        Color.DesignSystem.primary.opacity(0.34)
            .ignoresSafeArea()

        PhotoTipsView()
    }
}
