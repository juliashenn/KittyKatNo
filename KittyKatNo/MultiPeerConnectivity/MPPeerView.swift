//
//  MPPeerView.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/14/26.
//

import SwiftUI
import MultipeerConnectivity

struct MPPeerView: View {
    @EnvironmentObject var connectionManager: MPConnectionManager
    @EnvironmentObject var game: GameService
    @Binding var startGame: Bool
    var body: some View {
        VStack {
            Text("Available Players:")
            List(connectionManager.availablePeers, id: \.self) { peer in
                HStack {
                    Text(peer.displayName)
                    Spacer()
                    Button("Select") { // select sends invitation to person, and then they get accept or reject 
                        game.gameType = .peer
                        connectionManager.nearbyServiceBrowser.invitePeer(peer, to: connectionManager.session, withContext: nil, timeout: 30)
                        game.player1.name = connectionManager.myPeerId.displayName
                        game.player2.name = peer.displayName
                    }
                    .buttonStyle(.borderedProminent)
                }
                .alert("Received Invitation from \(connectionManager.receivedInviteFrom?.displayName ?? "Unknown")", isPresented: $connectionManager.receivedInvitation) {
                    Button("Accept") {
                        // this gets sent to session delegate did receive (MPConnection Manager line 146
                        if let invitationHandler = connectionManager.invitationHandler {
                            invitationHandler(true, connectionManager.session)
                            game.player1.name = connectionManager.receivedInviteFrom?.displayName ?? "Unknown"
                            game.player2.name = connectionManager.myPeerId.displayName
                            game.gameType = .peer
                        }
                    }
                    Button("Reject") {
                        if let invitationHandler = connectionManager.invitationHandler {
                            invitationHandler(false, nil)
                        }
                    }
                }
            }
        }
        .onAppear {
            connectionManager.isAvailable = true
            connectionManager.startBrowsing()
        }
        .onDisappear {
            connectionManager.stopBrowsing()
            connectionManager.isAvailable = false
            // connectionManager.stopAdvertising() is in tutorial but it should've been called when isAvailable = false anyway
        }
        // initial true means its called when its initialized/appears (no change needed) 
        .onChange(of: connectionManager.paired, initial: false) { oldValue, newValue in
            startGame = newValue
        }
    }
}

#Preview {
    MPPeerView(startGame: .constant(false))
        .environmentObject(MPConnectionManager(yourName: "testing"))
        .environmentObject(GameService())
}
