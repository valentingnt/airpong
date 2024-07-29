//
//  GameViewModel.swift
//  airpong
//
//  Created by Valentin Genest on 29/07/2024.
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState = GameState()
    @Published var currentPlayer: Player?
    
    // Ajoutez des méthodes pour gérer la logique du jeu
}
