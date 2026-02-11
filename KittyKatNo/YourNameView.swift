//
//  YourNameView.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/10/26.
//

import SwiftUI

struct YourNameView: View {
    @AppStorage("yourName") var yourName = ""
    @State private var userName = ""
    var body: some View {
        NavigationStack {
            VStack {
                Text("This will be the name associated with this device")
                TextField("Your Name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                Button("Submit") {
                    yourName = userName
                }
                .buttonStyle(.borderedProminent)
                .disabled(userName.isEmpty)
                Image("LaunchScreen")
                Spacer()
            }
            .padding()
            .navigationTitle("Tic Tac Toe")
        }
    }
        
}

#Preview {
    YourNameView()
}
