import SwiftUI

enum TrySampleTitleStyle {
    case eyebrow
    case section
}

struct TrySampleView: View {
    let title: String
    let imageNames: [String]
    var titleStyle: TrySampleTitleStyle = .eyebrow
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(titleFont)
                .foregroundColor(titleColor)
                .kerning(titleKerning)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(imageNames, id: \.self) { imageName in
                        Button(action: {
                            onSelect(imageName)
                        }) {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var titleFont: Font {
        switch titleStyle {
        case .eyebrow:
            FontFamily.Roboto.bold.swiftUIFont(size: 11)
        case .section:
            FontFamily.Roboto.bold.swiftUIFont(size: 14)
        }
    }

    private var titleColor: Color {
        switch titleStyle {
        case .eyebrow:
            .gray
        case .section:
            .DesignSystem.textPrimary
        }
    }

    private var titleKerning: CGFloat {
        switch titleStyle {
        case .eyebrow:
            1.2
        case .section:
            0
        }
    }
}
