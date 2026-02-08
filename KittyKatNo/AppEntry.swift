//
//  KittyKatNoApp.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/6/26.
//

import SwiftUI

@main
struct AppEntry: App {
    @StateObject var game = GameService()
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(game)
        }
    }
}
