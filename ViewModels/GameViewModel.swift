import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState = GameState()
    @Published var ballProximity: Double = 0.0 // 0.0 (far) to 1.0 (close)
    @Published var ballSpeed: Double = 0.015
    @Published var lastHitWasSmash: Bool = false
    @Published var isServing: Bool = true
    @Published var serveBallHeight: Double = 0.0 // 0.0 (low) to 1.0 (high)
    @Published var isGameOver: Bool = false
    @Published var ballInPlay: Bool = false
    @Published var canHitBall: Bool = false
    @Published var canStartNewGame: Bool = true
    @Published var canServe: Bool = true
    @Published var isPhoneOrientedForServe: Bool = false
    
    private let pointScoredDelay: TimeInterval = 1.5
    private let gameOverDelay: TimeInterval = 1 // 1 seconde de délai après un game over
    private let motionService: MotionService
    private let hapticService: HapticService
    private var cancellables = Set<AnyCancellable>()
    private var ballTimer: Timer?
    private var serveTimer: Timer?
    private var hasBouncedOnTable: Bool = false
    private var lastHitTime: Date?
    private let minimumTimeBetweenHits: TimeInterval = 0.5
    
    private var serveVelocity: Double = 0.0
    private var lastServeUpdateTime: Date?
    private let gravity: Double = 9.8
    private var serveMaxHeight: Double = 0.0

    init() {
        self.motionService = MotionService()
        self.hapticService = HapticService()
        setupMotionDetection()
    }

    private func setupMotionDetection() {
        motionService.$acceleration
            .throttle(for: .seconds(0.05), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] acceleration in
                guard let self = self else { return }
                
                let intensity = self.motionService.getMovementIntensity()
                
                // Mise à jour de l'orientation du téléphone
                self.isPhoneOrientedForServe = acceleration.z < -0.7 // Le téléphone est suffisamment incliné vers le haut
                
                if self.isServing {
                    if acceleration.z < -0.5 && intensity > 0.25 {
                        self.updateServe(withIntensity: intensity)
                    }
                } else if intensity > 0.25 {
                    self.hitBall(withIntensity: intensity)
                }
            }
            .store(in: &cancellables)
    }

    func startGame() {
        guard canStartNewGame else { return }
        
        gameState = GameState()
        isGameOver = false
        isServing = true
        ballInPlay = false
        ballProximity = 0.0
        ballSpeed = 0.015
        lastHitWasSmash = false
        serveBallHeight = 0.0
        hasBouncedOnTable = false
        lastHitTime = nil
        canStartNewGame = true
        canServe = true
        isPhoneOrientedForServe = false
        
        motionService.startAccelerometerUpdates()
        prepareServe()
    }

    func endGame() {
        motionService.stopAccelerometerUpdates()
        ballTimer?.invalidate()
        serveTimer?.invalidate()
        hapticService.playGameOverHaptic()
        isGameOver = true
    }

    private func prepareServe() {
        isServing = true
        ballInPlay = false
        serveBallHeight = 0.0
        serveVelocity = 0.0
        serveMaxHeight = 1.0
        lastServeUpdateTime = nil
        ballProximity = 0.0
        canHitBall = false
        
        serveTimer?.invalidate()
        serveTimer = nil
        
        if canServe {
            serveTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
                self?.updateServeBallHeight()
            }
        }
    }

    private func updateServeBallHeight() {
        let currentTime = Date()
        
        if let lastUpdate = lastServeUpdateTime {
            let deltaTime = currentTime.timeIntervalSince(lastUpdate)
            serveBallHeight += serveVelocity * deltaTime
            serveVelocity -= gravity * deltaTime
            
            if serveBallHeight > serveMaxHeight {
                serveMaxHeight = serveBallHeight
            }
            
            if serveBallHeight < 0 {
                serveBallHeight = 0
                serveVelocity = 0
                lastServeUpdateTime = nil
                canHitBall = false
            } else {
                lastServeUpdateTime = currentTime
                canHitBall = serveBallHeight > 0.1
            }
            
            serveBallHeight = max(0, min(serveBallHeight, 1))
            
            hapticService.playBallTossHaptic(height: serveBallHeight)
        }
    }

    private func updateServe(withIntensity intensity: Double) {
        let currentTime = Date()
        if serveVelocity == 0 || (lastHitTime == nil || currentTime.timeIntervalSince(lastHitTime!) > minimumTimeBetweenHits) {
            if serveVelocity == 0 {
                serveVelocity = intensity * 4.5
                lastServeUpdateTime = currentTime
                hapticService.playPaddleHitHaptic(intensity: Float(intensity))
            } else if canHitBall {
                hitBall(withIntensity: intensity)
            }
            lastHitTime = currentTime
        }
    }

    private func startBallMovement() {
        ballTimer?.invalidate()
        ballTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            self?.updateBallProximity()
        }
    }

    private func updateBallProximity() {
        guard !isGameOver && ballInPlay else { return }
        
        ballProximity += ballSpeed
        
        if !hasBouncedOnTable && ballProximity > 0.5 {
            hapticService.playTableBounceHaptic()
            hasBouncedOnTable = true
        } else {
            hapticService.playBallApproachingHaptic(progress: ballProximity)
        }
        
        if ballProximity > 1.0 {
            opponentScores()
        }
    }

    func hitBall(withIntensity intensity: Double) {
        guard !isGameOver && (ballInPlay || (isServing && canHitBall)) else { return }
        
        let currentTime = Date()
        guard lastHitTime == nil || currentTime.timeIntervalSince(lastHitTime!) > minimumTimeBetweenHits else {
            return
        }
        
        lastHitTime = currentTime
        
        if isServing {
            print("Serve hit at height: \(serveBallHeight)")
            hapticService.playPaddleHitHaptic(intensity: Float(intensity))
            isServing = false
            serveTimer?.invalidate()
            serveTimer = nil
            ballInPlay = true
            startBallMovement()
        } else {
            if ballProximity >= 0.8 && intensity >= 0.6 {
                print("Smash with intensity: \(intensity)")
                ballProximity = 0.0
                ballSpeed = 0.03 + (intensity * 0.02)
                lastHitWasSmash = true
                hapticService.playSmashHaptic()
            } else {
                print("Normal hit with intensity: \(intensity)")
                ballProximity = 0.0
                ballSpeed = 0.015 + (intensity * 0.015)
                lastHitWasSmash = false
                hapticService.playPaddleHitHaptic(intensity: Float(intensity))
            }
        }
        
        hasBouncedOnTable = false
    }

    private func opponentScores() {
        gameState.opponentScore += 1
        ballInPlay = false
        canServe = false
        isServing = false
        hapticService.playPointLostHaptic()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + pointScoredDelay) {
            self.checkForGameOver()
            if !self.isGameOver {
                self.isServing = true
                self.canServe = true
                self.prepareServe()
            }
        }
    }

    func playerScores() {
        guard !isGameOver else { return }
        
        gameState.playerScore += 1
        ballInPlay = false
        canServe = false
        isServing = false
        hapticService.playPointWonHaptic()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + pointScoredDelay) {
            self.checkForGameOver()
            if !self.isGameOver {
                self.isServing = true
                self.canServe = true
                self.prepareServe()
            }
        }
    }

    private func checkForGameOver() {
        if gameState.playerScore >= gameState.winningScore || gameState.opponentScore >= gameState.winningScore {
            isGameOver = true
            endGame()
            canStartNewGame = false
            DispatchQueue.main.asyncAfter(deadline: .now() + gameOverDelay) {
                self.canStartNewGame = true
            }
        }
    }
}
