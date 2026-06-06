import SwiftUI

struct PhotoTipsView: View {
    @Environment(\.dismiss) private var dismiss

    var onClose: (() -> Void)?
    var onGotIt: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    PhotoTipsSection(title: "REQUIREMENTS:") {
                        VStack(alignment: .leading, spacing: 8) {
                            PhotoTipsBullet("The file dimensions must be at least 512x512.")
                            PhotoTipsBullet("The file size must be less than 20 MB.")
                        }
                    }

                    PhotoTipsSection(title: "FOR OPTIMAL RESULTS:") {
                        VStack(alignment: .leading, spacing: 8) {
                            PhotoTipsBullet("**Landscape Mode:** Capture your image horizontally.")
                            PhotoTipsBullet("**Bright Lighting:** Ensure the room is well-lit to eliminate shadows.")
                            PhotoTipsBullet("**Wide Framing:** Capture all key angles in a single frame.")
                            PhotoTipsBullet("**Stay Steady:** Keep the camera still for a sharp, detailed image.")
                        }
                    }

                    exampleSection(
                        title: "BAD EXAMPLES:",
                        iconName: "xmark",
                        iconColor: .DesignSystem.photoTipsDanger,
                        examples: ["ic_tips_bad_01", "ic_tips_bad_02"],
                        isBadExample: true
                    )

                    exampleSection(
                        title: "GOOD EXAMPLES:",
                        iconName: "checkmark",
                        iconColor: .DesignSystem.photoTipsSuccess,
                        examples: ["ic_tips_good_01", "ic_tips_good_02"],
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
                .padding(.bottom, 34)
        }
        .background(Color.DesignSystem.photoTipsBackground)
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
            Text("Photo Tips")
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 22))
                .foregroundStyle(Color.DesignSystem.photoTipsTitle)

            HStack {
                Spacer()

                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.DesignSystem.photoTipsCloseIcon)
                        .frame(width: 40, height: 40)
                        .background(Color.DesignSystem.photoTipsCloseBackground, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.horizontal, 28)
        }
        .frame(height: 96)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.DesignSystem.photoTipsSeparator)
                .frame(height: 1)
        }
    }

    private var gotItButton: some View {
        Button(action: gotIt) {
            Text("GOT IT")
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                .tracking(4)
                .foregroundStyle(Color.DesignSystem.photoTipsBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.DesignSystem.photoTipsButtonBackground)
                )
                .shadow(color: Color.DesignSystem.photoTipsButtonShadow.opacity(0.18), radius: 22, x: 0, y: 12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Got it")
    }

    private func exampleSection(
        title: String,
        iconName: String,
        iconColor: Color,
        examples: [String],
        isBadExample: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(iconColor)
                    .frame(width: 16, height: 16)
                    .overlay {
                        Circle()
                            .stroke(iconColor, lineWidth: 2)
                    }

                Text(title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 16))
                    .tracking(1)
                    .foregroundStyle(Color.DesignSystem.photoTipsTitle)
            }

            HStack(spacing: 14) {
                ForEach(examples, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .saturation(isBadExample ? 0 : 1)
                        .opacity(isBadExample ? 0.55 : 1)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.36, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .clipped()
                }
            }
        }
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
                .foregroundStyle(Color.DesignSystem.photoTipsTitle)

            content
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .foregroundStyle(Color.DesignSystem.photoTipsBody)
                .lineSpacing(6)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.DesignSystem.photoTipsSectionBackground)
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
