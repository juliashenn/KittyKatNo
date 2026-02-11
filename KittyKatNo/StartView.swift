//
//  ContentView.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/6/26.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var game: GameService
    @State private var gameType: GameType = .undetermined
    @AppStorage("yourName") var yourName = ""
    @State private var opponentName: String = ""
    @FocusState private var focus: Bool
    @State private var start: Bool = false
    @State private var changeName = false
    @State private var newName = ""
    init(yourName: String) {
        self.yourName = yourName
    }
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome \(yourName)!")
                    .font(.system(size: 28))
                    .padding()
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
                    if gameType == .single {
                        VStack {
                            TextField("Opponent's Name", text: $opponentName)
                        }
                        .padding()
                    }
                }
                .textFieldStyle(.roundedBorder)
                .focused($focus)
                .frame(width: 350)
                
                if gameType != .peer {
                    Button("Start Game") {
                        game.setupGame(gameType: gameType, player1Name: yourName, player2Name: opponentName)
                        focus = false
                        start.toggle()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        gameType == .undetermined ||
                        gameType == .single && opponentName.isEmpty
                    )
                    Image("LaunchScreen")
                    Button("Change Name") {
                        changeName.toggle()
                    }
                    .buttonStyle(.bordered)
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
            .alert("Change Name", isPresented: $changeName, actions: {
                TextField("New Name", text: $newName)
                Button("OK", role: .destructive) {
                    yourName = newName
                    exit(-1)
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Press OK to change name and restart the app")
            })
        }
    }
}

#Preview {
    StartView(yourName: "You")
        .environmentObject(GameService())
}
