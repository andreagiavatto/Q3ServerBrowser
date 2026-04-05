//
//  PlayersView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 25/02/2023.
//

import SwiftUI
import GameServerQueryLibrary

struct PlayersView: View {
    let server: Server

    @State private var redExpanded: Bool = true
    @State private var blueExpanded: Bool = true
    @State private var spectatorsExpanded: Bool = false
    @State private var allPlayersExpanded: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            if server.isATeamMode {
                teamSection(
                    title: "Team Red",
                    players: server.teamRed?.players ?? [],
                    score: server.teamRed?.score,
                    colour: .red,
                    isExpanded: $redExpanded
                )

                Divider().padding(.leading, 14)

                teamSection(
                    title: "Team Blue",
                    players: server.teamBlue?.players ?? [],
                    score: server.teamBlue?.score,
                    colour: .blue,
                    isExpanded: $blueExpanded
                )

                if let specPlayers = server.teamSpectator?.players, !specPlayers.isEmpty {
                    Divider().padding(.leading, 14)
                    teamSection(
                        title: "Spectators",
                        players: specPlayers,
                        score: nil,
                        colour: .secondary,
                        isExpanded: $spectatorsExpanded
                    )
                }
            } else {
                let sorted = server.players.sorted {
                    (Int($0.score) ?? 0) > (Int($1.score) ?? 0)
                }
                playerSection(
                    title: "Players",
                    players: sorted,
                    colour: .primary,
                    isExpanded: $allPlayersExpanded
                )

                if let specPlayers = server.teamSpectator?.players, !specPlayers.isEmpty {
                    Divider().padding(.leading, 14)
                    teamSection(
                        title: "Spectators",
                        players: specPlayers,
                        score: nil,
                        colour: .secondary,
                        isExpanded: $spectatorsExpanded
                    )
                }
            }
        }
    }

    // MARK: - Section views

    @ViewBuilder
    private func teamSection(
        title: String,
        players: [Player],
        score: String?,
        colour: Color,
        isExpanded: Binding<Bool>
    ) -> some View {
        VStack(spacing: 0) {
            sectionHeader(
                title: title,
                detail: score.map { "Score: \($0)" },
                count: players.count,
                colour: colour,
                isExpanded: isExpanded
            )

            if isExpanded.wrappedValue {
                playerRows(players: players)
            }
        }
    }

    @ViewBuilder
    private func playerSection(
        title: String,
        players: [Player],
        colour: Color,
        isExpanded: Binding<Bool>
    ) -> some View {
        VStack(spacing: 0) {
            sectionHeader(
                title: title,
                detail: nil,
                count: players.count,
                colour: colour,
                isExpanded: isExpanded
            )

            if isExpanded.wrappedValue {
                playerRows(players: players)
            }
        }
    }

    // MARK: - Building blocks

    @ViewBuilder
    private func sectionHeader(
        title: String,
        detail: String?,
        count: Int,
        colour: Color,
        isExpanded: Binding<Bool>
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { isExpanded.wrappedValue.toggle() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(isExpanded.wrappedValue ? .degrees(90) : .degrees(0))

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colour)

                if let detail {
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(detail)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(colour.opacity(0.7))
                }

                Spacer()

                Text("\(count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(.quaternary, in: Capsule())
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func playerRows(players: [Player]) -> some View {
        if players.isEmpty {
            Text("No players")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
        } else {
            VStack(spacing: 0) {
                // Column header row
                HStack {
                    Text("Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Score")
                        .frame(width: 48, alignment: .trailing)
                    Text("Ping")
                        .frame(width: 48, alignment: .trailing)
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 14)
                .padding(.vertical, 3)

                ForEach(players) { player in
                    playerRow(player)
                }
            }
        }
    }

    @ViewBuilder
    private func playerRow(_ player: Player) -> some View {
        let pingInt = Int(player.ping) ?? 0
        let pingColour: Color = pingInt <= 0  ? .secondary
            : pingInt < 50                   ? .green
            : pingInt < 150                  ? .orange
            : .red

        HStack {
            Text(player.name.isEmpty ? "(unnamed)" : player.name)
                .font(.system(size: 13))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(player.score)
                .font(.system(size: 13))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 48, alignment: .trailing)

            Text(pingInt > 0 ? player.ping : "—")
                .font(.system(size: 13, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(pingColour)
                .frame(width: 48, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(.quaternary.opacity(0.3))
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 14)
        }
    }
}
