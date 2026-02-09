import SwiftUI

struct CountryDescriptionSheet: View {
    let selection: CountrySelection
    var store: CountryStore
    @Environment(\.dismiss) private var dismiss
    @State private var aiInsights: TravelInsights?
    @State private var isLoadingInsights = false
    @State private var insightsError: String?

    private var currentStatus: CountryStatus {
        store.status(for: selection.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    heroSection

                    VStack(spacing: 20) {
                        if TravelInsightsService.isAvailable {
                            travelInsightsSection
                        }

                        if let desc = CountryDescriptionsLoader.description(for: selection.id) {
                            aboutSection(desc)
                        } else {
                            placeholderAboutSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            if TravelInsightsService.isAvailable {
                Task { await loadInsights() }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 10) {
            Text(store.flagEmoji(for: selection.id))
                .font(.system(size: 64))

            Text(selection.name)
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                if let continent = store.countryContinents[selection.id], !continent.isEmpty {
                    Label(continent, systemImage: "globe")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                if currentStatus != .none {
                    Text("\u{00B7}")
                        .font(.subheadline)
                        .foregroundStyle(.quaternary)

                    HStack(spacing: 4) {
                        Image(systemName: currentStatus == .visited ? "checkmark.circle.fill" : "heart.fill")
                            .font(.caption)
                        Text(currentStatus.title)
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(currentStatus.color)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
    }

    // MARK: - About

    private func aboutSection(_ desc: CountryDescription) -> some View {
        VStack(spacing: 12) {
            sectionHeader("About", systemImage: "book.fill")

            VStack(alignment: .leading, spacing: 0) {
                infoBlock(title: "Overview", text: desc.overview, icon: "doc.text.fill")

                sectionDivider

                infoBlock(title: "Known for", text: desc.knownFor, icon: "star.fill")

                sectionDivider

                infoBlock(title: "Quick history", text: desc.quickHistory, icon: "clock.fill")
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var placeholderAboutSection: some View {
        VStack(spacing: 12) {
            sectionHeader("About", systemImage: "book.fill")

            VStack(alignment: .leading, spacing: 0) {
                infoBlock(
                    title: "Overview",
                    text: "A short overview of this destination will appear here. You'll find key facts, geography, and a brief introduction to the country.",
                    icon: "doc.text.fill"
                )

                sectionDivider

                infoBlock(
                    title: "Known for",
                    text: "Highlights and what this place is known for will be shown here.",
                    icon: "star.fill"
                )

                sectionDivider

                infoBlock(
                    title: "Quick history",
                    text: "A brief history will be available in a future update.",
                    icon: "clock.fill"
                )
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var sectionDivider: some View {
        Divider()
            .padding(.horizontal, 16)
    }

    private func infoBlock(title: String, text: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tint)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
    }

    // MARK: - Travel Insights

    @ViewBuilder
    private var travelInsightsSection: some View {
        VStack(spacing: 12) {
            sectionHeader("Travel insights", systemImage: "sparkles")

            if isLoadingInsights {
                skeletonInsightsGrid
            } else if let error = insightsError {
                errorCard(error)
            } else if let insights = aiInsights {
                insightsGrid(insights)
            }
        }
    }

    private var skeletonInsightsGrid: some View {
        VStack(spacing: 10) {
            SkeletonInsightRow(tint: .orange)
            SkeletonInsightRow(tint: .blue)
            SkeletonInsightRow(tint: .purple)
        }
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                Task { await loadInsights() }
            }
            .font(.subheadline.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func insightsGrid(_ insights: TravelInsights) -> some View {
        VStack(spacing: 10) {
            InsightRow(
                title: "Best time to visit",
                systemImage: "sun.and.horizon.fill",
                text: insights.bestTimeToVisit,
                tint: .orange
            )
            InsightRow(
                title: "Getting there",
                systemImage: "airplane.departure",
                text: insights.gettingThere,
                tint: .blue
            )
            InsightRow(
                title: "What to know",
                systemImage: "lightbulb.fill",
                text: insights.whatToKnow,
                tint: .purple
            )
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    @MainActor
    private func loadInsights() async {
        if let cached = TravelInsightsService.cachedInsights(for: selection.id) {
            aiInsights = cached
            insightsError = nil
            return
        }
        isLoadingInsights = true
        insightsError = nil
        defer { isLoadingInsights = false }
        do {
            let insights = try await TravelInsightsService.generateInsights(for: selection.name)
            TravelInsightsService.saveInsights(insights, for: selection.id)
            aiInsights = insights
        } catch {
            insightsError = error.localizedDescription
        }
    }
}

// MARK: - Insight Row

private struct InsightRow: View {
    let title: String
    let systemImage: String
    let text: String
    var tint: Color = .accentColor

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Skeleton Insight Row

private struct SkeletonInsightRow: View {
    var tint: Color = .gray
    @State private var isAnimating = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(skeletonFill)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(skeletonFill)
                    .frame(width: 120, height: 12)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(skeletonFill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(skeletonFill)
                    .frame(width: 220, height: 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(isAnimating ? 0.7 : 0.4)
        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear { isAnimating = true }
    }

    private var skeletonFill: Color {
        Color(uiColor: .tertiaryLabel)
    }
}

#Preview {
    CountryDescriptionSheet(
        selection: CountrySelection(id: "USA", name: "United States"),
        store: CountryStore()
    )
}
