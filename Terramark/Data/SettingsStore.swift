import Foundation
import Observation
import SwiftUI
import UIKit

private extension Color {
    static var defaultVisited: Color { Color(red: 0.1, green: 0.35, blue: 0.85) }
    static var defaultWantToVisit: Color { Color(red: 0.9, green: 0.4, blue: 0.05) }
}

private func hexString(from color: Color) -> String {
    let uiColor = UIColor(color)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
}

private func parseColor(fromHex hex: String) -> Color? {
    var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if hex.hasPrefix("#") { hex.removeFirst() }
    guard hex.count == 6 else { return nil }
    var rgb: UInt64 = 0
    guard Scanner(string: hex).scanHexInt64(&rgb) else { return nil }
    return Color(
        red: Double((rgb >> 16) & 0xFF) / 255,
        green: Double((rgb >> 8) & 0xFF) / 255,
        blue: Double(rgb & 0xFF) / 255
    )
}

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }

    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }

    var resolvedColorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

private let themeDefaultsKey = "TerramarkTheme"
private let visitedColorKey = "TerramarkVisitedColor"
private let wantToVisitColorKey = "TerramarkWantToVisitColor"

@Observable
@MainActor
final class SettingsStore {
    var theme: AppTheme {
        didSet { saveTheme() }
    }

    var visitedColor: Color {
        didSet {
            saveVisitedColor()
            colorSettingsRevision += 1
        }
    }

    var wantToVisitColor: Color {
        didSet {
            saveWantToVisitColor()
            colorSettingsRevision += 1
        }
    }

    private(set) var colorSettingsRevision: Int = 0

    init() {
        if let raw = UserDefaults.standard.string(forKey: themeDefaultsKey),
           let decoded = AppTheme(rawValue: raw) {
            self.theme = decoded
        } else {
            self.theme = .system
        }
        if let hex = UserDefaults.standard.string(forKey: visitedColorKey),
           let color = parseColor(fromHex: hex) {
            self.visitedColor = color
        } else {
            self.visitedColor = .defaultVisited
        }
        if let hex = UserDefaults.standard.string(forKey: wantToVisitColorKey),
           let color = parseColor(fromHex: hex) {
            self.wantToVisitColor = color
        } else {
            self.wantToVisitColor = .defaultWantToVisit
        }
    }

    private func saveTheme() {
        UserDefaults.standard.set(theme.rawValue, forKey: themeDefaultsKey)
    }

    private func saveVisitedColor() {
        UserDefaults.standard.set(hexString(from: visitedColor), forKey: visitedColorKey)
    }

    private func saveWantToVisitColor() {
        UserDefaults.standard.set(hexString(from: wantToVisitColor), forKey: wantToVisitColorKey)
    }

    func resetMapColorsToDefaults() {
        visitedColor = .defaultVisited
        wantToVisitColor = .defaultWantToVisit
    }

    func color(for status: CountryStatus) -> Color {
        switch status {
        case .none:
            return Color(uiColor: .systemGray)
        case .visited:
            return visitedColor
        case .wantToVisit:
            return wantToVisitColor
        }
    }

    var visitedUIColor: UIColor { UIColor(visitedColor) }
    var wantToVisitUIColor: UIColor { UIColor(wantToVisitColor) }
}
