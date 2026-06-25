import SwiftUI

struct InspirationView: View {
    @State private var viewModel = InspirationViewModel()
    @State private var showingFilter = false
    @State private var selectedItem: InspirationItem?
    @Binding private var showingDetail: Bool
    private let onFilterPresentationChanged: (Bool) -> Void

    init(
        showingDetail: Binding<Bool> = .constant(false),
        onFilterPresentationChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        _showingDetail = showingDetail
        self.onFilterPresentationChanged = onFilterPresentationChanged
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                VStack(spacing: 26) {
                    header
                    categoryTabs
                }
                .padding(.bottom, 24)
                
                ScrollView {
                    LazyVStack(spacing: 30) {
                        ForEach(viewModel.filteredItems) { item in
                            InspirationCardContainer(
                                item: item,
                                onLike: {
                                    viewModel.toggleLike(for: item)
                                },
                                onOpenDetail: {
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                                        showingDetail = true
                                    }
                                    selectedItem = item
                                }
                            )
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 96)
                }
            }

            filterButton
                .padding(.trailing, 24)
                .padding(.bottom, 80)

            if showingFilter {
                InspirationFilterOverlay(
                    viewModel: viewModel.filter,
                    showsOtherSpaces: false,
                    isPresented: $showingFilter
                )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                    .onAppear {
                        onFilterPresentationChanged(true)
                    }
                    .onDisappear {
                        onFilterPresentationChanged(false)
                    }
            }
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: detailPresentation) {
            if let selectedItem {
                InspirationDetailView(viewModel: InspirationDetailViewModel(item: selectedItem))
            }
        }
        .onAppear {
            showingDetail = false
        }
        .onDisappear {
            onFilterPresentationChanged(false)
        }
    }

    private var header: some View {
        MainTabHeaderView(title: L10n.Inspiration.title, titleSize: 32)
            .padding(.top, 16)
    }

    private var categoryTabs: some View {
        HStack(spacing: 0) {
            ForEach(InspirationCategory.allCases) { category in
                Button {
                    viewModel.selectCategory(category)
                } label: {
                    Text(category.rawValue.uppercased())
                        .font(FontFamily.Roboto.black.swiftUIFont(size: 12))
                        .foregroundStyle(viewModel.selectedCategory == category ? Color.DesignSystem.textPrimary : Color.DesignSystem.coolGray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedCategory == category ? .white : .clear)
                                .shadow(color: viewModel.selectedCategory == category ? .black.opacity(0.08) : .clear, radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.DesignSystem.cultured, in: Capsule())
        .padding(.horizontal, 22)
    }

    private var filterButton: some View {
        FloatingFilterButton {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                showingFilter = true
            }
        }
    }

    private var detailPresentation: Binding<Bool> {
        Binding(
            get: { selectedItem != nil },
            set: { isPresented in
                if !isPresented {
                    selectedItem = nil
                    showingDetail = false
                }
            }
        )
    }
}

private struct InspirationCardContainer: View {
    let item: InspirationItem
    let onLike: () -> Void
    let onOpenDetail: () -> Void

    var body: some View {
        InspirationCardContent(
            item: item,
            onLike: onLike,
            onOpenDetail: onOpenDetail
        )
    }
}

private struct InspirationCardContent: View {
    let item: InspirationItem
    let onLike: () -> Void
    let onOpenDetail: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = max(proxy.size.width - 48, 0)

            HStack(spacing: 0) {
                Spacer(minLength: 24)

                cardBody(width: cardWidth)

                Spacer(minLength: 24)
            }
        }
        .frame(height: 480)
    }

    private func cardBody(width: CGFloat) -> some View {
        Image(item.afterImageName)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: 480)
            .clipped()
            .contentShape(.rect)
            .onTapGesture(perform: onOpenDetail)
            .overlay(alignment: .bottom) {
                infoPanel
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .clipShape(.rect(cornerRadius: 40, style: .continuous))
            .shadow(color: .black.opacity(0.14), radius: 20, x: 0, y: 14)
    }

    private var infoPanel: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 12) {
                Text(item.title.capitalized)
                    .font(FontFamily.Roboto.black.swiftUIFont(size: 20))
                    .foregroundStyle(Color.DesignSystem.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentShape(.rect)
                    .onTapGesture(perform: onOpenDetail)

                Spacer(minLength: 8)

                Button(action: onLike) {
                    Image(item.isLiked ? "ic_Inspiration_heart_02" : "ic_Inspiration_heart_01")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.isLiked ? L10n.Inspiration.unlike : L10n.Inspiration.like)
            }

            Text(item.subtitle)
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 13))
                .foregroundStyle(Color.DesignSystem.slateGray)
                .lineSpacing(5)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(.rect)
                .onTapGesture(perform: onOpenDetail)

            tagFlow
                .contentShape(.rect)
                .onTapGesture(perform: onOpenDetail)
        }
        .padding(.leading, 24)
        .padding(.trailing, 18)
        .padding(.top, 22)
        .padding(.bottom, 22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
    }

    private var tagFlow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                InspirationTag(title: item.styleTag)
                InspirationTag(title: item.spaceType)
            }

            VStack(alignment: .leading, spacing: 8) {
                InspirationTag(title: item.styleTag)
                InspirationTag(title: item.spaceType)
            }
        }
    }
}

private struct InspirationTag: View {
    let title: String
    var isProminent = false

    var body: some View {
        Text(title.uppercased())
            .font(FontFamily.Roboto.black.swiftUIFont(size: 10))
            .foregroundStyle(isProminent ? Color.DesignSystem.amaranth : Color.DesignSystem.darkSlate)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isProminent ? Color.DesignSystem.lavenderBlush : Color.DesignSystem.brightGray)
            )
    }
}

#Preview {
    NavigationStack {
        InspirationView()
    }
}
