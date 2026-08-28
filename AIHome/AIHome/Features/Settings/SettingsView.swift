import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var remoteConfigManager = RemoteConfigManager.shared
    @State private var viewModel = SettingsViewModel()
    @State private var webPageToOpen: AppWebPage?
    @State private var appCheckDebugMessage: String?

    private var appVersionText: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let currentYear = Calendar.current.component(.year, from: Date())
        return "\(shortVersion) (\(currentYear))"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Restore Purchase
                SettingRow(
                    icon: "arrow.2.circlepath",
                    title: viewModel.isRestoringPurchase ? L10n.Settings.restoring : L10n.Settings.restorePurchase,
                    action: {
                        TrackingManager.shared.trackRestorePurchase()
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
                            Text(languageManager.localizedName(forCode: languageManager.selectedLanguage).uppercased())
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
                            url: AppConfig.URL.privacyPolicy
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
                            url: AppConfig.URL.termsOfService
                        )
                    }
                )
                
                // Feedback
                SettingRow(
                    icon: "ellipsis.message.fill",
                    title: L10n.Settings.feedback,
                    action: { 
                        TrackingManager.shared.trackSendFeedback()
                        if let url = URL(string: "mailto:support@billionx.co") {
                            UIApplication.shared.open(url)
                        }
                    }
                )

#if DEBUG
                SettingRow(
                    icon: "checkmark.seal.fill",
                    title: "Test App Check",
                    action: {
                        Task {
                            if let token = await viewModel.fetchAppCheckToken() {
                                UIPasteboard.general.string = token
                                appCheckDebugMessage = "App Check token copied to clipboard."
                            } else {
                                appCheckDebugMessage = "Could not fetch App Check token."
                            }
                        }
                    }
                )
#endif
                
                // Footer
                VStack(spacing: 8) {
                    Text("HOMEGPT - AI INTERIOR DESIGN")
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                        .foregroundColor(.secondary)
                        .tracking(1.5)
                    Text(L10n.Settings.version(appVersionText))
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(L10n.Settings.title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
            }
        }
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
        .alert(
            "App Check",
            isPresented: Binding(
                get: { appCheckDebugMessage != nil },
                set: { if !$0 { appCheckDebugMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(appCheckDebugMessage ?? "")
        }
        .sheet(item: $webPageToOpen) { webPage in
            AppWebView(title: webPage.title, url: webPage.url)
        }
        .onAppear {
            TrackingManager.shared.trackScreen(.settings)
            viewModel.syncProviderFromRemoteDefault()
        }
        .onChange(of: remoteConfigManager.homeGPTProviderKind) { _, _ in
            viewModel.syncProviderFromRemoteDefault()
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
