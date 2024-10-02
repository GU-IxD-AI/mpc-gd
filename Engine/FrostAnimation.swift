//
//  FrostAnimation.swift
//  MPCGD
//
//  Created by Simon Colton on 07/01/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class FrostAnimation: HKComponent{
    
    var frostImage: UIImage
    
    var frostNode: SKSpriteNode
    
    var innerNode: SKShapeNode
    
    var frost = UIImage(named: "Frost")!
    
    var size: CGSize
    
    var numFrosts = CGFloat(0)
    
    var currentScale = CGFloat(1)
    
    var pointBatches: [[CGPoint]] = []
    
    var outerPoints: [CGPoint] = []
    
    init(size: CGSize){
        
        frostImage = ImageUtils.getBlankImage(size, colour: UIColor.clear)
        frostNode = SKSpriteNode(texture: SKTexture(image: frostImage))
        frostNode.zPosition = 1000
        self.size = size
        let rect = CGRect(x: -size.width/2 + 25, y: -size.height/2  + 25, width: size.width - 50, height: size.height - 50)
        let path = CGPath(roundedRect: rect, cornerWidth: 30, cornerHeight: 30, transform: nil)
        self.innerNode = SKShapeNode(path: path)
        let cropNode = SKCropNode()
        cropNode.maskNode = SKSpriteNode(imageNamed: "BlankGraphic")
        super.init()
        cropNode.addChild(frostNode)
        isUserInteractionEnabled = false
        addChild(cropNode)
                
        // TO DO - DO THIS QUICKER (currently takes 0.75s)
        getOuterPoints()
        frostNode.isUserInteractionEnabled = false

        startAnimation()
    }
    
    func getOuterPoints(){
        let blankImage = UIImage(named: "BlankGraphic")!
        let data = ImageData(image: blankImage)
        let w = Int(blankImage.size.width) - 1
        let h = Int(blankImage.size.height) - 1
        for x in 1..<w{
            for y in 1..<h{
                if data.rgbaAt(x, y: y)[3] == 0{
                    for pair in [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]{
                        if data.rgbaAt(x + pair.0, y: y + pair.1)[3] != 0{
                            let x1 = round(CGFloat(x) * 0.5)
                            let y1 = round(CGFloat(y) * 0.5)
                            let p1 = CGPoint(x: x1 - 7, y: y1 - 7)
                            let p2 = CGPoint(x: size.width - x1 - 3, y: y1 - 7)
                            let p3 = CGPoint(x: x1 - 7, y: size.height - y1 - 3)
                            let p4 = CGPoint(x: size.width - x1 - 3, y: size.height - y1 - 3)
                            for p in [p1, p2, p3, p4]{
                                if !outerPoints.contains(p){
                                    outerPoints.append(p)
                                }
                            }
                            break
                        }
                    }
                }
            }
        }
        pointBatches.append(outerPoints)
    }
    
    func addNextPointBatch(){
        currentScale = currentScale - 0.02
        var nextBatch: [CGPoint] = []
        for p in outerPoints{
            let x1 = p.x - size.width/2
            let y1 = p.y - size.height/2
            let x = (x1 * currentScale) + size.width/2
            let y = (y1 * currentScale) + size.height/2
            nextBatch.append(CGPoint(x: x, y: y))
        }
        pointBatches.append(nextBatch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation(){
        numFrosts = 0
        currentScale = 1
        pointBatches = [outerPoints]
        frostNode.removeAllActions()
        frostImage = ImageUtils.getBlankImage(size, colour: UIColor.clear)
        frostNode.texture = SKTexture(image: frostImage)
        frostNode.alpha = 1
        frostNode.run(SKAction.wait(forDuration: 17), completion: {
            self.addSnowflake()
        })
    }
    
    func stopAnimation(){
        frostImage = ImageUtils.getBlankImage(size, colour: UIColor.clear)
        frostNode.removeAllActions()
    }
    
    func addSnowflake(){
        if !parent!.isHidden{
            if numFrosts < 2500{
                
                if numFrosts.truncatingRemainder(dividingBy: 200) == 0{
                    addNextPointBatch()
                }
                
                let pointBatch = RandomUtils.randomChoice(pointBatches) as [CGPoint]
                let snowflakeLocation = RandomUtils.randomChoice(pointBatch) as CGPoint
                
                let centrePoint = CGPoint(x: snowflakeLocation.x - size.width/2 + frost.size.width/2, y: snowflakeLocation.y - size.height/2 + frost.size.height/2)
                
                if !innerNode.contains(centrePoint){
                    frostImage = ImageUtils.drawImageInImageAtPosition(frostImage, topImage: frost, position: snowflakeLocation, opaque: false)
                    frostNode.texture = SKTexture(image: frostImage)
                    numFrosts += 1
                }
                frostNode.run(SKAction.wait(forDuration: 0.1), completion: {
                    self.addSnowflake()
                })
            }
        }
        else{
            startAnimation()
        }
    }
    
    func clearAndRestartAnimation(){
        if frostNode.alpha == 1{
            frostNode.run(SKAction.fadeOut(withDuration: 0.2), completion: {
                self.startAnimation()
            })
            if numFrosts > 0{
                for _ in 1...6{
                    let pointBatch = RandomUtils.randomChoice(pointBatches) as [CGPoint]
                    let particleEmitter = SKEmitterNode(fileNamed: "SnowExplode")!
                    particleEmitter.particleColorSequence = nil
                    particleEmitter.particleColor = Colours.getColour(.white)
                    let position = RandomUtils.randomChoice(pointBatch) as CGPoint
                    particleEmitter.position = CGPoint(x: position.x - size.width/2, y: position.y - size.height/2)
                    frostNode.addChild(particleEmitter)
                    particleEmitter.isUserInteractionEnabled = false
                    particleEmitter.run(SKAction.wait(forDuration: 0.3), completion: {
                        particleEmitter.removeFromParent()
                    })
                }                
            }
        }
    }

}
