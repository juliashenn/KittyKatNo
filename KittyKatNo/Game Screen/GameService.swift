//
//  GameService.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/6/26.
//

import SwiftUI
internal import Combine

class GameService: ObservableObject {
    @Published var player1 = Player(gamePiece: .fish, name: "Player1")
    @Published var player2 = Player(gamePiece: .cat, name: "Player2")
    @Published var possibleMoves = Move.all
    @Published var gameOver = false
    @Published var gameBoard = GameSquare.reset
    @Published var isThinking = false
    
    var gameType = GameType.single
    
    var selectedInd: Int = -1 // if cat is selected, hold it
    
    var currentPlayer : Player {
        if player1.isCurrent {
            return player1
        } else {
            return player2
        }
    }
    
    var gameStarted: Bool {
        player1.isCurrent || player2.isCurrent
    }
    
    var boardDisabled: Bool {
        gameOver || !gameStarted || isThinking
    }
    
    func setupGame(gameType: GameType, player1Name: String, player2Name: String) {
        switch gameType {
        case .single:
            self.gameType = .single
            self.player2.name = player2Name
        case .bot:
            self.gameType = .bot
            self.player2.name = UIDevice.current.name
        case .peer:
            self.gameType = .peer
        case .undetermined:
            break
        }
        self.player1.name = player1Name
    }
    
    func resetGame() {
        player1.isCurrent = false
        player2.isCurrent = false
        player1.moves.removeAll()
        player2.moves.removeAll()
        gameOver = false
        possibleMoves = Move.all
        gameBoard = GameSquare.reset
    }
    
    func updateMoves(index: Int) {
        if player1.isCurrent {
            player1.moves.append(index + 1)
            gameBoard[index].player = player1
        } else {
            player2.moves.append(index + 1)
            gameBoard[index].player = player2
        }
        gameBoard[index].enabled = false
        
    }
    
    func checkIfWinner() {
        if player1.isWinner || player2.isWinner {
            gameOver = true
        }
    }
    
    func toggleCurrent() {
        player1.isCurrent.toggle()
        player2.isCurrent.toggle()
        let players = [player1, player2]
            if let current = players.first(where: { $0.name == currentPlayer.name }) {
                current.gamePiece == .cat ? enableCats() : disableCats()
            }
    }
    
    func makeMove(at index: Int) {
        if gameBoard[index].player == nil {
            withAnimation {
                print("making move at \(index)")
                updateMoves(index: index)
                disableEating()
            }
            checkIfWinner()
            if !gameOver {
                if let matchingIndex = possibleMoves.firstIndex(where: {$0 == (index + 1)}) {
                    possibleMoves.remove(at: matchingIndex)
                }
                toggleCurrent()
                if gameType == .bot && currentPlayer.name == player2.name {
                    Task {
                        await deviceMove()
                    }
                }
            }
            if possibleMoves.isEmpty {
                gameOver = true
            }
        }
        else {
            if selectedInd != -1 {
                withAnimation {
                    gameBoard[selectedInd].player = nil
                    possibleMoves.append(selectedInd) // cat jumps so its empty now
                    updateMoves(index: index) // adds new cat pos to curr player moves
                }
                if player1.isCurrent { // p1 is current and therefore is cat
                    if let matchingIndex = player2.moves.firstIndex(where: {$0 == (index + 1)}) {
                        player2.moves.remove(at: matchingIndex) // remove fish from p2 moves
                    }
                    if let matchingIndex = player1.moves.firstIndex(where: {$0 == (selectedInd + 1)}) {
                        player1.moves.remove(at: matchingIndex) // remove cat from p1 moves
                    }
                } else {
                    if let matchingIndex = player1.moves.firstIndex(where: {$0 == (index + 1)}) {
                        player1.moves.remove(at: matchingIndex)
                    }
                    if let matchingIndex = player2.moves.firstIndex(where: {$0 == (selectedInd + 1)}) {
                        player2.moves.remove(at: matchingIndex) // remove cat from p1 moves
                    }
                }
                disableEating()
                checkIfWinner()
                if !gameOver {
                    
                    toggleCurrent()
                    if gameType == .bot && currentPlayer.name == player2.name {
                        Task {
                            await deviceMove()
                        }
                    }
                }
                if possibleMoves.isEmpty {
                    gameOver = true
                }
            }
        }
    }
    
    // need to change possible moves for the cat. it includes all empty spaces
    // as well as orthogonal spaces to current moves if they also have a fish there
    // cat at ind, then it can eat at ind - 1, ind + 1, ind - 5, ind + 5 (if theres also a fish there)
    // player1.moves = cat and player2.moves = fish, then for each cat move, if there exists the four possible indices in fish moves, add to possibleEats
    // its cats turn, add cat past moves as possible moves, when its selected, its gotta somehow check its orthogonal and enable the possible ones.
    // possibleMoves as empty squares,
    
    func enableEating(index: Int) {
        print("enable eating")
        disableEating()
        if index == selectedInd { // double selected cat = deselecting
            return
        }
        if index > 2 {
            // enable index -3
            gameBoard[index - 3].enabled = true
        }
        if index < 6 {
            // enable index + 3
            gameBoard[index + 3].enabled = true
        }
        if index % 3 > 0 {
            // enable index - 1
            gameBoard[index - 1].enabled = true
        }
        if index % 3 < 2 {
            // enable index + 1
            gameBoard[index + 1].enabled = true
        }
        selectedInd = index
    }
    
    func disableEating() {
        if selectedInd != -1 {
            print("disable eating")
            if selectedInd > 2 {
                // enable index -3
                gameBoard[selectedInd - 3].enabled = false
            }
            if selectedInd < 6 {
                // enable index + 3
                gameBoard[selectedInd + 3].enabled = false
            }
            if selectedInd % 3 > 0 {
                // enable index - 1
                gameBoard[selectedInd - 1].enabled = false
            }
            if selectedInd % 3 < 2 {
                // enable index + 1
                gameBoard[selectedInd + 1].enabled = false
            }
            selectedInd = -1
        }
    }
    
    func enableCats() {
        if player1.gamePiece == .cat {
            for move in player1.moves {
                gameBoard[move-1].enabled = true
            }
        } else {
            for move in player2.moves {
                gameBoard[move-1].enabled = true
            }
        }
    }
    
    func disableCats() {
        if player1.gamePiece == .cat {
            for move in player1.moves {
                gameBoard[move-1].enabled = false
            }
        } else {
            for move in player2.moves {
                gameBoard[move-1].enabled = false
            }
        }
    }
    
    func deviceMove() async {
        isThinking.toggle()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        if let move = possibleMoves.randomElement() {
            makeMove(at: move - 1)
        }
        isThinking.toggle()
    }
}
