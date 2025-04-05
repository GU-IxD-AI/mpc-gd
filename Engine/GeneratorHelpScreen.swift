//
//  GeneratorHelpScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 09/04/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class GeneratorHelpScreen : HKComponent{
    
    let size: CGSize
    
    var transNode: SKSpriteNode! = nil
    
    var char1: String! = nil
    
    var char2: String! = nil
    
    var char1Bold: String! = nil
    
    var char2Bold: String! = nil
    
    var char1Plural: String! = nil
    
    var char2Plural: String! = nil
    
    var char1PluralBold: String! = nil
    
    var char2PluralBold: String! = nil
    
    var hLines: [SKSpriteNode] = []

    var vLines: [SKSpriteNode] = []
    
    let linesNode = SKNode()
    
    init(size: CGSize, horizontalLines: [SKSpriteNode], verticalLines: [SKSpriteNode]){
        self.size = size
        super.init()
        self.isUserInteractionEnabled = false
        let cropSize = CGSize(width: size.width, height: size.height - 60)
        let transColour = Colours.getColour(.steelBlue).withAlphaComponent(0.9)
        transNode = SKSpriteNode(color: transColour, size: cropSize)
        addChild(transNode)
        zPosition = 1001
        position.y = -5
        for l in horizontalLines{
            let hLine = SKSpriteNode(color: Colours.getColour(.antiqueWhite), size: l.size)
            hLine.position = l.position
            hLines.append(hLine)
            linesNode.addChild(hLine)
        }
        for l in verticalLines{
            let vLine = SKSpriteNode(color: Colours.getColour(.antiqueWhite), size: l.size)
            vLine.position = l.position
            vLines.append(vLine)
            linesNode.addChild(vLine)
        }
        linesNode.position.y += 5
        addChild(linesNode)
    }
    
    func showOpeningInfo(_ char1Name: String, char2Name: String){
        self.char1 = char1Name
        self.char2 = char2Name
        self.char1Bold = "~\(char1Name)"
        self.char2Bold = "~\(char2Name)"
        linesNode.alpha = 1
        transNode.removeAllChildren()
        let textNode = SKMultilineLabel(text: "Tap any\nbutton\nfor info", size: CGSize(width: size.width, height: 100), pos: CGPoint(x: -82, y: 95), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: 20, fontColor: Colours.getColour(.antiqueWhite), leading: 5, alignment: .center, shouldShowBorder: false, spacing: 5)
        let textNode2 = SKMultilineLabel(text: "Tap\n\nto exit", size: CGSize(width: size.width, height: 100), pos: CGPoint(x: 82, y: -80), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: 20, fontColor: Colours.getColour(.antiqueWhite), leading: 5, alignment: .center, shouldShowBorder: false, spacing: 5)
        let qMark = SKSpriteNode(imageNamed: "HelpButton")
        transNode.addChild(qMark)
        qMark.position = CGPoint(x: 82, y: -87)
        transNode.addChild(textNode)
        transNode.addChild(textNode2)
        char1Plural = char1Name + "s"
        char2Plural = char2Name + "s"
        if char1Name == "Firefly"{
            char1Plural = "Fireflies"
        }
        if char2Name == "Firefly"{
            char2Plural = "Fireflies"
        }
        if char1Name == "Butterfly"{
            char1Plural = "Butterflies"
        }
        if char2Name == "Butterfly"{
            char2Plural = "Butterflies"
        }
        char1PluralBold = "~" + char1Plural
        char2PluralBold = "~" + char2Plural
        if char1Name == "Pine cone"{
            char1PluralBold = "~Pine ~cones"
        }
        if char2Name == "Pine cone"{
            char2PluralBold = "~Pine ~cones"
        }
        if char1Name == "Butterfly"{
            char1PluralBold = "~Butterflies"
        }
        if char2Name == "Butterfly"{
            char2PluralBold = "~Butterflies"
        }
    }
    
    func handleButtonTap(_ buttonNum: Int, liveMPCGDGenome: MPCGDGenome){
        for c in transNode.children{
            c.run(SKAction.fadeOut(withDuration: 0.3), completion: {
                c.removeFromParent()
            })
        }
        var text1 = ""
        var text2 = ""
        var y1 = CGFloat(0)
        var y2 = CGFloat(0)
        linesNode.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
        
        if buttonNum == 0{
            text1 = "Characters can stick\ntogether in ~clusters\nTap here to set when the\ncluster will ~burst"
            text2 = "In this game, "
            if liveMPCGDGenome.whiteCriticalClusterSize > 0{
                text2 += "a cluster of ~\(liveMPCGDGenome.whiteCriticalClusterSize)\n\(char1PluralBold.lowercased()) will burst, "
                let absScore = abs(liveMPCGDGenome.whiteExplodeScore * liveMPCGDGenome.whiteCriticalClusterSize)
                if liveMPCGDGenome.whiteExplodeScore == 0{
                    text2 += "but there will\nbe ~no ~change ~in ~score"
                }
                else if liveMPCGDGenome.whiteExplodeScore < 0{
                    text2 += "and the\n~score ~will ~go ~down ~by ~\(absScore)"
                }
                else if liveMPCGDGenome.whiteExplodeScore > 0{
                    text2 += "and the\nscore ~will ~go ~up ~by ~\(absScore)"
                }
            }
            else{
                text2 += "\(char1PluralBold.lowercased())\ndo not stick to each other"
            }
            y1 = 3
            y2 = -85
        }

        if buttonNum == 1{
            text1 = "Characters can stick\ntogether in ~clusters\nTap here to set when the\ncluster will ~burst"
            text2 = "In this game, "
            if liveMPCGDGenome.blueCriticalClusterSize > 0{
                text2 += "a cluster of ~\(liveMPCGDGenome.blueCriticalClusterSize)\n\(char2PluralBold.lowercased()) will burst, "
                let absScore = abs(liveMPCGDGenome.blueExplodeScore * liveMPCGDGenome.blueCriticalClusterSize)
                if liveMPCGDGenome.blueExplodeScore == 0{
                    text2 += "but there\nwill be ~no ~change ~in ~score"
                }
                else if liveMPCGDGenome.blueExplodeScore < 0{
                    text2 += "and the\n~score will ~go ~down ~by ~\(absScore)"
                }
                else if liveMPCGDGenome.blueExplodeScore > 0{
                    text2 += "and the\nscore will ~go ~up ~by ~\(absScore)"
                }
            }
            else{
                text2 += "\(char2PluralBold.lowercased())\ndo not stick to each other"
            }
            y1 = 3
            y2 = -85
        }
        
        if buttonNum == 2{
            text1 = "Characters can stick\ntogether in ~clusters.\nTap here to set when the\ncluster will ~burst."
            text2 = "Here, "
            if liveMPCGDGenome.mixedCriticalClusterSize > 0{
                text2 += "a cluster of ~\(liveMPCGDGenome.mixedCriticalClusterSize) \(char1PluralBold.lowercased())\nand \(char2PluralBold.lowercased()) will burst,"
                let absScore = abs(liveMPCGDGenome.mixedExplodeScore * liveMPCGDGenome.mixedCriticalClusterSize)
                if liveMPCGDGenome.mixedExplodeScore == 0{
                    text2 += "\nwith ~no ~change ~in ~score."
                }
                else if liveMPCGDGenome.mixedExplodeScore < 0{
                    text2 += "\nand the score will go ~down ~by ~\(absScore)."
                }
                else if liveMPCGDGenome.mixedExplodeScore > 0{
                    text2 += "\nand the score will go ~up ~by ~\(absScore)."
                }
            }
            else{
                text2 += "\(char1PluralBold.lowercased())\n and \(char2PluralBold.lowercased())\ndo not stick to each other"
            }
            y1 = 3
            y2 = -85
        }
        
        if buttonNum == 3{
            text1 = "With this button, choose what\nhappens to characters when you\n~tap them. And choose the \n~score ~changes this brings."
            text2 = "In this game, "
            switch liveMPCGDGenome.whiteTapAction{
            case 0: text2 += "tapping \(char1PluralBold) \ndoes nothing."
            case 1: text2 += "\(char1PluralBold.lowercased())\n~explode when tapped."
            case 2: text2 += "\(char1PluralBold.lowercased())\n~reverse direction when tapped."
            case 3: text2 += "tapped \(char1PluralBold.lowercased())\n~stick in place on a spring."
            case 4: text2 += "when tapped,\n\(char1PluralBold.lowercased()) become \(char2PluralBold.lowercased())."
            case 5: text2 += "\(char1PluralBold).lowercaseString\n~move ~up when tapped."
            case 6: text2 += "\(char1PluralBold.lowercased())\n~move ~down when tapped."
            case 7: text2 += "\(char1PluralBold.lowercased())\n~move ~left when tapped."
            case 8: text2 += "\(char1PluralBold.lowercased())\n~move ~right when tapped."
            default: text2 += ""
            }
            
            switch liveMPCGDGenome.blueTapAction{
            case 0: text2 += "\nTapping \(char2PluralBold.lowercased()) does nothing."
            case 1: text2 += "\n\(char2PluralBold) ~explode when tapped."
            case 2: text2 += "\n\(char2PluralBold) ~reverse direction when tapped."
            case 3: text2 += "\nTapped \(char2PluralBold.lowercased())~stick in\nplace on a spring."
            case 4: text2 += "\n\(char2PluralBold) become \(char1PluralBold.lowercased())\nwhen tapped."
            case 5: text2 += "\n\(char2PluralBold) ~move ~up\nwhen tapped."
            case 6: text2 += "\n\(char2PluralBold) ~move ~down\nwhen tapped."
            case 7: text2 += "\n\(char2PluralBold) ~move ~left\nwhen tapped."
            case 8: text2 += "\n\(char2PluralBold) ~move ~right\nwhen tapped."
            default: text2 += ""
            }
            
            y1 = 92
            y2 = -85
        }
        
        if buttonNum == 4{
            
            y1 = 92
            y2 = -85

            text1 = "With this button, you can\nchoose the character ~types,\ntheir ~sizes, and the ~maximum\nnumber on screen simultaneously."

            text2 = "Here, there "
            if liveMPCGDGenome.whiteMaxOnScreen == 0{
                text2 += "are no \(char1PluralBold.lowercased())."
            }
            else{
                let sizes = getNums(liveMPCGDGenome.whiteSizes)
                if sizes.count == 1{
                    text2 += "\n"
                }
                if liveMPCGDGenome.whiteMaxOnScreen == 1{
                    text2 += "is \(liveMPCGDGenome.whiteMaxOnScreen) \(char1Bold.lowercased())"
                }
                else{
                    text2 += "are \(liveMPCGDGenome.whiteMaxOnScreen) \(char1PluralBold.lowercased())"
                }
                if sizes.count == 1{
                    text2 += " of size \(sizes[0])."
                }
                else{
                    text2 += "\nof sizes ranging from \(sizes[0]) to \(sizes.last!)."
                }
            }
            if liveMPCGDGenome.blueMaxOnScreen == 0{
                text2 += "There are no \(char1PluralBold.lowercased())."
            }
            else{
                let sizes = getNums(liveMPCGDGenome.blueSizes)
                text2 += "\nAnd there "
                if sizes.count == 1{
                    text2 += "\n"
                }
                if liveMPCGDGenome.blueMaxOnScreen == 1{
                    text2 += "is \(liveMPCGDGenome.blueMaxOnScreen) \(char2Bold.lowercased())"
                }
                else{
                    text2 += "are \(liveMPCGDGenome.blueMaxOnScreen) \(char2PluralBold.lowercased())"
                }
                if sizes.count == 1{
                    text2 += " of size \(sizes[0])."
                }
                else{
                    text2 += "\nof sizes ranging from \(sizes[0]) to \(sizes.last!)."
                }
            }
        }
        
        if buttonNum == 5{
            y1 = 92
            y2 = -85

            /*
            text1 = "With this button, you can change\nthe ~weather conditions and the\n~behaviours of the characters\nin your game."
            
            text2 = "In this game, the ~wind speed is \(liveMPCGDGenome.speed),\nthe ~storm level is \(liveMPCGDGenome.noise), and characters\n~bounce at level \(liveMPCGDGenome.bounce). "
            
            if liveMPCGDGenome.ballControllerExplosions == 0{
                text2 += "Neither character\nexplodes against the controller."
            }
            else if liveMPCGDGenome.ballControllerExplosions == 3{
                text2 += "Both characters\nexplode against the controller."
            }
            else if liveMPCGDGenome.ballControllerExplosions == 1{
                text2 += "\(char1Plural)\nexplode against the controller"
            }
            else if liveMPCGDGenome.ballControllerExplosions == 2{
                text2 += "\(char2Plural)\nexplode against the controller"
            }
            */
        }
        
        if buttonNum == 6{
            y1 = 92
            y2 = 3
            
            text1 = "With this button, you can\nchange the ~scene and ~music\nfor your game, as well as\nthe game ~controller."

            switch liveMPCGDGenome.gridControl{
            case 0: text2 = "Here, the controller is ~dragged\naround."
            case 1: text2 = "Here, the controller is ~dragged\nand ~floats."
            case 2: text2 = "Here, the controller is attached\nby a ~spring."
            case 3: text2 = "Here, the controller ~rotates.\n"
            case 4: text2 = "Here, the controller moves\n~up ~and ~down."
            case 5: text2 = "Here, the controller moves\n~left ~and ~right."
            case 6: text2 = "Here, the controller ~chases\n~your ~finger."
            case 7: text2 = "Here, the controller is ~swiped \n~on ~a ~grid."
            case 8: text2 = "In this game, there is ~no \n~controller."
            default: text2 = ""
            }
            
            let _ = liveMPCGDGenome.backgroundChoice == 4 ? "an" : "a"
  
        }
        
        if buttonNum == 7{
            
            /*
            y1 = 92
            y2 = 3
            
            text1 = "Here, you can say where\nthe characters appear ~on ~screen\n(spawning). You can also\n specify some ~scoring ~zones."
            
            let whiteSpawnNums = getNums(liveMPCGDGenome.whiteSpawnPositions)
            let blueSpawnNums = getNums(liveMPCGDGenome.blueSpawnPositions)
            let whiteScoreZones = getNums(liveMPCGDGenome.whiteScoreZones)
            let blueScoreZones = getNums(liveMPCGDGenome.blueScoreZones)
            
            if whiteSpawnNums.isEmpty && blueSpawnNums.isEmpty{
                text2 = "In this game, no characters\nare spawned. So, the game \n~won't ~be ~much ~fun!"
            }
            else if whiteSpawnNums.isEmpty{
                text2 = "Here, no \(char1PluralBold.lowercased()) are spawned\nbut \(char2PluralBold.lowercased()) come from the\n\(getDirections(liveMPCGDGenome.blueSpawnPositions))"
            }
            else if blueSpawnNums.isEmpty{
                text2 = "Here, no \(char2PluralBold.lowercased()) are spawned\nbut \(char1PluralBold.lowercased()) come from the\n\(getDirections(liveMPCGDGenome.whiteSpawnPositions))"
            }
            else{
                let dirs = getDirections(liveMPCGDGenome.whiteSpawnPositions, numID2: liveMPCGDGenome.blueSpawnPositions)
                text2 = "Here, spawning happens at the\n\(dirs)."
            }
            
            if whiteScoreZones.isEmpty && blueScoreZones.isEmpty{
                text2 += "\nThere are no scoring zones."
            }
            else {
                let dirs = getDirections(liveMPCGDGenome.whiteScoreZones, numID2: liveMPCGDGenome.blueScoreZones, isScoreZone: true)
                text2 += "\nThere are scoring zones on the\n\(dirs)."
            }
 */
        }
        
        if buttonNum == 8{
            y1 = 92
            y2 = 3
            
            text1 = "With this button, you can\ndescribe how the game is ~won,\nhow it can be ~lost,\nand whether ~time ~passes."
            
            text2 = "In this game, players need\n ~\(liveMPCGDGenome.pointsToWin) ~points ~to ~win, but will\n~lose ~after ~\(liveMPCGDGenome.gameDuration) ~seconds."
            
            if liveMPCGDGenome.dayNightCycle == 0{
                text2 += "\nThere is passing of time."
            }
            else if liveMPCGDGenome.dayNightCycle == 1{
                text2 += "\nThe game goes from ~day to ~night."
            }
            else if liveMPCGDGenome.dayNightCycle == 2{
                text2 += "\nThe game goes through ~24 ~hours."
            }
        }
        
        let textNode1 = SKMultilineLabel(text: text1, size: CGSize(width: size.width, height: 100), pos: CGPoint(x: 0, y: y1), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: 16, fontColor: Colours.getColour(.antiqueWhite), leading: 6, alignment: .center, shouldShowBorder: false, spacing: 3)
        transNode.addChild(textNode1)
        
        if text2 != ""{
            let textNode2 = SKMultilineLabel(text: text2, size: CGSize(width: size.width, height: 100), pos: CGPoint(x: 0, y: y2), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: 16, fontColor: Colours.getColour(.antiqueWhite), leading: 6, alignment: .center, shouldShowBorder: false, spacing: 3)
            transNode.addChild(textNode2)
        }

    }
    
    func getDirections(_ numID: Int, numID2: Int! = nil, isScoreZone: Bool = false) -> String{
        var dirs: [String] = []
        var nums = getNums(numID)
        if numID2 != nil{
            let nums2 = getNums(numID2)
            for n in nums2{
                nums.append(n)
            }
        }
        if nums.isEmpty{
            return ""
        }
        print(nums)
        if nums.contains(1) || (nums.contains(5) && !isScoreZone){
            dirs.append("~top")
        }
        if nums.contains(2) || (nums.contains(6) && !isScoreZone){
            dirs.append("~right")
        }
        if nums.contains(3) || (nums.contains(7) && !isScoreZone){
            dirs.append("~bottom")
        }
        if nums.contains(4) || (nums.contains(8) && !isScoreZone){
            dirs.append("~left")
        }
        if nums.contains(5) && isScoreZone{
            dirs.append("~corners")
        }
        if dirs.count == 1{
            return dirs.last!
        }
        else{
            var directions = dirs[0]
            for pos in 1..<dirs.count-1{
                directions += ", " + dirs[pos] + " "
            }
            return directions + " and " + dirs.last!
        }
    }
    
    func getNums(_ numID: Int) -> [Int]{
        var nums: [Int] = []
        for pos in 0...7{
            if Int(exp2(Double(pos))) & numID != 0{
                nums.append(pos + 1)
            }
        }
        return nums
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
