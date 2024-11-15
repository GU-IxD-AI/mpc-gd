//
//  MacroTacticPlaytester.swift
//  Engine
//
//  Created by Powley, Edward on 16/03/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class MacroTacticPlaytester : MacroActionPlaytester {
    
    var tactics : [MacroTactic] = []
    
    let humanSettings = HumanSettings()
    
    var timeSinceLastAction = CGFloat.infinity
    
    var labelNode : SKLabelNode! = nil
    
    init(fascinator: Fascinator, playerSettings: AutoplayerSettings, strategySettings: [StrategySettings]) {
        for strategy in strategySettings{
            tactics.append(MacroTactic.create(strategy))
        }
        super.init(fascinator: fascinator, playerSettings: playerSettings)
        for tactic in tactics {
            tactic.playtester = self
        }
    }
    
    func scoreVectorSortFunction(_ settings: StrategySettings, a: (MacroAction, [CGFloat]), b: (MacroAction, [CGFloat])) -> Bool {
        let sa = a.1
        let sb = b.1
        assert(sa.count == sb.count)
        for i in 0 ..< sa.count {
            switch settings.tieBreakSettings[i].tieBreakChoice.value {
            case .smallest:
                if sa[i] < sb[i] {
                    return true
                }
                else if sa[i] > sb[i] {
                    return false
                }
            // else continue
            case .largest:
                if sa[i] > sb[i] {
                    return true
                }
                else if sa[i] < sb[i] {
                    return false
                }
                // else continue
            }
        }
        
        return false
    }
    
    func chooseActionByTieBreaking(_ actions: [MacroAction], settings: StrategySettings) -> MacroAction {
        if actions.count <= 1 {
            return actions.first!
        }
        else {
            //let fuzz = humanSettings.tieBreakFuzz.value
            var actionsWithScores : [(MacroAction, [CGFloat])] = []
            for action in actions {
                let scores = settings.tieBreakSettings.map({ tb in action.getTieBreakScore(tb.tieBreak.value) })
                actionsWithScores.append((action, scores))
            }
            
            actionsWithScores.sort(by: { (a,b) in scoreVectorSortFunction(settings, a: a, b: b) })
            
            let index = RandomUtils.randomInt(0, upperInc: min(actionsWithScores.count - 1, Int(floor(humanSettings.tieBreakFuzz))))
            return actionsWithScores[index].0
        }
    }
    
    func showLabel(_ text: String) {
        let font = UIFontCache(name: "Helvetica", size: 12)
        labelNode = SKLabelNode(font, UIColor.green)
        labelNode.text = text
        labelNode.zPosition = ZPositionConstants.automatedPlaytesterHand
        fascinator.fascinatorSKNode.addChild(labelNode)
        labelNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
            ]))
    }
    
    override func doAI() -> CGPoint? {
        let point = super.doAI()
        if labelNode != nil && point != nil {
            labelNode.position = point!
        }
        return point
    }
    
    override func selectNextMacroAction() -> MacroAction {
        if RandomUtils.randomFloat(0, upperInc: 1) > fascinator.playtesterStrategyGlobalProbability{
            return DoNothingMacroAction(duration: 1)
        }

        timeSinceLastAction += deltaTime
        if timeSinceLastAction < humanSettings.minTimeBetweenActions {
            return DoNothingMacroAction(duration: 1)
        }
        
        for tactic in tactics {
            let macroActions = tactic.findMacroActions(fascinator)
            if !macroActions.isEmpty {
                let delayTime = RandomUtils.randomFloat(0, upperInc: humanSettings.reactionTime)
                let delaySteps = Int(floor(delayTime / deltaTime))
                timeSinceLastAction = -delayTime
                
                var action = chooseActionByTieBreaking(macroActions, settings: tactic.settings)
                var logEntry : [String : AnyObject?] = [
                    "tactic" : "\(type(of: tactic))" as Optional<AnyObject>,
                    "humanPositionError" : CGPoint.zero as Optional<AnyObject>,
                    "humanDelay" : delayTime as Optional<AnyObject>
                ]
                
                if humanSettings.tapError > 0 {
                    let tapError = RandomUtils.randomUniformInCircle(humanSettings.tapError)
                    logEntry["humanPositionError"] = tapError as AnyObject??
                    action = PositionOffsetMacroAction(innerAction: action, offset: tapError)
                }
                
                //showLabel("\(tactic.dynamicType)")
                
                //fascinator.addLogEvent(logEntry, eventType: "aiAction")
                
                if delaySteps > 0 {
                    return SequenceMacroAction(actions: [DoNothingMacroAction(duration: delaySteps), action])
                }
                else {
                    return action
                }
            }
        }
        
        return DoNothingMacroAction(duration: 1)
    }
}
