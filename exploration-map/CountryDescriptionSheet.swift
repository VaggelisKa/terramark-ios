//
//  CountryDescriptionSheet.swift
//  exploration-map
//

import SwiftUI

struct CountryDescriptionSheet: View {
    let selection: CountrySelection
    var store: CountryStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDetent: PresentationDetent = .large

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection

                    if let desc = CountryDescriptionsLoader.description(for: selection.id) {
                        descriptionSection(title: "Overview", text: desc.overview)
                        descriptionSection(title: "Known for", text: desc.knownFor)
                        descriptionSection(title: "Quick history", text: desc.quickHistory)
                    } else {
                        descriptionSection(
                            title: "Overview",
                            text: "A short overview of this destination will appear here. You'll find key facts, geography, and a brief introduction to the country."
                        )
                        descriptionSection(
                            title: "Known for",
                            text: "Highlights and what this place is known for will be shown here."
                        )
                        descriptionSection(
                            title: "Quick history",
                            text: "A brief history will be available in a future update."
                        )
                    }

                    Spacer(minLength: 32)
                }
                .padding(20)
            }
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Text(store.flagEmoji(for: selection.id))
                            .font(.title2)
                        Text(selection.name)
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
        }
        .presentationDetents([.medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            Text(store.flagEmoji(for: selection.id))
                .font(.system(size: 48))
            VStack(alignment: .leading, spacing: 4) {
                Text(selection.name)
                    .font(.title2.weight(.semibold))
                if let continent = store.countryContinents[selection.id], !continent.isEmpty {
                    Text(continent)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func descriptionSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    CountryDescriptionSheet(
        selection: CountrySelection(id: "USA", name: "United States"),
        store: CountryStore()
    )
}
