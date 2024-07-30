import SwiftUI
import CoreMotion
import Combine

class GameViewModel: ObservableObject {
    @Published private(set) var gameState = GameState()
    @Published private(set) var ballProximity: Double = 0.0
    @Published private(set) var ballSpeed: Double = 0.015
    @Published private(set) var lastHitWasSmash: Bool = false
    @Published private(set) var isServing: Bool = true
    @Published private(set) var serveBallHeight: Double = 0.0
    @Published private(set) var ballInPlay: Bool = false
    @Published private(set) var canHitBall: Bool = false
    @Published private(set) var canStartNewGame: Bool = true
    @Published private(set) var canServe: Bool = true
    @Published private(set) var isPhoneOrientedForServe: Bool = false

    private let motionService: MotionService
    private let hapticService: HapticService
    private var cancellables = Set<AnyCancellable>()
    private var ballTimer: Timer?
    private var serveTimer: Timer?
    
    private let minServeBallHeight: Double = 0.3
    private let pointScoredDelay: TimeInterval = 1.5
    private let gameOverDelay: TimeInterval = 1
    private let minimumTimeBetweenHits: TimeInterval = 0.5
    private let motionThreshold: Double = 0.05
    private let minHitIntensity: Double = 3.0
    private let maxHitIntensity: Double = 10.0
    private let minServeIntensity: Double = 3.0
    private let gravity: Double = 9.8
    
    private var isServeTossing: Bool = false
    private var hasBouncedOnTable: Bool = false
    private var lastHitTime: Date?
    private var randomBouncePoint: Double = 0.5
    private var lastMotionIntensity: Double = 0
    private var serveVelocity: Double = 0.0
    private var lastServeUpdateTime: Date?
    private var serveMaxHeight: Double = 0.0

    init(motionService: MotionService = MotionService(), hapticService: HapticService = HapticService()) {
        self.motionService = motionService
        self.hapticService = hapticService
        setupMotionDetection()
    }

    private func setupMotionDetection() {
        motionService.$acceleration
            .throttle(for: .seconds(0.016), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] acceleration in
                self?.handleAccelerationUpdate(acceleration)
            }
            .store(in: &cancellables)
    }

    private func handleAccelerationUpdate(_ acceleration: CMAcceleration) {
        let rawIntensity = motionService.getMovementIntensity()
        let scaledIntensity = scaleIntensity(rawIntensity)
        
        isPhoneOrientedForServe = acceleration.z < -0.7

        if isServing {
            handleServeMotion(rawIntensity: rawIntensity, scaledIntensity: scaledIntensity)
        } else if ballInPlay && rawIntensity > minHitIntensity {
            hitBall(withIntensity: scaledIntensity)
        }
    }

    private func handleServeMotion(rawIntensity: Double, scaledIntensity: Double) {
        if isServeTossing {
            if isPhoneOrientedForServe && rawIntensity > minServeIntensity {
                startServeBallToss(withIntensity: rawIntensity)
            }
        } else if canHitBall && rawIntensity > minHitIntensity {
            hitServeBall(withIntensity: scaledIntensity)
        }
    }

    private func scaleIntensity(_ rawIntensity: Double) -> Double {
        return min(max((rawIntensity - minHitIntensity) / (maxHitIntensity - minHitIntensity), 0), 1)
    }

    func startGame() {
        guard canStartNewGame else { return }
        
        resetGameState()
        motionService.startAccelerometerUpdates()
        prepareServe()
    }

    private func resetGameState() {
        gameState.reset()
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
        randomBouncePoint = 0.5
    }

    func endGame() {
        motionService.stopAccelerometerUpdates()
        ballTimer?.invalidate()
        serveTimer?.invalidate()
        hapticService.playGameOverHaptic()
        gameState.isGameOver = true
    }

    func prepareServe() {
        isServing = true
        ballInPlay = false
        serveBallHeight = 0.0
        serveVelocity = 0.0
        serveMaxHeight = 1.0
        lastServeUpdateTime = nil
        canHitBall = false
        isServeTossing = true
        
        serveTimer?.invalidate()
        serveTimer = nil
    }

    private func updateServeBallHeight() {
        let currentTime = Date()
        
        if let lastUpdate = lastServeUpdateTime {
            let deltaTime = currentTime.timeIntervalSince(lastUpdate)
            serveBallHeight += serveVelocity * deltaTime
            serveVelocity -= gravity * deltaTime
            
            serveMaxHeight = max(serveMaxHeight, serveBallHeight)
            
            if serveBallHeight < 0 {
                resetServe()
            } else {
                lastServeUpdateTime = currentTime
                canHitBall = serveBallHeight >= minServeBallHeight
            }
            
            serveBallHeight = max(0, min(serveBallHeight, 1))
            
            hapticService.playBallTossHaptic(height: serveBallHeight)
        }
    }

    private func resetServe() {
        serveBallHeight = 0
        serveVelocity = 0
        lastServeUpdateTime = nil
        canHitBall = false
        isServeTossing = true
    }

    private func startServeBallToss(withIntensity intensity: Double) {
        guard isServeTossing else { return }
        
        serveVelocity = intensity * 0.5
        lastServeUpdateTime = Date()
        hapticService.playBallHitHaptic(intensity: Float(scaleIntensity(intensity)))
        
        startServeTossTimer()
        
        isServeTossing = false
    }
    
    private func startServeTossTimer() {
        serveTimer?.invalidate()
        serveTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateServeBallHeight()
        }
    }
    
    private func hitServeBall(withIntensity intensity: Double) {
        guard canHitBall && serveBallHeight >= minServeBallHeight else { return }
        
        hapticService.playBallHitHaptic(intensity: Float(serveBallHeight * intensity))
        isServing = false
        serveTimer?.invalidate()
        ballInPlay = true
        startBallMovement()
        
        canHitBall = false
        serveBallHeight = 0
    }

    private func startBallMovement() {
        ballTimer?.invalidate()
        ballTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            self?.updateBallProximity()
        }
        hasBouncedOnTable = false
        randomBouncePoint = Double.random(in: 0.4...0.6)
        ballProximity = 0.0
    }

    private func updateBallProximity() {
        guard !gameState.isGameOver && ballInPlay else { return }
         
        ballProximity += ballSpeed
        ballSpeed *= 1.001
         
        if !hasBouncedOnTable && ballProximity > randomBouncePoint {
            handleBallBounce()
        } else {
            hapticService.playBallApproachingHaptic(progress: ballProximity)
        }
         
        if ballProximity > 1.0 {
            opponentScores()
        }
    }

    private func handleBallBounce() {
        hapticService.playTableBounceHaptic()
        hasBouncedOnTable = true
        ballSpeed *= 0.95
    }

    func hitBall(withIntensity intensity: Double) {
        guard !gameState.isGameOver && ballInPlay else { return }
        
        let currentTime = Date()
        guard lastHitTime == nil || currentTime.timeIntervalSince(lastHitTime!) > minimumTimeBetweenHits else {
            return
        }
        
        if !hasBouncedOnTable {
            handleEarlyHit()
            return
        }
        
        lastHitTime = currentTime
        
        if isSmashHit(intensity: intensity) {
            performSmashHit(intensity: intensity)
        } else {
            performNormalHit(intensity: intensity)
        }
        
        resetBallState()
    }

    private func handleEarlyHit() {
        hapticService.playPointLostHaptic()
        opponentScores()
    }

    private func isSmashHit(intensity: Double) -> Bool {
        return ballProximity >= 0.90 && intensity >= 0.7
    }

    private func performSmashHit(intensity: Double) {
        ballProximity = 0.0
        ballSpeed = 0.03 + (intensity * 0.04)
        lastHitWasSmash = true
        hapticService.playBallHitHaptic(intensity: Float(intensity * 1.2))
    }

    private func performNormalHit(intensity: Double) {
        ballProximity = 0.0
        ballSpeed = 0.015 + (intensity * 0.025)
        lastHitWasSmash = false
        hapticService.playBallHitHaptic(intensity: Float(intensity * 0.8))
    }

    private func resetBallState() {
        randomBouncePoint = Double.random(in: 0.4...0.6)
        hasBouncedOnTable = false
    }

    private func opponentScores() {
        gameState.incrementOpponentScore()
        resetAfterPoint()
    }

    func playerScores() {
        guard !gameState.isGameOver else { return }
        
        gameState.incrementPlayerScore()
        resetAfterPoint()
    }

    private func resetAfterPoint() {
        ballInPlay = false
        canServe = false
        isServing = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + pointScoredDelay) { [weak self] in
            self?.prepareNextServe()
        }
    }

    private func prepareNextServe() {
        if !gameState.isGameOver {
            isServing = true
            canServe = true
            prepareServe()
        }
    }
}
