//
//  GameModels.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/6/26.
//

import SwiftUI

enum GameType {
    case single, bot, peer, undetermined
    
    var description : String {
        switch self {
        case .single: return "Share your iPhone/iPad to play with a friend!"
        case .bot: return "Play against your iPhone/iPad"
        case .peer: return "Invite someone nearby who has this app running!"
        case .undetermined: return ""
        }
    }
}

enum GamePiece: String {
    case cat, fish
    var image: Image {
        Image(self.rawValue)
    }
}


struct Player {
    var gamePiece: GamePiece
    var name: String
    var moves: [Int] = []
    var isCurrent: Bool = false
    var isWinner: Bool {
        for moves in Move.winningMoves {
            if moves.allSatisfy(self.moves.contains) {
                return true
            }
        }
        return false
    }
}

enum Move {
    static var all = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    static var winningMoves = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [1, 5, 9],
        [3, 5, 7],
        [1, 4, 7],
        [2, 5, 8],
        [3, 6, 9]
    ]
}
