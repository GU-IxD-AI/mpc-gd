//
//  MPCGDGenomeGenerator.swift
//  MPCGD
//
//  Created by Simon Colton on 29/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class MPCGDGenomeGenerator{
    
    static var showDebug = true
    
    static var sextuplets: [(Int, Int, Int, Int, Int, Int)] = []
    
    static var presets: [MPCGDGenome]!
    
    static func getInspiringGenome() -> MPCGDGenome{
        
        /*
        let encoding = "a06204U00G&Hu7WX07GlX&W3mdW90140&1ddbG/7WnU23tWK3m000009W5c1TwmZtl0"
        let genome = MPCGDGenome()
        _ = genome.decodeFromBase64(encoding)
        return genome
 */
        
        if presets == nil{
            loadPresets()
        }
        var wG = MPCGDGenome()
        var problem: String! = ""
        var trials = 0
        var problemsHash: [String : Int] = [:]
        while problem != nil && trials < 1000{
            wG = MPCGDGenome()
            substituteChromosome(.clusters, wG)
            substituteChromosome(.tapping, wG)
            substituteChromosome(.sizes, wG)
            substituteChromosome(.characters, wG)
            substituteChromosome(.spawning, wG)
            substituteChromosome(.zoneScores, wG)
            substituteChromosome(.maxOnScreen, wG)
            substituteChromosome(.controllerCollisions, wG)
            substituteChromosome(.behaviours, wG)
            substituteChromosome(.controllerNature, wG)
            substituteChromosome(.controllerControl, wG)
            substituteChromosome(.soundtrack, wG)
            substituteChromosome(.soundEffects, wG)
            substituteChromosome(.background, wG)
            substituteChromosome(.dayNightCycle, wG)
            substituteChromosome(.gameEndings, wG)
            problem = findProblem(wG)
            if problem != nil{
                if problemsHash[problem] == nil{
                    problemsHash[problem] = 1
                }
                else{
                    problemsHash[problem] = problemsHash[problem]! + 1
                }
            }
            trials += 1
        }
        if showDebug{
            print("=================")
            print("Trials: \(trials)")
            for k in problemsHash.keys{
                print("\(k): \(problemsHash[k]!)")
            }
            print("=================")
        }

        return wG
    }
    
    enum ChromosomeType{
        case clusters, tapping, sizes, characters, spawning, zoneScores, maxOnScreen, controllerCollisions, behaviours, controllerNature, controllerControl, soundtrack, soundEffects, background, dayNightCycle, gameEndings
    }
    
    static func findProblem(_ wG: MPCGDGenome) -> String!{
       
        if !wG.hasInteraction(){ // The player has no control
            return "no control"
        }
        if !wG.hasCharacters(){// There is no spawning of characters
            return "no characters"
        }
        if !wG.isWinnable(){// No game ending conditions
            return "not winnable"
        }
        if wG.numLives > 0 && !wG.livesCanBeLost(){// Cannot lose lives, but think you can
            return "no lives losable"
        }
        if wG.numLives == 0 && wG.livesCanBeLost(){// Losing of lives has no effect
            return "losing lives no effect"
        }
        if wG.whiteMaxOnScreen < wG.whiteCriticalClusterSize{// Non-achievable clusters
            return "non achievable white clusters"
        }
        if wG.blueMaxOnScreen < wG.blueCriticalClusterSize{// Non-achievable clusters
            return "non achievable blue clusters"
        }
        if wG.whiteMaxOnScreen + wG.blueMaxOnScreen > wG.mixedCriticalClusterSize{// Non-achievable clusters
            return "non achievable mixed clusters"
        }
        if !wG.hasWhiteCharacters(){
            if wG.whiteTapAction != 0 || wG.whiteCriticalClusterSize != 0 || wG.whiteControllerCollisionScore != 0 || wG.whiteScoreZones != 0{// Irrelevant details about non-existent whites
                return "irrelevant white details"
            }
        }
        if !wG.hasBlueCharacters(){
            if wG.blueTapAction != 0 || wG.blueCriticalClusterSize != 0 || wG.blueControllerCollisionScore != 0 || wG.blueScoreZones != 0{// Irrelevant details about non-existent blues
                return "irrelevant blue details"
            }
        }
        if (!wG.hasWhiteCharacters() || !wG.hasBlueCharacters()) && wG.mixedCriticalClusterSize > 0{// Irrelevant details about mixed clustering
            return "irrelevant mixed details"
        }

        return nil
    }
    
    static func substituteChromosome(_ type: ChromosomeType, _ base: MPCGDGenome){
        
        let changeTo = RandomUtils.randomChoice(presets)!
        
        if type == .clusters{
            base.whiteCriticalClusterSize = changeTo.whiteCriticalClusterSize
            base.blueCriticalClusterSize = changeTo.blueCriticalClusterSize
            base.whiteExplodeScore = changeTo.whiteExplodeScore
            base.blueExplodeScore = changeTo.blueExplodeScore
            base.mixedCriticalClusterSize = changeTo.mixedCriticalClusterSize
            base.mixedExplodeScore = changeTo.mixedExplodeScore
        }
        
        if type == .tapping{
            base.whiteTapAction = changeTo.whiteTapAction
            base.blueTapAction = changeTo.blueTapAction
            base.whiteTapScore = changeTo.whiteTapScore
            base.blueTapScore = changeTo.blueTapScore
        }
        
        if type == .sizes{
            base.whiteSizes = changeTo.whiteSizes
            base.blueSizes = changeTo.blueSizes
        }
        
        if type == .characters{
            base.whiteBallIconPack = changeTo.whiteBallIconPack
            base.blueBallIconPack = changeTo.blueBallIconPack
            base.whiteBallCollection = changeTo.whiteBallCollection
            base.blueBallCollection = changeTo.blueBallCollection
            base.whiteBallChoice = changeTo.whiteBallChoice
            base.blueBallChoice = changeTo.blueBallChoice
        }
        
        if type == .spawning{
            base.whiteEdgeSpawnPositions = changeTo.whiteEdgeSpawnPositions
            base.whiteMidSpawnPositions = changeTo.whiteMidSpawnPositions
            base.whiteCentralSpawnPositions = changeTo.whiteCentralSpawnPositions
            base.whiteSpawnRate = changeTo.whiteSpawnRate
            base.blueEdgeSpawnPositions = changeTo.blueEdgeSpawnPositions
            base.blueMidSpawnPositions = changeTo.blueMidSpawnPositions
            base.blueCentralSpawnPositions = changeTo.blueCentralSpawnPositions
            base.blueSpawnRate = changeTo.blueSpawnRate
        }
        
        if type == .zoneScores{
            base.whiteScoreZones = changeTo.whiteScoreZones
            base.whiteZoneScore = changeTo.whiteZoneScore
            base.blueScoreZones = changeTo.blueScoreZones
            base.blueZoneScore = changeTo.blueZoneScore
        }
        
        if type == .maxOnScreen{
            base.whiteMaxOnScreen = changeTo.whiteMaxOnScreen
            base.blueMaxOnScreen = changeTo.blueMaxOnScreen
        }
        
        if type == .controllerCollisions{
            base.whiteControllerCollisionScore = changeTo.whiteControllerCollisionScore
            base.blueControllerCollisionScore = changeTo.blueControllerCollisionScore
            base.ballControllerExplosions = changeTo.ballControllerExplosions
        }
        
        if type == .behaviours{
            base.whiteBounce = changeTo.whiteBounce
            base.whiteNoise = changeTo.whiteNoise
            base.whiteSpeed = changeTo.whiteSpeed
            base.whiteRotation = changeTo.whiteRotation
            base.blueBounce = changeTo.blueBounce
            base.blueNoise = changeTo.blueNoise
            base.blueSpeed = changeTo.blueSpeed
            base.blueRotation = changeTo.blueRotation
        }
        
        if type == .controllerNature{
            base.controllerPack = changeTo.controllerPack
            base.gridShape = changeTo.gridShape
            base.gridOrientation = changeTo.gridOrientation
            base.gridGrain = changeTo.gridGrain
            base.gridColour = changeTo.gridColour
            base.gridShade = changeTo.gridShade
            base.gridSize = changeTo.gridSize
            base.gridStartX = changeTo.gridStartX
            base.gridStartY = changeTo.gridStartY
            base.gridReflection = changeTo.gridReflection
        }
        
        if type == .controllerControl{
            base.gridControl = changeTo.gridControl
        }
        
        if type == .soundtrack{
            base.soundtrackPack = changeTo.soundtrackPack
            base.musicChoice = changeTo.musicChoice
            base.ambiance1 = changeTo.ambiance1
            base.ambiance2 = changeTo.ambiance2
            base.ambiance3 = changeTo.ambiance3
            base.ambiance4 = changeTo.ambiance4
            base.ambiance5 = changeTo.ambiance5
            base.channelVolume1 = changeTo.channelVolume1
            base.channelVolume2 = changeTo.channelVolume2
            base.channelVolume3 = changeTo.channelVolume3
            base.channelVolume4 = changeTo.channelVolume4
            base.channelVolume5 = changeTo.channelVolume5
            base.soundtrackMasterVolume = changeTo.soundtrackMasterVolume
        }
        
        if type == .soundEffects{
            base.sfxPack = changeTo.sfxPack
            base.sfxBooleans = changeTo.sfxBooleans
            base.sfxVolume = changeTo.sfxVolume
        }
        
        if type == .background{
            base.backgroundPack = changeTo.backgroundPack
            base.backgroundChoice = changeTo.backgroundChoice
            base.backgroundShade = changeTo.backgroundShade
        }
        
        if type == .dayNightCycle{
            base.dayNightCycle = changeTo.dayNightCycle
        }
        
        if type == .gameEndings{
            base.pointsToWin = changeTo.pointsToWin
            base.gameDuration = changeTo.gameDuration
            base.numLives = changeTo.numLives
        }
        
    }
    
    static func oldgetInspiringGenome() -> MPCGDGenome{
        if presets == nil{
            loadPresets()
        }
        let MPCGDGenome = RandomUtils.randomChoice(presets)!
        if RandomUtils.randomBool(){
  //          scramble(MPCGDGenome, p: 0.5)
 //                       scramble(MPCGDGenome, p: 0)
        }
        
        var ballTypes = [0, 1, 2, 3, 4, 5, 6, 7, 8]
        MPCGDGenome.whiteBallChoice = RandomUtils.randomChoice(ballTypes)
        ballTypes.remove(MPCGDGenome.whiteBallChoice)
        MPCGDGenome.blueBallChoice = RandomUtils.randomChoice(ballTypes)
        MPCGDGenome.backgroundChoice = RandomUtils.randomInt(0, upperInc: 8)
        MPCGDGenome.backgroundShade = RandomUtils.randomInt(0, upperInc: 8)
        
        return MPCGDGenome
    }
    
    static func r(_ p: CGFloat, _ a: Int, _ d: Int) -> Int{
        if RandomUtils.randomFloat(0, upperInc: 1) < p{
            return a
        }
        return d
    }
    
    static func loadPresets(){
        MPCGDGenomeGenerator.presets = []
        let path:String = Bundle.main.path(forResource: "StockForInspiration", ofType: "txt")!
        let text = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let lines = text?.components(separatedBy: "\n")
        for line in lines!{
            if line != ""{
                let MPCGDGenome = MPCGDGenome()
                if MPCGDGenome.decodeFromBase64(line.components(separatedBy: ",")[0]) {
                    MPCGDGenomeGenerator.presets.append(MPCGDGenome)
                } else {
                    print("!!!IGNORING!!! -> \(line)")
                }
            }
        }
    }
    
    static func getSextuplets(){
    
        let blueAverages: [CGFloat] = [0, 51.1, 20.1, 8.7, 4.5, 3, 0.8, 0.2, 0]
        //let blueSTDs: [CGFloat] = [0, 6.67, 3.93, 1.95, 2.27, 1.76, 0.92, 0.42, 0]
        
        let whiteAverage: [CGFloat] = [0, 51.4, 20.7, 9.1, 4.2, 2.7, 0.9, 0.2, 0]
        //let whiteSTDs: [CGFloat] = [0, 4.70, 4.45, 2.47, 2.04, 1.57, 1.10, 0.42, 0]
        
        let mixedAverages: [CGFloat] = [0, 36.6, 29.1, 26.8, 27.3, 26.8, 27.5, 28.7, 26.2]
        //let mixedSTDs: [CGFloat] = [0, 3.66, 5.47, 4.24, 4.16, 3.77, 3.41, 2.95, 2.30]

        let clusters: [CGFloat] = [0, 2, 3, 4, 5, 6, 7, 8, 9]

        var count = 0
        var trials = 0
        for b in 0...7{
            for w in 0...7{
                for m in 0...7{
                    for bs in -4...4{
                        for ws in -4...4{
                            for ms in -4...4{
                                let add1 = (clusters[b] * CGFloat(bs) * blueAverages[b])
                                let add2 = (clusters[w] * CGFloat(ws) * whiteAverage[w])
                                let add3 = (clusters[m] * CGFloat(ms) * mixedAverages[m])
                                let tot = add1 + add2 + add3
                                if (ws > 0 && w > 0) || (bs > 0 && b > 0) || (ms > 0 && m > 0){
                                    if ((b != 0 && w != 0) || (b != 0 && m != 0) || (w != 0 && m != 0)) && abs(tot) <= 5 && (add1 != 0 || add2 != 0 || add3 != 0){
                                        let s = (Int(clusters[w]), Int(clusters[b]), Int(clusters[m]), Int(ws), Int(bs), Int(ms))
                                        MPCGDGenomeGenerator.sextuplets.append(s)
                                        count += 1
                                    }
                                }
                                trials += 1
                            }
                        }
                    }
                }
            }
        }
    //    print("\(count) out of \(trials)")
    //    print(CGFloat(count)/CGFloat(trials))
    }

}
