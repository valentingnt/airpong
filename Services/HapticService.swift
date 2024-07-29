//
//  HapticService.swift
//  airpong
//
//  Created by Valentin Genest on 29/07/2024.
//

import CoreHaptics

class HapticService {
    private var engine: CHHapticEngine?

    init() {
        prepareHaptics()
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    // Vibration pour la balle qui avance
    func playBallApproachingHaptic(progress: Double) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(progress) * 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.1)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }

    // Vibration pour la balle lancée en l'air
    func playBallTossHaptic(height: Double) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(height) * 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }

    // Vibration pour la balle qui tape la table
    func playTableBounceHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }

    // Vibration pour la balle qui tape la raquette
    func playPaddleHitHaptic(intensity: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }

    // Vibration pour un smash
    func playSmashHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
        
        do {
            let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }

    // Vibration for a lost point (punitive)
    func playPointLostHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.2)
        let event3 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.4)
        
        let continuousIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let continuousSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [continuousIntensity, continuousSharpness], relativeTime: 0.6, duration: 0.5)
        
        do {
            let pattern = try CHHapticPattern(events: [event1, event2, event3, continuousEvent], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }

    // Vibration pour un point gagné
    func playPointWonHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
        let event3 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.2)
        
        do {
            let pattern = try CHHapticPattern(events: [event1, event2, event3], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }

    // Vibration pour la fin du jeu
    func playGameOverHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.2)
        let event3 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.4)
        let event4 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.6)
        
        do {
            let pattern = try CHHapticPattern(events: [event1, event2, event3, event4], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}
