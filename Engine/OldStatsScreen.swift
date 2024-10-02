//
//  OldStatsScreen.swift
//  MPCGD
//
//  Created by Colton, Simon on 16/01/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

enum StatStates{
    case chrono, averages, bestToWorst, session
}

class OldStatsScreen: HKComponent{
    
    var textColour = Colours.getColour(.black)
    
    var helpTextNode: SKLabelNode! = nil
    
    var cycler: HKComponentCycler! = nil
    
    var rankings: [Int] = []
    
    static var statsScreens: [String:OldStatsScreen] = [:]
    
    var state = StatStates.chrono
    
    var barChart: HKBarChart! = nil
    
    var scoreInfoTexts: [String] = []
    
    var scoreInfoNode: HKTextComponent! = nil
    
    var infoFont: UIFont! = nil
    
    var infoPosition = CGPoint(x: 0, y: 92)
    
    var lineHeight: CGFloat! = nil
    
    var lineNode: SKSpriteNode! = nil
    
    let cutOff = CGFloat(300)
    
    let barChartHeight = CGFloat(80)
    
    var size: CGSize! = nil
    
    var fsaButtonText: HKTextComponent! = nil
    
    var avButtonText: HKTextComponent! = nil
    
    var textSize: CGSize! = nil
    
    var summaryStatsLabel: SKSpriteNode! = nil
    
    var gameStatsLabel: SKSpriteNode! = nil
    
    var summaryLabels: [SKLabelNode] = []
    
    var playGameNode: HKTextComponent! = nil
    
    var numQuits = 0
    
    var gameID: String
    
    let fastestLabel = SKLabelNode(text: "Fastest:")
    let averageLabel = SKLabelNode(text: "Average:")
    let patchLabel = SKLabelNode(text: "Patch:")
    let slowestLabel = SKLabelNode(text: "Slowest:")
    let gamesLabel = SKLabelNode(text: "Wins:")
    let daysLabel = SKLabelNode(text: "Days:")
    let purplesLabel = SKLabelNode(text: "Purple:")
    let quitsLabel = SKLabelNode(text: "Quits:")
    
    var tapCode: (() -> ())! = nil
    
    init(gameID: String, size: CGSize){
        self.gameID = gameID
        self.size = size
        super.init()
        textSize = CGSize(width: size.width, height: 50)
        let sessions = SessionHandler.getSessions(gameID)
        
        addComponents(sessions)
        var empty = sessions.isEmpty
        if !empty{
            empty = true
            for s in sessions{
                if !s.quit{
                    empty = false
                }
            }
        }
        if empty{
            startUpEmpty()
        }
        OldStatsScreen.statsScreens[gameID] = self
    }
    
    func changeColours(_ colour: UIColor){
        self.textColour = colour
        changeSubcomponentsColour(summaryStatsLabel, colour: colour)
        changeSubcomponentsColour(gameStatsLabel, colour: colour)
        helpTextNode.fontColor = colour
        lineNode.color = colour
        for l in barChart.xLabels{
            l.fontColor = colour
        }
        if playGameNode != nil{
            changeSubcomponentsColour(playGameNode, colour: colour)
        }
    }
    
    func changeSubcomponentsColour(_ node: SKNode, colour: UIColor){
        if node is SKLabelNode{
            (node as! SKLabelNode).fontColor = colour
        }
        else{
            for child in node.children{
                changeSubcomponentsColour(child, colour: colour)
            }
        }
    }
    
    func startUpEmpty(){
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 17)!
        playGameNode = HKTextComponent(size: size, text: "Play some games and\ncheck back here to see\nhow you are doing", font: font, alignment: SKLabelHorizontalAlignmentMode.center, spacing: 2.0)
        addChild(playGameNode)
        
        gameStatsLabel.isHidden = true
        summaryStatsLabel.isHidden = true
        scoreInfoNode.isHidden = true
        lineNode.isHidden = true
        barChart.isHidden = true
        barChart.isUserInteractionEnabled = false
        playGameNode.isUserInteractionEnabled = false
        summaryStatsLabel.isUserInteractionEnabled = false
        gameStatsLabel.isUserInteractionEnabled = false
        scoreInfoNode.isUserInteractionEnabled = false
        scoreInfoNode.name = "Score info"
    }
    
    func updateRanking(_ sessions: [Session]){
        var winningSessions: [Session] = []
        for session in sessions{
            if session.quit == false{
                winningSessions.append(session)
            }
        }
        let sortedSessions = winningSessions.sorted { (s1, s2) -> Bool in
            return s1.time < s2.time
        }
        rankings.removeAll()
        for session in winningSessions{
            let pos = sortedSessions.index(where: {$0.time == session.time})!
            rankings.append(pos)
        }
    }
    
    func getRanking(_ pos: Int) -> String{
        var rank = rankings[pos]
        if rank == 0{
            return "Best"
        }
        rank += 1
        if rank % 100 == 11 || rank % 100 == 12 || rank % 100 == 13{
            return "\(rank)th best"
        }
        if rank % 10 == 1{
            return "\(rank)st best"
        }
        else if rank % 10 == 2{
            return "\(rank)nd best"
        }
        else if rank % 10 == 3{
            return "\(rank)rd best"
        }
        else{
            return "\(rank)th best"
        }
    }
    
    func refresh(){
        
        /*
         let sessions = SessionHandler.getSessions(gameID)
         updateRanking(sessions)
         let recentSession = sessions.last!
         if !recentSession.quit{
         barChart.addBar(recentSession.time, date: recentSession.date)
         }
         else{
         numQuits += 1
         updateSummaries()
         return
         }
         if playGameNode != nil{
         playGameNode.removeFromParent()
         }
         
         let dateString = getDateString(recentSession.date)
         let gameNum = SessionHandler.getSessions(gameID).count
         let dS = "Game \(gameNum) on \(dateString)"
         
         /*
         if !recentSession.quit{
         let aiPC = Int(round(recentSession.aiRatio * 100))
         let speedStr = NSString(format: "%.1f", recentSession.speed)
         scoreInfoTexts.append("\(dS)\nTime: \(Int(round(recentSession.time)))s  Score: \(recentSession.score)  Taps: \(recentSession.numberOfTaps)\nAI: \(aiPC)%  Speed: \(speedStr)")
         }
         if !recentSession.quit{
         let speedStr = NSString(format: "%.1f", recentSession.speed)
         scoreInfoTexts.append("\(dS)\nTime: \(Int(round(recentSession.time)))s  Score: \(recentSession.score)  Taps: \(recentSession.numberOfTaps)\nSpeed: \(speedStr)")
         }
         */
         
         updateSummaries()
         barChart.trayNode.position.x = -barChart.unselectedComponents.last!.position.x
         barChart.centralValuePosition = barChart.unselectedComponents.count - 1
         summaryStatsLabel.isHidden = false
         gameStatsLabel.isHidden = false
         scoreInfoNode.isHidden = false
         lineNode.isHidden = false
         barChart.isHidden = false
         barChart.isUserInteractionEnabled = true
         loadNewState()
         handleStatsChoiceChange()
         scoreInfoNode.isUserInteractionEnabled = false
         
         */
    }
    
    func getDateString(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/M/yy H:mm"
        let parts = formatter.string(from: date).components(separatedBy: " ")
        return "\(parts[0]) at \(parts[1])"
    }
    
    func addComponents(_ sessions: [Session]){
        
        addBarChart(sessions)
        
        gameStatsLabel = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width - 20, height: 75))
        gameStatsLabel.position = CGPoint(x: 0, y: size.height/2 - 69)
        
        infoFont = UIFontCache(name: "HelveticaNeue-Thin", size: 14)!
        scoreInfoNode = HKTextComponent(size: textSize, text: "", font: infoFont, colour: textColour, alignment: SKLabelHorizontalAlignmentMode.center)
        scoreInfoNode.isUserInteractionEnabled = false
        gameStatsLabel.addChild(scoreInfoNode)
        gameStatsLabel.position = infoPosition
        
        lineHeight = barChartHeight + 50
        lineNode = SKSpriteNode(color: textColour.withAlphaComponent(0.8), size: CGSize(width: 1, height: lineHeight))
        lineNode.position = CGPoint(x: 0, y: -1000)
        
        summaryStatsLabel = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width - 20, height: 75))
        summaryStatsLabel.position = CGPoint(x: 0, y: -size.height/2 + 69)
        
        addChild(summaryStatsLabel)
        addChild(gameStatsLabel)
        addChild(lineNode)
        
        fastestLabel.position = CGPoint(x: -42, y: 22)
        averageLabel.position = CGPoint(x: -42, y: 4)
        patchLabel.position = CGPoint(x: -42, y: -14)
        slowestLabel.position = CGPoint(x: -42, y: -31)
        
        gamesLabel.position = CGPoint(x: 60, y: 22)
        daysLabel.position = CGPoint(x: 60, y: 4)
        purplesLabel.position = CGPoint(x: 60, y: -14)
        quitsLabel.position = CGPoint(x: 60, y: -31)
        
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 14)
        for l in [fastestLabel, averageLabel, patchLabel, slowestLabel, gamesLabel, daysLabel, purplesLabel, quitsLabel]{
            l.fontColor = textColour
            l.fontSize = (font?.pointSize)!
            l.fontName = font?.fontName
            l.verticalAlignmentMode = SKLabelVerticalAlignmentMode.baseline
            l.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            summaryStatsLabel.addChild(l)
            let numLabel = SKLabelNode(font, textColour)
            numLabel.text = "?"
            numLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.baseline
            numLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            numLabel.position = CGPoint(x: l.position.x + 3, y: l.position.y)
            summaryLabels.append(numLabel)
            summaryStatsLabel.addChild(numLabel)
        }
        
        finaliseBarChart()
        
        let gray = Colours.getColour(.antiqueWhite).withAlphaComponent(0.2)
        let hSize = CGSize(width: size.width, height: 1)
        let topLine = SKSpriteNode(color: gray, size: hSize)
        let bottomLine = SKSpriteNode(color: gray, size: hSize)
        topLine.position = CGPoint(x: 0, y: 127)
        bottomLine.position = CGPoint(x: 0, y: -135)
        addChild(topLine)
        addChild(bottomLine)
        
        let helpTextFont = UIFontCache(name: "HelveticaNeue-Thin", size: 22)
        helpTextNode = SKLabelNode(helpTextFont, textColour, text: "Statistics")
        helpTextNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        helpTextNode.position.y = size.height/2 - 8
        addChild(helpTextNode)
    }
    
    func addBarChart(_ sessions: [Session]){
        
        /*
         if barChart != nil{
         barChart.removeFromParent()
         }
         
         updateRanking(sessions)
         
         var values: [CGFloat] = []
         var dates: [Date] = []
         
         var pos = 1
         for session in sessions{
         
         let val = session.time
         
         let dateString = getDateString(session.date as Date)
         //            let dS = "Game \(pos) on \(dateString)"
         
         if !session.quit{
         values.append(val)
         dates.append(session.date as Date)
         //                let aiPC = Int(round(session.aiRatio * 100))
         //                let speedStr = NSString(format: "%.1f", session.speed)
         /*
         scoreInfoTexts.append("\(dS)\nTime: \(Int(round(session.time)))s  Score: \(session.score)  Taps: \(session.numberOfTaps)\nAI: \(aiPC)%  Speed: \(speedStr)")
         */
         //                scoreInfoTexts.append("\(dS)\nTime: \(Int(round(session.time)))s  Score: \(session.score)  Taps: \(session.numberOfTaps)\nSpeed: \(speedStr)")
         pos += 1
         }
         else{
         numQuits += 1
         }
         }
         
         barChart = HKBarChart(values: values, dates: dates, size: CGSize(width: size.width, height: barChartHeight), barWidth: 12, cutOff: cutOff)
         barChart.canScroll = true
         barChart.centralValueChangedCode = handleStatsChoiceChange
         barChart.nonSelectingTapCode = self.handleBarChartTap
         barChart.position.y += 5
         
         addChild(barChart)
         */
    }
    
    func finaliseBarChart(){
        if !barChart.unselectedComponents.isEmpty{
            barChart.trayNode.position.x = -barChart.unselectedComponents.last!.position.x
            barChart.centralValuePosition = barChart.unselectedComponents.count - 1
            barChart.alpha = 1
            handleStatsChoiceChange()
            updateSummaries()
            barChart.hideComponents()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleStatsChoiceChange(){
        
        var pos = 0
        for label in [gamesLabel, fastestLabel, averageLabel, slowestLabel, daysLabel, purplesLabel, patchLabel, quitsLabel]{
            label.fontName = "Helvetica Neue Thin"
            summaryLabels[pos].fontName = "Helvetica Neue Thin"
            pos += 1
        }
        
        if state == .chrono || state == .bestToWorst || state == .session{
            lineNode.isHidden = false
            scoreInfoNode.isHidden = false
            scoreInfoNode.removeFromParent()
            var infoPos = barChart.centralValuePosition
            if state == .bestToWorst && !barChart.sortedValuePositions.isEmpty {
                infoPos = barChart.sortedValuePositions[barChart.centralValuePosition]
            }
            if infoPos == barChart.minPos{
                fastestLabel.fontName = "Helvetica Neue Bold"
                summaryLabels[0].fontName = "Helvetica Neue Bold"
            }
            if infoPos == barChart.maxPos{
                slowestLabel.fontName = "Helvetica Neue Bold"
                summaryLabels[3].fontName = "Helvetica Neue Bold"
            }
            let text = scoreInfoTexts[infoPos] + "  " + getRanking(infoPos)
            scoreInfoNode = HKTextComponent(size: textSize, text: text, font: infoFont, colour: textColour, alignment: SKLabelHorizontalAlignmentMode.center, spacing: 1.8)
            scoreInfoNode.alpha = 1
            if state == .session && barChart.unselectedComponents[infoPos].alpha < 1{
                scoreInfoNode.alpha = 0.2
            }
            scoreInfoNode.isUserInteractionEnabled = false
            gameStatsLabel.addChild(scoreInfoNode)
            let val = min(cutOff, barChart.values[infoPos])
            
            var prop = 1 - (val/cutOff)
            if val == 0{
                prop = 0.3
                quitsLabel.fontName = "Helvetica Neue Bold"
                summaryLabels[7].fontName = "Helvetica Neue Bold"
            }
            
            if val > 0 && val < 100{
                purplesLabel.fontName = "Helvetica Neue Bold"
                summaryLabels[6].fontName = "Helvetica Neue Bold"
            }
            lineNode.yScale = (barChartHeight * prop)/lineHeight + 0.075
            let y = barChart.position.y - barChartHeight/2 + lineNode.size.height/2 + (barChartHeight * (1 - prop)) + 5
            lineNode.position.y = y
            
            if state == .session && barChart.unselectedComponents[infoPos].alpha == 1{
                patchLabel.fontName = "Helvetica Neue Bold"
                summaryLabels[2].fontName = "Helvetica Neue Bold"
            }
            
        }
        else if state == .averages{
            scoreInfoNode.removeFromParent()
            let pos = barChart.centralValuePosition
            let av = Int(round(barChart.averages[pos]))
            
            var g = "games"
            if pos == 0{
                g = "game"
            }
            var text = "Average after \(pos + 1) \(g): "
            if av > 0{
                text += "\(av)s"
            }
            else{
                text += "No game completed"
            }
            scoreInfoNode = HKTextComponent(size: textSize, text: text, font: infoFont, colour: textColour, alignment: SKLabelHorizontalAlignmentMode.center, spacing: 1.8)
            scoreInfoNode.position = infoPosition
            addChild(scoreInfoNode)
            
            lineNode.yScale = 0.7
            lineNode.position.y = barChart.position.y - barChartHeight/2 + lineNode.size.height/2
        }
    }
    
    func updateSummaries(){
        var purples = 0
        
        for val in barChart.values{
            if val < 100 && val > 0{
                purples += 1
            }
        }
        
        let (patch, _, _) = barChart.getBestSessionDetails(10)
        let (mn, av, mx) = barChart.getMinAvMax()
        
        // fastestLabel, averageLabel, patchLabel, slowestLabel, gamesLabel, daysLabel, purplesLabel, quitsLabel
        
        summaryLabels[0].text = "\(Int(round(mn)))s"
        summaryLabels[1].text = "\(Int(round(av)))s"
        summaryLabels[2].text = "\(Int(round(patch)))s"
        summaryLabels[3].text = "\(Int(round(mx)))s"
        
        summaryLabels[4].text = "\(barChart.values.count)"
        summaryLabels[5].text = "\(barChart.getNumberOfDays())"
        summaryLabels[6].text = "\(purples)"
        summaryLabels[7].text = "\(numQuits)"
    }
    
    func handleBarChartTap(){
        if state == .chrono{
            state = .averages
        }
        else if state == .averages{
            state = .bestToWorst
        }
        else if state == .bestToWorst{
            state = .session
        }
        else if state == .session{
            state = .chrono
        }
        loadNewState()
        handleStatsChoiceChange()
        if tapCode != nil{
            tapCode()
        }
        loadNewState()
    }
    
    func loadNewState(){
        if state == .chrono{
            barChart.showOriginals()
        }
        else if state == .averages{
            barChart.showAverages()
        }
        else if state == .bestToWorst{
            barChart.reorderSmallestToLargest()
        }
        else if state == .session{
            barChart.highlightBestSession(10)
        }
    }
    
    func generateFakeData(){
        
        var fakeVals: [CGFloat] = []
        var fakeDates: [Date] = []
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = .medium
        
        for _ in 1...100{
            let gameTime = RandomUtils.randomFloat(50, upperInc: 500)
            
            var dateComponents = DateComponents()
            dateComponents.year = RandomUtils.randomInt(2015, upperInc: 2016)
            dateComponents.month = RandomUtils.randomInt(1, upperInc: 12)
            dateComponents.day = RandomUtils.randomInt(1, upperInc: 31)
            dateComponents.hour = RandomUtils.randomInt(0, upperInc: 23)
            dateComponents.minute = RandomUtils.randomInt(0, upperInc: 59)
            dateComponents.second = RandomUtils.randomInt(0, upperInc: 60)
            
            let userCalendar = Calendar.current
            let randomDate = userCalendar.date(from: dateComponents)!
            fakeDates.append(randomDate)
            
            if RandomUtils.randomInt(0, upperInc: 4) == 0{
                fakeVals.append(0)
            }
            else{
                fakeVals.append(gameTime)
            }
        }
        
        fakeDates.sort { (d1, d2) -> Bool in
            let days = (Calendar.current as NSCalendar).components(.day, from: d1, to: d2, options: []).day
            return days! > 0
        }
        
    }
    
}
