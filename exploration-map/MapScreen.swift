//
//  MapScreen.swift
//  exploration-map
//

import SwiftUI

struct MapScreen: View {
    @Environment(CountryStore.self) private var store
    @State private var selectedCountry: CountrySelection?
    @State private var showingWantToVisitList = false
    @State private var isStatsExpanded = UserDefaults.standard.bool(forKey: statsExpandedKey)

    var body: some View {
        ZStack(alignment: .bottom) {
            CountryMapView(store: store, selectedCountry: $selectedCountry)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                StatsView(store: store, isExpanded: $isStatsExpanded)

                if isStatsExpanded {
                    GlassEffectContainer {
                        Button {
                            showingWantToVisitList = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "list.star")
                                    .font(.subheadline.weight(.medium))
                                Text("Want to visit")
                                    .font(.subheadline.weight(.medium))
                                Text("(\(store.wantToVisitCount))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isStatsExpanded)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .sheet(item: $selectedCountry) { selection in
            CountryStatusSheet(selection: selection, store: store)
        }
        .sheet(isPresented: $showingWantToVisitList) {
            WantToVisitListView(store: store)
        }
    }
}

#Preview {
    MapScreen()
        .environment(CountryStore())
}
