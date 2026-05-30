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
]

for p in paths:
    full_path = os.path.join("/Users/mac/Documents/hai/ai_home", p)
    if os.path.exists(full_path):
        with open(full_path, "r") as f:
            content = f.read()
            
        modified = False
        
        # Fix the step text interpolation
        if 'Text("Step \\(viewModel' in content:
            content = content.replace('Text("Step \\(viewModel', 'Text("Step \(viewModel')
            modified = True
            
        # Add back button hidden if not already there
        if '.navigationBarTitleDisplayMode(.inline)' in content and '.navigationBarBackButtonHidden(true)' not in content:
            content = content.replace(
                '.navigationBarTitleDisplayMode(.inline)',
                '.navigationBarBackButtonHidden(true)\n            .navigationBarTitleDisplayMode(.inline)'
            )
            modified = True
            
        if modified:
            with open(full_path, "w") as f:
                f.write(content)
            print(f"Fixed UI bugs in {full_path}")
