//
//  Sidebar.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct Sidebar: View {
    @ObservedObject var gameViewModel: GameViewModel
    let supportedGames: [SupportedGames]
    @Binding var selectedGame: SupportedGames

    var body: some View {
        SideBarContent(
            gameViewModel: gameViewModel,
            supportedGames: supportedGames,
            selectedGame: $selectedGame
        )
    }
}

struct SideBarContent: View {
    @ObservedObject var gameViewModel: GameViewModel
    let supportedGames: [SupportedGames]
    @Binding var selectedGame: SupportedGames

    var body: some View {
        VStack(spacing: 0) {

            // ── Game picker ──────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                Text("Game")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.6)

                Picker("", selection: $selectedGame) {
                    ForEach(supportedGames, id: \.self) { game in
                        Text(game.name).tag(game)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .onChange(of: selectedGame) { _, newGame in
                    gameViewModel.switchGame(to: newGame)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // ── Filter chips ─────────────────────────────────────────────
            HStack(spacing: 6) {
                filterChip(
                    title: "Show Full",
                    isOn: gameViewModel.showFull
                ) {
                    gameViewModel.updateFullServersVisibility(allowFullServers: !gameViewModel.showFull)
                }
                filterChip(
                    title: "Show Empty",
                    isOn: gameViewModel.showEmpty
                ) {
                    gameViewModel.updateEmptyServersVisibility(allowEmptyServers: !gameViewModel.showEmpty)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 14)

            // ── Master server list ───────────────────────────────────────
            HStack {
                Text("Master Servers")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.6)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 4)

            List(gameViewModel.masterServers) { masterServer in
                masterServerRow(masterServer)
                    .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(masterServer.id == gameViewModel.currentMasterServer?.id
                                  ? Color.accentColor.opacity(0.15)
                                  : Color.clear)
                    )
            }
            .listStyle(.sidebar)

            Divider()

            // ── Footer ───────────────────────────────────────────────────
            HStack {
                if let refreshed = gameViewModel.lastRefreshed {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                    Text(refreshed, style: .time)
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                } else {
                    Text("Select a master server to begin")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func filterChip(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isOn ? Color.accentColor : Color.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(isOn ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(
                            isOn ? Color.accentColor.opacity(0.4) : Color.primary.opacity(0.1),
                            lineWidth: 0.5
                        )
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func masterServerRow(_ masterServer: MasterServer) -> some View {
        let isActive = masterServer.id == gameViewModel.currentMasterServer?.id
        let count = gameViewModel.masterServerResults[masterServer.id]

        Button {
            Task { await gameViewModel.updateMasterServer(masterServer) }
        } label: {
            HStack(spacing: 8) {
                // Status dot: green if we have results, gray if not yet queried
                Circle()
                    .fill(count != nil ? Color.green : Color.secondary.opacity(0.4))
                    .frame(width: 7, height: 7)

                VStack(alignment: .leading, spacing: 1) {
                    Text(masterServer.hostname)
                        .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                        .foregroundStyle(isActive ? Color.accentColor : Color.primary)
                        .lineLimit(1)

                    Text(":\(masterServer.port)")
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                }

                Spacer(minLength: 4)

                // Count badge — shown only after the master has responded
                if let count {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(isActive
                                           ? Color.accentColor.opacity(0.15)
                                           : Color.primary.opacity(0.08))
                        )
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
