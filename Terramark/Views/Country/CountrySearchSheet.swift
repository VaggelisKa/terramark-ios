import SwiftUI

struct CountrySearchSheet: View {
    var store: CountryStore
    var settingsStore: SettingsStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCountry: CountrySelection?

    private static let continentOrder = ["Africa", "Antarctica", "Asia", "Europe", "North America", "Oceania", "South America", "Other"]

    private var filteredCountriesByContinent: [(continent: String, countries: [(id: String, name: String)])] {
        let all = store.countryNames.map { (id: $0.key, name: $0.value) }
        let filtered: [(id: String, name: String)] = {
            guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
                return all
            }
            let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
            return all.filter { country in
                let continent = (store.countryContinents[country.id] ?? "Other").lowercased()
                return country.name.lowercased().contains(query)
                    || country.id.lowercased().contains(query)
                    || continent.contains(query)
            }
        }()
        let grouped = Dictionary(grouping: filtered) { country -> String in
            store.countryContinents[country.id]?.isEmpty == false
                ? (store.countryContinents[country.id] ?? "Other")
                : "Other"
        }
        let sortedCountries: ([(id: String, name: String)]) -> [(id: String, name: String)] = { $0.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending } }
        var result: [(continent: String, countries: [(id: String, name: String)])] = []
        for key in Self.continentOrder {
            if let countries = grouped[key], !countries.isEmpty {
                result.append((key, sortedCountries(countries)))
            }
        }
        for key in grouped.keys.sorted() where !Self.continentOrder.contains(key) {
            if let countries = grouped[key], !countries.isEmpty {
                result.append((key, sortedCountries(countries)))
            }
        }
        return result
    }

    private var hasNoResults: Bool {
        filteredCountriesByContinent.allSatisfy { $0.countries.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Group {
                if hasNoResults {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredCountriesByContinent, id: \.continent) { section in
                            Section(section.continent) {
                                ForEach(section.countries, id: \.id) { country in
                                    Button {
                                        Haptics.mediumImpact()
                                        selectedCountry = CountrySelection(id: country.id, name: country.name)
                                    } label: {
                                        HStack(spacing: 12) {
                                            Text(store.flagEmoji(for: country.id))
                                                .font(.title2)
                                            Text(country.name)
                                                .foregroundStyle(.primary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 4)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .searchable(text: $searchText, prompt: "Search countries")
            .navigationTitle("Search countries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .toolbarBackground(.hidden)
        }
        .presentationDragIndicator(.visible)
        .sheet(item: $selectedCountry) { selection in
            CountryStatusSheet(selection: selection, store: store, settingsStore: settingsStore)
        }
    }
}

#Preview {
    CountrySearchSheet(store: CountryStore(), settingsStore: SettingsStore())
}
