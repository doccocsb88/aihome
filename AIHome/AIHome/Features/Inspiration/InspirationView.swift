import SwiftUI

struct InspirationView: View {
    @State private var viewModel = InspirationViewModel()
    @Binding private var showingFilter: Bool
    @Binding private var showingDetail: Bool

    init(
        showingFilter: Binding<Bool> = .constant(false),
        showingDetail: Binding<Bool> = .constant(false)
    ) {
        _showingFilter = showingFilter
        _showingDetail = showingDetail
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: 30) {
                    VStack(spacing: 26) {
                        header
                        categoryTabs
                    }
                    .padding(.bottom, -4)

                    ForEach(viewModel.filteredItems) { item in
                        InspirationCardContainer(
                            item: item,
                            onLike: {
                                viewModel.toggleLike(for: item)
                            },
                            onOpenDetail: {
                                showingDetail = true
                            }
                        )
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 96)
            }

            filterButton
                .padding(.trailing, 24)
                .padding(.bottom, 16)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            showingDetail = false
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Inspiration")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.DesignSystem.textPrimary)

            Spacer()

            generationPill

            Text("PRO")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 52, height: 34)
                .background(Color(hex: "#FF2D5B"), in: Capsule())
        }
        .padding(.horizontal, 22)
    }

    private var categoryTabs: some View {
        HStack(spacing: 0) {
            ForEach(InspirationCategory.allCases) { category in
                Button {
                    viewModel.selectCategory(category)
                } label: {
                    Text(category.rawValue.uppercased())
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(viewModel.selectedCategory == category ? Color.DesignSystem.textPrimary : Color(hex: "#9CA3AF"))
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
        .background(Color(hex: "#F4F4F6"), in: Capsule())
        .padding(.horizontal, 22)
    }

    private var generationPill: some View {
        HStack(spacing: 5) {
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(hex: "#FF2D5B"))

            Text("3/3")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(hex: "#4B5563"))
        }
        .frame(width: 68, height: 34)
        .background(Color(hex: "#F4F4F6"), in: Capsule())
    }

    private var filterButton: some View {
        Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                showingFilter = true
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(Color(hex: "#FF2D5B"), in: Circle())
                .shadow(color: Color(hex: "#FF2D5B").opacity(0.35), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filter inspirations")
    }
}

private struct InspirationCardContainer: View {
    let item: InspirationItem
    let onLike: () -> Void
    let onOpenDetail: () -> Void

    var body: some View {
        NavigationLink {
            InspirationDetailView(viewModel: InspirationDetailViewModel(item: item))
                .onAppear(perform: onOpenDetail)
        } label: {
            InspirationCardContent(
                item: item,
                onLike: onLike
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded { onOpenDetail() })
    }
}

private struct InspirationCardContent: View {
    let item: InspirationItem
    let onLike: () -> Void

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
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.DesignSystem.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Button(action: onLike) {
                    Image(item.isLiked ? "ic_Inspiration_heart_02" : "ic_Inspiration_heart_01")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.isLiked ? "Unlike inspiration" : "Like inspiration")
            }

            Text(item.subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "#6B7280"))
                .lineSpacing(5)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            tagFlow
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
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(isProminent ? Color(hex: "#FF2D5B") : Color(hex: "#4B5563"))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isProminent ? Color(hex: "#FFEEF3") : Color(hex: "#F3F4F6"))
            )
    }
}

#Preview {
    NavigationStack {
        InspirationView()
    }
}
