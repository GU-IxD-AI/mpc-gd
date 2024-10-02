//
//  HKResizeableImageNode.swift
//  HUDKitDemo
//
//  Created by Rob Saunders on 8/10/16.
//  Copyright © 2016 Saunders, Rob. All rights reserved.
//

import SpriteKit

// TODO: Consider using a different class name, e.g.: HKImage, and making this a component
class HKImage : HKComponent {
    fileprivate var _dilateNode : SKSpriteNode! = nil
    var imageNode : SKSpriteNode
    
    var anchorPoint : CGPoint {
        get { return imageNode.anchorPoint }
        set(newAnchorPoint) { imageNode.anchorPoint = newAnchorPoint }
    }
    
    var colorBlendFactor : CGFloat {
        get { return imageNode.colorBlendFactor }
        set(newColorBlendFactor) { imageNode.colorBlendFactor = newColorBlendFactor }
    }
    
    var color : UIColor {
        get { return imageNode.color }
        set(newColor) { imageNode.color = newColor }
    }
    
    fileprivate var _size : CGSize
    var size : CGSize {
        get {
            return _size
        }
        set(newSize) {
            _size = newSize
            imageNode.xScale = _size.width / imageNode.texture!.size().width
            imageNode.yScale = _size.height / imageNode.texture!.size().height
            if _dilateNode != nil {
                _dilateNode.xScale = _size.width / imageNode.texture!.size().width
                _dilateNode.yScale = _size.height / imageNode.texture!.size().height
            }
        }
        
    }
    
    var width: CGFloat {
        get { return size.width }
        set { size.width = newValue }
    }
    
    var height: CGFloat {
        get { return size.height }
        set { size.height = newValue }
    }

    init(image: UIImage, tapRect: CGRect, tapAnchor: CGPoint) {
        let tapColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.001)
        _size = image.size
        /// Pete's visual debugging
        //let tapColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        //_size = tapRect.size
        _dilateNode = SKSpriteNode(color: tapColor, size: tapRect.size)
        _dilateNode.position = tapRect.origin
        _dilateNode.anchorPoint = tapAnchor
        _dilateNode.zPosition -= 1
        imageNode = SKSpriteNode(texture: SKTexture(image: image))
        imageNode.centerRect =
            CGRect(x: image.capInsets.left / image.size.width,
                   y: image.capInsets.top / image.size.height,
                   width: 1.0 - (image.capInsets.left + image.capInsets.right) / image.size.width,
                   height: 1.0 - (image.capInsets.top + image.capInsets.bottom) / image.size.height)
        imageNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageNode.position = CGPoint.zero
        super.init()
        _dilateNode.addChild(imageNode)
        addChild(_dilateNode)
        isUserInteractionEnabled = false
    }
    
    init(image: UIImage, dilateSize: CGSize, dilateAnchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        let tapSize = CGSize(width: image.size.width * dilateSize.width, height: image.size.height * dilateSize.height)
        //let tapColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.001)
        _size = image.size
        /// Pete's visual debugging
        let tapColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        _size = tapSize
        _dilateNode = SKSpriteNode(color: tapColor, size: tapSize)
        _dilateNode.anchorPoint = dilateAnchor
        _dilateNode.zPosition -= 1
        imageNode = SKSpriteNode(texture: SKTexture(image: image))
        imageNode.centerRect =
            CGRect(x: image.capInsets.left / image.size.width,
                   y: image.capInsets.top / image.size.height,
                   width: 1.0 - (image.capInsets.left + image.capInsets.right) / image.size.width,
                   height: 1.0 - (image.capInsets.top + image.capInsets.bottom) / image.size.height)
        imageNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageNode.position = CGPoint.zero
        super.init()
        _dilateNode.addChild(imageNode)
        addChild(_dilateNode)
        isUserInteractionEnabled = false
    }
    
    init(image: UIImage) {
        _size = image.size
        imageNode = SKSpriteNode(texture: SKTexture(image: image))
        imageNode.centerRect =
            CGRect(x: image.capInsets.left / image.size.width,
                   y: image.capInsets.top / image.size.height,
                   width: 1.0 - (image.capInsets.left + image.capInsets.right) / image.size.width,
                   height: 1.0 - (image.capInsets.top + image.capInsets.bottom) / image.size.height)
        imageNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageNode.position = CGPoint.zero
        super.init()
        addChild(imageNode)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Fatal Error: init(coder) not implemented!")
    }
}
