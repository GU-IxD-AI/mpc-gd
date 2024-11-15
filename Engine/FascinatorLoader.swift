//
//  FascinatorLoader.swift
//  Engine
//
//  Created by Simon Colton on 31/03/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class FascinatorLoader{
    
    static func loadFascinator(_ fascinatorName: String, genomeJsonString: String, controller: UIImage?, baseCampType: BaseCampType, scene: MainScene){
        
        let dict = JsonUtils.jsonStringToObject(genomeJsonString) as! NSDictionary
        
        scene.isPaused = true
        
        let newFascinator = Fascinator()
        
        newFascinator.pauseImmediately()
        let genome = convertDictToGenome(newFascinator, dict: dict)
        
        scene.isPaused = false
        
        newFascinator.constructFascinatorSKNode(genome, view: scene.view!, sceneSize: scene.size, controllerImage: controller)
        
        if scene.fascinatorNode != nil {
            scene.fascinatorNode.removeFromParent()
            scene.fascinatorNode = nil
        }
        
        scene.fascinator = newFascinator
        scene.fascinatorNode = scene.fascinator.getFascinatorSKNode()
        scene.fascinatorNode.setZPositionTo(ZPositionConstants.fascinatorNode)
        
        scene.fascinatorNode.isHidden = true
        scene.addChild(scene.fascinatorNode)
        
        let drawing = FascinatorLoader.convertJsonStringToDrawing(genomeJsonString, dict: dict)
        scene.fascinator.drawingPaths = drawing.paths
        newFascinator.calculateImageLayers()
        
        let textsDict = dict["Texts"] as! NSDictionary
        newFascinator.customHelpText = textsDict["Help"] as! String
        
        newFascinator.addPhysicsToScene(scene)
        
        scene.fascinatorNode.isHidden = false
        scene.fascinator.releaseFromPause()
        scene.fascinatorNode.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        scene.fascinatorNode.run(fadeIn)
        
        #if os(OSX)
            CommandLineHandler.onStartup(scene)
        #endif
    }
    
    static func loadBaseCampFascinator(_ fascinatorName: String, baseCampType: BaseCampType, scene: MainScene){
        let genomeJsonString = FileUtils.readFile("\(fascinatorName)_genome", fileType: "json")
        loadBaseCampFascinator(fascinatorName, genomeJsonString: genomeJsonString!, baseCampType: baseCampType, scene: scene)
    }
    
    static func loadBaseCampFascinator(_ fascinatorName: String, genomeJsonString: String, baseCampType: BaseCampType, scene: MainScene){
        let controller = ImageUtils.getBlankImage(scene.size, colour: UIColor.white)
        loadFascinator(fascinatorName, genomeJsonString: genomeJsonString, controller: controller, baseCampType: baseCampType, scene: scene)
    }
    
    static func convertDictToGenome(_ fascinator: Fascinator, dict: NSDictionary) -> Dictionary<ChromosomeName, Chromosome> {
        var result = Dictionary<ChromosomeName, Chromosome>()
        
        // For compatibility with old games, if the JSON dictionary doesn't contain a "Gameplay" entry, use the "Movement & Collisions" entry instead
        let gameplayDict = dict[ChromosomeName.Gameplay.rawValue] ?? dict["Movement & Collisions"]
        let gameplayChromosome = GameplayChromosome(stringRepresentation: "")
        gameplayChromosome.initFromJsonObject(gameplayDict as! [String : AnyObject])
        result[.Gameplay] = gameplayChromosome
        
        let imageAndLightingDict = dict[ChromosomeName.ImageAndLighting.rawValue]
        let imageAndLightingChromosome = ImageAndLightingChromosome(stringRepresentation: "")
        imageAndLightingChromosome.initFromJsonObject(imageAndLightingDict as! [String : AnyObject])
        result[.ImageAndLighting] = imageAndLightingChromosome
        
        return result
    }

    static func convertJsonStringToDrawing(_ jsonString: String, dict: NSDictionary) -> FascinatorDrawing{
        let drawing = FascinatorDrawing()
        let drawingsDict = dict["Drawings"] as! NSDictionary
        for (_, d) in drawingsDict{
            let drawingDict = d as! NSDictionary
            let size = drawingDict.count
            for pos in 0..<size{
                let pathDetails = drawingDict["path \(pos)"] as! NSDictionary
                drawing.paths.append(getPath(pathDetails))
            }
        }
        return drawing
    }
    
    static func getPath(_ pathDetails: NSDictionary) -> DrawingPath{
        let path = DrawingPath()
        path.closed = pathDetails.value(forKey: "closed") as! Bool
        let c = (pathDetails.value(forKey: "colour") as! String).components(separatedBy: ",")
        path.hue = getCGFloat(c[0])
        path.saturation = getCGFloat(c[1])
        path.brightness = getCGFloat(c[2])
        path.filled = pathDetails.value(forKey: "filled") as! Bool
        path.pathPoints = getPathPoints(pathDetails.value(forKey: "points") as! String)
        path.strokeWidth = pathDetails.value(forKey: "strokeWidth") as! CGFloat
        path.tag = DrawingPathTag(rawValue: pathDetails.value(forKey: "tag") as! String)!
        path.tagNumber = pathDetails.value(forKey: "tagNumber") as! Int
        path.visible = pathDetails.value(forKey: "visible") as! Bool
        path.isEraser = pathDetails.value(forKey: "isEraser") as! Bool
        return path
    }
    
    static func getPathPoints(_ pointsString: String) -> [CGPoint]{
        var points: [CGPoint] = []
        let parts = pointsString.components(separatedBy: " ")
        for p in parts{
            if p != ""{
                let ps = p.components(separatedBy: ",")
                let point = CGPoint(x: getCGFloat(ps[0]), y: getCGFloat(ps[1]))
                points.append(point)
            }
        }
        return points
    }
    
    static func getCGFloat(_ s: String) -> CGFloat{
        return CGFloat((s as NSString).floatValue)
    }
    
}
