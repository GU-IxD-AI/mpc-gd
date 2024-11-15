//
//  UIGraphics.swift
//  Engine
//
//  Created by Powley, Edward on 09/03/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import AppKit
import CoreGraphics

func UIImageJPEGRepresentation(image : UIImage, _ compressionQuality : CGFloat) -> NSData! {
    let tiffData = image.TIFFRepresentation!
    let imageRep = NSBitmapImageRep(data: tiffData)!
    let imageData = imageRep.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: [NSImageCompressionFactor: compressionQuality])
    return imageData
}

private var contextStack : [CGContextRef] = []

func UIGraphicsBeginImageContextWithOptions(size: CGSize, _ opaque : Bool, _ scale: CGFloat) {
    //print("Begin context")
    var flags : UInt32 = CGBitmapInfo.ByteOrder32Little.rawValue
    if opaque {
        flags |= CGImageAlphaInfo.NoneSkipFirst.rawValue
    }
    else {
        flags |= CGImageAlphaInfo.PremultipliedFirst.rawValue
    }
    
    if let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, CGColorSpaceCreateDeviceRGB(), flags) {
        // Flip the context
        CGContextTranslateCTM(context, 0, size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        contextStack.append(context)
    }
    else {
        assertionFailure("Failed to create context")
    }
}

func UIGraphicsBeginImageContext(size: CGSize) {
    UIGraphicsBeginImageContextWithOptions(size, false, 1)
}

func UIGraphicsGetCurrentContext() -> CGContextRef! {
    if contextStack.isEmpty {
        print("WARNING: no current context")
    }
    return contextStack.last
}

func UIGraphicsGetImageFromCurrentImageContext() -> NSImage! {
    if let cgImage = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext()) {
        return NSImage(CGImage: cgImage, size: NSZeroSize)
    }
    else {
        return nil
    }
}

func UIGraphicsEndImageContext() {
    contextStack.removeLast()
}

extension NSImage {
    var CGImage : CGImageRef! {
        return self.CGImageForProposedRect(nil, context: nil, hints: nil)
    }
    
    convenience init(CGImage: CGImageRef) {
        self.init(CGImage: CGImage, size: NSZeroSize)
    }
    
    func setSizeFromPixelSize() {
        self.size = CGSize(width: representations.first!.pixelsWide, height: representations.first!.pixelsHigh)
    }
}

extension CIImage {
    convenience init(image: NSImage) {
        self.init(CGImage: image.CGImage)
    }
}

extension NSFont {
    var lineHeight : CGFloat {
        return self.ascender - self.descender + self.leading
    }
}

extension UIBezierPath {
    convenience init(roundedRect: CGRect, cornerRadius: CGFloat) {
        self.init(roundedRect: roundedRect, xRadius: cornerRadius, yRadius: cornerRadius)
    }
    
    func addLineToPoint(point: CGPoint) {
        lineToPoint(point)
    }
    
    // Adapted from https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Paths/Paths.html#//apple_ref/doc/uid/TP40003290-CH206-SW2
    var CGPath : CGPathRef! {
        let numElements = self.elementCount
        if numElements > 0 {
            let path = CGPathCreateMutable()
            var points = Array(count: 3, repeatedValue: CGPoint.zero)
            
            for i in 0 ..< numElements {
                switch self.elementAtIndex(i, associatedPoints: &points) {
                case .MoveToBezierPathElement:
                    CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
                    
                case .LineToBezierPathElement:
                    CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
                    
                case .CurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y,
                        points[1].x, points[1].y,
                        points[2].x, points[2].y)
                    
                case .ClosePathBezierPathElement:
                    CGPathCloseSubpath(path)
                }
            }
            
            return path
        }
        else {
            return nil
        }
    }
}
