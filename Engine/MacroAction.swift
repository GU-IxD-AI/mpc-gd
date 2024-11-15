//
//  MacroAction.swift
//  Engine
//
//  Created by Powley, Edward on 09/03/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

protocol MacroAction {
    func hasFinished() -> Bool
    func getNextAction() -> CGPoint?
    func getTieBreakScore(_ type: StrategySettings.TieBreakType) -> CGFloat
}

class DurationMacroAction : MacroAction {
    fileprivate(set) var stepNum : Int = 0
    let duration : Int
    
    init(duration : Int) {
        self.duration = duration
    }
    
    func getNextAction() -> CGPoint? {
        stepNum += 1
        return nil
    }
    
    func hasFinished() -> Bool {
        return stepNum >= duration
    }
    
    func getTieBreakScore(_ type: StrategySettings.TieBreakType) -> CGFloat {
        fatalError("getTieBreakScore not implemented")
    }
}

class DoNothingMacroAction : DurationMacroAction {
    override func getTieBreakScore(_ type: StrategySettings.TieBreakType) -> CGFloat {
        return -CGFloat.infinity
    }
}

class LinearDragMacroAction : MacroAction {
    var step : Int = 0
    let dragDuration : Int
    let start, end : CGPoint
    
    init(start: CGPoint, end: CGPoint, dragDuration: Int) {
        self.start = start
        self.end = end
        self.dragDuration = dragDuration
    }
    
    func getNextAction() -> CGPoint? {
        if step <= dragDuration {
            let point = start + (end - start) * CGFloat(step) / CGFloat(dragDuration)
            step += 1
            return point
        }
        else {
            step += 1
            return nil
        }
    }
    
    func hasFinished() -> Bool {
        return step >= dragDuration + 2
    }
    
    func getTieBreakScore(_ type: StrategySettings.TieBreakType) -> CGFloat {
        return 0
    }
}

class BallTapMacroAction : MacroAction {
    let ball : Ball
    var step = 0
    
    init(ball: Ball) {
        self.ball = ball
    }
    
    func getNextAction() -> CGPoint? {
        step += 1
        if step == 1 {
            return ball.node.position
        }
        else {
            return nil
        }
    }
    
    func hasFinished() -> Bool {
        return step >= 2
    }
    
    func getTieBreakScore(_ type: StrategySettings.TieBreakType) -> CGFloat {
        switch type {
        case .random:
            return RandomUtils.randomFloat(0, upperInc: 1)
            
        case .speed:
            return ball.node.physicsBody!.velocity.magnitude()
            
        case .distanceFromLeft:
            return ball.node.position.x
            
        case .distanceFromRight:
            return -ball.node.position.x
            
        case .distanceFromTop:
            return -ball.node.position.y
            
        case .distanceFromBottom:
            return ball.node.position.y
            
        case .clusterSize:
            return CGFloat(ball.fascinator.getCluster(ball, clusterType: .same).count)
            
        case .touchingSameType, .touchingOtherType:
            var count : CGFloat = 0
            for body in ball.node.physicsBody!.allContactedBodies() {
                if let otherBall = body.node?.userData?["ball"] as? Ball {
                    if (type == .touchingSameType && otherBall.type == ball.type) || (type == .touchingOtherType && otherBall.type != ball.type) {
                        count += 1
                    }
                }
            }
            return count
        }
    }
}

class PositionOffsetMacroAction : MacroAction {
    let innerAction : MacroAction
    let offset : CGVector
    
    init(innerAction: MacroAction, offset: CGVector) {
        self.innerAction = innerAction
        self.offset = offset
    }
    
    func getNextAction() -> CGPoint? {
        if let point = innerAction.getNextAction() {
            return point + offset
        }
        else {
            return nil
        }
    }
    
    func hasFinished() -> Bool {
        return innerAction.hasFinished()
    }
    
    func getTieBreakScore(_ type: StrategySettings.TieBreakType) -> CGFloat {
        return innerAction.getTieBreakScore(type)
    }
}

class SequenceMacroAction : MacroAction {
    fileprivate let actions : [MacroAction]
    fileprivate var currentAction = 0
    
    init(actions: [MacroAction]) {
        self.actions = actions
    }
    
    func getNextAction() -> CGPoint? {
        while actions[currentAction].hasFinished() {
            currentAction += 1
            if currentAction >= actions.count {
                return nil
            }
        }
        
        return actions[currentAction].getNextAction()
    }
    
    func hasFinished() -> Bool {
        return currentAction >= actions.count
    }
    
    func getTieBreakScore(_ type: StrategySettings.TieBreakType) -> CGFloat {
        for action in actions {
            let score = action.getTieBreakScore(type)
            if score.isFinite {
                return score
            }
        }
        
        return -CGFloat.infinity
    }
}
