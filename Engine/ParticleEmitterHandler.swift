//
//  ParticleEmitterHandler.swift
//  MPCGD
//
//  Created by Simon Colton on 05/04/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class ParticleEmitterHandler{
    
    static func effectChange(forceIt: Bool, existingBackgroundChoice eB: Int, existingBackgroundShade eS: Int, newMPCGDGenome: MPCGDGenome, emitter: SKEmitterNode, screenSize: CGSize) -> Bool{
        let newB = newMPCGDGenome.backgroundChoice
        let newS = newMPCGDGenome.backgroundShade
        //let newDNC = newMPCGDGenome.dayNightCycle
        if !forceIt{
            if newB == eB && newS == eS{
                return true
            }
            if newB != eB{
                return false
            }            
        }
        
        if eB == 0{ // Fog
            if newS < 3{
                emitter.alpha = 0.05
                emitter.particleColor = Colours.getColour(.antiqueWhite)
            }
            else if newS < 6{
                emitter.particleColor = Colours.getColour(.lightGray)
                emitter.alpha = 0.025
            }
            else{
                emitter.particleColor = Colours.getColour(.darkGray)
                emitter.alpha = 0.025
            }
        }
        
        if eB == 1{// Steam
            if newS > 6{
                emitter.particleColor = Colours.getColour(.steelBlue)
            }
            else if newS > 3{
                emitter.particleColor = Colours.getColour(.darkOrange)
            }
            else{
                emitter.particleColor = Colours.getColour(.orangeRed)
            }
        }
        
        if eB == 2{// Birds/Bats - changing the texture causes a glitch, so better to start a new effect when transitioning
            if (eS < 7 && newS >= 7) || (eS >= 7 && newS < 7){
                return false
            }
            return true
            //emitter.particleTexture = (newS < 7) ? SKTexture(imageNamed: "WBird") : SKTexture(imageNamed: "Bat")
            //emitter.position = (newS < 7) ? CGPointMake(screenSize.width/2, screenSize.height/2) : CGPointMake(screenSize.width/2, screenSize.height * 0.75)
        }
        
        if eB == 3{//Swirling leaves
            emitter.particleColorSequence = nil
            if newS > 5{
                emitter.particleColor = Colours.getColour(.steelBlue)
            }
            else{
                emitter.particleColor = Colours.getColour(.brown)
            }
        }
        
        if eB == 4{// Clouds
            emitter.particleColorSequence = nil
            if newS < 4{
                emitter.particleColor = Colours.getColour(.white)
            }
            else if newS < 6{
                emitter.particleColor = Colours.getColour(.gray)
            }
            else{
                emitter.particleColor = Colours.getColour(.darkBlue)
            }
        }
        
        if eB == 5{// Rain
            emitter.particleColorSequence = nil
            if newS < 6{
                emitter.particleColor = Colours.getColour(.blue)
            }
            else{
                emitter.particleColor = Colours.getColour(.black)
            }
        }
        
        if eB == 6{// Flowers
            
            emitter.particleColorSequence = nil
            if newS > 5{
                emitter.particleColor = Colours.getColour(.steelBlue)
                emitter.particleColorRedRange = 0.1
                emitter.particleColorGreenRange = 0.1
                emitter.particleColorBlueRange = 0.1
            }
            else if newS > 3{
                emitter.particleColor = Colours.getColour(.darkOrange)
                emitter.particleColorRedRange = 0.75
                emitter.particleColorGreenRange = 0.75
                emitter.particleColorBlueRange = 0.75
            }
            else{
                emitter.particleColor = Colours.getColour(.yellow)
                emitter.particleColorRedRange = 1
                emitter.particleColorGreenRange = 1
                emitter.particleColorBlueRange = 1
            }
        }
        
        if eB == 7{// Snow
            emitter.particleColorSequence = nil
            if newS < 3{
                emitter.particleColor = Colours.getColour(.gray)
            }
            else{
                emitter.particleColor = Colours.getColour(.antiqueWhite)
            }
        }
        
        if eB == 8{ // Fireballs - never change
            return true
        }
        
        return true
    }
    
    static func getBackgroundEmitter(_ size: CGSize, MPCGDGenome: MPCGDGenome) -> SKEmitterNode{
        if DeviceType.simulationIs == .iPhone{
            return getIPhoneEmitter(size, MPCGDGenome: MPCGDGenome)
        }
        else{
            return getIPadEmitter(size, MPCGDGenome: MPCGDGenome)
        }
    }
    
    static func getEmitterName(_ MPCGDGenome: MPCGDGenome) -> String{
        switch MPCGDGenome.backgroundChoice{
        case 0: return "Fog"
        case 1: return "Steam"
        case 2: return (MPCGDGenome.dayNightCycle > 0 || MPCGDGenome.backgroundShade < 7) ? "Birds" : "Bats"
        case 3: return "SwirlingLeaves"
        case 4: return "Clouds"
        case 5: return "Rain"
        case 6: return "Flowers"
        case 7: return "Snow"
        case 8: return "FireBalls"
        default: return ""
        }
    }
    
    static func getIPhoneEmitter(_ size: CGSize, MPCGDGenome: MPCGDGenome) -> SKEmitterNode{
        
        let emitter = getEmitterName(MPCGDGenome)
        let backgroundParticleEmitter = SKEmitterNode(fileNamed: emitter)!
        
        if emitter == "Fog"{
            backgroundParticleEmitter.position = CGPoint(x: size.width/2, y: size.height * 1.5)
            backgroundParticleEmitter.particleColorSequence = nil
            if MPCGDGenome.backgroundShade < 3 || MPCGDGenome.dayNightCycle > 0{
                backgroundParticleEmitter.alpha = 0.05
                backgroundParticleEmitter.particleColor = Colours.getColour(.antiqueWhite)
            }
            else if MPCGDGenome.backgroundShade < 6{
                backgroundParticleEmitter.particleColor = Colours.getColour(.lightGray)
                backgroundParticleEmitter.alpha = 0.025
            }
            else{
                backgroundParticleEmitter.particleColor = Colours.getColour(.darkGray)
                backgroundParticleEmitter.alpha = 0.025
            }
        }
        else if emitter == "Steam"{
            backgroundParticleEmitter.position = CGPoint(x: size.width/2, y: 0)
            backgroundParticleEmitter.particleColorSequence = nil
            if MPCGDGenome.dayNightCycle == 0 && MPCGDGenome.backgroundShade > 6{
                backgroundParticleEmitter.particleColor = Colours.getColour(.steelBlue)
            }
            else if MPCGDGenome.dayNightCycle == 0 && MPCGDGenome.backgroundShade > 3{
                backgroundParticleEmitter.particleColor = Colours.getColour(.darkOrange)
            }
            else{
                backgroundParticleEmitter.particleColor = Colours.getColour(.orangeRed)
            }
            backgroundParticleEmitter.alpha = 0.05
        }
        else if (emitter == "Birds" || emitter == "Bats"){
            backgroundParticleEmitter.position = CGPoint(x: size.width/2, y: size.height/2)
            if emitter == "Bats"{
                backgroundParticleEmitter.position = CGPoint(x: size.width/2, y: size.height * 0.75)
            }
            backgroundParticleEmitter.particleColorSequence = nil
            backgroundParticleEmitter.particleColor = Colours.getColour(.black)
            backgroundParticleEmitter.particleColorRedRange = 0.2
            backgroundParticleEmitter.particleColorGreenRange = 0.2
            backgroundParticleEmitter.particleColorBlueRange = 0.2
            backgroundParticleEmitter.alpha = 1
        }
        else if emitter == "SwirlingLeaves"{
            backgroundParticleEmitter.position = CGPoint(x: size.width/2, y: size.height * 0.25)
            backgroundParticleEmitter.particleColorSequence = nil
            if MPCGDGenome.dayNightCycle == 0 && MPCGDGenome.backgroundShade > 5{
                backgroundParticleEmitter.particleColor = Colours.getColour(.steelBlue)
            }
            else{
                backgroundParticleEmitter.particleColor = Colours.getColour(.brown)
            }
            backgroundParticleEmitter.alpha = 0.9
            backgroundParticleEmitter.particleRenderOrder = .oldestLast
        }
        else if emitter == "Clouds"{
            backgroundParticleEmitter.position = CGPoint(x: size.width + 40, y: size.height - 120)
            backgroundParticleEmitter.particleColorSequence = nil
            if MPCGDGenome.dayNightCycle > 0 || MPCGDGenome.backgroundShade < 4{
                backgroundParticleEmitter.particleColor = Colours.getColour(.white)
            }
            else if MPCGDGenome.backgroundShade < 6{
                backgroundParticleEmitter.particleColor = Colours.getColour(.gray)
            }
            else{
                backgroundParticleEmitter.particleColor = Colours.getColour(.darkBlue)
            }
            backgroundParticleEmitter.alpha = 0.2
        }
        else if emitter == "Rain"{
            backgroundParticleEmitter.position = CGPoint(x: size.width/2, y: size.height + 20)
            backgroundParticleEmitter.particleColorSequence = nil
            if MPCGDGenome.dayNightCycle > 0 || MPCGDGenome.backgroundShade < 6{
                backgroundParticleEmitter.particleColor = Colours.getColour(.blue)
            }
            else{
                backgroundParticleEmitter.particleColor = Colours.getColour(.black)
            }
            backgroundParticleEmitter.alpha = 0.3
        }
        else if emitter == "Flowers"{
            backgroundParticleEmitter.position = CGPoint(x: size.width/2, y: -5)
            backgroundParticleEmitter.particleColorSequence = nil
            if MPCGDGenome.dayNightCycle == 0 && MPCGDGenome.backgroundShade > 5{
                backgroundParticleEmitter.particleColor = Colours.getColour(.steelBlue)
                backgroundParticleEmitter.particleColorRedRange = 0.1
                backgroundParticleEmitter.particleColorGreenRange = 0.1
                backgroundParticleEmitter.particleColorBlueRange = 0.1
            }
            else if MPCGDGenome.dayNightCycle == 0 && MPCGDGenome.backgroundShade > 3{
                backgroundParticleEmitter.particleColor = Colours.getColour(.darkOrange)
                backgroundParticleEmitter.particleColorRedRange = 0.75
                backgroundParticleEmitter.particleColorGreenRange = 0.75
                backgroundParticleEmitter.particleColorBlueRange = 0.75
            }
            else{
                backgroundParticleEmitter.particleColor = Colours.getColour(.yellow)
                backgroundParticleEmitter.particleColorRedRange = 1
                backgroundParticleEmitter.particleColorGreenRange = 1
                backgroundParticleEmitter.particleColorBlueRange = 1
            }
            backgroundParticleEmitter.alpha = 0.4
            backgroundParticleEmitter.particleRenderOrder = .oldestFirst
        }
        else if emitter == "Snow"{
            backgroundParticleEmitter.position = CGPoint(x: size.width/2, y: size.height + 20)
            backgroundParticleEmitter.particleColorSequence = nil
            if MPCGDGenome.dayNightCycle == 0 || MPCGDGenome.backgroundShade < 3{
                backgroundParticleEmitter.particleColor = Colours.getColour(.gray)
            }
            else{
                backgroundParticleEmitter.particleColor = Colours.getColour(.antiqueWhite)
            }
            backgroundParticleEmitter.alpha = 0.3
        }
        else if emitter == "FireBalls"{
            backgroundParticleEmitter.position = CGPoint(x: size.width * 0.9, y: size.height * 0.55)
            backgroundParticleEmitter.alpha = 1
            backgroundParticleEmitter.particleRenderOrder = .oldestLast
        }
        
        return backgroundParticleEmitter
    }
    
    
    static func getIPadEmitter(_ size: CGSize, MPCGDGenome: MPCGDGenome) -> SKEmitterNode{
        let emitter = getEmitterName(MPCGDGenome)
        if emitter == "FireBalls"{
            let backgroundParticleEmitter = SKEmitterNode(fileNamed: emitter)!
            backgroundParticleEmitter.position = CGPoint(x: size.width * 0.825, y: size.height * 0.48)
            backgroundParticleEmitter.alpha = 1
            return backgroundParticleEmitter
        }
        
        return getIPhoneEmitter(size, MPCGDGenome: MPCGDGenome)
    }
    
}
