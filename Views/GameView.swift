//
//  GameView.swift
//  airpong
//
//  Created by Valentin Genest on 29/07/2024.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            Text("Score")
                .font(.title)
            HStack {
                Text("You: \(viewModel.gameState.playerScore)")
                Text("Opponent: \(viewModel.gameState.opponentScore)")
            }
            .padding()
            
            Spacer()
            
            if viewModel.isGameOver {
                Text("Game Over!")
                    .font(.title)
                    .foregroundColor(.red)
                
                Button("Restart Game") {
                    viewModel.startGame()
                }
                .padding()
                .background(viewModel.canStartNewGame ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!viewModel.canStartNewGame)
            } else if viewModel.isServing && viewModel.canServe {
                VStack {
                    Text("Serve")
                        .font(.title2)
                    ProgressView(value: viewModel.serveBallHeight)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                    if viewModel.isPhoneOrientedForServe {
                        Text(viewModel.canHitBall ? "Shake up to hit the ball!" : "Lift your phone upward to serve!")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.green)
                    } else {
                        Text("Orient your phone upward to serve")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                    }
                    Text("Ball Height: \(String(format: "%.2f", viewModel.serveBallHeight))")
                        .font(.caption)
                        .padding(.top)
                }
            }
            else if viewModel.ballInPlay {
                VStack {
                    Text("Ball Distance")
                    ProgressView(value: viewModel.ballProximity)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                    
                    Text("Ball Speed: \(String(format: "%.2f", viewModel.ballSpeed))")
                        .font(.caption)
                    
                    if viewModel.lastHitWasSmash {
                        Text("SMASH!")
                            .font(.title)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Text(viewModel.ballProximity >= 0.8 ? "Shake hard to SMASH!" : "Shake your phone to hit the ball!")
                        .font(.headline)
                        .padding()
                }
            } else {
                Text("Get ready for next serve")
                    .font(.headline)
                    .padding()
            }
                
            Spacer()
            
            // Bouton de debug pour le score
            Button("Score Point (Debug)") {
                viewModel.playerScores()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
            .padding()
            .navigationTitle("Ping Pong Game")
            .onAppear {
                viewModel.startGame()
            }
            .onDisappear {
                viewModel.endGame()
            }
    }
}

