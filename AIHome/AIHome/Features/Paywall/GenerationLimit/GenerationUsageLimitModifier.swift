import SwiftUI

struct GenerationUsageLimitModifier: ViewModifier {
    @Binding var isPresented: Bool

    var placement: AdaptyPurchaseService.Placement = .limitToken

    @State private var isShowingPaywall = false

    func body(content: Content) -> some View {
        content
            .limitPopup(
                isPresented: $isPresented,
                kind: .limitReached,
                onUpgrade: {
                    isShowingPaywall = true
                }
            )
            .adaptyPaywall(isPresented: $isShowingPaywall, placement: placement)
    }
}

extension View {
    func generationUsageLimit(
        isPresented: Binding<Bool>,
        placement: AdaptyPurchaseService.Placement = .limitToken
    ) -> some View {
        modifier(GenerationUsageLimitModifier(isPresented: isPresented, placement: placement))
    }
}
