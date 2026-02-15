import SwiftUI

struct SettingsView: View {
    @Bindable var settingsStore: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settingsStore.theme) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.title, systemImage: theme.iconName)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Map") {
                    Toggle("Show search button", isOn: $settingsStore.showSearchButton)
                }

                Section("Map colors") {
                    ColorPicker("Visited or lived", selection: $settingsStore.visitedColor, supportsOpacity: false)
                    ColorPicker("Want to visit", selection: $settingsStore.wantToVisitColor, supportsOpacity: false)
                    Button("Reset to defaults", systemImage: "arrow.counterclockwise") {
                        settingsStore.resetMapColorsToDefaults()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label:  {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(settingsStore: SettingsStore())
}
