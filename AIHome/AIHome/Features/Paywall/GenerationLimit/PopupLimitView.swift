import SwiftUI

enum PopupLimitKind: Equatable {
    case generationsLeft(remaining: Int = 3, total: Int = 3)
    case limitReached

    var iconName: String {
        switch self {
        case .generationsLeft:
            "ic_generation_left"
        case .limitReached:
            "ic_limit_reached"
        }
    }

    var title: String {
        switch self {
        case let .generationsLeft(remaining, total):
            L10n.Limit.GenerationsLeft.title(remaining, total)
        case .limitReached:
            L10n.Limit.Reached.title
        }
    }

    var message: String {
        switch self {
        case .generationsLeft:
            L10n.Limit.GenerationsLeft.message
        case .limitReached:
            L10n.Limit.Reached.message
        }
    }

    var iconSize: CGSize {
        switch self {
        case .generationsLeft:
            CGSize(width: 96, height: 96)
        case .limitReached:
            CGSize(width: 90, height: 90)
        }
    }

    var iconTopPadding: CGFloat {
        switch self {
        case .generationsLeft:
            4
        case .limitReached:
            10
        }
    }

    var titleTopPadding: CGFloat {
        switch self {
        case .generationsLeft:
            26
        case .limitReached:
            24
        }
    }

    var messageTopPadding: CGFloat {
        switch self {
        case .generationsLeft:
            42
        case .limitReached:
            28
        }
    }

    var buttonTopPadding: CGFloat {
        switch self {
        case .generationsLeft:
            64
        case .limitReached:
            54
        }
    }
}

struct PopupLimitView: View {
    var kind: PopupLimitKind
    var onClose: () -> Void
    var onUpgrade: () -> Void

    var body: some View {
        ZStack {
            Color.DesignSystem.primary.opacity(0.34)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                closeButton

                Image(kind.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: kind.iconSize.width, height: kind.iconSize.height)
                    .padding(.top, kind.iconTopPadding)

                titleView
                    .padding(.top, kind.titleTopPadding)

                messageView
                    .padding(.top, kind.messageTopPadding)

                Button(action: onUpgrade) {
                    Text(L10n.Limit.upgradeNow)
                        .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.DesignSystem.folly)
                        )
                        .shadow(color: Color.DesignSystem.royalBlue.opacity(0.16), radius: 16, x: 0, y: 10)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Upgrade Now")
                .padding(.horizontal, 32)
                .padding(.top, kind.buttonTopPadding)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: 313)
            .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.DesignSystem.primary.opacity(0.22), radius: 28, x: 0, y: 18)
            .padding(.horizontal, 44)
            .accessibilityAddTraits(.isModal)
        }
    }

    private var titleView: some View {
        Text(kind.title)
            .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 24))
            .foregroundStyle(Color.DesignSystem.darkKnight)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .padding(.horizontal, 24)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var messageView: some View {
        Text(kind.message)
            .font(FontFamily.Inter24pt.regular.swiftUIFont(size: 14))
            .foregroundStyle(Color.DesignSystem.slateGray)
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            .padding(.horizontal, 34)
            .fixedSize(horizontal: false, vertical: true)
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

struct PopupLimitModifier: ViewModifier {
    @Binding var isPresented: Bool

    var kind: PopupLimitKind
    var onUpgrade: () -> Void

    func body(content: Content) -> some View {
        content
            .blur(radius: isPresented ? 6 : 0)
            .overlay {
                if isPresented {
                    PopupLimitView(
                        kind: kind,
                        onClose: dismiss,
                        onUpgrade: upgrade
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

    private func upgrade() {
        onUpgrade()
        isPresented = false
    }
}

extension View {
    func limitPopup(
        isPresented: Binding<Bool>,
        kind: PopupLimitKind,
        onUpgrade: @escaping () -> Void
    ) -> some View {
        modifier(PopupLimitModifier(isPresented: isPresented, kind: kind, onUpgrade: onUpgrade))
    }
}

#Preview("Generations Left") {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()

        PopupLimitView(
            kind: .generationsLeft(),
            onClose: {},
            onUpgrade: {}
        )
    }
}

#Preview("Limit Reached") {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()

        PopupLimitView(
            kind: .limitReached,
            onClose: {},
            onUpgrade: {}
        )
    }
}
