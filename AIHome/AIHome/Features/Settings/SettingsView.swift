import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Restore Purchase
                SettingRow(
                    icon: "arrow.2.circlepath",
                    title: viewModel.isRestoringPurchase ? "Restoring..." : "Restore Purchase",
                    action: {
                        Task {
                            await viewModel.restorePurchase()
                        }
                    }
                )
                
                // Language
                Button(action: {
                    // Open language picker
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "globe")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Color(uiColor: .systemGray6))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Language")
                                .font(FontFamily.Roboto.medium.swiftUIFont(size: 16))
                                .foregroundColor(.primary)
                            Text(viewModel.selectedLanguage.uppercased())
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
                    title: "Privacy Policy",
                    action: { viewModel.openPrivacyPolicy() }
                )
                
                // Terms of Service
                SettingRow(
                    icon: "doc.text.fill",
                    title: "Terms of Service",
                    action: { viewModel.openTermsOfService() }
                )
                
                // Feedback
                SettingRow(
                    icon: "ellipsis.message.fill",
                    title: "Feedback",
                    action: { viewModel.sendFeedback() }
                )
                
                // Footer
                VStack(spacing: 8) {
                    Text("HOMEGPT - AI INTERIOR DESIGN")
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                        .foregroundColor(.secondary)
                        .tracking(1.5)
                    Text("Version 2.4.0 (2026)")
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
        .navigationTitle("Setting")
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
