//
//  HKEasing.swift
//  HUDKitDemo
//
//  Created by Saunders, Rob on 19/10/2016.
//  Copyright © 2016 Saunders, Rob. All rights reserved.
//

import Foundation
import SpriteKit

public typealias HKEasingFunction = (CGFloat)->CGFloat

public func quad(_ x:CGFloat) -> CGFloat { return x * x }
public func cubic(_ x:CGFloat) -> CGFloat { return x * x * x }
public func quart(_ x:CGFloat) -> CGFloat { return x * x * x * x }
public func quint(_ x:CGFloat) -> CGFloat { return x * x * x * x * x }
public func back(_ x:CGFloat) -> CGFloat { return x * x * x - x * sin(x * CGFloat.pi) }
public func bounce(_ x:CGFloat) -> CGFloat {
    if (x < 4/11.0) {
        return (121 * x * x)/16.0
    } else if (x < 8/11.0) {
        return (363/40.0 * x * x) - (99/10.0 * x) + 17/5.0
    } else if(x < 9/10.0) {
        return (4356/361.0 * x * x) - (35442/1805.0 * x) + 16061/1805.0
    } else {
        return (54/5.0 * x * x) - (513/25.0 * x) + 268/25.0
    }
}

public func LinearInterpolation(_ x:CGFloat) -> CGFloat { return x }
public func  QuadraticEaseIn(_ x:CGFloat) -> CGFloat { return quad(x) }
public func QuadraticEaseOut(_ x:CGFloat) -> CGFloat { return 1 - quad(1 - x) }
public func QuadraticEaseInOut(_ x:CGFloat) -> CGFloat { return (x < 0.5) ? 0.5 * QuadraticEaseIn(2 * x) : 0.5 * QuadraticEaseOut((2 * x) - 1) + 0.5 }

// y = x^3
public func CubicEaseIn(_ x:CGFloat) -> CGFloat { return cubic(x) }
// y = (x - 1)^3 + 1
public func CubicEaseOut(_ x:CGFloat) -> CGFloat { return cubic(x - 1) + 1 }
public func CubicEaseInOut(_ x:CGFloat) -> CGFloat { return (x < 0.5) ? 0.5 * CubicEaseIn(2 * x) : 0.5 * CubicEaseOut((2 * x) - 1) + 0.5 }

// y = x^4
public func QuarticEaseIn(_ x:CGFloat) -> CGFloat { return quart(x) }
// y = 1 - (x - 1)^4
public func QuarticEaseOut(_ x:CGFloat) -> CGFloat { return 1 - quart(x - 1) }
public func QuarticEaseInOut(_ x:CGFloat) -> CGFloat { return (x < 0.5) ? 0.5 * QuarticEaseIn(2 * x) : 0.5 * QuarticEaseOut((2 * x) - 1) + 0.5 }

// y = x^5
public func QuinticEaseIn(_ x:CGFloat) -> CGFloat { return quint(x) }
// y = (x - 1)^5 + 1
public func QuinticEaseOut(_ x:CGFloat) -> CGFloat { return quint(x - 1) + 1 }
public func QuinticEaseInOut(_ x:CGFloat) -> CGFloat { return (x < 0.5) ? 0.5 * QuinticEaseIn(2 * x) : 0.5 * QuinticEaseOut((2 * x) - 1) + 0.5 }

// y = sin(2 * PI * (x-1)) + 1
public func SineEaseIn(_ x:CGFloat) -> CGFloat { return sin((CGFloat.pi / 2) * (x - 1)) + 1 }
// y = sin(2 * PI * x)
public func SineEaseOut(_ x:CGFloat) -> CGFloat { return sin((CGFloat.pi / 2) * x) }
// y = (1 - cos(PI * x)) / 2
public func SineEaseInOut(_ x:CGFloat) -> CGFloat { return 0.5 * (1 - cos(CGFloat.pi * x)) }

// Shifted quadrant IV of unit circle
public func CircularEaseIn(_ x:CGFloat) -> CGFloat { return 1 - sqrt(1 - (x * x)) }
// Shifted quadrant II of unit circle
public func CircularEaseOut(_ x:CGFloat) -> CGFloat { return sqrt((2 - x) * x) }
public func CircularEaseInOut(_ x:CGFloat) -> CGFloat { return (x < 0.5) ? 0.5 * CircularEaseIn(2 * x) : 0.5 * CircularEaseOut((2 * x) - 1) + 0.5 }

// y = 2^(10(x - 1))
public func ExponentialEaseIn(_ x:CGFloat) -> CGFloat { return (x == 0) ? x : pow(2, 10 * (x - 1)) }
// y = -2^(-10x) + 1
public func ExponentialEaseOut(_ x:CGFloat) -> CGFloat { return (x == 1) ? x : 1 - pow(2, -10 * x) }
public func ExponentialEaseInOut(_ x:CGFloat) -> CGFloat { return (x < 0.5) ? 0.5 * ExponentialEaseIn(2 * x) : 0.5 * ExponentialEaseOut((2 * x) - 1) + 0.5 }

// y = sin(13pi/2*x) * pow(2, 10 * (x - 1))
public func ElasticEaseIn(_ x:CGFloat) -> CGFloat { return sin(13 * (CGFloat.pi / 2) * x) * pow(2, 10.0 * (x - 1.0)) }
// y = sin(-13pi/2*(x + 1)) * pow(2, -10x) + 1
public func ElasticEaseOut(_ x:CGFloat) -> CGFloat { return sin(-13 * (CGFloat.pi / 2) * (x + 1)) * pow(2, -10 * x) + 1 }
public func ElasticEaseInOut(_ x:CGFloat)->CGFloat { return (x < 0.5) ? 0.5 * ElasticEaseIn(2 * x) : 0.5 * ElasticEaseOut((2 * x) - 1) + 0.5 }

// y = x^3-x*sin(x*pi)
public func BackEaseIn(_ x:CGFloat) -> CGFloat { return back(x) }
// y = 1-((1-x)^3-(1-x)*sin((1-x)*pi))
public func BackEaseOut(_ x:CGFloat) -> CGFloat { return 1 - back(1 - x) }
public func BackEaseInOut(_ x:CGFloat) -> CGFloat { return (x < 0.5) ? 0.5 * BackEaseIn(2 * x) : 0.5 * BackEaseOut((2 * x) - 1) + 0.5 }

public func BounceEaseIn(_ x:CGFloat) -> CGFloat { return 1 - bounce(1 - x) }
public func BounceEaseOut(_ x:CGFloat) -> CGFloat { return bounce(x) }
public func BounceEaseInOut(_ x:CGFloat) -> CGFloat { return (x < 0.5) ? 0.5 * BounceEaseIn(2 * x) : 0.5 * BounceEaseOut((2 * x) - 1) + 0.5 }

open class HKEasing {
    // !!!ACHTUNG!!!! Ask pete about Swift 4 @objc inference as to why this got changed
    static func ease_FIXME(_ keyPath:String, to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        var from: CGFloat!
        let action = SKAction.customAction(withDuration: duration, actionBlock: {
            (node:SKNode, elapsedTime:CGFloat) in
            if from == nil { from = node.value(forKeyPath: keyPath) as! CGFloat }
            let currentTime = easingFunction(CGFloat(elapsedTime) / CGFloat(duration))
            let currentValue:CGFloat = from + CGFloat(currentTime) * (to - from)
            node.setValue(currentValue, forKeyPath: keyPath)
        })
        return action
    }

    // Swift 4.0 @objc inference - workaround fix for SKNode ONLY
    enum EaseParam: Int{
        // Position
        case x
        case y
        // Scale
        case xScale
        case yScale
        // Rotation
        case zRotation
        // Misc
        case alpha
    }
    
    static func get_sknode_param(_ node: SKNode, _ param: EaseParam) -> CGFloat {
        switch param {
        case .x: return node.x
        case .y: return node.y
        case .xScale: return node.xScale
        case .yScale: return node.yScale
        case .zRotation: return node.zRotation
        case .alpha: return node.alpha
        }
    }
    
    static func set_sknode_param(_ node: SKNode, _ param: EaseParam, _ value: CGFloat) {
        switch param {
        case .x: node.x = value
        case .y: node.y = value
        case .xScale: node.xScale = value
        case .yScale: node.yScale = value
        case .zRotation: node.zRotation = value
        case .alpha: node.alpha = value
        }
    }
    
    static func ease(_ param:EaseParam, to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        var from = CGFloat.greatestFiniteMagnitude
        let action = SKAction.customAction(withDuration: duration, actionBlock: {
            (node:SKNode, elapsedTime:CGFloat) in
            if from == CGFloat.greatestFiniteMagnitude { from = get_sknode_param(node, param) }
            let currentTime = easingFunction(CGFloat(elapsedTime) / CGFloat(duration))
            set_sknode_param(node, param, from + CGFloat(currentTime) * (to - from))
        })
        return action
    }
    
    static func ease(_ param:EaseParam, by:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        var from = CGFloat.greatestFiniteMagnitude
        let action = SKAction.customAction(withDuration: duration, actionBlock: {
            (node:SKNode, elapsedTime:CGFloat) in
            if from == CGFloat.greatestFiniteMagnitude { from = get_sknode_param(node, param) }
            let currentTime = easingFunction(CGFloat(elapsedTime) / CGFloat(duration))
            set_sknode_param(node, param, from + CGFloat(currentTime) * by)
        })
        return action
    }
    
    static func moveXTo(_ x:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.x, to:x, duration:duration, easingFunction:easingFunction)
    }
    
    static func moveYTo(_ y:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.y, to:y, duration:duration, easingFunction:easingFunction)
    }
    
    static func moveTo(x:CGFloat, y:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return SKAction.group([
            moveXTo(x, duration:duration, easingFunction:easingFunction),
            moveYTo(y, duration:duration, easingFunction:easingFunction)
            ])
    }
    
    static func moveTo(_ to:CGPoint, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return moveTo(x:to.x, y:to.y, duration:duration, easingFunction:easingFunction)
    }
    
    static func moveXBy(_ x:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.x, by:x, duration:duration, easingFunction:easingFunction)
    }
    
    static func moveYBy(_ y:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.y, by:y, duration:duration, easingFunction:easingFunction)
    }
    
    static func moveBy(x:CGFloat, y:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return SKAction.group([
            moveXBy(x, duration:duration, easingFunction:easingFunction),
            moveYBy(y, duration:duration, easingFunction:easingFunction)
            ])
    }
    
    static func moveBy(_ by:CGPoint, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return moveBy(x:by.x, y:by.y, duration:duration, easingFunction:easingFunction)
    }
    
    static func scaleXTo(_ to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.xScale, to:to, duration:duration, easingFunction:easingFunction)
    }
    
    static func scaleYTo(_ to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.yScale, to:to, duration:duration, easingFunction:easingFunction)
    }
    
    static func scaleTo(x:CGFloat, y:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return SKAction.group([
            scaleXTo(x, duration:duration, easingFunction:easingFunction),
            scaleYTo(y, duration:duration, easingFunction:easingFunction)
            ])
    }
    
    static func scaleTo(_ to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return scaleTo(x:to, y:to, duration:duration, easingFunction:easingFunction)
    }
    
    static func scaleXBy(_ by:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.xScale, by:by, duration:duration, easingFunction:easingFunction)
    }
    
    static func scaleYBy(_ by:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.yScale, by:by, duration:duration, easingFunction:easingFunction)
    }
    
    static func scaleBy(x:CGFloat, y:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return SKAction.group([
            scaleXBy(x, duration:duration, easingFunction:easingFunction),
            scaleYBy(y, duration:duration, easingFunction:easingFunction)
            ])
    }
    
    static func scaleBy(_ by:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return scaleBy(x:by, y:by, duration:duration, easingFunction:easingFunction)
    }
    
    static func rotateTo(_ to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.zRotation, to: to, duration:duration, easingFunction:easingFunction)
    }
    
    static func rotateBy(_ by:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.zRotation, by: by, duration:duration, easingFunction:easingFunction)
    }
    
    static func fadeTo(_ to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.alpha, to: to, duration:duration, easingFunction:easingFunction)
    }

    static func fadeBy(_ by:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
        return ease(.alpha, by: by, duration:duration, easingFunction:easingFunction)
    }

// !!!ACHTUNG!!!! Ask pete about Swift 4 @objc inference as to why this got changed

//    open class func resizeWidthTo(_ to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
//        return ease("width", to:to, duration:duration, easingFunction:easingFunction)
//    }
//
//    open class func resizeHeightTo(_ to:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
//        return ease("height", to:to, duration:duration, easingFunction:easingFunction)
//    }
//
//    open class func resizeTo(width:CGFloat, height:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
//        return SKAction.group([
//            resizeWidthTo(width, duration:duration, easingFunction:easingFunction),
//            resizeHeightTo(height, duration:duration, easingFunction:easingFunction)
//            ])
//    }
//
//    open class func resizeTo(size:CGSize, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
//        return resizeTo(width:size.width, height:size.height, duration:duration, easingFunction:easingFunction)
//    }
//
//    open class func resizeWidthBy(_ by:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
//        return ease("width", by:by, duration:duration, easingFunction:easingFunction)
//    }
//
//    open class func resizeHeightBy(_ by:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
//        return ease("height", by:by, duration:duration, easingFunction:easingFunction)
//    }
//
//    open class func resizeBy(width:CGFloat, height:CGFloat, duration:TimeInterval, easingFunction:@escaping HKEasingFunction) -> SKAction {
//        return SKAction.group([
//            resizeWidthBy(width, duration:duration, easingFunction:easingFunction),
//            resizeHeightBy(height, duration:duration, easingFunction:easingFunction)
//            ])
//    }
}

// MARK: SKNode extension
extension SKNode {
    var x: CGFloat {
        get { return position.x }
        set { position.x = newValue }
    }
    var y: CGFloat {
        get { return position.y }
        set { position.y = newValue }
    }
}

// MARK: SKSpriteNode extension
extension SKSpriteNode {
    var width: CGFloat {
        get { return size.width }
        set { size.width = newValue }
    }
    var height: CGFloat {
        get { return size.height }
        set { size.height = newValue }
    }
}
