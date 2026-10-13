//
//  PlayersView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 25/02/2023.
//

import SwiftUI
import GameServerQueryLibrary

/// Players grouped by team (or sorted by score in free-for-all), with a single
/// column header. Spectators start collapsed.
struct PlayersView: View {
    let server: Server

    @State private var spectatorsExpanded: Bool = false

    private var redPlayers: [Player] { server.teamRed?.players ?? [] }
    private var bluePlayers: [Player] { server.teamBlue?.players ?? [] }
    private var spectators: [Player] { server.teamSpectator?.players ?? [] }

    /// Team modes whose mod doesn't report team membership fall back to a flat list.
    private var showsTeams: Bool {
        server.isATeamMode && !(redPlayers.isEmpty && bluePlayers.isEmpty)
    }

    private var playersByScore: [Player] {
        server.players.sorted { (Int($0.score) ?? 0) > (Int($1.score) ?? 0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if server.players.isEmpty {
                Text("No one is playing right now")
                    .foregroundStyle(.secondary)
                    .padding(16)
            } else {
                columnHeader

                if showsTeams {
                    teamGroup("Red", colour: .red, players: redPlayers)
                    teamGroup("Blue", colour: .blue, players: bluePlayers)
                } else {
                    ForEach(playersByScore) { player in
                        playerRow(player)
                    }
                }

                if showsTeams && !spectators.isEmpty {
                    CollapsibleHeader(title: "Spectators",
                                      count: spectators.count,
                                      isExpanded: $spectatorsExpanded)
                        .padding(.top, 6)
                    if spectatorsExpanded {
                        ForEach(spectators) { player in
                            playerRow(player)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Building blocks

    private var columnHeader: some View {
        HStack {
            Text("Player")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Score")
                .frame(width: 44, alignment: .trailing)
            Text("Ping")
                .frame(width: 44, alignment: .trailing)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 2)
    }

    private func teamGroup(_ title: String, colour: Color, players: [Player]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(colour)
                Text("\(players.count)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 2)

            if players.isEmpty {
                Text("No players")
                    .font(.callout)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
            } else {
                ForEach(players) { player in
                    playerRow(player)
                }
            }
        }
    }

    private func playerRow(_ player: Player) -> some View {
        let ping = Int(player.ping) ?? 0
        let name = player.name.cleanedQ3Name
        return HStack {
            Text(name.isEmpty ? "(unnamed)" : name)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(player.score)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .trailing)
            PingBadge(ping: ping)
                .frame(width: 44, alignment: .trailing)
        }
        .monospacedDigit()
        .padding(.horizontal, 16)
        .frame(height: 22)
    }
}
