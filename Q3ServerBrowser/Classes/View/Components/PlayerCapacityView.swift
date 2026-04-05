//
//  PlayerCapacityView.swift
//  Q3ServerBrowser
//

import SwiftUI

/// Shows player count as "current / max" text with a coloured fill-bar beneath it.
/// The bar colour encodes how full the server is, using the same semantic scale
/// as PingBadge: green → sparse, orange → busy, red → (nearly) full.
struct PlayerCapacityView: View {
    let current: String
    let max: String

    private var fraction: Double {
        guard let c = Double(current), let m = Double(max), m > 0 else { return 0 }
        return min(c / m, 1.0)
    }

    private var barColour: Color {
        if fraction >= 0.9 { return .red }
        if fraction >= 0.5 { return .orange }
        return .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(current) / \(max)")
                .font(.system(size: 10.5))
                .monospacedDigit()
                .foregroundStyle(.secondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    if fraction > 0 {
                        Capsule()
                            .fill(barColour)
                            .frame(width: Swift.max(geo.size.width * fraction, 2))
                    }
                }
            }
            .frame(height: 3)
        }
    }
}
