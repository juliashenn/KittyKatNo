//
//  SquareView.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/7/26.
//

import SwiftUI
import MultipeerConnectivity

struct SquareView: View {
    @EnvironmentObject var game: GameService
    @EnvironmentObject var connectionManager: MPConnectionManager
    private var isEnabled: Bool {
        game.gameBoard[index].player == nil || game.gameBoard[index].enabled
//        || (game.gameBoard[index].player?.gamePiece == .cat && game.currentPlayer.name == game.gameBoard[index].player?.name)
    }
    let index: Int
    var body: some View {
        Button {
            print("pressed")
            if !game.isThinking {
                if game.gameBoard[index].player != nil {
                    if game.selectedInd != -1 && game.gameBoard[index].player?.gamePiece == .fish{
                        game.makeMove(at: index)
                    }
                    else if game.gameBoard[index].player?.gamePiece == .cat && game.currentPlayer.name == game.gameBoard[index].player?.name {
                        game.enableEating(index: index)
                    }
                } else {
                    game.makeMove(at: index)
                }
                // and enabled because its an empty space
//
            }
            if game.gameType == .peer {
                let gameMove = MPGameMove(action: .move, playerName: connectionManager.myPeerId.displayName, index: index, removeInd: nil)
                connectionManager.send(gameMove: gameMove)
            }
        } label: {
            game.gameBoard[index].image
                .resizable()
                .frame(width:100, height: 100)
                .overlay(
                            Rectangle()
                                .stroke(Color.accentColor, lineWidth: isEnabled ? 6 : 0)
                        )
        }
        .disabled(!isEnabled)
        // need to make it so if its cat's turn, the cats arent disabled
        // if its cat, and its cats turn, and this is selected, we need to enable the orthogonal squares (prob need to change gameServices and add an enabled property here)
        //.foregroundColor(.primary)
    }
}

#Preview {
    SquareView(index: 1)
        .environmentObject(GameService())
        .environmentObject(MPConnectionManager(yourName: "testing"))
}
