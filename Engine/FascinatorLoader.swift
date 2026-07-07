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
        
        let dict = JsonUtils.jsonStringToObject(genomeJsonString) as? NSDictionary ?? NSDictionary()
        
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
        
        let textsDict = dict["Texts"] as? NSDictionary
        newFascinator.customHelpText = textsDict?["Help"] as? String ?? ""
        
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
        guard let genomeJsonString = FileUtils.readFile("\(fascinatorName)_genome", fileType: "json") else {
            print("Could not load base camp genome JSON for \(fascinatorName)")
            return
        }
        loadBaseCampFascinator(fascinatorName, genomeJsonString: genomeJsonString, baseCampType: baseCampType, scene: scene)
    }
    
    static func loadBaseCampFascinator(_ fascinatorName: String, genomeJsonString: String, baseCampType: BaseCampType, scene: MainScene){
        let controller = ImageUtils.getBlankImage(scene.size, colour: UIColor.white)
        loadFascinator(fascinatorName, genomeJsonString: genomeJsonString, controller: controller, baseCampType: baseCampType, scene: scene)
    }
    
    static func convertDictToGenome(_ fascinator: Fascinator, dict: NSDictionary) -> Dictionary<ChromosomeName, Chromosome> {
        var result = Dictionary<ChromosomeName, Chromosome>()
        
        // For compatibility with old games, if the JSON dictionary doesn't contain a "Gameplay" entry, use the "Movement & Collisions" entry instead
        let gameplayDict = dict[ChromosomeName.Gameplay.rawValue] ?? dict["Movement & Collisions"] ?? NSDictionary()
        let gameplayChromosome = GameplayChromosome(stringRepresentation: "")
        gameplayChromosome.initFromJsonObject(gameplayDict as? [String : AnyObject] ?? [:])
        result[.Gameplay] = gameplayChromosome
        
        let imageAndLightingDict = dict[ChromosomeName.ImageAndLighting.rawValue] ?? NSDictionary()
        let imageAndLightingChromosome = ImageAndLightingChromosome(stringRepresentation: "")
        imageAndLightingChromosome.initFromJsonObject(imageAndLightingDict as? [String : AnyObject] ?? [:])
        result[.ImageAndLighting] = imageAndLightingChromosome
        
        return result
    }

    static func convertJsonStringToDrawing(_ jsonString: String, dict: NSDictionary) -> FascinatorDrawing{
        let drawing = FascinatorDrawing()
        let drawingsDict = dict["Drawings"] as? NSDictionary ?? NSDictionary()
        for (_, d) in drawingsDict{
            guard let drawingDict = d as? NSDictionary else { continue }
            let size = drawingDict.count
            for pos in 0..<size{
                guard let pathDetails = drawingDict["path \(pos)"] as? NSDictionary else { continue }
                drawing.paths.append(getPath(pathDetails))
            }
        }
        return drawing
    }
    
    static func getPath(_ pathDetails: NSDictionary) -> DrawingPath{
        let path = DrawingPath()
        path.closed = pathDetails.value(forKey: "closed") as? Bool ?? false
        let c = (pathDetails.value(forKey: "colour") as? String ?? "0,0,0").components(separatedBy: ",")
        path.hue = c.indices.contains(0) ? getCGFloat(c[0]) : 0
        path.saturation = c.indices.contains(1) ? getCGFloat(c[1]) : 0
        path.brightness = c.indices.contains(2) ? getCGFloat(c[2]) : 0
        path.filled = pathDetails.value(forKey: "filled") as? Bool ?? false
        path.pathPoints = getPathPoints(pathDetails.value(forKey: "points") as? String ?? "")
        path.strokeWidth = pathDetails.value(forKey: "strokeWidth") as? CGFloat ?? 0
        let tagString = pathDetails.value(forKey: "tag") as? String ?? "Controller"
        path.tag = DrawingPathTag(rawValue: tagString) ?? .Controller
        path.tagNumber = pathDetails.value(forKey: "tagNumber") as? Int ?? 0
        path.visible = pathDetails.value(forKey: "visible") as? Bool ?? true
        path.isEraser = pathDetails.value(forKey: "isEraser") as? Bool ?? false
        return path
    }
    
    static func getPathPoints(_ pointsString: String) -> [CGPoint]{
        var points: [CGPoint] = []
        let parts = pointsString.components(separatedBy: " ")
        for p in parts{
            if p != ""{
                let ps = p.components(separatedBy: ",")
                if ps.count >= 2 {
                    let point = CGPoint(x: getCGFloat(ps[0]), y: getCGFloat(ps[1]))
                    points.append(point)
                }
            }
        }
        return points
    }
    
    static func getCGFloat(_ s: String) -> CGFloat{
        return CGFloat((s as NSString).floatValue)
    }
    
}
