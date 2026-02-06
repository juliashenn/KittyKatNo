//
//  ContentView.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/6/26.
//

import SwiftUI

struct StartView: View {
    @State private var gameType: GameType = .undetermined
    @State private var yourName: String = ""
    @State private var opponentName: String = ""
    @FocusState private var focus: Bool
    @State private var start: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Game", selection: $gameType) {
                    Text("Select Game Type").tag(GameType.undetermined)
                    Text("Two Players sharing this device").tag(GameType.single)
                    Text("Challenge your device").tag(GameType.bot)
                    Text("Challenge a friend").tag(GameType.peer)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 2))
                Text(gameType.description)
                
                VStack {
                    switch gameType {
                    case .single:
                        VStack {
                            TextField("Your Name", text: $yourName)
                            TextField("Opponent's Name", text: $opponentName)
                        }
                    case .bot:
                        TextField("Your Name", text: $yourName)
                    case .peer:
                        EmptyView()
                    case .undetermined:
                        EmptyView()
                    }
                }
                .padding()
                .textFieldStyle(.roundedBorder)
                .focused($focus)
                .frame(width: 350)
                
                if gameType != .peer {
                    Button("Start Game") {
                        focus = false
                        start.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        gameType == .undetermined ||
                        gameType == .single && (yourName.isEmpty || opponentName.isEmpty) ||
                        gameType == .bot && yourName.isEmpty
                    )
                    Image("LaunchScreen")
                }
                Spacer()
                //            Image(systemName: "globe")
                //                .imageScale(.large)
                //                .foregroundStyle(.tint)
                //            Text("Hello, world!")
            }
            .padding()
            .fullScreenCover(isPresented: $start) {
                GameView()
            }
            .navigationTitle("Tic Tac Toe")
        }
    }
}

#Preview {
    StartView()
}
