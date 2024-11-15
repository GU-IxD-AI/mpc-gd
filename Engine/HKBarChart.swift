//
//  HKBarChart.swift
//  MPCGD
//
//  Created by Simon Colton on 16/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class HKBarChart: HKComponentCardChooser{
    
    var averages: [CGFloat] = []

    var values: [CGFloat]
    
    var dates: [Date]!
    
    var sortedValuePositions: [Int] = []
    
    var barWidth: CGFloat
    
    var cutOff: CGFloat
    
    var barSize: CGSize
    
    var includeXAxis: Bool
    
    var minPos = 0
    
    var maxPos = 0
    
    var xLabels: [SKLabelNode] = []
    
    init(values: [CGFloat], dates: [Date]! = nil, size: CGSize, barWidth: CGFloat, cutOff: CGFloat, includeXAxis: Bool = true){
        self.values = values
        self.barWidth = barWidth
        self.cutOff = cutOff
        self.includeXAxis = includeXAxis
        self.dates = dates
        var cardIDs: [String] = []
        let blank = ImageUtils.getBlankImage(CGSize(width: 1,height: 1), colour: UIColor.clear)
        self.barSize = CGSize(width: barWidth, height: size.height)
        for pos in 0..<values.count{
            cardIDs.append("\(pos)")
        }
        let bars = HKBarChart.getBarComponents(values, cutOff: cutOff, barSize: barSize, size: size)

        super.init(cardIDs: cardIDs, size: size, cardSize: barSize, separatorWidth: 0, separatorAtStart: false, unselectedComponents: bars, selectedComponents: bars, chooserType: .none, verticalBarImage: blank, scrollBarImage: blank, scrollBarType: .none, timeBetweenTaps: 0.1, useCropNode: false, snapToCentre: true)

        // Add some extra slop around our touchable drag region
        self.trayNodeDragRect.origin.x -= 25
        self.trayNodeDragRect.size.width += 50
        self.trayNodeDragRect.origin.y -= 25
        self.trayNodeDragRect.size.height += 50
        
        _ = getMinAvMax()
        if includeXAxis{
            addXLabels()
        }
        super.hideComponents()
    }
    
    func getMinAvMax() -> (CGFloat, CGFloat, CGFloat){
        averages.removeAll()
        var runningTotal = CGFloat(0)
        var takeOff = 0
        var mn = CGFloat(100000)
        var mx = CGFloat(0)
        for pos in 0..<values.count{
            if values[pos] > 0 && values[pos] < mn{
                mn = values[pos]
                minPos = pos
            }
            if values[pos] > mx{
                mx = values[pos]
                maxPos = pos
            }
            if values[pos] == 0{
                if pos == 0 || averages[pos - 1] < 0{
                    runningTotal = -1
                    takeOff += 1
                }
                else{
                    runningTotal += averages[pos - 1]
                }
            }
            else{
                runningTotal += values[pos]
            }
            
            if runningTotal > 0{
                averages.append(runningTotal/(CGFloat(pos - takeOff) + 1))
            }
            else{
                averages.append(-1)
            }
        }
        if averages.isEmpty{
            return (0, 0, 0)
        }
        return (mn, averages.last!, mx)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showOriginals(){
        var hkImages: [HKComponent] = []
        let originals = HKBarChart.getBarComponents(values, cutOff: cutOff, barSize: barSize, size: size)
        var xPos = CGFloat(0)
        if !selectedComponents.isEmpty{
            xPos = selectedComponents[0].position.x
        }
        for pos in 0..<originals.count{
            let hkImage = originals[pos]
            hkImages.append(hkImage)
            hkImage.position.x = xPos
            xPos += barSize.width
        }
        addHKImages(hkImages)
    }
    
    func getBestSessionDetails(_ sessionSize: Int) -> (CGFloat, Int, Int){
        var n = 0
        for v in values{
            if v > 0{
                n += 1
            }
        }
        if sessionSize >= n{
            if averages.count > 0 {
                return (averages[averages.count - 1], 0, values.count)
            } else {
                return (0.0, 0, 0)
            }
        }
        var minAv = CGFloat(100000)
        var minStartPos = 0
        var extendedSessionSize = 0
        for startPos in 0...values.count - sessionSize{
            if values[startPos] > 0{
                var numCompleted = 0
                var pos = 0
                var av = CGFloat(0)
                var numVals = 0
                while numCompleted < sessionSize && (startPos + pos) < values.count{
                    let val = values[startPos + pos]
                    if val > 0{
                        numCompleted += 1
                        av += val
                        numVals += 1
                    }
                    pos += 1
                }
                av = av/CGFloat(sessionSize)
                if numVals == sessionSize && av < minAv{
                    minAv = av
                    minStartPos = startPos
                    extendedSessionSize = pos
                }
            }
        }
        return (minAv, minStartPos, extendedSessionSize)
    }
    
    func highlightBestSession(_ sessionSize: Int){
        let (_, minStartPos, extendedSessionSize) = getBestSessionDetails(sessionSize)
        showOriginals()
        for pos in 0..<values.count{
            if pos < minStartPos || pos >= minStartPos + extendedSessionSize{
                selectedComponents[pos].isHidden = true
                unselectedComponents[pos].isHidden = false
                unselectedComponents[pos].alpha = 0.2
            }
        }
        trayNode.removeAllActions()
        //let midPos = minStartPos + Int(round(CGFloat(extendedSessionSize)/2))
        
        let midPos : Int
        if extendedSessionSize == 1 {
            midPos = 0
        } else {
            midPos = minStartPos + Int(round(CGFloat(extendedSessionSize)/2))
        }
        
        let midX = selectedComponents[midPos].position.x
        trayNode.position.x = -midX
        centralValuePosition = midPos
    }
    
    func reorderSmallestToLargest(){
        let originals = HKBarChart.getBarComponents(values, cutOff: cutOff, barSize: barSize, size: size)
        var triples: [(CGFloat, HKComponent, Int)] = []
        for pos in 0..<originals.count{
            let hkImage = originals[pos]
            triples.append((values[pos], hkImage, pos))
        }
        triples.sort { (triple1, triple2) -> Bool in
            if triple1.0 == 0{
                return false
            }
            if triple2.0 == 0{
                return true
            }
            return triple1.0 < triple2.0
        }
        var hkImages: [HKComponent] = []
        var xPos = selectedComponents[0].position.x
        sortedValuePositions.removeAll()
        for triple in triples{
            hkImages.append(triple.1)
            sortedValuePositions.append(triple.2)
            triple.1.position.x = xPos
            xPos += barWidth
        }
        addHKImages(hkImages)
    }
    
    static func getBarComponents(_ values: [CGFloat], cutOff: CGFloat, barSize: CGSize, size: CGSize) -> [HKComponent]{
        var components: [HKComponent] = []
        for pos in 0..<values.count{
            let val = min(cutOff, values[pos])
            var colour = Colours.getColour(.antiqueWhite)
            if val < 100{
                colour = Colours.getColour(.purple)
            }
            var yOff = size.height * (1 - val/cutOff)
            if val == cutOff{
                yOff += 8
                colour = Colours.getColour(.gray)
            }

            let component = HKComponent()
            let node = SKSpriteNode()
            node.size = CGSize(width: barSize.width - 2, height: barSize.height * (val/cutOff))
            node.color = colour
            node.position.y -= (1 - barSize.height * (val/cutOff))/2 + barSize.height/2 - 2
            component.addChild(node)
            
            let baseNode = SKSpriteNode()
            baseNode.size = CGSize(width: barSize.width, height: 2)
            baseNode.color = Colours.getColour(.black)
            baseNode.position.y -= barSize.height/2 - 1
            component.addChild(baseNode)

            components.append(component)
        }
        return components
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        super.hideComponents()
    }
    
    func showAverages(){
        var hkImages: [HKImage] = []
        var previousYVal: CGFloat! = nil
        var xPos = selectedComponents[0].position.x
        for pos in 0..<averages.count{
            let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: barWidth * 3, height: size.height * 3))
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
            let context = UIGraphicsGetCurrentContext()!
            let val = min(cutOff, averages[pos])
            if val > 0{
                let colour = Colours.getColour(.antiqueWhite)
                context.setStrokeColor(colour.cgColor)
                context.setLineWidth(6)
                let yVal = size.height * (1 - val/cutOff) + 2
                if previousYVal == nil{
                    previousYVal = yVal
                }
                context.beginPath()
                context.move(to: CGPoint(x: 0, y: previousYVal * 3))
                context.addLine(to: CGPoint(x: barWidth * 3, y: yVal * 3))
                context.strokePath()
                previousYVal = yVal
            }
            
            context.setFillColor(Colours.getColour(.black).cgColor)
            context.fill(CGRect(origin: CGPoint(x: 0, y: (barSize.height - 2) * 3), size: CGSize(width: barSize.width * 3, height: 6)))
            
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let hkImage = HKImage(image: image)
            hkImage.position.x = xPos
            hkImages.append(hkImage)
            hkImage.size = CGSize(width: barWidth, height: size.height)
            xPos += barSize.width
        }
        addHKImages(hkImages)
    }
    
    func addHKImages(_ hkImages: [HKComponent]){
        selectedComponents.removeAll()
        unselectedComponents.removeAll()
        trayNode.removeAllChildren()
        for hkImage in hkImages{
            selectedComponents.append(hkImage)
            unselectedComponents.append(hkImage)
            trayNode.addChild(hkImage)
        }
        if includeXAxis{
            addXLabels()
        }
    }
    
    func addXLabels(){
        for label in xLabels{
            label.removeFromParent()
        }
        xLabels.removeAll()
        if !unselectedComponents.isEmpty{
            let font = UIFontCache(name: "HelveticaNeue-Thin", size: 11)
            for pos in 1...unselectedComponents.count{
                if pos % 10 == 0{
                    let label = SKLabelNode(font, Colours.getColour(.black))
                    label.text = "\(pos)"
                    label.position = CGPoint(x: 0, y: -barSize.height/2 - 2)
                    label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
                    unselectedComponents[pos - 1].addChild(label)
                    xLabels.append(label)
                }
            }            
        }
    }
    
    func getNumberOfDays() -> Int!{
        if dates == nil{
            return nil
        }
        var maxDays = 0
        for date in dates{
            let today = Date()
            let days = (Calendar.current as NSCalendar).components(.day, from: date, to: today, options: []).day
            maxDays = max(days!, maxDays)
        }
        return maxDays
    }
    
    func addBar(_ value: CGFloat, date: Date){
        values.append(value)
        dates.append(date)
        showOriginals()
        trayWidth += barWidth
        trayNode.size = CGSize(width: trayWidth, height: trayNode.size.height)
        maxTrayMovement = trayWidth - size.width
        leftMostTrayX = floor(-maxTrayMovement)
        _ = getMinAvMax()
        if includeXAxis{
            addXLabels()
        }
        numCards += 1
    }
    
}
