import SwiftUI

struct PhotoSelectedImagePreviewView: View {
    let image: UIImage
    let onRemove: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let cardSide = proxy.size.width
            let imageSide = max(cardSide - 20, 0)

            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.DesignSystem.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.DesignSystem.platinum.opacity(0.65), lineWidth: 1)
                    )

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSide, height: imageSide)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                VStack {
                    HStack {
                        Spacer()
                        Button(action: onRemove) {
                            Image(systemName: "xmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 38, height: 38)
                                .background(Color.black.opacity(0.55))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 18)
                        .padding(.trailing, 18)
                    }

                    Spacer()
                }
            }
            .frame(width: cardSide, height: cardSide)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, 24)
    }
}
