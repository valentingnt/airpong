//
//  GameView.swift
//  airpong
//
//  Created by Valentin Genest on 29/07/2024.
//

import Foundation
import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            Text("Score: \(viewModel.gameState.playerScore) - \(viewModel.gameState.opponentScore)")
            // Ajoutez plus d'éléments UI spécifiques au jeu ici
        }
    }
}
