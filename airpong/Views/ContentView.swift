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
        VStack {
            Text("Ping Pong Game")
            // Ajoutez plus d'éléments UI ici
        }
    }
}

#Preview {
    ContentView()
}
