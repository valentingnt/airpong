struct GameState {
    var playerScore: Int = 0
    var opponentScore: Int = 0
    var isGameOver: Bool = false
    let winningScore: Int = 11
    
    mutating func reset() {
        playerScore = 0
        opponentScore = 0
        isGameOver = false
    }
    
    mutating func incrementPlayerScore() {
        playerScore += 1
        checkGameOver()
    }
    
    mutating func incrementOpponentScore() {
        opponentScore += 1
        checkGameOver()
    }
    
    private mutating func checkGameOver() {
        isGameOver = playerScore >= winningScore || opponentScore >= winningScore
    }
}
