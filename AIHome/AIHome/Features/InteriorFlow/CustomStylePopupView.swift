import SwiftUI

struct CustomStylePopupView: View {
    @Binding var text: String
    let onClose: () -> Void
    let onApply: (String) -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.black.opacity(0.38)
                .ignoresSafeArea()

            popupCard
                .padding(.horizontal, 32)
        }
    }

    private var popupCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.black)
                    .clipShape(Circle())

                Text("Custom Style")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                    .foregroundColor(.DesignSystem.textPrimary)
                    .padding(.top, 18)

                customStyleTextEditor
                    .padding(.top, 30)

                Button(action: {
                    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedText.isEmpty else { return }
                    onApply(trimmedText)
                }) {
                    Text("Apply")
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 68)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 32)
            }
            .padding(.top, 48)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(Color.DesignSystem.coolGray)
                    .frame(width: 32, height: 32)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 24)
            .padding(.trailing, 24)
        }
        .background(Color.DesignSystem.background)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 28, x: 0, y: 16)
    }

    private var customStyleTextEditor: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.systemGray6))

            TextEditor(text: $text)
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 14))
                .foregroundColor(.DesignSystem.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 21)
                .padding(.vertical, 20)
                .onChange(of: text) { _, newValue in
                    if newValue.count > 150 {
                        text = String(newValue.prefix(150))
                    }
                }

            if text.isEmpty {
                Text("Describe your dream interior style\n(e.g. Modern Japanese Zen with\ndark wood accents)...")
                    .font(FontFamily.Roboto.medium.swiftUIFont(size: 14))
                    .foregroundColor(Color.DesignSystem.coolGray)
                    .lineSpacing(8)
                    .padding(.top, 25)
                    .padding(.leading, 21)
                    .allowsHitTesting(false)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(text.count)/150")
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                        .foregroundColor(Color.DesignSystem.coolGray.opacity(0.45))
                        .padding(.trailing, 28)
                        .padding(.bottom, 24)
                }
            }
        }
        .frame(height: 186)
        .padding(.horizontal, 32)
    }
}
