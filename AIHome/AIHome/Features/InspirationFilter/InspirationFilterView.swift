import SwiftUI

struct InspirationFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = InspirationFilterViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Favourite")) {
                    Toggle("Liked Only", isOn: $viewModel.showLikedOnly)
                }
                
                Section(header: Text("Interior Spaces")) {
                    Picker("Space", selection: $viewModel.selectedInteriorSpace) {
                        ForEach(viewModel.interiorSpaces, id: \.self) { space in
                            Text(space).tag(space)
                        }
                    }
                }
                
                Section(header: Text("Exterior Spaces")) {
                    Picker("Space", selection: $viewModel.selectedExteriorSpace) {
                        ForEach(viewModel.exteriorSpaces, id: \.self) { space in
                            Text(space).tag(space)
                        }
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.reset()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    InspirationFilterView()
}
