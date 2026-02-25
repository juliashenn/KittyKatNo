//
//  MPGameMove.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/14/26.
//

import Foundation

struct MPGameMove: Codable {
    enum Action: Int, Codable {
        case start, move, reset, end
    }
    let action: Action
    let playerName: String?
    let index: Int? // where the players piece is placed
    let removeInd: Int? // if its a cat eating as their move, remove the piece from here
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
