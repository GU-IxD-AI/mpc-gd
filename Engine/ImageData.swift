//
//  ImageData.swift
//  Beeee
//
//  Created by Simon Colton on 27/08/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class ImageData{
    
    var data: [UInt8]
    
    let bytesPerRow: Int
    
    let bounds: CGRect
    
    var bitmapInfo : CGBitmapInfo
    
    fileprivate static let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    
    init(cgImage: CGImage) {
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        bitmapInfo = cgImage.bitmapInfo
        
        // Force an alpha channel
        var rawBitmapInfo: UInt32 = bitmapInfo.rawValue & ~CGBitmapInfo.alphaInfoMask.rawValue
        rawBitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue
        bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        
        let pixelData = cgImage.dataProvider!.data
        let dataLength = CFDataGetLength(pixelData)
        data = Array(repeating: UInt8(0), count: dataLength)
        CFDataGetBytes(pixelData, CFRangeMake(0, dataLength), &data)
        bytesPerRow = Int(CGFloat(CFDataGetLength(pixelData))/imageSize.height)
        bounds = CGRect(origin: CGPoint.zero, size: imageSize)
    }
    
    convenience init(image: UIImage){
        self.init(cgImage: image.cgImage!)
    }
    
    init(width: Int, height: Int) {
        bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        data = Array(repeating: UInt8(0), count: width * height * 4)
        bytesPerRow = width * 4
        bounds = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    func rgbaAt(_ x: Int, y: Int) -> [UInt8] {
        let dataPos = (y * bytesPerRow) + (x * 4)
        let b = data[dataPos]
        let g = data[dataPos + 1]
        let r = data[dataPos + 2]
        let a = data[dataPos + 3]
        return [r, g, b, a]
    }
    
    func rgbaTupleAt(_ x: Int, y: Int) -> (UInt8, UInt8, UInt8, UInt8) {
        let dataPos = (y * bytesPerRow) + (x * 4)
        let b = data[dataPos]
        let g = data[dataPos + 1]
        let r = data[dataPos + 2]
        let a = data[dataPos + 3]
        return (r, g, b, a)
    }
    
    func colourAt(_ x: Int, y: Int) -> UIColor{
        let rgba = rgbaAt(x, y: y)
        let r = CGFloat(rgba[0])/255
        let g = CGFloat(rgba[1])/255
        let b = CGFloat(rgba[2])/255
        let a = CGFloat(rgba[3])/255
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func averageColourInRect(_ rect: CGRect) -> UIColor!{
        if !rect.intersects(bounds){
            return nil
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        var count: CGFloat = 0
        var rgba: [UInt8] = []
        for x in Int(rect.origin.x)..<Int(rect.origin.x + rect.width){
            for y in Int(rect.origin.y)..<Int(rect.origin.y + rect.height){
                if x >= 0 && y >= 0 && x < Int(bounds.width) && y < Int(bounds.height){
                    rgba = rgbaAt(x, y: y)
                    r += CGFloat(rgba[0])
                    g += CGFloat(rgba[1])
                    b += CGFloat(rgba[2])
                    a += CGFloat(rgba[3])
                    count += 1
                }
            }
        }
        let divisor = count * 255
        return UIColor(red: r/divisor, green: g/divisor, blue: g/divisor, alpha: a/divisor)
    }
    
    func averageColourAroundPoint(_ point: CGPoint, boxSize: CGFloat) -> UIColor{
        let rect = CGRect(x: point.x - boxSize/2, y: point.y - boxSize/2, width: boxSize, height: boxSize)
        return averageColourInRect(rect)
    }
    
    func setAt(_ x: Int, y: Int, colour: UIColor) {
        let (fr, fg, fb, fa) = colour.getRGBA()
        let dataPos = (y * bytesPerRow) + (x * 4)
        data[dataPos+0] = UInt8(fb * 255.0)
        data[dataPos+1] = UInt8(fg * 255.0)
        data[dataPos+2] = UInt8(fr * 255.0)
        data[dataPos+3] = UInt8(fa * 255.0)
    }
    
    func setAt(_ x: Int, y: Int, r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        let dataPos = (y * bytesPerRow) + (x * 4)
        data[dataPos + 0] = b
        data[dataPos + 1] = g
        data[dataPos + 2] = r
        data[dataPos + 3] = a
    }
    
    func toImage() -> UIImage {
        
        let fooData = Data(bytes: self.data)
        let providerRef = CGDataProvider(data: fooData as CFData)
        
        let cgim = CGImage(
            width: Int(bounds.width),
            height: Int(bounds.height),
            bitsPerComponent: 8, // bitsPerComponent
            bitsPerPixel: 32, // bitsPerPixel
            bytesPerRow: bytesPerRow,
            space: ImageData.rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil, // decode
            shouldInterpolate: true, // shouldInterpolate
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        #if os(OSX)
            // The image comes out flipped on OSX because of reasons
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
            let context = UIGraphicsGetCurrentContext()
            CGContextTranslateCTM(context, 0, bounds.height)
            CGContextScaleCTM(context, 1, -1)
            CGContextDrawImage(context, CGRect(origin: CGPoint.zero, size: bounds.size), cgim)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        #else
            return UIImage(cgImage: cgim!)
        #endif
    }

}
