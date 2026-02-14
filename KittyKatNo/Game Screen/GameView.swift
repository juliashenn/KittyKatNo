//
//  GameView.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/6/26.
//

import SwiftUI
import MultipeerConnectivity

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var connectionManager: MPConnectionManager
    @EnvironmentObject var game: GameService
    var body: some View {
        NavigationStack {
            VStack {
                if [game.player1.isCurrent, game.player2.isCurrent].allSatisfy({$0 == false}) {
                    Text("Select a player to start") // that $0 means both are false
                }
                HStack {
                    // !!! want to make this randomized later
                    Button(game.player1.name) {
                        game.player1.isCurrent = true
                        if game.gameType == .peer {
                            let gameMove = MPGameMove(action: .start, playerName: game.player1.name, index: nil)
                            connectionManager.send(gameMove: gameMove)
                        }
                    }
                    .buttonStyle(PlayerButtonStyle(isCurrent: game.player1.isCurrent))
                    
                    Button(game.player2.name) {
                        game.player2.isCurrent = true
                        if game.gameType == .bot {
                            Task {
                                await game.deviceMove()
                            }
                        }
                        if game.gameType == .peer {
                            let gameMove = MPGameMove(action: .start, playerName: game.player2.name, index: nil)
                            connectionManager.send(gameMove: gameMove)
                        }
                    }
                    .buttonStyle(PlayerButtonStyle(isCurrent: game.player2.isCurrent))
                }
                .disabled(game.gameStarted) // before game starts, need to decide who goes first
                
                // Make the game board
                VStack {
                    HStack {
                        ForEach(0...2, id: \.self) {
                            index in SquareView(index:index)
                        }
                    }
                    HStack {
                        ForEach(3...5, id: \.self) {
                            index in SquareView(index:index)
                        }
                    }
                    HStack {
                        ForEach(6...8, id: \.self) {
                            index in SquareView(index:index)
                        }
                    }
                }
                .overlay {
                    if game.isThinking {
                        VStack {
                            Text(" Hmm Thinking... ")
                                .foregroundColor(.accent)
                                .background(Rectangle().fill(Color(.systemBackground)))
                            ProgressView()
                        }
                    }
                }
                .disabled(game.boardDisabled || !game.gameStarted ||
                          (game.gameType == .peer && connectionManager.myPeerId.displayName != game.currentPlayer.name)) // cant place while its not my turn
                
                VStack {
                    if game.gameOver {
                        Text("Game Over")
                        if game.possibleMoves.isEmpty {
                            Text("Nobody won, it's a tie!")
                        } else {
                            Text("\(game.currentPlayer.name) won!")
                        }
                        Button("New Game") {
                            game.resetGame()
                            if game.gameType == .peer {
                                let gameMove = MPGameMove(action: .reset, playerName: nil, index: nil)
                                connectionManager.send(gameMove: gameMove)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .font(.largeTitle)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("End Game") {
                        dismiss()
                        if game.gameType == .peer {
                            let gameMove = MPGameMove(action: .end, playerName: nil, index: nil)
                            connectionManager.send(gameMove: gameMove)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Tic Tac Toe")
            .onAppear {
                game.resetGame()
                if game.gameType == .peer {
                    connectionManager.setup(game: game)
                }
            }
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameService())
}


struct PlayerButtonStyle : ButtonStyle {
    let isCurrent: Bool
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(isCurrent ? Color.accent : Color.gray) // if is current, then use accent color, else use gray
            )
            .foregroundColor(Color.white)
    }
    
}
