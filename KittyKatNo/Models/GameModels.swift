//
//  GameModels.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/6/26.
//

import Foundation

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
