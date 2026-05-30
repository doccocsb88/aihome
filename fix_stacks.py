import os

paths = [
    "AIHome/AIHome/Features/InteriorFlow/InteriorFlowView.swift",
    "AIHome/AIHome/Features/ExteriorFlow/ExteriorFlowView.swift",
    "AIHome/AIHome/Features/GardenFlow/GardenFlowView.swift",
    "AIHome/AIHome/Features/ReferenceStyleFlow/ReferenceStyleFlowView.swift",
    "AIHome/AIHome/Features/RemoveObjectsFlow/RemoveObjectsFlowView.swift",
    "AIHome/AIHome/Features/ReplaceObjectsFlow/ReplaceObjectsFlowView.swift",
    "AIHome/AIHome/Features/NewFlooringFlow/NewFlooringFlowView.swift",
    "AIHome/AIHome/Features/NewWallsFlow/NewWallsFlowView.swift",
    "AIHome/AIHome/Features/Settings/SettingsView.swift",
    "AIHome/AIHome/Features/Inspiration/InspirationView.swift",
    "AIHome/AIHome/Features/History/HistoryView.swift",
    "AIHome/AIHome/Features/FurnitureFinderFlow/FurnitureFinderView.swift"
]

for p in paths:
    full_path = os.path.join("/Users/mac/Documents/hai/ai_home", p)
    if os.path.exists(full_path):
        with open(full_path, "r") as f:
            content = f.read()
        if "NavigationStack {" in content:
            new_content = content.replace("NavigationStack {", "Group {")
            with open(full_path, "w") as f:
                f.write(new_content)
            print(f"Fixed {full_path}")
    else:
        print(f"File not found: {full_path}")
