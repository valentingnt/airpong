import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ScoreView(playerScore: viewModel.gameState.playerScore, opponentScore: viewModel.gameState.opponentScore)
            
            Spacer()
            
            if viewModel.gameState.isGameOver {
                GameOverView(canStartNewGame: viewModel.canStartNewGame, onRestart: viewModel.startGame)
            } else if viewModel.isServing && viewModel.canServe {
                ServeView(viewModel: viewModel)
            } else if viewModel.ballInPlay {
                BallPlayView(viewModel: viewModel)
            } else {
                Text("Get ready for next serve")
                    .font(.headline)
                    .padding()
            }
                
            Spacer()
            
            #if DEBUG
            DebugScoreButton(action: viewModel.playerScores)
            #endif
        }
        .padding()
        .navigationTitle("Air Pong")
        .onAppear(perform: viewModel.startGame)
        .onDisappear(perform: viewModel.endGame)
    }
}

struct ScoreView: View {
    let playerScore: Int
    let opponentScore: Int
    
    var body: some View {
        VStack {
            Text("Score")
                .font(.title)
            HStack {
                Text("You: \(playerScore)")
                Text("Opponent: \(opponentScore)")
            }
            .padding()
        }
    }
}

struct GameOverView: View {
    let canStartNewGame: Bool
    let onRestart: () -> Void
    
    var body: some View {
        VStack {
            Text("Game Over!")
                .font(.title)
                .foregroundColor(.red)
            
            Button("Restart Game", action: onRestart)
                .padding()
                .background(canStartNewGame ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!canStartNewGame)
        }
    }
}

struct ServeView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
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
}

struct BallPlayView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
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
    }
}

#if DEBUG
struct DebugScoreButton: View {
    let action: () -> Void
    
    var body: some View {
        Button("Score Point (Debug)", action: action)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
#endif

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel())
    }
}
