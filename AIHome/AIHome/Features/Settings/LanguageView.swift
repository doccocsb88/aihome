import SwiftUI

struct LanguageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var languageManager
    @State private var pendingLanguage = LanguageManager.shared.selectedLanguage

    private var hasPendingChanges: Bool {
        pendingLanguage != languageManager.selectedLanguage
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .stroke(Color.DesignSystem.brightGray, lineWidth: 1)
                        )
                }
                
                Spacer()
                
                Text(L10n.Language.title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 20))
                    .foregroundColor(Color.DesignSystem.textPrimary)
                
                Spacer()

                Button(L10n.Language.save) {
                    languageManager.applyLanguage(pendingLanguage)
                    dismiss()
                }
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 16))
                .foregroundColor(hasPendingChanges ? Color.DesignSystem.folly : Color.DesignSystem.slateGray)
                .disabled(!hasPendingChanges)
                .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
            
            // List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(languageManager.availableLanguages) { language in
                        Button(action: {
                            pendingLanguage = language.code
                        }) {
                            HStack {
                                Text(languageManager.localizedName(for: language))
                                    .font(FontFamily.Roboto.medium.swiftUIFont(size: 16))
                                    .foregroundColor(Color.DesignSystem.textPrimary)
                                
                                Spacer()
                                
                                if pendingLanguage == language.code {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.DesignSystem.folly)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(uiColor: .systemGray3))
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 68)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.DesignSystem.brightGray, lineWidth: 1)
                                    .background(RoundedRectangle(cornerRadius: 24).fill(Color(uiColor: .systemBackground)))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .background(Color(uiColor: .systemBackground))
        .onAppear {
            pendingLanguage = languageManager.selectedLanguage
        }
    }
}

#Preview {
    LanguageView()
}
