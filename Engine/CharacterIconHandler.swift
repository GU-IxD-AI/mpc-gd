//
//  CharacterIconHandler.swift
//  MPCGD
//
//  Created by Simon Colton on 26/04/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class CharacterIconHandler{
    
    static var iconPolyData : [String : AnyObject]! = nil
    
    static var collectionNames: [String] = []
    
    static var characterNames: [[String]] = []
    
    static var convexHulls: [String:[CGPoint]] = [:]
    
    static var slimPolygonPaths: [String:[[CGPoint]]] = [:]
    
    static var fatPolygonPaths: [String:[[CGPoint]]] = [:]

    static var boundingBoxes: [String:CGRect] = [:]
    
    static var characterColours: [String:UIColor] = [:]
    
    static let ballList = ["Bee", "Ladybird", "Dandelion", "Earth", "Moon", "Sun", "Sunflower", "Baseball", "Basketball", "Beachball", "Soccer ball", "Tennis ball", "Volleyball", "Snowflake"]

    
    static func initialise(){
        let lines = FileUtils.readFileLines("characters", fileType: "csv")!
        for _ in 1...9{
            characterNames.append([])
        }
        var collectionNum = -1
        var flatCharNames: [String] = []
        for linePos in 0...80{
            let parts = lines[linePos].components(separatedBy: ",")
            if linePos % 9 == 0{
                collectionNames.append(parts[0])
                collectionNum += 1
            }
            let characterName = parts[1]
            flatCharNames.append(characterName)
            characterNames[collectionNum].append(characterName)
            var convexHull: [CGPoint] = []
            var ind = 2
            while ind < parts.count - 6{// NOTE: REMOVED THE LAST 3 POINTS, WHICH ARE THE START
                let x = Double(parts[ind])!
                let y = Double(parts[ind + 1])!
                let p = CGPoint(x: x, y: y)
                convexHull.append(p)
                ind += 2
            }
            convexHulls[characterName] = convexHull
        }
        for charName in flatCharNames{
            _ = addPolygonPathsAndBounds(charName: charName, slim: false)
            _ = addPolygonPathsAndBounds(charName: charName, slim: true)
        }
        for line in FileUtils.readFileLines("ControllerColours", fileType: "csv")!{
            let parts = line.components(separatedBy: ",")
            if parts.count > 1{
                let rgb = parts[1].components(separatedBy: ":")
                let r = CGFloat(Double(rgb[0])!/255)
                let g = CGFloat(Double(rgb[1])!/255)
                let b = CGFloat(Double(rgb[2])!/255)
                let colour = UIColor(red: r, green: g, blue: b, alpha: 1)
                characterColours[parts[0]] = colour
            }
        }
    }
    
    static func printOutColoursFile(flatCharNames: [String]){
        
        for name in flatCharNames{
            var hash: [String : Int] = [:]
            let image = PDFImage(named: name, size: CGSize(width: 100, height: 100))
            let imageData = ImageData(cgImage: (image?.cgImage!)!)
            for x in 0...99{
                for y in 0...99{
                    let rgba = imageData.rgbaAt(x, y: y)
                    if rgba[3] == 255{
                        let key = "\(rgba[0]):\(rgba[1]):\(rgba[2])"
                        if hash[key] == nil{
                            hash[key] = 1
                        }
                        else{
                            hash[key] = hash[key]! + 1
                        }
                    }
                }
            }
            var pairs: [(String, Int)] = []
            
            for key in hash.keys{
                if hash[key]! > 100{
                    pairs.append((key, hash[key]!))
                }
            }
            pairs.sort{(pair1, pair2) in
                return pair1.1 < pair2.1
            }
            var pos = 1
            var line = "\(name),"
            while pos < 5 && pairs.count - pos >= 0{
                line += "\(pairs[pairs.count - pos].0),"
                pos += 1
            }
            print(line.subString(0, length: line.count - 1))
        }
    }
    
    static func addPolygonPathsAndBounds(charName: String, slim: Bool) -> Int{
        if ballList.contains(charName){
            boundingBoxes[charName] = CGRect(x: 0, y: 0, width: 1, height: 1)
            return 0
        }
        
        // I USED THIS TO GET THE RIGHT TOLERANCE LEVELS
        
        /*
        var lines: [String] = []
        var addOn = 100
        while addOn <= 1500 && (lines.isEmpty || lines.count >= 10) {
            let fileName = charName + "-t\(addOn)"
            lines = FileUtils.readFileLines(fileName, fileType: ".csv")!
            if lines.count < 10{
                print("cp \"\(fileName).csv\" \"slim/\(charName)-polys.csv\"")
            }
            addOn += 100
        }
 */
        let fileName = slim ? "\(charName)-polys" : "\(charName)-t100"
        let lines = FileUtils.readFileLines(fileName, fileType: ".csv")!
 
        var paths: [[CGPoint]] = []
        var minX = 10000.0
        var maxX = 0.0
        var minY = 10000.0
        var maxY = 0.0
        for line in lines{
            var path: [CGPoint] = []
            let parts = line.components(separatedBy: ",")
            var pos = 0
            while pos < parts.count - 1{
                let x = Double(parts[pos])!
                let y = Double(parts[pos + 1])!
                let p = CGPoint(x: x, y: y)
                minX = min(x, minX)
                maxX = max(x, maxX)
                minY = min(y, minY)
                maxY = max(y, maxY)
                path.append(p)
                pos += 2
            }
            if !path.isEmpty{
                paths.append(path)
            }
        }
        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        if slim{
            slimPolygonPaths[charName] = paths
        }
        else{
            boundingBoxes[charName] = rect
            fatPolygonPaths[charName] = paths
        }
        return paths.count
    }
    
    static func alterNodeOrientation(isGrid: Bool, collectionNum: Int, characterNum: Int, reflectionID: Int, node: SKNode){
        if !isGrid && requiresHorizontalFlipIfSpawnedOnRight(collectionNum: collectionNum, characterNum: characterNum) || requiresHorizontalFlipIfSpawnedOnLeft(collectionNum: collectionNum, characterNum: characterNum){
            node.xScale = 1
            node.zRotation = 0
            if reflectionID == 1{
                node.xScale = -1
            }
            else if reflectionID == 2{
                node.zRotation = CGFloat.pi / 2
            }
            else if reflectionID == 3{
                node.zRotation = CGFloat.pi / 2
                node.xScale = -1
            }
        }
        else{
            node.xScale = 1
            let rot = CGFloat([0, CGFloat.pi, CGFloat.pi/2, -CGFloat.pi/2][reflectionID])
            node.zRotation = rot
        }
    }
    
    static func alterBallOnReverse(ball: Ball){
        let cc = ball.chromosome.characterCollectionNum.value
        let c = ball.chromosome.characterNum.value

        ball.node.physicsBody!.angularVelocity = 0
        if requiresRotationIfSpawnedAtTopOrSides(collectionNum: cc, characterNum: c){
            if ball.spawnedFrom == .top{
                ball.node.run(SKAction.rotate(toAngle: CGFloat.pi, duration: 0.1))
            }
            else if ball.spawnedFrom == .bottom{
                ball.node.run(SKAction.rotate(toAngle: CGFloat(0), duration: 0.1))
            }
            else if ball.spawnedFrom == .left{
                ball.node.run(SKAction.rotate(toAngle: -CGFloat.pi/2, duration: 0.1))
            }
            else if ball.spawnedFrom == .right{
                ball.node.run(SKAction.rotate(toAngle: CGFloat.pi/2, duration: 0.1))
            }
        }
        else if requiresHorizontalFlipIfSpawnedOnRight(collectionNum: cc, characterNum: c){
            ball.node.run(SKAction.rotate(toAngle: CGFloat(0), duration: 0.15))
            if ball.spawnedFrom == .right{
                ball.node.run(SKAction.scaleX(to: -1, duration: 0.15))
            }
            if ball.spawnedFrom == .left{
                ball.node.run(SKAction.scaleX(to: 1, duration: 0.15))
            }
        }
        else if requiresHorizontalFlipIfSpawnedOnLeft(collectionNum: cc, characterNum: c){
            ball.node.run(SKAction.rotate(toAngle: CGFloat(0), duration: 0.15))
            if ball.spawnedFrom == .right{
                ball.node.run(SKAction.scaleX(to: 1, duration: 0.15))
            }
            if ball.spawnedFrom == .left{
                ball.node.run(SKAction.scaleX(to: -1, duration: 0.15))
            }
        }
    }
    
    static func requiresHorizontalFlipIfSpawnedOnLeft(collectionNum: Int, characterNum: Int) -> Bool{
        let charName = getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        let flipList = ["Elephant", "Fish", "Snail", "Caterpillar", "Chicken", "Helicopter", "Zeppelin"]
        return flipList.contains(charName)
    }
    
    static func requiresHorizontalFlipIfSpawnedOnRight(collectionNum: Int, characterNum: Int) -> Bool{
        if collectionNum == 3{
            return true
        }
        let charName = getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        let flipList = ["Football", "Rugby ball", "Air rescue", "Wind"]
        return flipList.contains(charName)
    }
    
    static func requiresRotationIfSpawnedAtTopOrSides(collectionNum: Int, characterNum: Int) -> Bool{
        let charName = getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        let flipList = ["Ant", "Housefly", "Dragonfly", "Rocket", "Satellite", "Shuttlecock", "Aeroplane", "Jet", "Paper plane"]
        return flipList.contains(charName)
    }
    
    static func getCharacterColour(collectionNum: Int, characterNum: Int) -> UIColor{
        let charName = getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        return characterColours[charName]!
    }
    
    static func getParticleEffectNameForCharacter(collectionNum: Int, characterNum: Int) -> String{
        return "BallExplode"
    }
    
    static func getConvexHull(collectionNum: Int, characterNum: Int) -> [CGPoint]{
        let charName = getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        return convexHulls[charName]!
    }
    
    static func getCharacterImage(collectionNum: Int, characterNum: Int, size: CGSize) -> UIImage!{
        let charName = characterNames[collectionNum][characterNum]
        return PDFImage(named: charName, size: size)
    }
    
    static func getCharacterName(collectionNum: Int, characterNum: Int, lowerCase: Bool = false) -> String{
        return lowerCase ? characterNames[collectionNum][characterNum].lowercased() : characterNames[collectionNum][characterNum]
    }
    
    static func getCollectionName(_ collectionNum: Int, lowerCase: Bool = false) -> String{
        return lowerCase ? collectionNames[collectionNum].lowercased() : collectionNames[collectionNum]
    }
    
    static func isBall(collectionNum: Int, characterNum: Int) -> Bool{
        let charName = getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        return ballList.contains(charName)
    }
    
    static func getPhysicsBody(radius: CGFloat, collectionNum: Int, characterNum: Int, isController: Bool) -> SKPhysicsBody{
        if isBall(collectionNum: collectionNum, characterNum: characterNum){
            return SKPhysicsBody.init(circleOfRadius: radius - 2)
        }
        else if radius < 5{
            return SKPhysicsBody.init(circleOfRadius: 4)
        }
        else if radius <= 20{
            return getConvexHullPhysicsBody(radius: radius - 2, collectionNum: collectionNum, characterNum: characterNum)
        }
        else{
            return getPolygonPhysicsBody(radius: radius - 2, collectionNum: collectionNum, characterNum: characterNum, slim: !isController)
        }
    }
    
    private static func getConvexHullPhysicsBody(radius: CGFloat, collectionNum: Int, characterNum: Int) -> SKPhysicsBody{
        
        let cgPath = CGMutablePath()
        var bodies : [SKPhysicsBody] = []
        let convexHull = getConvexHull(collectionNum: collectionNum, characterNum: characterNum)
        
        for pos in 0..<convexHull.count {
            let h = convexHull[pos]
            let p = CGPoint(x: (h.x - 64) * radius/64, y: -(h.y - 64) * radius/64)
            if pos == 0{
                cgPath.move(to: p)
            }
            else{
                cgPath.addLine(to: p)
            }
        }
        
        cgPath.closeSubpath()
        
        let body : SKPhysicsBody! = SKPhysicsBody(polygonFrom: cgPath)
        if body != nil {
            bodies.append(body)
        }
        
        return SKPhysicsBody(bodies: bodies)
    }

    private static func getPolygonPhysicsBody(radius: CGFloat, collectionNum: Int, characterNum: Int, slim: Bool) -> SKPhysicsBody{
        
        var bodies : [SKPhysicsBody] = []
        let charName = getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        let pPaths = slim ? slimPolygonPaths[charName]! : fatPolygonPaths[charName]!
        
        for polygon in pPaths{
            let cgPath = CGMutablePath()
            for pos in 0..<polygon.count {
                let h = polygon[pos]
                let p = CGPoint(x: (h.x - 0.5) * radius * 2, y: -(h.y - 0.5) * radius * 2)
                if pos == 0{
                    cgPath.move(to: p)
                }
                else{
                    cgPath.addLine(to: p)
                }
            }
            cgPath.closeSubpath()
            let body : SKPhysicsBody! = SKPhysicsBody(polygonFrom: cgPath)
            if body != nil {
                bodies.append(body)
            }
        }
        
        return SKPhysicsBody(bodies: bodies)

    }
    
    static func getCharacterBoundingBox(radius: CGFloat, collectionNum: Int, characterNum: Int, centreOffset: CGPoint) -> CGRect{
        let charName = getCharacterName(collectionNum: collectionNum, characterNum: characterNum)
        let bb = boundingBoxes[charName]!
        let r = CGRect(x: ((bb.origin.x - 0.5) * radius) + centreOffset.x, y: ((bb.origin.y - 0.5) * radius) + centreOffset.y, width: bb.width * radius, height: bb.height * radius)
        return r
    }
    
    static func getBoundingPoints(radius: CGFloat, collectionNum: Int, characterNum: Int) -> [CGPoint]{
        let convexHull = CharacterIconHandler.getConvexHull(collectionNum: collectionNum, characterNum: characterNum)
        var boundingPoints: [CGPoint] = []
        for pos in 0..<convexHull.count {
            let h = convexHull[pos]
            let p = CGPoint(x: (h.x - 64) * radius/64, y: -(h.y - 64) * radius/64)
            boundingPoints.append(p)
        }
        return boundingPoints
    }
    
    static func getFourCharacterNode(nodeSize: CGSize, collectionNum: Int) -> SKNode{
        let node = SKNode()
        var xPos = -nodeSize.width/4
        var yPos = nodeSize.width/4 + 10
        
        for pos in 0...3{
            let charImage = getCharacterImage(collectionNum: collectionNum, characterNum: pos, size: nodeSize * 0.35)
            let charNode = SKSpriteNode(texture: SKTexture(image: charImage!))
            charNode.position = CGPoint(x: xPos, y: yPos)
            node.addChild(charNode)
            xPos += nodeSize.width/2
            if pos == 1{
                xPos = -nodeSize.width/4
                yPos -= nodeSize.width/2
            }
        }
        let labelNode = SKLabelNode(text: getCollectionName(collectionNum))
        labelNode.fontColor = Colours.getColour(.antiqueWhite)
        labelNode.fontName = "Helvetica Neue Thin"
        labelNode.fontSize = 20
        labelNode.position = CGPoint(x: 0, y: -nodeSize.height/2 - 3)
        node.addChild(labelNode)
        return node
    }

    static func getCharacterNode(nodeSize: CGSize, collectionNum: Int, characterNum: Int) -> SKNode{
        let node = SKNode()
        let charImage = getCharacterImage(collectionNum: collectionNum, characterNum: characterNum, size: nodeSize * 0.8)
        let charNode = SKSpriteNode(texture: SKTexture(image: charImage!))
        charNode.position = CGPoint(x: 0, y: 10)
        node.addChild(charNode)
        let labelNode = SKLabelNode(text: getCharacterName(collectionNum: collectionNum, characterNum: characterNum))
        labelNode.fontColor = Colours.getColour(.antiqueWhite)
        labelNode.fontName = "Helvetica Neue Thin"
        labelNode.fontSize = 20
        labelNode.position = CGPoint(x: 0, y: -nodeSize.height/2 - 3)
        node.addChild(labelNode)
        return node
    }
    
}
