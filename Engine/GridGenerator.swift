//
//  GridGenerator.swift
//  MPCGD
//
//  Created by Simon Colton on 07/02/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction{
    case left, right, up, down
}

class GridGenerator{
    
    static let controllerShapePackNames = ["Rectangle", "Circular", "Bins", "Pachinko", "Blocks", "ZigZag", "Maze", "Dividers", "Containers"]
    
    var font = UIFontCache(name: "HelveticaNeue-Thin", size: 45)!
    
    static func getScreenSizeForButton(_ buttonSize: CGSize) -> CGSize{
        let overallSize = buttonSize * 2
        let internalSize = overallSize * 0.61
        let h = internalSize.height
        let ratio = DeviceType.simulationIs == .iPad ? CGFloat(3)/CGFloat(4) : CGFloat(9)/CGFloat(16)
        let w = internalSize.height * ratio
        let screenSize = CGSize(width: w, height: h)
        return screenSize
    }

    func getGridIcon(iconSize: CGSize, controllerPack: Int, shape: Int, orientation: Int, grain: Int, size: Int, colour: UIColor, includeBorder: Bool = true) -> UIImage{
        
        let overallSize = iconSize * 2
        let internalSize = overallSize * 0.61
        let h = internalSize.height
        let ratio = DeviceType.simulationIs == .iPad ? CGFloat(3)/CGFloat(4) : CGFloat(9)/CGFloat(16)
        let w = internalSize.height * ratio
        
        let screenSize = CGSize(width: w, height: h)
        let xMargin = (overallSize.width - screenSize.width)/2
        let yMargin = (overallSize.height - screenSize.height)/2

        UIGraphicsBeginImageContextWithOptions(overallSize, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setStrokeColor(Colours.getColour(.antiqueWhite).cgColor)
        context.setLineWidth(2)
        if includeBorder{
            context.stroke(CGRect(origin: CGPoint(x: xMargin - 5, y: yMargin - 5), size: CGSize(width: screenSize.width + 10, height: screenSize.height + 10)))
        }
        if controllerPack == 0{
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
        else if controllerPack == 1{
            if LAF.controllerFillAlpha > 0 {
                let polys = getPolys(controllerPack: controllerPack, shape: shape, orientation: orientation, grain: grain, size: size)
                context.setFillColor(colour.withAlphaComponent(LAF.controllerFillAlpha).cgColor)
                for poly in polys {
                    context.move(to: CGPoint(x: xMargin + poly[0].x * screenSize.width, y: yMargin + poly[0].y * screenSize.height))
                    for i in 1 ..< poly.count {
                        context.addLine(to: CGPoint(x: xMargin + poly[i].x * screenSize.width, y: yMargin + poly[i].y * screenSize.height))
                    }
                    context.closePath()
                    context.fillPath()
                }
            }
            
            let lines = getLines(controllerPack: controllerPack, shape: shape, orientation: orientation, grain: grain, size: size)
            context.setStrokeColor(colour.cgColor)
            for (p1, p2) in lines{
                let x1 = xMargin + (p1.x * screenSize.width)
                let y1 = yMargin + (p1.y * screenSize.height)
                let x2 = xMargin + (p2.x * screenSize.width)
                let y2 = yMargin + (p2.y * screenSize.height)
                context.move(to: CGPoint(x: x1, y: y1))
                context.addLine(to: CGPoint(x: x2, y: y2))
                context.strokePath()
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
        else{
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let characterImageName = CharacterIconHandler.getCharacterName(collectionNum: shape, characterNum: orientation)
            let characterWidth = (CGFloat(size)/62) * screenSize.width
            let characterSize = CGSize(width: characterWidth, height: characterWidth)
            let charImage = PDFImage(named: characterImageName, size: characterSize)!
            return ImageUtils.drawImageInImageCentre(image, topImage: charImage, opaque: false)
        }
    }
    
    func getBoundingBox(_ iconSize: CGSize, controllerPack: Int, shape: Int, orientation: Int, grain: Int, size: Int, reflectionID: Int, useIconSize: Bool = false) -> CGRect{
        let screenSize = useIconSize ? iconSize : GridGenerator.getScreenSizeForButton(iconSize)
        if controllerPack == 2{
            let radius = screenSize.width * CGFloat(size)/62
            var bounds = CharacterIconHandler.getCharacterBoundingBox(radius: radius, collectionNum: shape, characterNum: orientation, centreOffset: CGPoint(x: 0, y: 0))
            if reflectionID > 1{
                let rot = CGAffineTransform.init(rotationAngle: CGFloat.pi / 2)
                bounds = bounds.applying(rot)
            }
            return bounds
        }
        let lines = getLines(controllerPack: controllerPack, shape: shape, orientation: orientation, grain: grain, size: size)
        var maxX = CGFloat(0)
        var minX = CGFloat(1)
        var maxY = CGFloat(0)
        var minY = CGFloat(1)
        for l in lines{
            maxX = max(maxX, l.0.x)
            maxX = max(maxX, l.1.x)
            maxY = max(maxY, l.0.y)
            maxY = max(maxY, l.1.y)
            minX = min(minX, l.0.x)
            minX = min(minX, l.1.x)
            minY = min(minY, l.0.y)
            minY = min(minY, l.1.y)
        }
        var bounds = CGRect(x: minX * screenSize.width, y: minY * screenSize.height, width: (maxX - minX) * screenSize.width, height: (maxY - minY) * screenSize.height)
        if reflectionID > 1{
            let rot = CGAffineTransform.init(rotationAngle: CGFloat.pi / 2)
            bounds = bounds.applying(rot)
        }
        return bounds
    }
    
    func getLines(controllerPack: Int, shape: Int, orientation: Int, grain: Int, size: Int) -> [(CGPoint, CGPoint)]{
        
        if controllerPack != 1{
            return []
        }
        
        // FIX THIS - NEED TO ADD ANOTHER SET OF GRIDS
        // I.E. REMOVE REPEATED getSegregationLines at the end of the array
        // DON'T FORGET TO FIX GET POLYS TOO
        
        let funcs = [getSquareLines, getCircularLines, getBinLines, getPachinkoLines, getStepLines, getZigZagLines, getMazeLines, getSegregationLines, getContainerLines]
        
        let lines = funcs[shape](orientation, grain)
        
        var scaledLines: [(CGPoint, CGPoint)] = []
        
        let scale = CGFloat(size)/62
        let margin = (1 - scale) * 0.5
        for (p1, p2) in lines{
            let x1 = margin + (p1.x * scale)
            let y1 = margin + (p1.y * scale)
            let x2 = margin + (p2.x * scale)
            let y2 = margin + (p2.y * scale)
            let scaledLine = (CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2))
            scaledLines.append(scaledLine)
        }

        return scaledLines
    }
    
    // NOTE: getPolys must return convex polygons, otherwise the physics engine will get confused
    func getPolys(controllerPack: Int, shape: Int, orientation: Int, grain: Int, size: Int) -> [[CGPoint]]{
        
        if controllerPack != 1{
            return []
        }
        
        // FIX THIS - NEED TO ADD ANOTHER SET OF GRIDS
        // I.E. REMOVE REPEATED getSegregationLines at the end of the array

        let funcs = [getSquarePolys, getCircularPolys, getBinPolys, getPachinkoPolys, getStepPolys, getZigZagPolys, getMazePolys, getSegregationPolys, getContainerPolys]
        
        let polys = funcs[shape](orientation, grain)
        
        var scaledPolys: [[CGPoint]] = []
        
        let scale = CGFloat(size)/62
        let margin = (1 - scale) * 0.5
        for poly in polys{
            var scaledPoly : [CGPoint] = []
            for p in poly {
                let x = margin + (p.x * scale)
                let y = margin + (p.y * scale)
                scaledPoly.append(CGPoint(x: x, y: y))
            }
            scaledPolys.append(scaledPoly)
        }
        
        return scaledPolys
    }
    
    
    func getSquareLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        
        var lines: [(CGPoint, CGPoint)] = []
        lines.append(contentsOf: getRect(0, 0, 1, 1))
        var seg = CGFloat(1)/CGFloat(grain + 2)
        var linesToRemove: [Int] = []
        
        if orientation == 0 || orientation == 1{
            if grain > 0{
                lines.removeAll()
                let h = 1 - ((0.125) * CGFloat(grain))
                lines.append(contentsOf: getRect(0, (1 - h)/2, 1, h))
            }
        }
        
        if orientation == 2 || orientation == 3 || orientation == 4 || orientation == 5 || orientation == 6{
            linesToRemove.append(0)
            lines.append(getLine(0, 0, 0.5 - seg/2, 0))
            lines.append(getLine(0.5 + seg/2, 0, 1, 0))
        }
        if orientation == 3 || orientation == 4 || orientation == 5 {
            linesToRemove.append(1)
            lines.append(getLine(1, 0, 1, 0.5 - seg/2))
            lines.append(getLine(1, 0.5 + seg/2, 1, 1))
        }
        if orientation == 4 || orientation == 5 || orientation == 6 {
            linesToRemove.append(2)
            lines.append(getLine(0, 1, 0.5 - seg/2, 1))
            lines.append(getLine(0.5 + seg/2, 1, 1, 1))
        }
        if orientation == 5 {
            linesToRemove.append(3)
            lines.append(getLine(0, 0, 0, 0.5 - seg/2))
            lines.append(getLine(0, 0.5 + seg/2, 0, 1))
        }
        if orientation == 7{
            seg = CGFloat(1)/CGFloat(grain + 3)
            lines.removeAll()
            lines.append(getLine(0, 0, 1 - seg, 0))
            lines.append(getLine(seg, 1, 1, 1))
            lines.append(getLine(0, 0, 0, 1 - seg))
            lines.append(getLine(1, seg, 1, 1))
        }
        if orientation == 8{
            seg = CGFloat(1)/CGFloat(grain + 3)
            lines.removeAll()
            lines.append(getLine(seg, 0, 1 - seg, 0))
            lines.append(getLine(seg, 1, 1 - seg, 1))
            lines.append(getLine(0, seg, 0, 1 - seg))
            lines.append(getLine(1, seg, 1, 1 - seg))
        }
        
        var slimmedLines: [(CGPoint, CGPoint)] = []
        for pos in 0..<lines.count{
            if !linesToRemove.contains(pos){
                slimmedLines.append(lines[pos])
            }
        }
        lines = stretchLines(slimmedLines)
        
        return lines
    }
    
    func getSquarePolys(_ orientation: Int, grain: Int) -> [[CGPoint]]{
        if orientation == 0 && grain != 8 {
            let poly : [CGPoint]
            let h = 1 - ((0.125) * CGFloat(grain))
            poly = getRectPoly(0, (1 - h)/2, 1, h)
            return stretchPolys([poly])
        }
        else {
            return []
        }
    }

    func getCircularLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        
        // Grain here is the number of edges in the polyhedra
        
        var lines: [(CGPoint, CGPoint)] = []
        
        var onOff = true
        var numSegs = grain + 3
        if orientation == 2 || orientation == 3 || orientation == 7{
            numSegs = (grain * 2) + 6
        }
        if orientation == 4 || orientation == 5 || orientation == 8{
            numSegs = (grain * 3) + 6
        }
        let r = 0.5

        for pos in 1...numSegs{
            let theta = (2 * .pi) * Double(pos)/Double(numSegs)
            let x1 = 0.5 + (r * sin(theta))
            let y1 = 0.5 + (r * cos(theta))
            let theta2 = (2 * .pi) * Double(pos + 1)/Double(numSegs)
            let x2 = 0.5 + (r * sin(theta2))
            let y2 = 0.5 + (r * cos(theta2))
            if orientation == 0 || orientation == 1{
                lines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
            }
            else if orientation == 2 && onOff{
                lines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
            }
            else if orientation == 3 && onOff{
                lines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
                lines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(0.5), CGFloat(0.5)))
                lines.append(getLine(CGFloat(x2), CGFloat(y2), CGFloat(0.5), CGFloat(0.5)))
            }
            else if (orientation == 4 || orientation == 5) && onOff && pos < (numSegs - 1){
                if orientation == 4{
                    lines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
                }
                lines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(0.5), CGFloat(0.5)))
                lines.append(getLine(CGFloat(x2), CGFloat(y2), CGFloat(0.5), CGFloat(0.5)))
            }
            else if orientation == 6{
                lines.append(getLine(0.5, 0.5, CGFloat(x1), CGFloat(y1)))
            }
            else if orientation == 7 && onOff{
                let theta3 = (2 * .pi) * (Double(pos) + Double(0.5))/Double(numSegs)
                let x3 = 0.5 + (0.2 * sin(theta3))
                let y3 = 0.5 + (0.2 * cos(theta3))
                lines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
                lines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x3), CGFloat(y3)))
                lines.append(getLine(CGFloat(x2), CGFloat(y2), CGFloat(x3), CGFloat(y3)))
            }
            else if orientation == 8 && onOff{
                let theta3 = (2 * .pi) * (Double(pos) + Double(0.5))/Double(numSegs)
                let x3 = 0.5 + (0.5 * sin(theta3))
                let y3 = 0.5 + (0.5 * cos(theta3))
                let x4 = 0.5 + (0.3 * sin(theta))
                let y4 = 0.5 + (0.3 * cos(theta))
                let x5 = 0.5 + (0.3 * sin(theta2))
                let y5 = 0.5 + (0.3 * cos(theta2))
                lines.append(getLine(CGFloat(x3), CGFloat(y3), CGFloat(x4), CGFloat(y4)))
                lines.append(getLine(CGFloat(x3), CGFloat(y3), CGFloat(x5), CGFloat(y5)))
                lines.append(getLine(CGFloat(x4), CGFloat(y4), CGFloat(x5), CGFloat(y5)))
                
            }
            if orientation == 4 || orientation == 5 || orientation == 8{
                onOff = (pos % 3 == 0)
            }
            else{
                onOff = !onOff
            }
        }
        lines = stretchLines(lines)
        return lines
    }
    
    func getCircularPolys(_ orientation: Int, grain: Int) -> [[CGPoint]]{
        // Grain here is the number of edges in the polyhedra
        
        if orientation == 2 || orientation == 5 || orientation == 6 {
            return []
        }
        
        var polys: [[CGPoint]]
        
        var onOff = true
        var numSegs = grain + 3
        if orientation == 2 || orientation == 3 || orientation == 7{
            numSegs = (grain * 2) + 6
        }
        if orientation == 4 || orientation == 5 || orientation == 8{
            numSegs = (grain * 3) + 6
        }
        
        let r = 0.5
        if orientation == 0 {
            var poly : [CGPoint] = []
            for pos in 1...numSegs {
                let theta = (2 * .pi) * Double(pos)/Double(numSegs)
                let x1 = 0.5 + (r * sin(theta))
                let y1 = 0.5 + (r * cos(theta))
                poly.append(CGPoint(x: CGFloat(x1), y: CGFloat(y1)))
            }
            polys = [poly]
        }
        else {
            polys = []
            let centre = CGPoint(x: 0.5, y: 0.5)
            
            for pos in 1...numSegs {
                let theta = (2 * .pi) * Double(pos)/Double(numSegs)
                let x1 = 0.5 + (r * sin(theta))
                let y1 = 0.5 + (r * cos(theta))
                let p1 = CGPoint(x: CGFloat(x1), y: CGFloat(y1))
                let theta2 = (2 * .pi) * Double(pos + 1)/Double(numSegs)
                let x2 = 0.5 + (r * sin(theta2))
                let y2 = 0.5 + (r * cos(theta2))
                let p2 = CGPoint(x: CGFloat(x2), y: CGFloat(y2))
                
                if orientation == 3 && onOff{
                    polys.append([p1, p2, centre])
                }
                else if orientation == 4  && onOff && pos < (numSegs - 1){
                    polys.append([p1, p2, centre])
                }
                else if orientation == 7 && onOff{
                    let theta3 = (2 * .pi) * (Double(pos) + Double(0.5))/Double(numSegs)
                    let x3 = 0.5 + (0.2 * sin(theta3))
                    let y3 = 0.5 + (0.2 * cos(theta3))
                    let p3 = CGPoint(x: CGFloat(x3), y: CGFloat(y3))
                    polys.append([p1, p2, p3])
                }
                else if orientation == 8 && onOff{
                    let theta3 = (2 * .pi) * (Double(pos) + Double(0.5))/Double(numSegs)
                    let x3 = 0.5 + (0.5 * sin(theta3))
                    let y3 = 0.5 + (0.5 * cos(theta3))
                    let p3 = CGPoint(x: CGFloat(x3), y: CGFloat(y3))
                    let x4 = 0.5 + (0.3 * sin(theta))
                    let y4 = 0.5 + (0.3 * cos(theta))
                    let p4 = CGPoint(x: CGFloat(x4), y: CGFloat(y4))
                    let x5 = 0.5 + (0.3 * sin(theta2))
                    let y5 = 0.5 + (0.3 * cos(theta2))
                    let p5 = CGPoint(x: CGFloat(x5), y: CGFloat(y5))
                    polys.append([p3, p4, p5])
                }
                
                if orientation == 4 || orientation == 5 || orientation == 8{
                    onOff = (pos % 3 == 0)
                }
                else{
                    onOff = !onOff
                }
            }
        }
        
        polys = stretchPolys(polys)
        return polys
    }
    
    // Classic bins
    
    func getBinLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        var numLines = CGFloat(grain + 1)
        let a = CGFloat(0.2)
        let m = CGFloat(0.5)
        let b = CGFloat(0.8)
        if orientation < 8{
            for lineNum in 0...(grain + 1){
                let f = CGFloat(lineNum)/numLines
                if orientation == 0 || orientation == 1 || orientation == 4 || orientation == 6{
                    lines.append(getLine(f, a, f, b))
                }
                else{
                    lines.append(getLine(a, f, b, f))
                }
            }
            if orientation < 6{
                let endLines = [
                    getLine(0, b, 1, b),
                    getLine(0, a, 1, a),
                    getLine(b, 0, b, 1),
                    getLine(a, 0, a, 1),
                    getLine(0, m, 1, m),
                    getLine(m, 0, m, 1)
                ]
                lines.append(endLines[orientation])
                if orientation == 1{
                    lines.append(endLines[0])
                }
                if orientation == 3{
                    lines.append(endLines[2])
                }
            }
        }
        else{
            numLines += 1
            for lineNum in 0...(grain + 2){
                let f = CGFloat(lineNum)/numLines
                lines.append(getLine(f, 0, f, 1))
                lines.append(getLine(0, f, 1, f))
            }
        }
        return lines
    }
    
    func getBinPolys(_ orientation: Int, grain: Int) -> [[CGPoint]]{
        return []
    }
    
   func getPachinkoLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        
        let numCols = CGFloat((grain + 2) * 2)
        
        var lines: [(CGPoint, CGPoint)] = []
        let seg = CGFloat(1)/(numCols + 1)
        var shiftX = false
        
        for y in 0...Int(numCols){
            let xMax = shiftX ? numCols - 1 : numCols
            for x in 0...Int(xMax){
                if x % 2 == 0 && y % 2 == 0{
                    let shiftedX = shiftX ? (seg * CGFloat(x)) + seg : seg * CGFloat(x)
                    if orientation < 4{
                        var rectLines = getRect(shiftedX, seg * CGFloat(y), seg, seg)
                        if orientation == 2{
                            rectLines.remove(at: 0)
                        }
                        if orientation == 3{
                            rectLines.remove(at: 2)
                            rectLines[0].0.y += seg/2
                            rectLines[0].1.y += seg/2
                        }
                        lines.append(contentsOf: rectLines)
                    }
                    else if orientation == 4{
                        lines.append(contentsOf: getDiamond(shiftedX, seg * CGFloat(y), seg, seg))
                    }
                    else if orientation == 5{
                        lines.append(getLine(shiftedX, (seg * CGFloat(y)) + seg/2, shiftedX + seg, (seg * CGFloat(y)) + seg/2))
                        lines.append(getLine(shiftedX + seg/2, seg * CGFloat(y), shiftedX + seg/2, seg * CGFloat(y) + seg))
                    }
                    else if orientation == 6{
                        lines.append(getLine(shiftedX, (seg * CGFloat(y)), shiftedX + seg, (seg * CGFloat(y)) + seg))
                        lines.append(getLine(shiftedX + seg, seg * CGFloat(y), shiftedX, seg * CGFloat(y) + seg))
                    }
                    else if orientation == 7{
                        lines.append(contentsOf: getOctagon(shiftedX, seg * CGFloat(y), seg, seg))
                    }
                    else if orientation == 8{
                        lines.append(getLine(shiftedX, (seg * CGFloat(y)), shiftedX + seg/2, (seg * CGFloat(y)) + seg))
                        lines.append(getLine(shiftedX + seg, seg * CGFloat(y), shiftedX + seg/2, seg * CGFloat(y) + seg))
                    }
                }
            }
            if y % 2 == 0{
                shiftX = !shiftX
            }
        }
        lines = stretchLines(lines)
        return lines
    }
    
    func getPachinkoPolys(_ orientation: Int, grain: Int) -> [[CGPoint]]{
        if orientation == 0 || orientation == 4 || orientation == 7 {
            let numCols = CGFloat((grain + 2) * 2)
            
            var polys: [[CGPoint]] = []
            let seg = CGFloat(1)/(numCols + 1)
            var shiftX = false
            
            for y in 0...Int(numCols){
                let xMax = shiftX ? numCols - 1 : numCols
                for x in 0...Int(xMax){
                    if x % 2 == 0 && y % 2 == 0{
                        let shiftedX = shiftX ? (seg * CGFloat(x)) + seg : seg * CGFloat(x)
                        if orientation == 0 {
                            let rect = getRectPoly(shiftedX, seg * CGFloat(y), seg, seg)
                            polys.append(rect)
                        }
                        else if orientation == 4 {
                            let diamond = getDiamondPoly(shiftedX, seg * CGFloat(y), seg, seg)
                            polys.append(diamond)
                        }
                        else if orientation == 7 {
                            let octagon = getOctagonPoly(shiftedX, seg * CGFloat(y), seg, seg)
                            polys.append(octagon)
                        }
                    }
                }
                if y % 2 == 0{
                    shiftX = !shiftX
                }
            }
            polys = stretchPolys(polys)
            return polys
        }
        else {
            return []
        }
    }
    
    func getStepLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []

        // Here, grain is the number of steps
        let numSteps = CGFloat(grain + 3)
        let seg = 1/numSteps
        let a = CGFloat(0.2)
        let b = CGFloat(0.8)

        let hAdd = CGFloat(b - a)/(ceil(numSteps/2))
        var stepHeight = CGFloat(0)
        var midNum = CGFloat(-1)
        if numSteps.truncatingRemainder(dividingBy: 2) == 0{
            midNum = CGFloat(ceil(numSteps/2))
        }
        for pos in 0..<Int(numSteps){
            if CGFloat(pos) < numSteps/2{
                stepHeight += hAdd
            }
            else if CGFloat(pos) != midNum{
                stepHeight -= hAdd
            }
            var rectLines: [(CGPoint, CGPoint)] = []
            if orientation == 0 || orientation == 1{
                rectLines = getRect(seg * CGFloat(pos), b - stepHeight, seg, stepHeight)
            }
            else if orientation == 2 || orientation == 3{
                rectLines = getRect(a, seg * CGFloat(pos), stepHeight, seg)
            }
            else if orientation == 4 || orientation == 5{
                rectLines = getRect(seg * CGFloat(pos), a, seg, b - stepHeight)
            }
            else if orientation == 6 || orientation == 7{
                rectLines = getRect(stepHeight, seg * CGFloat(pos), b - stepHeight, seg)
            }
            else if orientation == 8{
                rectLines = getRect(seg * CGFloat(pos), 0.5 - stepHeight/2, seg, stepHeight)
            }
            lines.append(contentsOf: rectLines)
        }
        
        return lines
    }
    
    func getStepPolys(_ orientation: Int, grain: Int) -> [[CGPoint]]{
        var polys: [[CGPoint]] = []
        
        // Here, grain is the number of steps
        let numSteps = CGFloat(grain + 3)
        let seg = 1/numSteps
        let a = CGFloat(0.2)
        let b = CGFloat(0.8)
        
        let hAdd = CGFloat(b - a)/(ceil(numSteps/2))
        var stepHeight = CGFloat(0)
        var midNum = CGFloat(-1)
        if numSteps.truncatingRemainder(dividingBy: 2) == 0{
            midNum = CGFloat(ceil(numSteps/2))
        }
        for pos in 0..<Int(numSteps){
            if CGFloat(pos) < numSteps/2{
                stepHeight += hAdd
            }
            else if CGFloat(pos) != midNum{
                stepHeight -= hAdd
            }
            if orientation == 0{
                polys.append(getRectPoly(seg * CGFloat(pos), b - stepHeight, seg, stepHeight))
            }
            else if orientation == 2{
                polys.append(getRectPoly(a, seg * CGFloat(pos), stepHeight, seg))
            }
            else if orientation == 4{
                polys.append(getRectPoly(seg * CGFloat(pos), a, seg, b - stepHeight))
            }
            else if orientation == 6{
                polys.append(getRectPoly(stepHeight, seg * CGFloat(pos), b - stepHeight, seg))
            }
            else if orientation == 8{
                polys.append(getRectPoly(seg * CGFloat(pos), 0.5 - stepHeight/2, seg, stepHeight))
            }
        }
        
        return polys
    }
    
    func getZigZagLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        
        // Grain here is the number of zigzags (both in and out)
        
        var lines: [(CGPoint, CGPoint)] = []
        let numZigs = grain + 1
        let seg = CGFloat(1)/CGFloat(numZigs)
        let inOut = CGFloat(0.1)
        
        if orientation == 4{
            lines.append(getLine(0.5 + inOut, 0, 0.5 - inOut, 0))
        }
        else if orientation == 5{
            lines.append(getLine(0, 0.5 + inOut, 0, 0.5 - inOut))
        }

        for pos in 0..<numZigs{
            let startPos = CGFloat(pos) * seg
            if orientation == 0{
                lines.append(getLine(startPos, 0.5 - inOut, startPos + seg/2, 0.5 + inOut))
                lines.append(getLine(startPos + seg/2, 0.5 + inOut, startPos + seg, 0.5 - inOut))
            }
            else if orientation == 1{
                lines.append(getLine(startPos + seg/4, 0.5 - inOut, startPos + seg/2, 0.5 + inOut))
                lines.append(getLine(startPos + seg/2, 0.5 + inOut, startPos + seg * 0.75, 0.5 - inOut))
            }
            else if orientation == 2{
                lines.append(getLine(0.5 - inOut, startPos, 0.5 + inOut, startPos + seg/2))
                lines.append(getLine(0.5 + inOut, startPos + seg/2, 0.5 - inOut, startPos + seg))
            }
            else if orientation == 3{
                lines.append(getLine(0.5 - inOut, startPos + seg/4, 0.5 + inOut, startPos + seg/2))
                lines.append(getLine(0.5 + inOut, startPos + seg/2, 0.5 - inOut, startPos + seg * 0.75))
            }
            else if orientation == 4{
                lines.append(getLine(0.5 - inOut, startPos, 0.5 - inOut, startPos + seg/2))
                lines.append(getLine(0.5 - inOut, startPos + seg/2, 0.5 + inOut, startPos + seg/2))
                lines.append(getLine(0.5 + inOut, startPos + seg/2, 0.5 + inOut, startPos + seg))
                lines.append(getLine(0.5 + inOut, startPos + seg, 0.5 - inOut, startPos + seg))
            }
            else if orientation == 5{
                lines.append(getLine(startPos, 0.5 - inOut, startPos + seg/2, 0.5 - inOut))
                lines.append(getLine(startPos + seg/2, 0.5 - inOut, startPos + seg/2, 0.5 + inOut))
                lines.append(getLine(startPos + seg/2, 0.5 + inOut, startPos + seg, 0.5 + inOut))
                lines.append(getLine(startPos + seg, 0.5 + inOut, startPos + seg, 0.5 - inOut))
            }
            else if orientation == 6{
                lines.append(getLine(startPos, 0.75 - inOut, startPos + seg/2, 0.75 + inOut))
                lines.append(getLine(startPos + seg/2, 0.75 + inOut, startPos + seg, 0.75 - inOut))
                lines.append(getLine(startPos, 0.25 + inOut, startPos + seg/2, 0.25 - inOut))
                lines.append(getLine(startPos + seg/2, 0.25 - inOut, startPos + seg, 0.25 + inOut))
            }
            else if orientation == 7{
                lines.append(getLine(startPos, 0.25 - inOut, startPos + seg/2, 0.25 + inOut))
                lines.append(getLine(startPos + seg/2, 0.25 + inOut, startPos + seg, 0.25 - inOut))
                lines.append(getLine(startPos, 0.75 + inOut, startPos + seg/2, 0.75 - inOut))
                lines.append(getLine(startPos + seg/2, 0.75 - inOut, startPos + seg, 0.75 + inOut))
            }
            else if orientation == 8{
                lines.append(getLine(startPos, 0.25 - inOut, startPos + seg/2, 0.25 + inOut))
                lines.append(getLine(startPos + seg/2, 0.25 + inOut, startPos + seg, 0.25 - inOut))
                lines.append(getLine(startPos, 0.75 - inOut, startPos + seg/2, 0.75 + inOut))
                lines.append(getLine(startPos + seg/2, 0.75 + inOut, startPos + seg, 0.75 - inOut))
            }
        }
        return lines
    }
    
    func getZigZagPolys(_ orientation: Int, grain: Int) -> [[CGPoint]]{
        // No filled polygons for this grid type
        return []
    }
    
    func getMazeLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        
        var lines: [(CGPoint, CGPoint)] = []
        
        // inOut + (numLines - 1) * yMovement = 1
        // yMovement = (1 - inOut)/(numLines - 1)
        //

        if orientation == 0 || orientation == 1{
            let numZigs = CGFloat(5)
            let numLines = CGFloat(grain + 2)
            let depthMultiplier = CGFloat(1.2)
            let inOut = (1/numLines) * depthMultiplier
            let yMovement = (1 - inOut)/(numLines - 1)
            let seg = (1/numZigs) * 0.5
            for lineNum in 0..<Int(numLines){
                let yPos = yMovement * CGFloat(lineNum)
                for segNum in 0..<Int(numZigs){
                    let s = CGFloat(segNum)
                    if orientation == 0{
                        lines.append(getLine(s * seg * 2, yPos, (s * seg * 2) + seg, yPos + inOut))
                        lines.append(getLine((s * seg * 2) + seg, yPos + inOut, (s * seg * 2) + (2 * seg), yPos))
                    }
                    else{
                        lines.append(getLine(yPos, s * seg * 2, yPos + inOut, (s * seg * 2) + seg))
                        lines.append(getLine(yPos + inOut, (s * seg * 2) + seg, yPos, (s * seg * 2) + (2 * seg)))
                    }
                }
            }
            return lines
        }
        
        if orientation == 2{
            let seg = CGFloat(1)/CGFloat(grain + 5)
            var steps: [Direction] = []
            let top: [Direction] = Array.init(repeating: .right, count: grain + 3)
            let left: [Direction] = Array.init(repeating: .down, count: grain + 4)
            let right: [Direction] = Array.init(repeating: .down, count: grain + 3)
            let bottom: [Direction] = Array.init(repeating: .right, count: grain + 4)
            for _ in 0..<(grain + 4){
                steps.append(.right)
                steps.append(.down)
            }
            lines.append(contentsOf: getPath(CGPoint(x: 0, y: seg), seg: seg, directions: steps))
            steps.removeFirst()
            steps.removeLast()
            lines.append(contentsOf: getPath(CGPoint(x: seg * 2, y: 0), seg: seg, directions: steps))
            lines.append(contentsOf: getPath(CGPoint(x: seg * 2, y: 0), seg: seg, directions: top))
            lines.append(contentsOf: getPath(CGPoint(x: 1, y: 0), seg: seg, directions: right))
            lines.append(contentsOf: getPath(CGPoint(x: 0, y: 1), seg: seg, directions: bottom))
            lines.append(contentsOf: getPath(CGPoint(x: 0, y: seg), seg: seg, directions: left))
            
            //lines = stretchLines(lines)
        }
        
        if orientation == 3 || orientation == 4{
            let stretch = (grain > 4)
            let g = grain % 5
            let squareSize = CGFloat(1)/CGFloat(g + 3)
            for x in 0...(g + 2){
                for y in 0...(g + 2){
                    var f = CGFloat(0.33)
                    var s = CGFloat(0.66)
                    let holeWidth = (s - f)/CGFloat(g + 2)
                    if holeWidth < 0.05{
                        let h = 0.05 * CGFloat(g + 2)
                        f = 1 - (h / (1/CGFloat(grain + 2)))
                        s = 1 - f
                    }
                    if orientation == 3{
                        let rect = getRectWithHoles(CGFloat(x) * squareSize, CGFloat(y) * squareSize, squareSize, squareSize, f, s)
                        lines.append(contentsOf: rect)
                    }
                    else if orientation == 4{
                        let rect = getDiamondWithHoles(CGFloat(x) * squareSize, CGFloat(y) * squareSize, squareSize, squareSize, f, s)
                        lines.append(contentsOf: rect)
                    }
                }
            }
            if stretch{
                lines = stretchLines(lines)
            }
        }
        else if orientation == 5{
            let g = grain < 6 ? CGFloat(grain) : CGFloat(grain - 3)
            let mult = DeviceType.simulationIs == .iPad ? CGFloat(3)/CGFloat(4) : CGFloat(9)/CGFloat(16)
            let squareSize = CGFloat(1)/CGFloat(g + 2)
            let yAdd = squareSize * mult
            let ratio = DeviceType.simulationIs == .iPad ? 4/3 : 16/9
            for x in 0...(Int(g + 1)){
                for y in 0...Int(round((g + 1) * (CGFloat(ratio)))){
                    if grain < 6 || (x % 2 !=  y % 2) {
                    lines.append(contentsOf: getOctagon(CGFloat(x)/(g+2) + squareSize/5, CGFloat(y) * yAdd + squareSize/5, squareSize * (3/5), squareSize * (3/5) * mult))
                    }
                }
            }
            lines = centreLinesVertically(lines)
        }
        else if orientation == 6{
            // Grain here is number of lines (-2)
            var y = CGFloat(0)
            let seg = 1/CGFloat(grain + 2)
            for pos in 0...(grain + 1){
                if pos % 2 == 0{
                    lines.append(getLine(0, y, 0.7, y + seg))
                }
                else{
                    lines.append(getLine(0.3, y + seg, 1, y))
                }
                y += seg
            }
        }
        else if orientation == 7{
            let seg = 1/CGFloat(grain + 1)
            lines.append(getLine(0, 0, 1, 1))
            if grain > 0{
                for pos in 1...grain{
                    let segPos = seg * CGFloat(pos)
                    lines.append(getLine(0, segPos, 1 - segPos, 1))
                    lines.append(getLine(segPos, 0, 1, 1 - segPos))
                }
            }
        }
        else if orientation == 8{
            let seg = 1/CGFloat(grain + 1)
            lines.append(getLine(0, 1, 1, 0))
            if grain > 0{
                for pos in 1...grain{
                    let segPos = seg * CGFloat(pos)
                    lines.append(getLine(0, 1 - segPos, 1 - segPos, 0))
                    lines.append(getLine(segPos, 1, 1, segPos))
                }
            }
        }
        
        return lines
    }
    
    func getMazePolys(_ orientation: Int, grain: Int) -> [[CGPoint]]{
        if orientation == 2 {
            let seg = CGFloat(1)/CGFloat(grain + 5)
            var polys : [[CGPoint]] = []
            
            for i in 0 ... grain+3 {
                let f = CGFloat(i) * seg
                let rect = getRectPoly(f, f+seg, seg, 1-f-seg)
                polys.append(rect)
                
                if i > 0 {
                    let rect2 = getRectPoly(f+seg, 0, seg, f)
                    polys.append(rect2)
                }
            }
            
            return polys
        }
        else if orientation == 5 {
            var polys : [[CGPoint]] = []
            let g = grain < 6 ? CGFloat(grain) : CGFloat(grain - 3)
            let mult = DeviceType.simulationIs == .iPad ? CGFloat(3)/CGFloat(4) : CGFloat(9)/CGFloat(16)
            let squareSize = CGFloat(1)/CGFloat(g + 2)
            let yAdd = squareSize * mult
            let ratio = DeviceType.simulationIs == .iPad ? 4/3 : 16/9
            for x in 0...(Int(g + 1)){
                for y in 0...Int(round((g + 1) * (CGFloat(ratio)))){
                    if grain < 6 || (x % 2 !=  y % 2) {
                        polys.append(getOctagonPoly(CGFloat(x)/(g+2) + squareSize/5, CGFloat(y) * yAdd + squareSize/5, squareSize * (3/5), squareSize * (3/5) * mult))
                    }
                }
            }
            return centrePolysVertically(polys)
        }
        else {
            return []
        }
    }
    
    func getSegregationLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        
        if orientation == 0 || orientation == 1{
            let addOn = CGFloat(0.03)
            let offSet = (CGFloat(9 - grain) * addOn)
            let f = 0.5 - offSet
            let s = 0.5 + offSet
            if orientation == 0{
                lines.append(contentsOf: getSplitLines(0, 0.5, 1, 0.5, f, s))
                lines.append(getLine(0, 0, 0, 1))
                lines.append(getLine(1, 0, 1, 1))
            }
            else if orientation == 1{
                lines.append(contentsOf: getSplitLines(0.5, 0, 0.5, 1, f, s))
                lines.append(getLine(0, 0, 1, 0))
                lines.append(getLine(0, 1, 1, 1))
            }
        }
        
        if orientation == 2 || orientation == 3{
            let addOn = CGFloat(0.025)
            let f = CGFloat(0.2 + (addOn * CGFloat(grain + 1)))
            let w = (1-(2*f))
            lines.append(contentsOf: stretchLines(getOctagon(f, f, w, w)))
            let y1 = lines[5].1.y
            let y2 = lines[0].1.y
            lines.remove(at: 2)
            lines.remove(at: 5)
            if orientation == 2{
                lines.append(getLine(0, 0, 0, 1))
                lines.append(getLine(1, 0, 1, 1))
                lines.append(contentsOf: getSplitLines(0, 0.5, 1, 0.5, f, 1-f))
            }
            else{
                lines.append(getLine(0, 0, 1, 0))
                lines.append(getLine(0, 1, 1, 1))
                lines.append(contentsOf: getSplitLines(0.5, 0, 0.5, 1, y1, y2))
            }
        }
        
        if orientation == 4{
            let addOn = CGFloat(0.045)
            let offSet = (CGFloat(9 - grain) * addOn)
            let f = 0.5 - offSet
            let s = 0.5 + offSet
            lines.append(contentsOf: getSplitLines(0, 0.5, 0.5, 0.5, f, s))
            lines.append(contentsOf: getSplitLines(0.5, 0.5, 1, 0.5, f, s))
            lines.append(contentsOf: getSplitLines(0.5, 0, 0.5, 0.5, f, s))
            lines.append(contentsOf: getSplitLines(0.5, 0.5, 0.5, 1, f, s))
        }
        
        if orientation == 5 {
            let addOn = CGFloat(0.045)
            let offSet = (CGFloat(grain) * addOn)
            lines.append(contentsOf: getSplitLines(offSet, 1 - offSet, 0.5, offSet, 0.4, 0.6))
            lines.append(contentsOf: getSplitLines(0.5, offSet, 1 - offSet, 1 - offSet, 0.4, 0.6))
            lines.append(contentsOf: getSplitLines(1 - offSet, 1 - offSet, offSet, 1 - offSet, 0.4, 0.6))
            lines = stretchLines(lines)
            lines.append(getLine(0, 1, lines[0].0.x, lines[0].0.y))
            lines.append(getLine(lines[2].0.x, lines[2].0.y, 0.5, 0))
            lines.append(getLine(lines[4].0.x, lines[4].0.y, 1, 1))
        }
        
        if orientation == 6{
            let numSegs = grain + 2
            let r = Double(0.5)
            for pos in 0..<numSegs{
                let theta = (2 * .pi) * Double(pos)/Double(numSegs)
                let x1 = 0.5 + (r * sin(theta))
                let y1 = 0.5 + (r * cos(theta))
                lines.append(getLine(0.5, 0.5, CGFloat(x1), CGFloat(y1)))
            }
        }
        
        if orientation == 7 || orientation == 8{
            let addOn = CGFloat(0.03)
            let offSet = (CGFloat(9 - grain) * addOn)
            let f = 0.5 - offSet
            let s = 0.5 + offSet
            if orientation == 7{
                lines.append(contentsOf: getSplitLines(0, 0.5, 1, 0.5, f, s))
                lines.append(getLine(0, 0, 0, 1))
                lines.append(getLine(1, 0, 1, 1))
                
                let yOff = CGFloat(0.3)
                let xOff = CGFloat(0.1) + (CGFloat(grain) * 0.03)
                lines.append(getLine(f, 0.5, f - xOff, 0.5 + yOff))
                lines.append(getLine(f, 0.5, f - xOff, 0.5 - yOff))
                lines.append(getLine(s, 0.5, s + xOff, 0.5 + yOff))
                lines.append(getLine(s, 0.5, s + xOff, 0.5 - yOff))
            }
            else if orientation == 8{
                lines.append(contentsOf: getSplitLines(0.5, 0, 0.5, 1, f, s))
                lines.append(getLine(0, 0, 1, 0))
                lines.append(getLine(0, 1, 1, 1))

                let yOff = CGFloat(0.3)
                let xOff = CGFloat(0.1) + (CGFloat(grain) * 0.03)
                lines.append(getLine(0.5, f, 0.5 + yOff, f - xOff))
                lines.append(getLine(0.5, f, 0.5 - yOff, f - xOff))
                lines.append(getLine(0.5, s, 0.5 + yOff, s + xOff))
                lines.append(getLine(0.5, s, 0.5 - yOff, s + xOff))
            }
        }
        return lines
    }
    
    func getSegregationPolys(_ orientation: Int, grain: Int) -> [[CGPoint]]{
        // No filled polygons for this grid type
        return []
    }
    
    func getContainerLines(_ orientation: Int, grain: Int) -> [(CGPoint, CGPoint)]{
        
        var lines: [(CGPoint, CGPoint)] = []
        if orientation == 0{
            // Glass

            let lX = 0.33 - (CGFloat(grain) * 0.03)
            let rX = 0.66 + (CGFloat(grain) * 0.03)
            lines.append(getLine(0, 0, lX, 1))
            lines.append(getLine(lX, 1, rX, 1))
            lines.append(getLine(rX, 1, 1, 0))
        }
        
        if orientation == 1{
            // Bowl
            var tempLines: [(CGPoint, CGPoint)] = []

            
            let r = 0.5
            
            let numSegs = 35
            let first = Int(Double(numSegs) * 0.25)
            let last = Int(Double(numSegs) * 0.75)
            let m = (1 - Double(grain)/10)
            var topY = Double(0)
            var bottomY = Double(1)
            
            for pos in first...last{
                let theta = (2 * .pi) * Double(pos)/Double(numSegs)
                let x1 = 0.5 + (r * sin(theta))
                let y1 = (0.5 - (r * cos(theta))) * m
                let theta2 = (2 * .pi) * Double(pos + 1)/Double(numSegs)
                let x2 = 0.5 + (r * sin(theta2))
                let y2 = (0.5 - (r * cos(theta2))) * m
                tempLines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
                topY = max(topY, y1)
                topY = max(topY, y2)
                bottomY = min(bottomY, y1)
                bottomY = min(bottomY, y2)
            }
            let dist = topY - bottomY
            let moveBy = CGFloat(0.5 - (dist/2) - bottomY)
            for pair in tempLines{
                let p1 = CGPoint(x: pair.0.x, y: pair.0.y + moveBy)
                let p2 = CGPoint(x: pair.1.x, y: pair.1.y + moveBy)
                let movedLine = (p1, p2)
                lines.append(movedLine)
            }

        }

        if orientation == 2{
            // Bowl
            var tempLines: [(CGPoint, CGPoint)] = []
            let r = 0.5
            
            let numSegs = 25
            let first, last: Int
            switch grain % 3{
            case 0:
                first = Int(Double(numSegs) * 0.15) - 3
                last = Int(Double(numSegs) * 0.85) + 3
            case 1:
                first = Int(Double(numSegs) * 0.15) - 2
                last = Int(Double(numSegs) * 0.85) + 2
            case 2:
                first = Int(Double(numSegs) * 0.15) - 1
                last = Int(Double(numSegs) * 0.85) + 1
            default:
                first = 0
                last = 0
            }
            let g = grain % 3 == 0 ? grain : grain % 3 == 1 ? grain - 1 : grain - 2
            let m = (1 - Double(g)/10)
            var topY = Double(0)
            var bottomY = Double(1)
            
            for pos in first...last{
                let theta = (2 * .pi) * Double(pos)/Double(numSegs)
                let x1 = 0.5 + (r * sin(theta))
                let y1 = (0.5 - (r * cos(theta))) * m
                let theta2 = (2 * .pi) * Double(pos + 1)/Double(numSegs)
                let x2 = 0.5 + (r * sin(theta2))
                let y2 = (0.5 - (r * cos(theta2))) * m
                tempLines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
                topY = max(topY, y1)
                topY = max(topY, y2)
                bottomY = min(bottomY, y1)
                bottomY = min(bottomY, y2)
            }
            let dist = topY - bottomY
            let moveBy = CGFloat(0.5 - (dist/2) - bottomY)
            for pair in tempLines{
                let p1 = CGPoint(x: pair.0.x, y: pair.0.y + moveBy)
                let p2 = CGPoint(x: pair.1.x, y: pair.1.y + moveBy)
                let movedLine = (p1, p2)
                lines.append(movedLine)
            }
            
        }
        
        if orientation == 3{
            let seg = 0.5 - (CGFloat(grain) * 0.06)
            lines.append(getLine(seg, 0, 0, 1))
            lines.append(getLine(0, 1, 1, 1))
            lines.append(getLine(1, 1, 1 - seg, 0))
        }
        
        if orientation == 4{
            let seg = 0.5 - (CGFloat(grain + 2) * 0.03)
            let neckHeight = 0.5 - ((1 - CGFloat(grain + 1)) * 0.04)
            lines.append(getLine(seg, 0, seg, 1 - neckHeight))
            lines.append(getLine(seg, 1 - neckHeight, 0, 1 - neckHeight))
            lines.append(getLine(0, 1 - neckHeight, 0, 1))
            lines.append(getLine(0, 1, 1, 1))
            lines.append(getLine(1, 1, 1, 1 - neckHeight))
            lines.append(getLine(1, 1 - neckHeight, 1 - seg, 1 - neckHeight))
            lines.append(getLine(1 - seg, 1 - neckHeight, 1 - seg, 0))
        }
        
        if orientation == 5{
            var tempLines: [(CGPoint, CGPoint)] = []
            let r = 0.5
            
            let numSegs = 45
            let first = grain + 1
            let last = numSegs - (grain + 2)
            
            var topY = Double(0)
            var bottomY = Double(1)
            
            for pos in first...last{
                let theta = (2 * .pi) * Double(pos)/Double(numSegs)
                let x1 = 0.5 + (r * sin(theta))
                let y1 = (0.5 - (r * cos(theta)))
                let theta2 = (2 * .pi) * Double(pos + 1)/Double(numSegs)
                let x2 = 0.5 + (r * sin(theta2))
                let y2 = (0.5 - (r * cos(theta2)))
                tempLines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
                topY = max(topY, y1)
                topY = max(topY, y2)
                bottomY = min(bottomY, y1)
                bottomY = min(bottomY, y2)
            }
            let p1 = tempLines[0].0
            let p2 = tempLines.last!.1
            let neckLength = CGFloat(0.2)
            tempLines.append(getLine(p1.x, p1.y, p1.x, p1.y - neckLength))
            tempLines.append(getLine(p2.x, p2.y, p2.x, p2.y - neckLength))
            topY = max(topY, Double(p1.y) - Double(neckLength))
            bottomY = min(bottomY, Double(p1.y) - Double(neckLength))
            let dist = topY - bottomY
            let moveBy = CGFloat(0.5 - (dist/2) - bottomY)
            for pair in tempLines{
                let p1 = CGPoint(x: pair.0.x, y: pair.0.y + moveBy)
                let p2 = CGPoint(x: pair.1.x, y: pair.1.y + moveBy)
                let movedLine = (p1, p2)
                lines.append(movedLine)
            }
            lines = stretchLines(lines)
        }
        
        if orientation == 6{
            let seg = 0.5 - (CGFloat(grain + 2) * 0.03)
            lines.append(getLine(0, 0, seg, 0))
            lines.append(getLine(seg, 0, seg, 1))
            lines.append(getLine(seg, 1, 1-seg, 1))
            lines.append(getLine(1-seg, 1, 1-seg, 0))
            lines.append(getLine(1-seg, 0, 1, 0))
        }
        
        if orientation == 7{
            let seg = 0.5 - (CGFloat(grain + 2) * 0.03)
            lines.append(getLine(seg, 0, 0, 0.5))
            lines.append(getLine(0, 0.5, 0.5, 1))
            lines.append(getLine(0.5, 1, 1, 0.5))
            lines.append(getLine(1, 0.5, 1-seg, 0))
        }
        
        if orientation == 8{
            var tempLines: [(CGPoint, CGPoint)] = []
            let r = 0.5
            
            let numSegs = 31
            let first = grain + 2
            let last = numSegs - (grain + 3)
                
            for pos in first...last{
                let theta = (2 * .pi) * Double(pos)/Double(numSegs)
                let x1 = 0.5 + (r * sin(theta))
                let y1 = (0.5 - (r * cos(theta)))
                let theta2 = (2 * .pi) * Double(pos + 1)/Double(numSegs)
                let x2 = 0.5 + (r * sin(theta2))
                let y2 = (0.5 - (r * cos(theta2)))
                tempLines.append(getLine(CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2)))
            }
            
            var biggestY = Double(0)
            var leastY = Double(1)
            tempLines = stretchLines(tempLines)
            for l in tempLines{
                biggestY = max(biggestY, Double(l.0.y))
                biggestY = max(biggestY, Double(l.1.y))
                leastY = min(leastY, Double(l.0.y))
                leastY = min(leastY, Double(l.1.y))
            }
            let neckLength = CGFloat(0.5)
            biggestY -= leastY
            let addOn  = (1 - (CGFloat(biggestY) + neckLength))/2
            for l in tempLines{
                lines.append(getLine(l.0.x, l.0.y - CGFloat(leastY) + addOn, l.1.x, l.1.y - CGFloat(leastY) + addOn))
            }
            lines.append(getLine(0.5, CGFloat(biggestY) + addOn, 0.5, CGFloat(biggestY) + neckLength + addOn))
            lines.append(getLine(0.25, CGFloat(biggestY) + neckLength + addOn, 0.75, CGFloat(biggestY) + neckLength + addOn))
        }

        return lines
    }
    
    func getContainerPolys(_ orientation: Int, graint: Int) -> [[CGPoint]]{
        
        return []
    }
    
    func stretchLines(_ lines: [(CGPoint, CGPoint)]) -> [(CGPoint, CGPoint)]{
        var stretchedLines: [(CGPoint, CGPoint)] = []
        let mult = DeviceType.simulationIs == .iPad ? CGFloat(3)/CGFloat(4) : CGFloat(9)/CGFloat(16)
        let offSet = (1 - mult)/2
        for (p1, p2) in lines{
            let sL = (CGPoint(x: p1.x, y: (p1.y * mult) + offSet), CGPoint(x: p2.x, y: (p2.y * mult) + offSet))
            stretchedLines.append(sL)
        }
        return stretchedLines
    }
    
    func stretchPolys(_ polys: [[CGPoint]]) -> [[CGPoint]]{
        var stretchedPolys: [[CGPoint]] = []
        let mult = DeviceType.simulationIs == .iPad ? CGFloat(3)/CGFloat(4) : CGFloat(9)/CGFloat(16)
        
        let offSet = (1 - mult)/2
        for poly in polys{
            var stretchedPoly : [CGPoint] = []
            for p in poly {
                let sP = CGPoint(x: p.x, y: (p.y * mult) + offSet)
                stretchedPoly.append(sP)
            }
            stretchedPolys.append(stretchedPoly)
        }
        return stretchedPolys
    }
    
    func getLine(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) -> (CGPoint, CGPoint){
        return (CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2))
    }
 
    func getRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        if h == 0{
            lines.append(getLine(x, y, x + w, y))
        }
        else if w == 0{
            lines.append(getLine(x, y, x, y + h))
        }
        else{
            lines.append(getLine(x, y, x + w, y))
            lines.append(getLine(x + w, y, x + w, y + h))
            lines.append(getLine(x, y + h, x + w, y + h))
            lines.append(getLine(x, y, x, y + h))
        }
        return lines
    }

    func getRectPoly(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [CGPoint]{
        return [
            CGPoint(x: x, y: y),
            CGPoint(x: x, y: y+h),
            CGPoint(x: x+w, y: y+h),
            CGPoint(x: x+w, y: y)
        ]
    }

    func getRectWithHoles(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ f: CGFloat, _ s: CGFloat) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        if h == 0{
            lines.append(getLine(x, y, x + (w * f), y))
            lines.append(getLine(x + (w * s), y, x + w, y))
        }
        else if w == 0{
            lines.append(getLine(x, y, x, y + (h * f)))
            lines.append(getLine(x, y + (h * s), x, y + h))
        }
        else{
            lines.append(getLine(x, y, x + (w * f), y))
            lines.append(getLine(x + (w * s), y, x + w, y))
            lines.append(getLine(x, y + h, x + (w * f), y + h))
            lines.append(getLine(x + (w * s), y + h, x + w, y + h))

            lines.append(getLine(x, y, x, y + (h * f)))
            lines.append(getLine(x, y + (h * s), x, y + h))
            lines.append(getLine(x + w, y, x + w, y + (h * f)))
            lines.append(getLine(x + w, y + (h * s), x + w, y + h))
        }
        return lines
    }
    
    func getPath(_ start: CGPoint, seg: CGFloat, directions: [Direction]) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        var current = start
        for d in directions{
            var next = start
            switch d{
            case .left:
                next = CGPoint(x: current.x - seg, y: current.y)
            case .right:
                next = CGPoint(x: current.x + seg, y: current.y)
            case .up:
                next = CGPoint(x: current.x, y: current.y - seg)
            case .down:
                next = CGPoint(x: current.x, y: current.y + seg)
            }
            lines.append((current, next))
            current = next
        }
        
        return lines
    }
    
    func getDiamond(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        lines.append(getLine(x + w/2, y, x + w, y + h/2))
        lines.append(getLine(x + w, y + h/2, x + w/2, y + h))
        lines.append(getLine(x + w/2, y + h, x, y + h/2))
        lines.append(getLine(x, y + h/2, x + w/2, y))
        return lines
    }
    
    func getDiamondPoly(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [CGPoint]{
        return [
            CGPoint(x: x + w/2, y: y),
            CGPoint(x: x + w, y: y + h/2),
            CGPoint(x: x + w/2, y: y + h),
            CGPoint(x: x, y: y + h/2)
        ]
    }
    
    func getDiamondWithHoles(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ f: CGFloat, _ s: CGFloat) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        lines.append(contentsOf: getSplitLines(x + w/2, y, x + w, y + h/2, f, s))
        lines.append(contentsOf: getSplitLines(x + w, y + h/2, x + w/2, y + h, f, s))
        lines.append(contentsOf: getSplitLines(x + w/2, y + h, x, y + h/2, f, s))
        lines.append(contentsOf: getSplitLines(x, y + h/2, x + w/2, y, f, s))
        return lines
    }
    
    func getOctagon(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        let x0 = x
        let x1 = x + w/3
        let x2 = x + (2*w)/3
        let x3 = x + w
        let y0 = y
        let y1 = y + h/3
        let y2 = y + (2*h)/3
        let y3 = y + h
        lines.append(getLine(x0, y2, x1, y3))
        lines.append(getLine(x1, y3, x2, y3))
        lines.append(getLine(x2, y3, x3, y2))
        lines.append(getLine(x3, y2, x3, y1))
        lines.append(getLine(x3, y1, x2, y0))
        lines.append(getLine(x1, y0, x2, y0))
        lines.append(getLine(x1, y0, x0, y1))
        lines.append(getLine(x0, y1, x0, y2))
        
        return lines
    }
    
    func getOctagonPoly(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [CGPoint]{
        let x0 = x
        let x1 = x + w/3
        let x2 = x + (2*w)/3
        let x3 = x + w
        let y0 = y
        let y1 = y + h/3
        let y2 = y + (2*h)/3
        let y3 = y + h
        
        return [
            CGPoint(x: x0, y: y2),
            CGPoint(x: x1, y: y3),
            CGPoint(x: x2, y: y3),
            CGPoint(x: x3, y: y2),
            CGPoint(x: x3, y: y1),
            CGPoint(x: x2, y: y0),
            CGPoint(x: x1, y: y0),
            CGPoint(x: x0, y: y1)
        ]
    }
    
    
    func getSplitLines(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ f: CGFloat, _ s: CGFloat) -> [(CGPoint, CGPoint)]{
        var lines: [(CGPoint, CGPoint)] = []
        let xAddF = (x2 - x1) * f
        let xAddS = (x2 - x1) * s
        let yAddF = (y2 - y1) * f
        let yAddS = (y2 - y1) * s
        lines.append(getLine(x1, y1, x1 + xAddF, y1 + yAddF))
        lines.append(getLine(x1 + xAddS, y1 + yAddS, x2, y2))
        return lines
    }
    
    func centreLinesVertically(_ lines: [(CGPoint, CGPoint)]) -> [(CGPoint, CGPoint)]{
        var centredLines: [(CGPoint, CGPoint)] = []
        var maxY = CGFloat(0)
        var minY = CGFloat(1)
        for l in lines{
            maxY = max(maxY, l.0.y)
            maxY = max(maxY, l.1.y)
            minY = min(minY, l.0.y)
            minY = min(minY, l.1.y)
        }
        let vSize = maxY - minY
        let ySpace = 1 - vSize
        let yOff = ySpace/2 - minY
        for pos in 0..<lines.count{
            var l = lines[pos]
            l.0.y = l.0.y + yOff
            l.1.y = l.1.y + yOff
            centredLines.append(l)
        }
        return centredLines
    }
    
    func centrePolysVertically(_ polys: [[CGPoint]]) -> [[CGPoint]]{
        var centredPolys: [[CGPoint]] = []
        var maxY = CGFloat(0)
        var minY = CGFloat(1)
        for poly in polys{
            for p in poly{
                maxY = max(maxY, p.y)
                minY = min(minY, p.y)
            }
        }
        let vSize = maxY - minY
        let ySpace = 1 - vSize
        let yOff = ySpace/2 - minY
        for poly in polys{
            var newPoly: [CGPoint] = []
            for p in poly{
                newPoly.append(CGPoint(x: p.x, y: p.y + yOff))
            }
            centredPolys.append(newPoly)
        }
        return centredPolys
    }
}
