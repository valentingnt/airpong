//
//  MotionService.swift
//  airpong
//
//  Created by Valentin Genest on 29/07/2024.
//

import Foundation
import CoreMotion

class MotionService {
    private let motionManager = CMMotionManager()
    
    func startMotionUpdates(handler: @escaping (CMDeviceMotion) -> Void) {
        // Implémentez la logique pour détecter les mouvements
    }
}
