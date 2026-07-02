import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var webPageToOpen: AppWebPage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Restore Purchase
                SettingRow(
                    icon: "arrow.2.circlepath",
                    title: viewModel.isRestoringPurchase ? L10n.Settings.restoring : L10n.Settings.restorePurchase,
                    action: {
                        Task {
                            await viewModel.restorePurchase()
                        }
                    }
                )
                
                // Language
                NavigationLink(destination: LanguageView()) {
                    HStack(spacing: 16) {
                        Image(systemName: "globe")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Color(uiColor: .systemGray6))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Settings.language)
                                .font(FontFamily.Roboto.medium.swiftUIFont(size: 16))
                                .foregroundColor(.primary)
                            Text(LanguageManager.shared.localizedName(forCode: viewModel.selectedLanguage).uppercased())
                                .font(FontFamily.Roboto.regular.swiftUIFont(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(uiColor: .systemGray3))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.DesignSystem.brightGray, lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 24).fill(Color(uiColor: .systemBackground)))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Privacy Policy
                SettingRow(
                    icon: "checkmark.shield.fill",
                    title: L10n.Settings.privacyPolicy,
                    action: { 
                        webPageToOpen = AppWebPage(
                            title: "Privacy Policy",
                            url: URL(string: "https://sites.google.com/billionx.co/homegpt-privacy-policy")!
                        )
                    }
                )
                
                // Terms of Service
                SettingRow(
                    icon: "doc.text.fill",
                    title: L10n.Settings.termsOfService,
                    action: { 
                        webPageToOpen = AppWebPage(
                            title: "Terms of Service",
                            url: URL(string: "https://sites.google.com/billionx.co/homegpt-tos")!
                        )
                    }
                )
                
                // Feedback
                SettingRow(
                    icon: "ellipsis.message.fill",
                    title: L10n.Settings.feedback,
                    action: { 
                        if let url = URL(string: "mailto:support@billionx.co") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
                
                // Footer
                VStack(spacing: 8) {
                    Text("HOMEGPT - AI INTERIOR DESIGN")
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                        .foregroundColor(.secondary)
                        .tracking(1.5)
                    Text(L10n.Settings.version("2.4.0 (2026)"))
                        .font(FontFamily.Roboto.regular.swiftUIFont(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle(L10n.Settings.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Restore Purchase",
            isPresented: Binding(
                get: { viewModel.purchaseMessage != nil },
                set: { if !$0 { viewModel.purchaseMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.purchaseMessage ?? "")
        }
        .sheet(item: $webPageToOpen) { webPage in
            AppWebView(title: webPage.title, url: webPage.url)
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(Circle())
                
                Text(title)
                    .font(FontFamily.Roboto.medium.swiftUIFont(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(uiColor: .systemGray3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.DesignSystem.brightGray, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color(uiColor: .systemBackground)))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
