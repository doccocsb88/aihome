import SwiftUI
import UIKit

struct InspirationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @State var viewModel: InspirationDetailViewModel
    @State private var showingBefore = false

    private let advancedTools: [ProjectType] = [
        .referenceStyle,
        .replaceObjects,
        .removeObjects,
        .newWalls,
        .newFlooring
    ]

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    hero(width: proxy.size.width, height: max(proxy.size.height * 0.575, 490))
                    actionPanel
                        .frame(width: proxy.size.width)
                        .frame(minHeight: max(proxy.size.height * 0.425, 360), alignment: .top)
                }
                .frame(width: proxy.size.width)
            }
            .scrollIndicators(.hidden)
            .background(.white)
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func hero(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(showingBefore ? viewModel.item.beforeImageName : viewModel.item.afterImageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()

            LinearGradient(
                colors: [
                    .black.opacity(0.04),
                    .black.opacity(0.1),
                    .black.opacity(0.55)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            heroControls
                .frame(maxHeight: .infinity, alignment: .top)

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.item.title.capitalized)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 25))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: width - 70, alignment: .leading)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

                Text("\(viewModel.item.styleTag.uppercased())  ·  \(viewModel.item.spaceType.uppercased())")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 11))
                    .tracking(4.2)
                    .foregroundStyle(.white.opacity(0.74))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: width - 70, alignment: .leading)
            }
            .padding(.horizontal, 35)
            .padding(.bottom, 35)
        }
        .frame(width: width, height: height)
        .clipped()
    }

    private var heroControls: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.DesignSystem.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.88), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    showingBefore.toggle()
                }
            } label: {
                Image(showingBefore ? "ic_after" : "ic_before")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.88), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showingBefore ? "Show after image" : "Show before image")
        }
        .padding(.horizontal, 28)
        .padding(.top, 54)
    }

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            AdvancedToolsSection(
                tools: advancedTools,
                onSelect: handleNavigation
            )

            Spacer(minLength: 42)

            Text("OR")
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 11))
                .tracking(4)
                .foregroundStyle(Color.DesignSystem.inspirationBody)
                .frame(maxWidth: .infinity)

            NavigationLink {
                redesignDestination
            } label: {
                Text("REDESIGN")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 13))
                    .tracking(5)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 14)
            }
            .simultaneousGesture(TapGesture().onEnded {
                AppLogger.logAction("Inspiration Redesign", details: viewModel.item.id)
            })
            .buttonStyle(.plain)
            .padding(.horizontal, 35)
            .padding(.top, 64)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity)
        }
        .background(.white)
        .clipped()
    }

    private func handleNavigation(for tool: ProjectType) {
        AppLogger.logAction("Inspiration Advanced Tool", details: tool.inspirationToolTitle)

        switch tool {
        case .interior:
            coordinator.push(.interiorFlow)
        case .exterior:
            coordinator.push(.exteriorFlow)
        case .garden:
            coordinator.push(.gardenFlow)
        case .referenceStyle:
            coordinator.push(.referenceStyleFlow)
        case .removeObjects:
            coordinator.push(.removeObjectsFlow)
        case .replaceObjects:
            coordinator.push(.replaceObjectsFlow)
        case .newFlooring:
            coordinator.push(.newFlooringFlow)
        case .newWalls:
            coordinator.push(.newWallsFlow)
        }
    }

    @ViewBuilder
    private var redesignDestination: some View {
        let beforeImage = UIImage(named: viewModel.item.beforeImageName)

        switch viewModel.item.category {
        case .interior:
            InteriorFlowContainerView(initialImage: beforeImage)
        case .exterior:
            ExteriorFlowContainerView(initialImage: beforeImage)
        case .garden:
            GardenFlowContainerView(initialImage: beforeImage)
        }
    }
}

private struct AdvancedToolsSection: View {
    let tools: [ProjectType]
    let onSelect: (ProjectType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ADVANCED TOOLS")
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 11))
                .tracking(4)
                .foregroundStyle(Color.DesignSystem.inspirationBody)
                .padding(.horizontal, 35)
                .padding(.top, 35)

            ScrollView(.horizontal) {
                HStack(spacing: 18) {
                    ForEach(tools, id: \.self) { tool in
                        AdvancedToolCard(tool: tool) {
                            onSelect(tool)
                        }
                    }
                }
                .padding(.horizontal, 35)
                .padding(.vertical, 27)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity)
            .clipped()
        }
    }
}

private struct AdvancedToolCard: View {
    let tool: ProjectType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                Image(tool.inspirationToolIconAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)

                Text(tool.inspirationToolTitle)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                    .foregroundStyle(Color.DesignSystem.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 19)
            .frame(height: 57)
            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.DesignSystem.inspirationBorder, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private extension ProjectType {
    var inspirationToolTitle: String {
        switch self {
        case .referenceStyle:
            "Reference"
        case .replaceObjects:
            "Replace"
        case .removeObjects:
            "Remove"
        case .newWalls:
            "New Wall"
        case .newFlooring:
            "New Flooring"
        case .interior, .exterior, .garden:
            rawValue.capitalized
        }
    }

    var inspirationToolIconAsset: String {
        switch self {
        case .referenceStyle:
            "ic_inspiration_tool_reference"
        case .replaceObjects:
            "ic_inspiration_tool_replace"
        case .removeObjects:
            "ic_inspiration_tool_remove"
        case .newWalls:
            "ic_inspiration_tool_newwall"
        case .newFlooring:
            "ic_inspiration_tool_newflooring"
        case .interior, .exterior, .garden:
            ""
        }
    }
}

#Preview {
    NavigationStack {
        InspirationDetailView(
            viewModel: InspirationDetailViewModel(
                item: InspirationItem(
                    id: "preview",
                    category: .interior,
                    spaceType: "Workspace",
                    styleTag: "Scandinavian",
                    beforeImageName: "interior_03_before",
                    afterImageName: "interior_03_after",
                    title: "Stockholm Studio",
                    subtitle: "Clean Nordic minimalism infused with a refreshing, luminous water-inspired tint.",
                    interventionLevel: .medium,
                    isLiked: false
                )
            )
        )
    }
}
