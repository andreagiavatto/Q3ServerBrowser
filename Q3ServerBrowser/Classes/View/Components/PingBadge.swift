//
//  PingBadge.swift
//  Q3ServerBrowser
//

import SwiftUI

/// Ping in milliseconds as plain monospaced text. Colour is used only when the
/// ping is a problem (see `PingThreshold`); unknown pings show an em dash.
struct PingBadge: View {
    let ping: Int

    var body: some View {
        Text(ping > 0 ? "\(ping)" : "—")
            .monospacedDigit()
            .foregroundStyle(pingStyle(for: ping))
    }
}
