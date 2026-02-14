import SwiftUI

struct CountryStatusSheet: View {
    let selection: CountrySelection
    var store: CountryStore
    var settingsStore: SettingsStore
    @Environment(\.dismiss) private var dismiss
    @State private var pendingStatus: CountryStatus

    init(selection: CountrySelection, store: CountryStore, settingsStore: SettingsStore) {
        self.selection = selection
        self.store = store
        self.settingsStore = settingsStore
        _pendingStatus = State(initialValue: store.status(for: selection.id))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(CountryStatus.allCases) { status in
                    Button {
                        pendingStatus = status
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(settingsStore.color(for: status))
                                .frame(width: 10, height: 10)
                            Text(status.title)
                                .foregroundStyle(.primary)
                            Spacer()
                            if pendingStatus == status {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle([store.flagEmoji(for: selection.id), selection.name].filter { !$0.isEmpty }.joined(separator: " "))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button ("Save") {
                        store.updateStatus(pendingStatus, for: selection.id)
                        dismiss()
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    CountryStatusSheet(
        selection: CountrySelection(id: "USA", name: "United States"),
        store: CountryStore(),
        settingsStore: SettingsStore()
    )
}
