import SwiftUI

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Air Pong")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
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
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
