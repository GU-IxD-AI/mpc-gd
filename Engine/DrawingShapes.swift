//
//  DrawingShapes.swift
//  Fask
//
//  Created by Simon Colton on 12/09/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class DrawingShapes{
    
    static func getRoundedRectImage(_ rect: CGRect, colour: UIColor, cornerRadius: CGFloat) -> UIImage{
        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        DrawingShapes.fillRoundedRectOnContext(context!, rect: rect, colour: colour, cornerRadius: cornerRadius)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func getCircleImage(_ diameter: CGFloat, colour: UIColor) -> UIImage{
        let size = CGSize(width: diameter, height: diameter)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        let centre = CGPoint(x: diameter/2, y: diameter/2)
        fillCircleOnContext(context!, colour: colour, centre: centre, radius: diameter/2)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func strokeCircleOnContext(_ context: CGContext, colour: UIColor, strokeWidth: CGFloat, centre: CGPoint, radius: CGFloat){
        context.setLineWidth(strokeWidth)
        context.setStrokeColor(colour.cgColor)
        let rectOrigin = CGPoint(x: centre.x - radius, y: centre.y - radius)
        let rectSize = CGSize(width: radius * 2, height: radius * 2)
        let rect = CGRect(origin: rectOrigin, size: rectSize)
        context.strokeEllipse(in: rect)
    }
    
    static func fillCircleOnContext(_ context: CGContext, colour: UIColor, centre: CGPoint, radius: CGFloat){
        context.setFillColor(colour.cgColor)
        let rectOrigin = CGPoint(x: centre.x - radius, y: centre.y - radius)
        let rectSize = CGSize(width: radius * 2, height: radius * 2)
        let rect = CGRect(origin: rectOrigin, size: rectSize)
        context.fillEllipse(in: rect)
    }
    
    static func strokeLineOnContext(_ context: CGContext, colour: UIColor, point1: CGPoint, point2: CGPoint){
        context.setStrokeColor(colour.cgColor)
        context.move(to: CGPoint(x: CGFloat(point1.x), y: CGFloat(point1.y)))
        context.addLine(to: CGPoint(x: CGFloat(point2.x), y: CGFloat(point2.y)))
        context.strokePath()
    }
    
    static func strokeRectOnContext(_ context: CGContext, rect: CGRect, strokeWidth: CGFloat, colour: UIColor){
        context.setStrokeColor(colour.cgColor)
        context.setLineWidth(strokeWidth)
        context.stroke(rect)
    }
    
    static func fillRectOnContext(_ context: CGContext, rect: CGRect, colour: UIColor){
        context.setFillColor(colour.cgColor)
        context.fill(rect)
    }
    
    static func strokeRoundedRectOnContext(_ context: CGContext, rect: CGRect, strokeWidth: CGFloat, colour: UIColor, cornerRadius: CGFloat){
        context.setFillColor(colour.cgColor)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.setLineWidth(strokeWidth)
        context.setStrokeColor(colour.cgColor)
        context.addPath(path.cgPath)
        context.strokePath()
    }
    
    static func fillRoundedRectOnContext(_ context: CGContext, rect: CGRect, colour: UIColor, cornerRadius: CGFloat){
        context.setFillColor(colour.cgColor)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.setFillColor(colour.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
    }
    
}
