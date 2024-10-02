//
//  Colours.swift
//  Fask
//
//  Created by Simon Colton on 12/09/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class Colours{
    
    static var background = Colours.getColour(ColourNames.orange)
    
    static var transBackground = background.withAlphaComponent(0.8)
    
    static var foreground = Colours.getColour(ColourNames.black)
    
    static var transForeground = foreground.withAlphaComponent(0.25)
    
    static var skillColour = Colours.getColour(ColourNames.orangeRed)
    
    static var ingenuityColour = Colours.getColour(ColourNames.forestGreen)
    
    static var patienceColour = Colours.getColour(ColourNames.royalBlue)
    
    static var colours: [UIColor] = []
    
    static var colourNames: [String] = []
    
    // Note that NameColours.csv has been sorted by hue
    
    static func loadColours(){
        let colourLines = FileUtils.readFileLines("NamedColours", fileType: "csv")!
        for line in colourLines{
            let parts = line.components(separatedBy: ",")
            if parts.count > 1{
                Colours.colourNames.append(parts[0])
                let colour = getColour(parts[1], g: parts[2], b: parts[3], a: parts[4])
                Colours.colours.append(colour)                
            }
        }
    }
    
    static func getColour(_ r: String, g: String, b: String, a: String) -> UIColor{
        return UIColor(red: CGFloat(Int(r)!)/255, green: CGFloat(Int(g)!)/255, blue: CGFloat(Int(b)!)/255, alpha: CGFloat(Int(a)!)/255)
    }
    
    static func getColour(_ colourName: ColourNames) -> UIColor{
        if colourNames.isEmpty{
            loadColours()
        }
        return colours[colourName.rawValue]
    }
    
    static func getColour(_ colourNum: Int) -> UIColor{
        return colours[colourNum]
    }
    
    static func getColourNameAsString(_ colourName: ColourNames) -> String{
        return colourNames[colourName.rawValue]
    }
}
