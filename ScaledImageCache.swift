// TODO(pete): Remove ALL ScaledImageCache references and delete once PDF transition complete.
//
////
////  ScaledImageCache.swift
////  Engine
////
////  Created by Powley, Edward on 16/02/2016.
////  Copyright © 2016 Simon Colton. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//
//class ScaledImageCache {
//    
//    fileprivate static func loadImages() -> [IconTypeEnum : UIImage] {
//        var result : [IconTypeEnum : UIImage] = [:]
//        var i = 0
//        while let icon = IconTypeEnum(rawValue: i) {
//            // Convert icon name from .camelCase to .PascalCase so appease the asset gods
//            var name = "\(icon)"
//            name.replaceSubrange(name.startIndex...name.startIndex, with: String(name[name.startIndex]).capitalized)
//            let image = UIImage(named: name)
//            result[icon] = image
//            i += 1
//        }
//        return result
//    }
//    
//    static let originalImages = ScaledImageCache.loadImages()
//    
//    static var dominantColours : [IconTypeEnum : UIColor] = [:]
//    
//    fileprivate class CacheItem {
//        let icon : IconTypeEnum
//        let size : CGSize
//        
//        let image : UIImage
//        let texture : SKTexture
//        
//        lazy var dominantColour : UIColor = {
//            let imageData = ImageData(image: self.image)
//            var result: UIColor! = nil
//            var dominantSaturation: CGFloat = -1
//            
//            for x in 0 ..< Int(imageData.bounds.width) {
//                for y in 0 ..< Int(imageData.bounds.height) {
//                    let c = imageData.colourAt(x, y: y)
//                    let (hue, saturation, brightness, alpha) = c.getHSBA()
//                    let scaledSaturation = saturation * brightness * alpha
//                    if result == nil || scaledSaturation > dominantSaturation {
//                        result = c.withAlphaComponent(1)
//                        dominantSaturation = scaledSaturation
//                    }
//                }
//            }
//            
//            return result
//        }()
//        
//        init(icon: IconTypeEnum, size: CGSize, image: UIImage) {
//            self.icon = icon
//            self.size = size
//            self.image = image
//            self.texture = SKTexture(image: image)
//        }
//    }
//    fileprivate static var cache : [CacheItem] = []
//    
//    // Threshold, in pixels, to consider the requested size to be "close enough" to re-use a cached size
//    static let sizeTolerance: CGFloat = 4
//    
//    fileprivate static func getCacheItem(_ icon: IconTypeEnum, size: CGSize, maintainAspectRatio: Bool) -> CacheItem? {
//        if let originalImage = originalImages[icon] {
//            
//            // Calculate the target size
//            let actualSize : CGSize
//            if maintainAspectRatio {
//                let scaleFactor = min(size.width / originalImage.size.width, size.height / originalImage.size.height)
//                actualSize = originalImage.size * scaleFactor
//            }
//            else {
//                actualSize = size
//            }
//            
//            // Search in the cache
//            for item in cache {
//                let sizeDiff = max(abs(item.size.width - actualSize.width), abs(item.size.height - actualSize.height))
//                if item.icon == icon && sizeDiff <= sizeTolerance {
//                    return item
//                }
//            }
//            
//            // Not found in the cache, so create it
////            print("getCacheItem creating \(actualSize)")
//            let scaledImage = ImageUtils.getScaledImage(originalImage, size: actualSize)
//            let newItem = CacheItem(icon: icon, size: actualSize, image: scaledImage)
//            cache.append(newItem)
////            print("  cache now has \(cache.count) items")
//            return newItem
//        }
//        else {
//            return nil
//        }
//    }
//    
//    static func getScaledTexture(_ icon: IconTypeEnum, size: CGSize, maintainAspectRatio: Bool) -> SKTexture! {
//        return getCacheItem(icon, size: size, maintainAspectRatio: maintainAspectRatio)?.texture
//    }
//    
//    static func getScaledImage(_ icon: IconTypeEnum, size: CGSize, maintainAspectRatio: Bool) -> UIImage! {
//        return getCacheItem(icon, size: size, maintainAspectRatio: maintainAspectRatio)?.image
//    }
//    
//    static func getDominantColour(_ icon: IconTypeEnum, size: CGSize, maintainAspectRatio: Bool) -> UIColor! {
//        return getCacheItem(icon, size: size, maintainAspectRatio: maintainAspectRatio)?.dominantColour
//    }
//    
//    static func clearCache() {
//        cache.removeAll()
//    }
//}
