//
//  GameSquare.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/7/26.
//

import Foundation
import SwiftUI

struct GameSquare {
    var ind: Int
    var player: Player?
    
    var image: Image {
        if let player = player {
            return player.gamePiece.image
        } else {
            return Image("none")
        }
    }
    
    static var reset: [GameSquare] {
        var squares = [GameSquare]()
        for index in 1...9 {
            squares.append(GameSquare(ind: index))
        }
        return squares
    }
}
