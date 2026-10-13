//
//  PlayerCapacityView.swift
//  Q3ServerBrowser
//

import SwiftUI
import GameServerQueryLibrary

/// Player count as "current/max", right-aligned. The current count is emphasised,
/// dimmed when the server is empty and red when it is full.
struct PlayerCapacityView: View {
    let server: Server

    private var countStyle: AnyShapeStyle {
        if server.isFullServer { return AnyShapeStyle(Color.red) }
        return AnyShapeStyle(server.rowStyle)
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("\(server.currentPlayerCount)")
                .fontWeight(server.isEmptyServer ? .regular : .medium)
                .foregroundStyle(countStyle)
            Text("/\(server.maxPlayerCount)")
                .foregroundStyle(.secondary)
        }
        .monospacedDigit()
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
