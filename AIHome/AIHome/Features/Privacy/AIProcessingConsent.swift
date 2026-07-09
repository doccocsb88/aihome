import SwiftUI

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

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 42, height: 5)
                .padding(.top, 12)

            VStack(spacing: 14) {
                Image(systemName: "wand.and.sparkles")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color.DesignSystem.textPrimary)

                Text(L10n.Privacy.AiProcessing.title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                    .foregroundStyle(Color.DesignSystem.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.Privacy.AiProcessing.message)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                    .foregroundStyle(Color.DesignSystem.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Button {
                    AIProcessingConsentStore.accept()
                    dismiss()
                    onContinue()
                } label: {
                    Text(L10n.Privacy.AiProcessing.continue)
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                        .foregroundStyle(Color.DesignSystem.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.DesignSystem.textPrimary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
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
            .padding(.bottom, 24)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .presentationDetents([.height(380)])
        .presentationDragIndicator(.hidden)
    }
}

private struct AIProcessingConsentSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onContinue: () -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                AIProcessingConsentSheet(onContinue: onContinue)
            }
    }
}

extension View {
    func aiProcessingConsentSheet(isPresented: Binding<Bool>, onContinue: @escaping () -> Void) -> some View {
        modifier(AIProcessingConsentSheetModifier(isPresented: isPresented, onContinue: onContinue))
    }
}
