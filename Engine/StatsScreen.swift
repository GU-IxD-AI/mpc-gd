//
//  StatsScreen.swift
//  MPCGD
//
//  Created by Colton, Simon on 16/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class StatsScreen: HKComponent{
    
    let clearStatsButton: HKButton
    
    var gameID: String
    
    var size: CGSize
    
    var MPCGDGenome: MPCGDGenome
    
    var sessions: [Session] = []
    
    var textLabels: [SKLabelNode] = []
    
    var valueLabels: [SKLabelNode] = []
    
    var endGameProfile: [Bool] = []
    
    init(gameID: String, wG: MPCGDGenome, size: CGSize){
        self.size = size
        clearStatsButton = HKButton(image: UIImage(named: "ResetStatsButton")!)
        self.gameID = gameID
        self.MPCGDGenome = wG
        super.init()
        let invisibleNode = SKSpriteNode(color: UIColor.clear, size: size)
        addChild(invisibleNode)
        let hSize = CGSize(width: size.width, height: 1)
        let gray = Colours.getColour(.antiqueWhite).withAlphaComponent(0.2)
        let topLine = SKSpriteNode(color: gray, size: hSize)
        let bottomLine = SKSpriteNode(color: gray, size: hSize)
        topLine.position = CGPoint(x: 0, y: 127)
        bottomLine.position = CGPoint(x: 0, y: -135)
        addChild(topLine)
        addChild(bottomLine)
        
        let helpTextNode = SKLabelNode(text: "Statistics")
        helpTextNode.fontName = "Helvetica Neue Thin"
        helpTextNode.fontColor = Colours.getColour(.antiqueWhite)
        helpTextNode.fontSize = 22
        helpTextNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        helpTextNode.position.y = size.height/2 - 8
        addChild(helpTextNode)

        clearStatsButton.position.y = -100
        clearStatsButton.isUserInteractionEnabled = false
        addChild(clearStatsButton)
        
        refresh(gameID: gameID, wG: wG)
        endGameProfile = [wG.pointsToWin != 0, wG.numLives != 0, wG.gameDuration != 0]
    }
    
    deinit {
        //print("!!! [DEINIT] StatsScreen")
    }

    func reactToGenomeChange(alteredMPCGDGenome: MPCGDGenome){
        let newEndGameProfile = [alteredMPCGDGenome.pointsToWin != 0, alteredMPCGDGenome.numLives != 0, alteredMPCGDGenome.gameDuration != 0]
        var needsRefresh = false
        for pos in 0..<3{
            if endGameProfile[pos] != newEndGameProfile[pos]{
                needsRefresh = true
            }
        }
        if needsRefresh{
            refresh(gameID: gameID, wG: alteredMPCGDGenome)
        }
        MPCGDGenome = alteredMPCGDGenome
        endGameProfile = newEndGameProfile
    }
    
    func refresh(gameID: String, wG: MPCGDGenome){
        sessions = SessionHandler.getSessions(gameID)
        clearStatsButton.enabled = !sessions.isEmpty
        clearStatsButton.alpha = sessions.isEmpty ? 0.2 : 1.0
        for l in textLabels{
            l.removeFromParent()
        }
        for l in valueLabels{
            l.removeFromParent()
        }
        textLabels = []
        valueLabels = []

        var quits = 0
        var wins = 0
        var losses = 0
        var avScore = CGFloat(0)
        var avTime = CGFloat(0)
        for s in sessions{
            if s.quit{
                quits += 1
            }
            else if s.wasWon{
                wins += 1
                avScore += CGFloat(s.score)
                avTime += CGFloat(s.time)
            }
            else{
                losses += 1
            }
        }
        if wins > 0{
            avScore = avScore/CGFloat(wins)
            avTime = avTime/CGFloat(wins)
        }
        let avS = String(format: "%.1f", avScore)
        let avT = String(format: "%.1f", avTime)
        let pair = MPCGDGenome.getBestText(gameID: gameID)
        
        textLabels.append(getLabel(text: "Games:", isHeavy: false))
        valueLabels.append(getLabel(text: "\(sessions.count)", isHeavy: true))
        
        if (wG.gameDuration > 0 && wG.numLives > 0) || wG.pointsToWin > 0{
            textLabels.append(getLabel(text: "Wins:", isHeavy: false))
            valueLabels.append(getLabel(text: "\(wins)", isHeavy: true))
            textLabels.append(getLabel(text: "Losses:", isHeavy: false))
            valueLabels.append(getLabel(text: "\(losses)", isHeavy: true))
        }
        
        if pair.0 != nil && pair.1 != "Completes"{
            if wG.gameDuration > 0 || wG.numLives > 0 || wG.pointsToWin > 0{
                textLabels.append(getLabel(text: "\(pair.1):", isHeavy: false))
                valueLabels.append(getLabel(text: "\(pair.0!)", isHeavy: true))
                if wins > 1{
                    textLabels.append(getLabel(text: "Average:", isHeavy: false))
                    let avText = (pair.1 == "High score") ? "\(avS) pts" : "\(avT)s"
                    valueLabels.append(getLabel(text: "\(avText)", isHeavy: true))
                }
            }
        }
        
        textLabels.append(getLabel(text: "Quits:", isHeavy: false))
        valueLabels.append(getLabel(text: "\(quits)", isHeavy: true))
        
        let numLines = CGFloat(textLabels.count)
        let numSections = numLines + 2
        let spaceAvailable = CGFloat(250)
        let takeOff = spaceAvailable/numSections
        
        var yPos = CGFloat(0)
        let labelsNode = SKNode()
        for pos in 0..<textLabels.count{
            labelsNode.addChild(textLabels[pos])
            labelsNode.addChild(valueLabels[pos])
            textLabels[pos].position.y = yPos
            valueLabels[pos].position.y = yPos
            yPos -= takeOff
        }
        addChild(labelsNode)
        labelsNode.position.y = (numLines/2 * takeOff)
        
        var maxW1 = CGFloat(0)
        var maxW2 = CGFloat(0)
        for pos in 0..<textLabels.count{
            maxW1 = max(textLabels[pos].frame.size.width, maxW1)
            maxW2 = max(valueLabels[pos].frame.size.width, maxW2)
        }
        let margin = (size.width - maxW1 - maxW2 - 10)/2
        let xPos = -size.width/2 + margin + maxW1
        for pos in 0..<textLabels.count{
            textLabels[pos].horizontalAlignmentMode = .right
            valueLabels[pos].horizontalAlignmentMode = .left
            textLabels[pos].position.x = xPos
            valueLabels[pos].position.x = xPos + 10
        }
    }
    
    func getLabel(text: String, isHeavy: Bool) -> SKLabelNode{
        let label = SKLabelNode(text: text)
        label.fontName = isHeavy ? "Helvetica Neue Bold" : "Helvetica Neue Thin"
        label.fontSize = 22
        label.fontColor = Colours.getColour(.antiqueWhite)
        label.verticalAlignmentMode = .baseline
        return label
    }
    
    func reactToGameIDChange(newGameID: String){
        gameID = newGameID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
