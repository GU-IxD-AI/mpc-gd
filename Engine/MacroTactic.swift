//
//  MacroTactics.swift
//  Engine
//
//  Created by Powley, Edward on 16/03/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

enum MacroTacticType : Int {
    case none
    case stopClusterFromForming
    case destroyBlueBlockingWhites
    case tapRandomlyWhenQuiescent
    case jiggleWhenQuiescent
    case rainRainTactic
    case jackFrostTactic
    case slushSloshTactic
}

class MacroTactic {
    
    let settings: StrategySettings
    
    weak var playtester : MacroTacticPlaytester! = nil
    
    init(settings: StrategySettings) {
        self.settings = settings
    }
    
    func findMacroActions(_ fascinator: Fascinator) -> [MacroAction] {
        return []
    }
    
    static func create(_ settings: StrategySettings) -> MacroTactic! {
        switch settings.tactic {
        case .none: return nil
        case .stopClusterFromForming: return StopClusterFromForming(settings: settings)
        case .destroyBlueBlockingWhites: return DestroyBlueBlockingWhites(settings: settings)
        case .tapRandomlyWhenQuiescent: return TapRandomlyWhenQuiescent(settings: settings)
        case .jiggleWhenQuiescent: return JiggleWhenQuiescent(settings: settings)
        case .rainRainTactic: return RainRainTactic(settings: settings)
        case .jackFrostTactic: return JackFrostTactic(settings: settings)
        case .slushSloshTactic: return SlushSloshTactic(settings: settings)
        }
    }
    
    func distanceAtTime(_ time: CGFloat, _ ballA : Ball, _ ballB : Ball) -> CGFloat {
        let nextA = ballA.node.position + ballA.node.physicsBody!.velocity * time
        let nextB = ballB.node.position + ballB.node.physicsBody!.velocity * time
        return (nextA - nextB).magnitude()
    }
    
    func nearestDistance(_ ballA : Ball, _ ballB : Ball) -> CGFloat {
        let distNow = (ballA.node.position - ballB.node.position).magnitude()
        let distNext = distanceAtTime(playtester.deltaTime, ballA, ballB)
        
        if settings.useMovementPrediction {
            let velDiff = ballA.node.physicsBody!.velocity - ballB.node.physicsBody!.velocity
            let posDiff = ballA.node.position - ballB.node.position
            let timeOfClosestApproach = -posDiff.dot(velDiff) / velDiff.sqrMagnitude()
            if timeOfClosestApproach >= 0 && timeOfClosestApproach <= playtester.deltaTime {
                let dist = distanceAtTime(timeOfClosestApproach, ballA, ballB)
                return dist
            }
            else {
                return min(distNow, distNext)
            }
        }
        else {
            return distNow
        }
    }

}
