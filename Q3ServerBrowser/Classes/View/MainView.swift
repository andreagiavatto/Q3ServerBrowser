//
//  MainView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct MainView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var selectedRow: Server.ID?
    @State var showFull: Bool = true
    @State var showEmpty: Bool = true
    
    var body: some View {
        NavigationView {
            Sidebar()
            VStack {
                VSplitView {
                    ServersView(selectedServer: $selectedRow)
                        .frame(minHeight: 400, idealHeight: 600)
                        .onChange(of: selectedRow) { newSelectedRow in
                            let server = gameViewModel.server(by: newSelectedRow)
                            gameViewModel.updateServerStatus(server)
                        }
                    if gameViewModel.currentSelectedServer != nil {
                        Divider()
                        PlayersView()
                    }
                }
                Divider()
            }
        }
        .toolbar {
            Button(action: refreshList) {
                Label("Refresh List", systemImage: "arrow.triangle.2.circlepath")
            }
            
            Toggle(isOn: $showFull) {
                Text("Show Full")
            }
            .toggleStyle(CheckboxToggleStyle())
            .onChange(of: showFull) { newValue in
                gameViewModel.updateFullServersVisibility(allowFullServers: newValue)
            }
            
            Toggle(isOn: $showEmpty) {
                Text("Show Empty")
            }
            .toggleStyle(CheckboxToggleStyle())
            .onChange(of: showEmpty) { newValue in
                gameViewModel.updateEmptyServersVisibility(allowEmptyServers: newValue)
            }
        }
        .navigationTitle("Q3ServerBrowser")
        .navigationSubtitle(Text("\(gameViewModel.servers.count) servers found"))
    }
    
    func refreshList() {
        gameViewModel.refreshCurrentList()
    }
}
