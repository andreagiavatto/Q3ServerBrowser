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
            .frame(minWidth: 300, idealWidth: 350, maxWidth: 350)
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
                }
                .padding(EdgeInsets(top: 0, leading: 12.0, bottom: 0, trailing: 12.0))
                .frame(minHeight: 24)
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: 12.0, style: .continuous).fill(masterServer.description == selectedMasterServer?.description ? Color(.gray).opacity(0.25) : Color.clear)
                )
                .onTapGesture {
                    self.selectedMasterServer = masterServer
                }
            }
            .listStyle(SidebarListStyle())
        }
    }
}
