import SwiftUI

struct PopupRatingView: View {
    var onClose: () -> Void
    var onWriteReview: () -> Void

    private let cardMaxWidth: CGFloat = 313

    var body: some View {
        ZStack {
            Color.black.opacity(0.34)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                closeButton

                Image("ic_rating_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .padding(.top, 8)

                Text("Your feedback =\nbetter designs")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(red: 31/255, green: 33/255, blue: 37/255))
                    .lineSpacing(2)
                    .padding(.top, 26)

                HStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image("ic_rating_star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Five star rating")
                .padding(.top, 20)

                Text("We'd love to hear your thoughts! If you're enjoying the transformations, please consider leaving a rating. Your feedback helps us build a more powerful AI experience for you.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(red: 111/255, green: 119/255, blue: 134/255))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 34)
                    .padding(.top, 23)

                Button(action: onWriteReview) {
                    HStack(spacing: 11) {
                        Image("ic_rating_edit")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)

                        Text("Write a Review")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(red: 1, green: 43/255, blue: 91/255))
                    )
                    .shadow(color: Color(red: 1, green: 43/255, blue: 91/255).opacity(0.28), radius: 13, x: 0, y: 10)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Write a Review")
                .padding(.horizontal, 32)
                .padding(.top, 34)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: cardMaxWidth)
            .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: 28, x: 0, y: 18)
            .padding(.horizontal, 44)
            .accessibilityAddTraits(.isModal)
        }
    }

    private var closeButton: some View {
        HStack {
            Spacer()

            Button(action: onClose) {
                Image("ic_rating_close")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.top, 18)
        .padding(.trailing, 17)
    }
}

struct PopupRatingModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onWriteReview: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    PopupRatingView(
                        onClose: dismiss,
                        onWriteReview: writeReview
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.2), value: isPresented)
    }

    private func dismiss() {
        isPresented = false
    }

    private func writeReview() {
        onWriteReview()
        isPresented = false
    }
}

extension View {
    func ratingPopup(
        isPresented: Binding<Bool>,
        onWriteReview: @escaping () -> Void
    ) -> some View {
        modifier(PopupRatingModifier(isPresented: isPresented, onWriteReview: onWriteReview))
    }
}

#Preview("Popup Rating") {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()

        PopupRatingView(
            onClose: {},
            onWriteReview: {}
        )
    }
}
