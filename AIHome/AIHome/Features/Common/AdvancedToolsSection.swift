import SwiftUI

struct AdvancedToolsSection: View {
    let tools: [ProjectType]
    let onSelect: (ProjectType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Advanced Tools")
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 20))
                .foregroundStyle(Color.DesignSystem.textPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 24)

            ScrollView(.horizontal) {
                HStack(spacing: 18) {
                    ForEach(tools, id: \.self) { tool in
                        ProjectTypeToolCard(tool: tool) {
                            onSelect(tool)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity)
            .clipped()
        }
    }
}

private struct ProjectTypeToolCard: View {
    let tool: ProjectType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                toolIcon

                Text(tool.advancedToolTitle)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                    .foregroundStyle(Color.DesignSystem.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 19)
            .frame(height: 57)
            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.DesignSystem.platinum, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var toolIcon: some View {
        if let systemName = tool.advancedToolSystemIcon {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.DesignSystem.textPrimary)
                .frame(width: 22, height: 22)
        } else {
            Image(tool.advancedToolIconAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        }
    }
}

extension ProjectType {
    static let resultAdvancedTools: [ProjectType] = [
        .referenceStyle,
        .replaceObjects,
        .removeObjects,
        .newWalls,
        .newFlooring,
        .furnitureFinder
    ]

    var advancedToolTitle: String {
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
        case .furnitureFinder:
            "Furniture Finder"
        case .interior, .exterior, .garden:
            rawValue.capitalized
        }
    }

    var advancedToolIconAsset: String {
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
        case .interior, .exterior, .garden, .furnitureFinder:
            ""
        }
    }

    var advancedToolSystemIcon: String? {
        switch self {
        case .furnitureFinder:
            "magnifyingglass"
        case .interior, .exterior, .garden, .referenceStyle, .replaceObjects, .removeObjects, .newFlooring, .newWalls:
            nil
        }
    }
}
