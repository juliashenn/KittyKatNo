//
//  GameView.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/6/26.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("End Game") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Tic Tac Toe")
        }
    }
}

#Preview {
    GameView()
}
