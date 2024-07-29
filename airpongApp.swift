//
//  airpongApp.swift
//  airpong
//
//  Created by Valentin Genest on 29/07/2024.
//

import SwiftUI

@main
struct airpongApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(viewModel: GameViewModel())
        }
    }
}
