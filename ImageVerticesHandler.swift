//
//  ImageVerticesHandler.swift
//  Engine
//
//  Created by Simon Colton on 15/02/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class ImageVerticesHandler{
    
    static func getImageVertices(_ imageName: String) -> [CGPoint]!{
        var vertices: [CGPoint] = []
        let lines = FileUtils.readFileLines("ImageList", fileType: "txt")!
        for line in lines{
            let parts = line.components(separatedBy: ",")
            if parts[0] == imageName || parts[0] == imageName + ".png" {
                for pos in stride(from: 1, to:parts.count-1, by: 2) {
                    let x = CGFloat(Int(parts[pos])!)
                    let y = CGFloat(Int(parts[pos + 1])!)
                    let point = CGPoint(x: x, y: y)
                    vertices.append(point)
                }
            }
        }
        if vertices.isEmpty{
            return nil
        }
        return vertices
    }
    
    static func getImagePath(_ imageName: String, offset: CGVector, scale: CGVector) -> CGPath! {
        if let vertices = getImageVertices(imageName) {
            
            var fudge : CGFloat = 1
            if imageName == "RavenHeidiBallTrans" {
                // I think the values in the CSV file are wrong for this image -- this fudges them to the correct scale
                // TODO: correct the CSV values and remove the fudge factor
                fudge = 1.85
            }
            
            let path = CGMutablePath()
            var first = true
            
            for vertex in vertices {
                let x = vertex.x * scale.dx * fudge + offset.dx
                let y = vertex.y * scale.dy * fudge + offset.dy
                
                if first {
                    path.move(to: CGPoint(x: x, y: y))
                    first = false
                }
                else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            path.closeSubpath()
            return path
        }
        else {
            return nil
        }
    }
}
