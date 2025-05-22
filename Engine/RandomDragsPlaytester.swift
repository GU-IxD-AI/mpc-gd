//
//  RandomDragsPlaytester.swift
//  MPCGD
//
//  Created by Mark Nelson on 5/21/25.
//

import Foundation
import SpriteKit

class RandomDragsPlaytester: AutomatedPlaytester {
    let dragSize = 20.0

    init(fascinator: Fascinator) {
        let playerSettings = AutoplayerSettings()
        super.init(fascinator: fascinator, playerSettings: playerSettings)
    }

    override func doAI() -> CGPoint? {
        let x = fascinator.lastFingerPos.x + Double.random(in: -dragSize...dragSize)
        let y = fascinator.lastFingerPos.y + Double.random(in: -dragSize...dragSize)
        // TODO: clamp to sceneSize
        print("Moving to: \(x), \(y)")
        print("Bounds: \(fascinator.sceneSize.width), \(fascinator.sceneSize.height)")
        return CGPoint(x:x, y:y)
    }
}
