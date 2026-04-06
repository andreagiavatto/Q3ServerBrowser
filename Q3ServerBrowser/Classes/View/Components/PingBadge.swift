//
//  PingBadge.swift
//  Q3ServerBrowser
//

import SwiftUI

/// Displays a ping value in milliseconds with a colour that encodes quality:
///   < 50 ms  → green   (good)
///   50–149   → orange  (acceptable)
///   ≥ 150    → red     (poor)
///   0 / nil  → secondary (unknown / not yet fetched)
struct PingBadge: View {
    let ping: String

    private var pingInt: Int { Int(ping) ?? 0 }

    private var colour: Color {
        guard pingInt > 0 else { return .secondary }
        if pingInt < 50  { return .green }
        if pingInt < 150 { return .orange }
        return .red
    }

    private var label: String {
        pingInt > 0 ? "\(pingInt) ms" : "—"
    }

    var body: some View {
        Text(label)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(colour)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(colour.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
