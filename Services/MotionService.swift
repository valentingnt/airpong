//
//  MotionService.swift
//  airpong
//
//  Created by Valentin Genest on 29/07/2024.
//

import CoreMotion

class MotionService: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var acceleration: CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    
    init() {
        motionManager.accelerometerUpdateInterval = 0.1
    }
    
    func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available")
            return
        }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self?.acceleration = data.acceleration
        }
    }
    
    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func getMovementIntensity() -> Double {
        let totalAcceleration = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )
        return min(max(totalAcceleration - 1.0, 0), 2) / 2 // Normalise entre 0 et 1
    }
}
