//
//  ContentView.swift
//  airpong
//
//  Created by Valentin Genest on 29/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Ping Pong Game")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: GameView(viewModel: gameViewModel)) {
                    Text("Start Game")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Text("Shake your phone to hit the ball!")
                    .font(.subheadline)
                    .padding()
            }
        }
    }
}
