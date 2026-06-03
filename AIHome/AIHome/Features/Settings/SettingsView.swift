import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Restore Purchase
                SettingRow(
                    icon: "arrow.2.circlepath",
                    title: "Restore Purchase",
                    action: { viewModel.restorePurchase() }
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
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(viewModel.selectedLanguage.uppercased())
                                .font(.system(size: 12))
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
                            .stroke(Color(hex: "#F3F4F6"), lineWidth: 1)
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
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .tracking(1.5)
                    Text("Version 2.4.0 (2026)")
                        .font(.caption2)
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(uiColor: .systemGray3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: "#F3F4F6"), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color(uiColor: .systemBackground)))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
