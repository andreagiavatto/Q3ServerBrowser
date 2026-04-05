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
        .frame(minWidth: 300, idealWidth: 350, maxWidth: 350)
    }
}

struct SideBarContent: View {
    @ObservedObject var gameViewModel: GameViewModel
    let supportedGames: [SupportedGames]
    @Binding var selectedGame: SupportedGames

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Game")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Picker("", selection: $selectedGame) {
                    ForEach(supportedGames, id: \.self) { game in
                        Text(game.name).tag(game)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }
            .frame(height: 28)
            .padding(.horizontal, 28)
            .onChange(of: selectedGame) { _, newGame in
                gameViewModel.switchGame(to: newGame)
            }

            Divider()
                .padding(.horizontal, 28)
                .padding(.top, 4)

            Section {
                List(gameViewModel.masterServers) { masterServer in
                    HStack {
                        Text(masterServer.description)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 12.0, bottom: 0, trailing: 12.0))
                    .frame(minHeight: 24)
                    .contentShape(Rectangle())
                    .background(
                        RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                            .fill(masterServer.id == gameViewModel.currentMasterServer?.id
                                  ? Color(.gray).opacity(0.25)
                                  : Color.clear)
                    )
                    .onTapGesture {
                        Task {
                            await gameViewModel.updateMasterServer(masterServer)
                        }
                    }
                }
                .listStyle(.sidebar)
            } header: {
                HStack {
                    Text("Master Servers")
                        .font(.title3)
                    Spacer()
                }
                .fontWeight(.bold)
                .frame(height: 28)
                .padding(.horizontal, 28)

                Divider()
                    .padding(.horizontal, 28)
            }
        }
    }
}
