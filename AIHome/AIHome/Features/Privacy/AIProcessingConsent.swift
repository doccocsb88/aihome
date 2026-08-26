import SwiftUI

private enum AIProcessingConsentSheetMetrics {
    static let height: CGFloat = 390
}

enum AIProcessingConsentStore {
    private static let hasAcceptedKey = "privacy.aiProcessingConsent.hasAccepted"

    static var hasAccepted: Bool {
        UserDefaults.standard.bool(forKey: hasAcceptedKey)
    }

    static func accept() {
        UserDefaults.standard.set(true, forKey: hasAcceptedKey)
    }
}

struct AIProcessingConsentSheet: View {
    let onContinue: () -> Void
    let onCancel: () -> Void

    @State private var webPageToOpen: AppWebPage?

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 42, height: 5)
                .padding(.top, 6)

            VStack(spacing: 14) {
                Image(systemName: "wand.and.sparkles")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color.DesignSystem.textPrimary)

                Text(L10n.Privacy.AiProcessing.title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                    .foregroundStyle(Color.DesignSystem.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.Privacy.AiProcessing.message)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.DesignSystem.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(4)

                HStack(spacing: 4) {
                    Text(L10n.Privacy.AiProcessing.learnMore)
                        .font(FontFamily.Roboto.regular.swiftUIFont(size: 13))
                        .foregroundStyle(Color.DesignSystem.gray)

                    Button {
                        webPageToOpen = AppWebPage(title: L10n.Settings.privacyPolicy, url: AppConfig.URL.privacyPolicy)
                    } label: {
                        Text(L10n.Settings.privacyPolicy)
                            .font(FontFamily.Roboto.bold.swiftUIFont(size: 13))
                            .foregroundStyle(Color.DesignSystem.eerieBlack)
                            .underline()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Button {
                    AIProcessingConsentStore.accept()
                    onContinue()
                } label: {
                    Text(L10n.Privacy.AiProcessing.continue)
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                        .foregroundStyle(Color.DesignSystem.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.DesignSystem.eerieBlack, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    onCancel()
                } label: {
                    Text(L10n.Privacy.AiProcessing.cancel)
                        .font(FontFamily.Roboto.medium.swiftUIFont(size: 14))
                        .foregroundStyle(Color.DesignSystem.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .environment(\.isEnabled, true)
        .sheet(item: $webPageToOpen) { webPage in
            AppWebView(title: webPage.title, url: webPage.url)
        }
    }
}

private struct AIProcessingConsentSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onContinue: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GeometryReader { proxy in
                        ZStack(alignment: .bottom) {
                            Color.black.opacity(0.22)
                                .ignoresSafeArea()

                            Color.DesignSystem.background
                                .overlay(alignment: .top) {
                                    AIProcessingConsentSheet(
                                        onContinue: {
                                            isPresented = false
                                            onContinue()
                                        },
                                        onCancel: {
                                            isPresented = false
                                        }
                                    )
                                    .frame(height: AIProcessingConsentSheetMetrics.height, alignment: .top)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(
                                    height: AIProcessingConsentSheetMetrics.height + proxy.safeAreaInsets.bottom,
                                    alignment: .top
                                )
                                .clipShape(
                                    UnevenRoundedRectangle(
                                        cornerRadii: .init(
                                            topLeading: 36,
                                            bottomLeading: 0,
                                            bottomTrailing: 0,
                                            topTrailing: 36
                                        ),
                                        style: .continuous
                                    )
                                )
                                .ignoresSafeArea(edges: .bottom)
                        }
                        .ignoresSafeArea(edges: .bottom)
                        .transition(.opacity)
                        .zIndex(1)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.18), value: isPresented)
    }
}

extension View {
    func aiProcessingConsentSheet(isPresented: Binding<Bool>, onContinue: @escaping () -> Void) -> some View {
        modifier(AIProcessingConsentSheetModifier(isPresented: isPresented, onContinue: onContinue))
    }
}
