import SwiftUI

struct InspirationFilterView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: InspirationFilterViewModel
    var onApply: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            HStack(alignment: .center) {
                Text("Filters")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                    .foregroundStyle(Color.DesignSystem.textPrimary)

                Spacer()

                Button("Reset") {
                    viewModel.reset()
                }
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .foregroundStyle(Color.DesignSystem.slateGray)
            }
            .padding(.top, 24)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    FilterSection(title: "FAVOURITE") {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: !viewModel.showLikedOnly,
                            action: { viewModel.showLikedOnly = false }
                        )

                        FilterChip(
                            title: "Liked",
                            isSelected: viewModel.showLikedOnly,
                            action: { viewModel.showLikedOnly = true }
                        )
                    }
                }

                FilterSection(title: "INTERIOR SPACES") {
                    ChipFlow(spacing: 8, rowSpacing: 9) {
                        ForEach(viewModel.interiorSpaces, id: \.self) { space in
                            FilterChip(
                                title: space,
                                isSelected: viewModel.selectedInteriorSpace == space,
                                action: { viewModel.selectedInteriorSpace = space }
                            )
                        }
                    }
                }

                FilterSection(title: "EXTERIOR SPACES") {
                    ChipFlow(spacing: 8, rowSpacing: 9) {
                        ForEach(viewModel.exteriorSpaces, id: \.self) { space in
                            FilterChip(
                                title: space,
                                isSelected: viewModel.selectedExteriorSpace == space,
                                action: { viewModel.selectedExteriorSpace = space }
                            )
                        }
                    }
                }

                FilterSection(title: "GARDEN SPACES") {
                    ChipFlow(spacing: 8, rowSpacing: 9) {
                        ForEach(viewModel.gardenSpaces, id: \.self) { space in
                            FilterChip(
                                title: space,
                                isSelected: viewModel.selectedGardenSpace == space,
                                action: { viewModel.selectedGardenSpace = space }
                            )
                        }
                    }
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 50)
            }
            Button {
                if let onApply {
                    onApply()
                } else {
                    dismiss()
                }
            } label: {
                Text("Apply")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.16), radius: 22, x: 0, y: 12)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 32)
        .background(Color.DesignSystem.snow)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 34,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 34,
                style: .continuous
            )
        )
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color.DesignSystem.platinum)
            .frame(width: 48, height: 4)
            .padding(.top, 16)
    }
}

private struct FilterSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                .tracking(3)
                .foregroundStyle(Color.DesignSystem.slateGray)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                .foregroundStyle(isSelected ? .white : Color.DesignSystem.slateGray)
                .lineLimit(1)
                .padding(.horizontal, 17)
                .frame(height: 34)
                .background(
                    Capsule()
                        .fill(isSelected ? .black : Color.DesignSystem.alabaster)
                )
                .overlay {
                    Capsule()
                        .stroke(isSelected ? .black : Color.DesignSystem.platinum, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

private struct ChipFlow<Content: View>: View {
    let spacing: CGFloat
    let rowSpacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        FlowLayout(spacing: spacing, rowSpacing: rowSpacing) {
            content
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 0
        let rows = rows(for: subviews, maxWidth: maxWidth)
        let height = rows.reduce(CGFloat.zero) { partial, row in
            partial + row.height
        } + CGFloat(max(rows.count - 1, 0)) * rowSpacing

        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var origin = bounds.origin

        for row in rows(for: subviews, maxWidth: bounds.width) {
            origin.x = bounds.minX

            for item in row.items {
                item.subview.place(
                    at: origin,
                    proposal: ProposedViewSize(item.size)
                )
                origin.x += item.size.width + spacing
            }

            origin.y += row.height + rowSpacing
        }
    }

    private func rows(for subviews: Subviews, maxWidth: CGFloat) -> [FlowRow] {
        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextWidth = currentItems.isEmpty ? size.width : currentWidth + spacing + size.width

            if nextWidth > maxWidth, !currentItems.isEmpty {
                rows.append(FlowRow(items: currentItems, height: currentHeight))
                currentItems = [FlowItem(subview: subview, size: size)]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentItems.append(FlowItem(subview: subview, size: size))
                currentWidth = nextWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if !currentItems.isEmpty {
            rows.append(FlowRow(items: currentItems, height: currentHeight))
        }

        return rows
    }

    private struct FlowRow {
        let items: [FlowItem]
        let height: CGFloat
    }

    private struct FlowItem {
        let subview: LayoutSubview
        let size: CGSize
    }
}

#Preview {
    Color.gray.opacity(0.45)
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            InspirationFilterView(viewModel: InspirationFilterViewModel())
        }
}
