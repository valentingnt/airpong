import CoreHaptics

class HapticService {
    private var engine: CHHapticEngine?
    
    init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            engine?.resetHandler = { [weak self] in
                print("Restarting Haptic engine")
                try? self?.engine?.start()
            }
        } catch {
            print("Failed to create the engine: \(error.localizedDescription)")
        }
    }
    
    private func playHapticEvent(intensity: Float, sharpness: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
    
    func playBallApproachingHaptic(progress: Double) {
        playHapticEvent(intensity: Float(progress) * 0.7, sharpness: 0.6)
    }
    
    func playBallHitHaptic(intensity: Float) {
        playHapticEvent(intensity: intensity, sharpness: 0.8)
    }
    
    func playTableBounceHaptic() {
        playHapticEvent(intensity: 1.0, sharpness: 0.9)
    }
    
    func playPointLostHaptic() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                self.playHapticEvent(intensity: 1.0, sharpness: 1.0)
            }
        }
    }
    
    func playGameOverHaptic() {
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                self.playHapticEvent(intensity: 1.0, sharpness: 0.5)
            }
        }
    }
    
    func playBallTossHaptic(height: Double) {
        playHapticEvent(intensity: Float(height) * 0.7, sharpness: 0.5 + Float(height) * 0.3)
    }
}
