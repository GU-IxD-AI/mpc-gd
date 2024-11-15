//
//  ImageUtils.swift
//  Fask
//
//  Created by Simon Colton on 14/09/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class ImageUtils{
    
    
    static func getJPEG(_ image: UIImage, compressionQuality: CGFloat) -> Data!{
        return UIImageJPEGRepresentation(image, compressionQuality)
    }
    
    static func writeJPEG(_ jpeg: Data!, filePath: URL){
        do {
            try jpeg.write(to: filePath)
        } catch {
            print("ImageUtils.writeJPEG failed: \(error)")
        }
    }
    
    static func getSubImage(_ image: UIImage, rect: CGRect) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: image.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.translateBy(x: 0 - round(rect.origin.x), y: round(rect.origin.y))
        context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let subImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return subImage!
    }
    
    static func getBlankImage(_ size: CGSize, colour: UIColor) -> UIImage{
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(colour.cgColor)
        context!.fill(CGRect(origin: CGPoint.zero, size: size * 2))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func getTransparentImage(_ size: CGSize) -> UIImage{
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor.clear.cgColor)
        context!.fill(bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func drawImageOntoContext(_ context: CGContext, image: UIImage){
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
    }
    
    static func drawImageOntoContextAtPositionWithoutFlip(_ context: CGContext, image: UIImage, position: CGPoint){
        let movedPosition = CGPoint(x: position.x, y: image.size.height - position.y - image.size.height)
        let rect = CGRect(origin: movedPosition, size: image.size)
        context.draw(image.cgImage!, in: rect)
    }
    
    static func drawImageOntoContextAtPosition(_ context: CGContext, baseImageHeight: CGFloat, image: UIImage, position: CGPoint){
        context.translateBy(x: 0, y: baseImageHeight)
        context.scaleBy(x: 1.0, y: -1.0)
        let movedPosition = CGPoint(x: position.x, y: baseImageHeight - position.y - image.size.height)
        let rect = CGRect(origin: movedPosition, size: image.size)
        context.draw(image.cgImage!, in: rect)
        context.translateBy(x: 0, y: baseImageHeight)
        context.scaleBy(x: 1.0, y: -1.0)
    }
    
    static func drawImageInImageAtPosition(_ size: CGSize, bottomImage: CGImage, topImage: CGImage, position: CGPoint, opaque: Bool) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, opaque, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(bottomImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let movedPosition = CGPoint(x: position.x, y: size.height - position.y - size.height)
        let rect = CGRect(origin: movedPosition, size: size)
        context!.draw(topImage, in: rect)
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return compositeImage!
    }
    
    static func drawImageInImageAtPosition(_ bottomImage: UIImage, topImage: UIImage, position: CGPoint, opaque: Bool) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(bottomImage.size, opaque, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: bottomImage.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(bottomImage.cgImage!, in: CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height))
        let movedPosition = CGPoint(x: position.x, y: bottomImage.size.height - position.y - topImage.size.height)
        let rect = CGRect(origin: movedPosition, size: topImage.size)
        context!.draw(topImage.cgImage!, in: rect)
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return compositeImage!
    }
    
    static func drawImageInImageCentre(_ bottomImage: UIImage, topImage: UIImage, opaque: Bool) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(bottomImage.size, opaque, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: bottomImage.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(bottomImage.cgImage!, in: CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height))
        let xOff: CGFloat = (bottomImage.size.width - topImage.size.width)/2
        let yOff: CGFloat = (bottomImage.size.height - topImage.size.height)/2
        context!.draw(topImage.cgImage!, in: CGRect(x: xOff, y: yOff, width: topImage.size.width, height: topImage.size.height))
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return compositeImage!
    }
    
    static func drawImageOntoImageInRect(_ bottomImage: UIImage, topImage: UIImage, rect: CGRect, opaque: Bool) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(bottomImage.size, opaque, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: bottomImage.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(bottomImage.cgImage!, in: CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height))
        context!.draw(topImage.cgImage!, in: rect)
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return compositeImage!
    }
    
    static func drawImageOntoContextInRect(_ context: CGContext, baseImageHeight: CGFloat, image: UIImage, rect: CGRect){
        context.translateBy(x: 0, y: baseImageHeight)
        context.scaleBy(x: 1.0, y: -1.0)
        let movedPosition = CGPoint(x: rect.origin.x, y: baseImageHeight - rect.origin.y - rect.height)
        let movedRect = CGRect(origin: movedPosition, size: rect.size)
        
        context.draw(image.cgImage!, in: movedRect)
        context.translateBy(x: 0, y: baseImageHeight)
        context.scaleBy(x: 1.0, y: -1.0)
    }
    
    static func getScaledImage(_ image: UIImage, size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    static func getScaledImage(_ image: UIImage, scale: CGFloat) -> UIImage{
        let size = CGSize(width: floor(image.size.width * scale), height: floor(image.size.height * scale))
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    static func getScaledImageOnSameSizeWhiteCanvas(_ image: UIImage, scale: CGFloat) -> UIImage{
        let size = CGSize(width: floor(image.size.width * scale), height: floor(image.size.height * scale))
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor.white.cgColor)
        context!.fill(CGRect(origin: CGPoint.zero, size: image.size))
        let xOffset = (image.size.width - (image.size.width * scale))/2
        let yOffset = (image.size.height - (image.size.height * scale))/2
        context!.translateBy(x: xOffset, y: size.height + yOffset)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    static func getScaledImageOnCanvasWithSize(_ image: UIImage, scale: CGFloat, canvasSize: CGSize) -> UIImage{
        let size = CGSize(width: floor(image.size.width * scale), height: floor(image.size.height * scale))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 1)
        let context = UIGraphicsGetCurrentContext()
        //CGContextSetFillColorWithColor(context!, UIColor.whiteColor().CGColor)
        //CGContextFillRect(context!, CGRect(origin: CGPoint.zero, size: canvasSize))
        let xOffset = (canvasSize.width - (image.size.width * scale))/2
        let yOffset = (canvasSize.height - (image.size.height * scale))/2
        context!.translateBy(x: xOffset, y: size.height + yOffset)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    static func getImageScaledToSize(_ image: UIImage, size: CGSize) -> UIImage{
        let size = CGSize(width: round(size.width), height: round(size.height))
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(image.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    // All blend modes listed here:
    // https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
    
    // These work for white images:
    
    // CILinearBurnBlendMode
    // CIMultiplyBlendMode
    // CIMultiplyCompositing
    // CIOverlayBlendMode
    // CISoftLightBlendMode
    
    static func blendImages(_ bottomImage: UIImage, topImage: UIImage, blendMode: String) -> UIImage{
        autoreleasepool{
            let imageSize = CGSize(width: bottomImage.size.width, height: bottomImage.size.height)
            let bounds = CGRect(origin: CGPoint.zero, size: imageSize)
            UIGraphicsBeginImageContextWithOptions(imageSize, true, 1)
            let context = UIGraphicsGetCurrentContext()
            let filter = CIFilter(name: blendMode)
            filter!.setDefaults()
            filter!.setValue(CIImage(image: bottomImage), forKey: "inputBackgroundImage")
            filter!.setValue(CIImage(image: topImage), forKey: "inputImage")
            let composite = filter!.outputImage!
            let ciContext: CIContext! = CIContext(options: nil)
            let cgImage = ciContext.createCGImage(composite, from: composite.extent)
            context!.translateBy(x: 0, y: bounds.height)
            context!.scaleBy(x: 1.0, y: -1.0)
            context!.draw(cgImage!, in: bounds)
        }
        let blendedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blendedImage!
    }
    
    #if os(iOS)
        static func getBlurredImage(_ image: UIImage, blurRadius: Int) -> UIImage{
            let clampFilter = CIFilter(name: "CIAffineClamp")
            clampFilter!.setValue(NSValue(cgAffineTransform: CGAffineTransform.identity), forKey: "inputTransform")
            clampFilter!.setValue(CIImage(image: image), forKey: "inputImage")
            let imageToBlur = clampFilter!.outputImage
            
            let blurFilter = CIFilter(name: "CIGaussianBlur")
            blurFilter!.setDefaults()
            blurFilter!.setValue(blurRadius, forKey: "inputRadius")
            blurFilter!.setValue(imageToBlur, forKey: "inputImage")
            let blurredCIImage = blurFilter!.outputImage!
            let ciContext: CIContext! = CIContext(options: nil)
            let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            return UIImage(cgImage: ciContext.createCGImage(blurredCIImage, from: rect)!)
        }
    #endif
    
    static func getNegativeImage(_ image: UIImage) -> UIImage{
        let filter = CIFilter(name: "CIColorInvert")
        filter!.setDefaults()
        filter!.setValue(CIImage(image: image), forKey: "inputImage")
        let filteredImage = filter!.outputImage!
        let ciContext: CIContext! = CIContext(options: nil)
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        return UIImage(cgImage: ciContext.createCGImage(filteredImage, from: rect)!)
    }
    
    static func getPixelatedImage(_ image: UIImage, targetSize: CGSize, rectSize: CGSize, bgColour: UIColor) -> UIImage{
        let fullScaleImage = getImageScaledToSize(image, size: targetSize)
        let data = ImageData(image: fullScaleImage)
        
        let xOffset = (targetSize.width.truncatingRemainder(dividingBy: rectSize.width))/2
        let yOffset = (targetSize.height.truncatingRemainder(dividingBy: rectSize.height))/2
        
        let origin = CGPoint(x: xOffset, y: yOffset)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(bgColour.cgColor)
        context!.fill(CGRect(origin: CGPoint.zero, size: targetSize))
        
        var rect = CGRect(origin: origin, size: rectSize)
        while rect.origin.y + rectSize.height <= targetSize.height{
            rect.origin.x = xOffset
            while rect.origin.x + rectSize.width <= targetSize.width{
                let fillColour = data.colourAt(Int(rect.midX), y: Int(rect.midY))
                context!.setFillColor(fillColour.cgColor)
                context!.fill(rect)
                context!.setStrokeColor(UIColor.lightGray.cgColor)
                context!.stroke(rect)
                rect.origin.x += rectSize.width
            }
            rect.origin.y += rectSize.height
        }
        
        let pixelatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return pixelatedImage!
    }
    
    static func getOverlaidImage(_ baseImage: UIImage, overlayImage: UIImage, alpha: CGFloat) -> UIImage{
        let alphaImage = overlayImage.alpha(alpha)
        return drawImageInImageCentre(baseImage, topImage: alphaImage, opaque: false)
    }
    
    static func tintImage(_ image: UIImage, tint: UIColor, tintPC: CGFloat) -> UIImage!{
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: image.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        let tint = tint.withAlphaComponent(tintPC)
        context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        context!.setFillColor(tint.cgColor)
        context!.fill(bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    
    static func getGrayscaleImage(_ image: UIImage) -> UIImage{
        // Ported from http://iosdevelopertips.com/graphics/convert-an-image-uiimage-to-grayscale.html
        
        var newImage: UIImage! = nil
        
        autoreleasepool{
            // Create image rectangle with current image width/height
            let imageRect = CGRect(origin: CGPoint.zero, size: image.size)
            
            // Grayscale color space
            let colorSpace = CGColorSpaceCreateDeviceGray()
            
            // Create bitmap content with current image size and grayscale colorspace
            let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)
            
            // Draw image into current context, with specified rectangle
            // using previously defined context (with grayscale colorspace)
            context!.draw(image.cgImage!, in: imageRect)
            
            // Create bitmap image info from pixel data in current context
            let imageRef = context!.makeImage();
            
            // Create a new UIImage object
            newImage = UIImage(cgImage: imageRef!)
        }
        
        // Return the new grayscale image
        return newImage
    }
    
    static func getImageIslands(_ image: UIImage, rgbaPredicate: (UInt8, UInt8, UInt8, UInt8) -> Bool, ignoreIslandsAtEdges: Bool) -> [UIImage] {
        var result = Array<UIImage>()
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let imageData = ImageData(image: image)
        
        var todo = ArrayUtils.create2DArray(width: width, height: height, initial: false)
        
        for x in 0..<width {
            for y in 0..<height {
                let (r,g,b,a) = imageData.rgbaTupleAt(x, y: y)
                todo[x][y] = rgbaPredicate(r, g, b, a)
            }
        }
        
        for x in 0..<width {
            for y in 0..<height {
                if todo[x][y] {
                    
                    // Flood fill starting at x,y to find the island
                    
                    let island = ImageData(width: width, height: height)
                    var pixelsInIsland = 0
                    var maxQueueSize = 0
                    var islandTouchesEdge = false
                    
                    let q = Queue<(Int, Int)>()
                    q.enqueue((x, y))
                    
                    //println("  floodfilling")
                    while let (nx, ny) = q.dequeue() {
                        
                        maxQueueSize = max(maxQueueSize, q.count)
                        
                        if !todo[nx][ny] {
                            continue
                        }
                        
                        // Scan to the west
                        var w = nx
                        while w > 0 && todo[w-1][ny] {
                            w -= 1
                        }
                        
                        // Scan to the east
                        var e = nx
                        while e < width-1 && todo[e+1][ny] {
                            e += 1
                        }
                        
                        // Fill the range
                        var lastAbove = false
                        var lastBelow = false
                        for sx in w...e {
                            let (r,g,b,a) = imageData.rgbaTupleAt(sx, y: ny)
                            island.setAt(sx, y: ny, r: r, g: g, b: b, a: a)
                            todo[sx][ny] = false
                            pixelsInIsland += 1
                            
                            if sx == 0 || sx == width-1 || ny == 0 || ny == height-1 {
                                islandTouchesEdge = true
                            }
                            
                            // Look above
                            if ny > 0 {
                                let thisAbove = todo[sx][ny-1]
                                if thisAbove && !lastAbove {
                                    q.enqueue((sx, ny-1))
                                }
                                
                                lastAbove = thisAbove
                            }
                            
                            // Look below
                            if ny < height-1 {
                                let thisBelow = todo[sx][ny+1]
                                if thisBelow && !lastBelow {
                                    q.enqueue((sx, ny+1))
                                }
                                
                                lastBelow = thisBelow
                            }
                        }
                    }
                    
                    //println("Island has \(pixelsInIsland) pixels, max queue length \(maxQueueSize)")
                    
                    if !(islandTouchesEdge && ignoreIslandsAtEdges) {
                        result.append(island.toImage())
                    }
                }
            }
        }
        return result
    }
    
    static func getImageIslandsOnWhite(_ image: UIImage, ignoreIslandsAtEdges: Bool) -> [UIImage] {
        return getImageIslands(image, rgbaPredicate: isNotWhite, ignoreIslandsAtEdges: ignoreIslandsAtEdges)
    }
    
    static func isNotWhite(_ r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> Bool {
        return a == 255 && (r < 255 || g < 255 || b < 255)
    }

    static func replaceWhiteWithTransparent(_ image: UIImage) -> UIImage {
        let data = ImageData(image: image)
        let width = Int(data.bounds.width)
        let height = Int(data.bounds.height)
        
        for x in 0 ..< width {
            for y in 0 ..< height {
                let (r,g,b,a) = data.rgbaTupleAt(x, y: y)
                if !isNotWhite(r, g: g, b: b, a: a) {
                    data.setAt(x, y: y, r: 0, g: 0, b: 0, a: 0)
                }
            }
        }
        return data.toImage()
    }

}
