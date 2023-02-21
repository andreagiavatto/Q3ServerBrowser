//
//  Sidebar.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 14/04/2022.
//

import SwiftUI
import GameServerQueryLibrary

struct Sidebar: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        SideBarContent()
            .environmentObject(gameViewModel)
            .frame(minWidth: 300, idealWidth: 300, maxWidth: 300)
    }
}

struct SideBarContent: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    @State var selectedMasterServer: MasterServer? {
        didSet {
            gameViewModel.updateMasterServer(selectedMasterServer)
        }
    }
    
    var body: some View {
        Section("Master Servers") {
            List(gameViewModel.masterServers, id: \.description) { masterServer in
                HStack {
                    Text(masterServer.description)
                    Spacer()
                    if masterServer.description == selectedMasterServer?.description {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }.onTapGesture {
                    self.selectedMasterServer = masterServer
                }
            }
            .listStyle(SidebarListStyle())
        }
    }
}
