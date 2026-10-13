//
//  ServerPresentation.swift
//  Q3ServerBrowser
//
//  Display helpers shared by the list and the detail panel, so thresholds and
//  labels are defined in one place.
//

import SwiftUI
import AppKit
import GameServerQueryLibrary

// MARK: - Ping

enum PingThreshold {
    /// Ping at or above this is shown in orange.
    static let warning = 80
    /// Ping at or above this is shown in red.
    static let critical = 150
}

extension Color {
    /// Returns a colour only when the ping is a problem; normal pings use the surrounding style.
    static func pingWarning(for ping: Int) -> Color? {
        if ping >= PingThreshold.critical { return .red }
        if ping >= PingThreshold.warning { return .orange }
        return nil
    }
}

/// Style for a ping value: tertiary when unknown, orange/red when high, secondary otherwise.
func pingStyle(for ping: Int) -> AnyShapeStyle {
    if ping <= 0 { return AnyShapeStyle(HierarchicalShapeStyle.tertiary) }
    if let warning = Color.pingWarning(for: ping) { return AnyShapeStyle(warning) }
    return AnyShapeStyle(HierarchicalShapeStyle.secondary)
}

// MARK: - Names

extension String {
    /// Removes any leftover Quake 3 colour codes (`^x`), stray carets and control
    /// characters, collapses runs of whitespace and trims the ends.
    var cleanedQ3Name: String {
        var result = replacingOccurrences(of: "\\^.", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "^", with: "")
        result = String(result.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) })
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Server

extension Server {
    var displayName: String {
        let cleaned = name.cleanedQ3Name
        return cleaned.isEmpty ? hostname : cleaned
    }

    var currentPlayerCount: Int { Int(currentPlayers) ?? 0 }
    var maxPlayerCount: Int { Int(maxPlayers) ?? 0 }

    var isEmptyServer: Bool { currentPlayerCount == 0 }
    var isFullServer: Bool { maxPlayerCount > 0 && currentPlayerCount >= maxPlayerCount }

    /// Text style for a row: empty servers recede so populated ones stand out.
    var rowStyle: HierarchicalShapeStyle { isEmptyServer ? .secondary : .primary }

    var modeLabel: String {
        switch gametype {
        case "ffa": return "FFA"
        case "tourney": return "1v1"
        case "tdm": return "TDM"
        case "ctf": return "CTF"
        default: return "—"
        }
    }

    /// The mod name, or an empty string for the default `baseq3`.
    var displayMod: String { mod == "baseq3" ? "" : mod }

    func rule(_ keys: String...) -> String? {
        rules.first { keys.contains($0.key.lowercased()) }?.value
    }

    var isPasswordProtected: Bool { rule("g_needpass") == "1" }

    /// Time limit in minutes, when the server sets one.
    var timeLimit: Int? {
        guard let value = rule("timelimit", "g_timelimit").flatMap({ Int($0) }), value > 0 else { return nil }
        return value
    }

    /// Capture limit for CTF, frag limit otherwise, when the server sets one.
    var scoreLimit: (value: Int, label: String)? {
        if gametype == "ctf" {
            guard let caps = rule("capturelimit").flatMap({ Int($0) }), caps > 0 else { return nil }
            return (caps, caps == 1 ? "cap" : "caps")
        }
        guard let frags = rule("fraglimit").flatMap({ Int($0) }), frags > 0 else { return nil }
        return (frags, frags == 1 ? "frag" : "frags")
    }

    /// True when the server reports team scores (some mods don't).
    var hasTeamScores: Bool {
        isATeamMode && rule("score_red") != nil && rule("score_blue") != nil
    }
}

// MARK: - Pasteboard

@MainActor
enum Pasteboard {
    static func copy(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
