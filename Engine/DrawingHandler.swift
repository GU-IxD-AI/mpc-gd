//
//  DrawingWidget.swift
//  Engine
//
//  Created by Simon Colton on 20/11/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

// Useful tutorial for drawing smooth lines: http://code.tutsplus.com/tutorials/smooth-freehand-drawing-on-ios--mobile-13164

class DrawingHandler{
    
    static func getPath(_ fromPoints: [CGPoint], closed: Bool) -> UIBezierPath{
        let path = UIBezierPath()
        path.move(to: fromPoints[0])
        for pos in 1..<fromPoints.count{
            path.addLine(to: fromPoints[pos])
        }
        if closed{
            path.close()
        }
        return path
    }
    
    static func addNormalPath(_ context: CGContext, path: DrawingPath){
        if path.alpha <= 0 {
            return
        }
        
        let bezierPath = getPath(path.pathPoints, closed: path.closed)
        var pathColour = UIColor(hue: path.hue, saturation: path.saturation, brightness: path.brightness, alpha: path.alpha)
        if path.isEraser{
            pathColour = UIColor.white
        }
        if path.filled{
            context.setFillColor(pathColour.cgColor)
            context.addPath(bezierPath.cgPath)
            context.fillPath()
        }
        else{
            context.setStrokeColor(pathColour.cgColor)
            context.setLineWidth(path.strokeWidth)
            context.addPath(bezierPath.cgPath)
            context.strokePath()
        }
    }
    
    static func getDrawingImage(paths: [DrawingPath], sceneSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(sceneSize.doubled(), false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.black.cgColor)
        context.setFillColor(UIColor.white.cgColor)
        //CGContextFillRect(context, CGRect(origin: CGPoint.zero, size: image.size * 2))
        var pathNum = 0
        for path in paths{
            context.setLineWidth(path.strokeWidth)
            addNormalPath(context, path: path)
            pathNum += 1
        }
        let drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return drawingImage!
    }
    
    static func transformPointForPhysicsBody(_ p: CGPoint, scale: CGFloat, sceneSize: CGSize) -> CGPoint {
        return CGPoint(x: p.x * scale - sceneSize.width * 0.5, y: -(p.y * scale - sceneSize.height * 0.5))
    }
    
    static func getPhysicsBody(_ scale: CGFloat, paths: [DrawingPath], sceneSize: CGSize) -> SKPhysicsBody {
        var bodies : [SKPhysicsBody] = []
        var minX = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var minY = CGFloat.infinity
        
        for path in paths {
            if path.pathPoints.count == 2 { // Straight line segment
                let p0 = transformPointForPhysicsBody(path.pathPoints[0], scale: scale, sceneSize: sceneSize)
                let p1 = transformPointForPhysicsBody(path.pathPoints[1], scale: scale, sceneSize: sceneSize)
                let centre = (p0 + p1) * 0.5
                
                minX = min(minX, p0.x, p1.x)
                maxX = max(maxX, p0.x, p1.x)
                minY = min(minY, p0.y, p1.y)

                if p0.y.approxEquals(p1.y) { // Horizontal
                    let minx = min(p0.x, p1.x)
                    let lineLength = (centre.x - minx) * 2
                    let size = CGSize(width: lineLength, height: path.strokeWidth * scale)
                    bodies.append(SKPhysicsBody(rectangleOf: size, center: centre))
                }
                else if p0.x.approxEquals(p1.x) { // Vertical
                    let miny = min(p0.y, p1.y)
                    let lineLength = (centre.y - miny) * 2
                    let size = CGSize(width: path.strokeWidth * scale, height: lineLength)
                    bodies.append(SKPhysicsBody(rectangleOf: size, center: centre))
                }
                else { // Diagonal
                    let linePath = getPath([p0, p1], closed: false)
                    let strokePath = CGPath(__byStroking: linePath.cgPath, transform: nil, lineWidth: path.strokeWidth * scale, lineCap: CGLineCap.butt, lineJoin: CGLineJoin.miter, miterLimit: 10000)!
                    bodies.append(SKPhysicsBody(polygonFrom: strokePath))
                }
            }
            else if path.pathPoints.count > 2 && path.filled {
                let cgPath = CGMutablePath()
                
                for i in 0 ..< path.pathPoints.count {
                    let transPoint = transformPointForPhysicsBody(path.pathPoints[i], scale: scale, sceneSize: sceneSize)
                    if i == 0 {
                        cgPath.move(to: transPoint)
                    }
                    else {
                        cgPath.addLine(to: transPoint)
                    }
                }
                
                cgPath.closeSubpath()
                
                let body : SKPhysicsBody! = SKPhysicsBody(polygonFrom: cgPath)
                if body != nil {
                    bodies.append(body)
                }
            }
            else { // Something else?
                print("😰 Found a path that I don't know how to make into a physics body -- Ed needs to fix this")
            }
        }
        
        return SKPhysicsBody(bodies: bodies)
    }
    
    static func getBoundingBox(_ scale: CGFloat, paths: [DrawingPath], sceneSize: CGSize) -> CGRect! {
        var result : CGRect! = nil
        
        var minX = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var minY = CGFloat.infinity
        
        for path in paths {
            for point in path.pathPoints {
                let p0 = transformPointForPhysicsBody(point, scale: scale, sceneSize: sceneSize)
                let pointRect = CGRect(origin: p0, size: CGSize.zero)
                if result == nil {
                    result = pointRect
                }
                else {
                    result = result.union(pointRect)
                }
                
                minX = min(minX, p0.x)
                maxX = max(maxX, p0.x)
                minY = min(minY, p0.y)
            }
        }
        
        return result
    }
}
