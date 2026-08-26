import SwiftUI

struct InspirationFilterView: View {
    enum ContentStyle {
        case spaces
        case historyFeatures
    }

    @Environment(\.dismiss) private var dismiss
    var viewModel: InspirationFilterViewModel
    var contentStyle: ContentStyle = .spaces
    var showsOtherSpaces: Bool = true
    var onApply: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            HStack(alignment: .center) {
                Text(L10n.InspirationFilter.title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                    .foregroundStyle(Color.DesignSystem.textPrimary)

                Spacer()

                Button(L10n.InspirationFilter.reset) {
                    viewModel.reset()
                }
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .foregroundStyle(Color.DesignSystem.slateGray)
            }
            .padding(.top, 24)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    FilterSection(title: L10n.InspirationFilter.favourite) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: L10n.InspirationFilter.all,
                            isSelected: !viewModel.showLikedOnly,
                            action: { viewModel.showLikedOnly = false }
                        )

                        FilterChip(
                            title: L10n.InspirationFilter.liked,
                            isSelected: viewModel.showLikedOnly,
                            action: { viewModel.showLikedOnly = true }
                        )
                    }
                }

                switch contentStyle {
                case .spaces:
                    FilterSection(title: L10n.InspirationFilter.interiorSpaces) {
                        ChipFlow(spacing: 8, rowSpacing: 9) {
                            ForEach(viewModel.interiorSpaces, id: \.self) { space in
                                FilterChip(
                                    title: localizedSpaceTitle(space),
                                    isSelected: viewModel.selectedInteriorSpace == space,
                                    action: { viewModel.selectedInteriorSpace = space }
                                )
                            }
                        }
                    }

                    FilterSection(title: L10n.InspirationFilter.exteriorSpaces) {
                        ChipFlow(spacing: 8, rowSpacing: 9) {
                            ForEach(viewModel.exteriorSpaces, id: \.self) { space in
                                FilterChip(
                                    title: localizedSpaceTitle(space),
                                    isSelected: viewModel.selectedExteriorSpace == space,
                                    action: { viewModel.selectedExteriorSpace = space }
                                )
                            }
                        }
                    }

                    FilterSection(title: L10n.InspirationFilter.gardenSpaces) {
                        ChipFlow(spacing: 8, rowSpacing: 9) {
                            ForEach(viewModel.gardenSpaces, id: \.self) { space in
                                FilterChip(
                                    title: localizedSpaceTitle(space),
                                    isSelected: viewModel.selectedGardenSpace == space,
                                    action: { viewModel.selectedGardenSpace = space }
                                )
                            }
                        }
                    }

                    if showsOtherSpaces {
                        FilterSection(title: L10n.InspirationFilter.otherSpaces) {
                            ChipFlow(spacing: 8, rowSpacing: 9) {
                                ForEach(viewModel.otherSpaces, id: \.self) { space in
                                    FilterChip(
                                        title: localizedSpaceTitle(space),
                                        isSelected: viewModel.selectedOtherSpace == space,
                                        action: { viewModel.selectedOtherSpace = space }
                                    )
                                }
                            }
                        }
                    }
                case .historyFeatures:
                    FilterSection(title: L10n.InspirationFilter.features) {
                        ChipFlow(spacing: 8, rowSpacing: 9) {
                            ForEach(viewModel.historyFeatures, id: \.self) { feature in
                                FilterChip(
                                    title: feature.historyFilterTitle,
                                    isSelected: viewModel.selectedFeature == feature,
                                    action: {
                                        viewModel.selectedFeature = viewModel.selectedFeature == feature ? nil : feature
                                    }
                                )
                            }
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
                Text(L10n.InspirationFilter.apply)
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

    private func localizedSpaceTitle(_ space: String) -> String {
        switch space {
        case "All":
            return L10n.InspirationFilter.all
        case "Living room":
            return L10n.InspirationFilter.Space.livingRoom
        case "Bathroom":
            return L10n.InspirationFilter.Space.bathroom
        case "Bedroom":
            return L10n.InspirationFilter.Space.bedroom
        case "Toilet":
            return L10n.InspirationFilter.Space.toilet
        case "Kitchen":
            return L10n.InspirationFilter.Space.kitchen
        case "Garden":
            return L10n.InspirationFilter.Space.garden
        case "Villa":
            return L10n.InspirationFilter.Space.villa
        case "Backyard":
            return L10n.InspirationFilter.Space.backyard
        case "Pool":
            return L10n.InspirationFilter.Space.pool
        case "Courtyard":
            return L10n.InspirationFilter.Space.courtyard
        case "Reference Style":
            return L10n.Home.Tool.ReferenceStyle.title
        case "Replace Objects":
            return L10n.Home.Tool.ReplaceObjects.title
        case "Remove Objects":
            return L10n.Home.Tool.RemoveObjects.title
        case "New Flooring":
            return L10n.Home.Tool.NewFlooring.title
        case "New Walls":
            return L10n.Home.Tool.NewWalls.title
        case "Furniture Finder":
            return L10n.InspirationFilter.Feature.furnitureFinder
        case "Edit":
            return L10n.InspirationFilter.Feature.edit
        default:
            return space
        }
    }
}

struct InspirationFilterOverlay: View {
    var viewModel: InspirationFilterViewModel
    var contentStyle: InspirationFilterView.ContentStyle = .spaces
    var showsOtherSpaces: Bool = true
    @Binding var isPresented: Bool

    @State private var draftViewModel: InspirationFilterViewModel
    @State private var dragOffset: CGFloat = 0

    init(
        viewModel: InspirationFilterViewModel,
        contentStyle: InspirationFilterView.ContentStyle = .spaces,
        showsOtherSpaces: Bool = true,
        isPresented: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self.contentStyle = contentStyle
        self.showsOtherSpaces = showsOtherSpaces
        _isPresented = isPresented
        _draftViewModel = State(initialValue: viewModel.makeDraft())
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(.black.opacity(0.45))
                    .opacity(1.0 - Double(dragOffset / 400.0))
                    .ignoresSafeArea()
                    .onTapGesture {
                        close()
                    }

                InspirationFilterView(
                    viewModel: draftViewModel,
                    contentStyle: contentStyle,
                    showsOtherSpaces: showsOtherSpaces,
                    onApply: applyAndClose
                )
                .frame(maxWidth: .infinity)
                .frame(height: sheetHeight + proxy.safeAreaInsets.bottom)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 150 || value.velocity.height > 500 {
                                close()
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            draftViewModel.copyValues(from: viewModel)
        }
    }

    private func applyAndClose() {
        viewModel.copyValues(from: draftViewModel)
        close()
    }

    private var sheetHeight: CGFloat {
        switch contentStyle {
        case .spaces:
            678
        case .historyFeatures:
            560
        }
    }

    private func close() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            isPresented = false
            dragOffset = 0
        }
    }
}

extension ProjectType {
    var historyFilterTitle: String {
        switch self {
        case .interior: L10n.InspirationFilter.Feature.interiorRedesign
        case .exterior: L10n.ExteriorFlow.title
        case .garden: L10n.Home.Tool.Garden.title
        case .referenceStyle: L10n.Home.Tool.ReferenceStyle.title
        case .replaceObjects: L10n.Home.Tool.ReplaceObjects.title
        case .removeObjects: L10n.Home.Tool.RemoveObjects.title
        case .newFlooring: L10n.Home.Tool.NewFlooring.title
        case .newWalls: L10n.Home.Tool.NewWalls.title
        case .furnitureFinder: L10n.InspirationFilter.Feature.furnitureFinder
        case .edit: L10n.InspirationFilter.Feature.edit
        }
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
