import SwiftUI
import StoreKit

enum PopupRatingKind {
    case homeEnjoyment
    case resultFeedback

    var title: String {
        switch self {
        case .homeEnjoyment:
            "Enjoying HomeGPT?"
        case .resultFeedback:
            "Your feedback =\nbetter designs"
        }
    }

    var message: String {
        switch self {
        case .homeEnjoyment:
            "Rate your experience and help us build the future of AI home design. It only takes a second!"
        case .resultFeedback:
            "We'd love to hear your thoughts! If you're enjoying the transformations, please consider leaving a rating. Your feedback helps us build a more powerful AI experience for you."
        }
    }

    var buttonTitle: String {
        switch self {
        case .homeEnjoyment:
            "Rate on App Store"
        case .resultFeedback:
            "Write a Review"
        }
    }

    var showsButtonIcon: Bool {
        switch self {
        case .homeEnjoyment:
            false
        case .resultFeedback:
            true
        }
    }

    var cardMaxWidth: CGFloat {
        switch self {
        case .homeEnjoyment:
            345
        case .resultFeedback:
            313
        }
    }

    var titleFontSize: CGFloat {
        switch self {
        case .homeEnjoyment:
            18
        case .resultFeedback:
            24
        }
    }

    var messageHorizontalPadding: CGFloat {
        switch self {
        case .homeEnjoyment:
            42
        case .resultFeedback:
            34
        }
    }

    var outerHorizontalPadding: CGFloat {
        switch self {
        case .homeEnjoyment:
            24
        case .resultFeedback:
            44
        }
    }

    var buttonHorizontalPadding: CGFloat {
        switch self {
        case .homeEnjoyment:
            32
        case .resultFeedback:
            32
        }
    }
}

struct PopupRatingView: View {
    var kind: PopupRatingKind = .resultFeedback
    var onClose: () -> Void
    var onRateOnStore: () -> Void
    var onSelectRating: (Int) -> Void

    var body: some View {
        ZStack {
            Color.DesignSystem.primary.opacity(0.34)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                closeButton

                Image("ic_rating_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48, alignment: .center)
                    .frame(width: 80, height: 80, alignment: .center)
                    .background(Color.DesignSystem.mistyRose, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.top, kind == .homeEnjoyment ? 10 : 8)

                if kind == .homeEnjoyment {
                    titleView
                        .padding(.top, 24)

                    messageView
                        .padding(.top, 16)

                    starsView
                        .padding(.top, 28)
                } else {
                    titleView
                        .padding(.top, 26)

                    starsView
                        .padding(.top, 20)

                    messageView
                        .padding(.top, 23)
                }

                Button(action: onRateOnStore) {
                    buttonContent
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: kind == .homeEnjoyment ? 58 : 64)
                        .background(
                            RoundedRectangle(cornerRadius: kind == .homeEnjoyment ? 16 : 18, style: .continuous)
                                .fill(Color.DesignSystem.folly)
                        )
                        .shadow(color: Color.DesignSystem.folly.opacity(0.28), radius: 13, x: 0, y: 10)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(kind.buttonTitle)
                .padding(.horizontal, kind.buttonHorizontalPadding)
                .padding(.top, kind == .homeEnjoyment ? 30 : 34)
                .padding(.bottom, kind == .homeEnjoyment ? 32 : 32)
            }
            .frame(maxWidth: kind.cardMaxWidth)
            .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.DesignSystem.primary.opacity(0.22), radius: 28, x: 0, y: 18)
            .padding(.horizontal, kind.outerHorizontalPadding)
            .accessibilityAddTraits(.isModal)
        }
    }

    private var titleView: some View {
        Text(kind.title)
            .font(FontFamily.Inter24pt.bold.swiftUIFont(size: kind.titleFontSize))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.DesignSystem.primary)
            .lineSpacing(2)
            .padding(.horizontal, 20)
    }

    private var messageView: some View {
        Text(kind.message)
            .font(FontFamily.Inter24pt.regular.swiftUIFont(size: kind == .homeEnjoyment ? 13 : 14))
            .foregroundStyle(Color.DesignSystem.primary.opacity(0.58))
            .multilineTextAlignment(.center)
            .lineSpacing(kind == .homeEnjoyment ? 5 : 6)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, kind.messageHorizontalPadding)
    }

    private var starsView: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { rating in
                Button {
                    onSelectRating(rating)
                } label: {
                    Image("ic_rating_star")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(Color.DesignSystem.cyberYellow)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(rating) star rating")
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Five star rating")
    }

    private var buttonContent: some View {
        HStack(spacing: 11) {
            if kind.showsButtonIcon {
                Image("ic_rating_edit")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }

            Text(kind.buttonTitle)
                .font(FontFamily.Inter24pt.bold.swiftUIFont(size: kind == .homeEnjoyment ? 16 : 18))
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
    @AppStorage("popupRating.hasCompletedRating") private var hasCompletedRating = false
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    var kind: PopupRatingKind
    var onWriteReview: () -> Void

    private var shouldPresent: Bool {
        isPresented && !hasCompletedRating
    }

    func body(content: Content) -> some View {
        content
            .blur(radius: shouldPresent ? 6 : 0)
            .overlay {
                if shouldPresent {
                    PopupRatingView(
                        kind: kind,
                        onClose: dismiss,
                        onRateOnStore: rateOnStore,
                        onSelectRating: completeRating
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.2), value: shouldPresent)
    }

    private func dismiss() {
        isPresented = false
    }

    private func rateOnStore() {
        completeRating(5)
    }

    private func completeRating(_ rating: Int) {
        onWriteReview()
        hasCompletedRating = true
        isPresented = false

        if rating >= 4 {
            requestReview()
        } else {
            openFeedbackEmail(for: rating)
        }
    }

    private func openFeedbackEmail(for rating: Int) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "support@billionx.co"
        components.queryItems = [
            URLQueryItem(name: "subject", value: "HomeGPT feedback"),
            URLQueryItem(name: "body", value: "Rating: \(rating)/5\n\nFeedback:")
        ]

        if let url = components.url {
            openURL(url)
        }
    }
}

extension View {
    func ratingPopup(
        isPresented: Binding<Bool>,
        kind: PopupRatingKind = .resultFeedback,
        onWriteReview: @escaping () -> Void
    ) -> some View {
        modifier(PopupRatingModifier(isPresented: isPresented, kind: kind, onWriteReview: onWriteReview))
    }
}

#Preview("Result Rating") {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()

        PopupRatingView(
            kind: .resultFeedback,
            onClose: {},
            onRateOnStore: {},
            onSelectRating: { _ in }
        )
    }
}

#Preview("Home Rating") {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()

        PopupRatingView(
            kind: .homeEnjoyment,
            onClose: {},
            onRateOnStore: {},
            onSelectRating: { _ in }
        )
    }
}
