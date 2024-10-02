//
//  SKNodeExtension.swift
//  Fask
//
//  Created by Simon Colton on 22/09/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKit

extension SKNode{
    
    func hasLiveComponentUnderTouch(_ touchPoint: CGPoint) -> Bool{
        for child in children{
            if child.hasLiveComponentUnderTouch(touchPoint){
                return true
            }
        }
        if alpha > 0 && !isHidden && isUserInteractionEnabled && contains(touchPoint){
            return true
        }
        return false
    }
    
    func turnOffUserInteraction(){
        isUserInteractionEnabled = false
        for child in children{
            child.turnOffUserInteraction()
        }
    }
    
    /*
    func isTopLiveComponentUnderTouch(touchPoint: CGPoint) -> Bool{
        for node in children{
            if node.isTopLiveComponentUnderTouch(touchPoint){
                return false
            }
        }
        if !hidden && userInteractionEnabled && containsPoint(touchPoint){
            return true
        }
        return false
    }
 */

    @objc func containsScenePoint(_ point: CGPoint) -> Bool {
        let localPoint: CGPoint
        if parent != nil && scene != nil {
            localPoint = parent!.convert(point, from: scene!)
        }
        else {
            localPoint = point
        }
        
        return frame.contains(localPoint)
    }
    
    func getLocalPoint(_ point: CGPoint) -> CGPoint {
        let localPoint: CGPoint
        if parent != nil && scene != nil {
            localPoint = parent!.convert(point, from: scene!)
        }
        else {
            localPoint = point
        }
        return localPoint
    }
    
    func isActive() -> Bool{
        for child in children{
            if child.isActive(){
                return true
            }
        }
        if hasActions(){
            return true
        }
        if self is SKFieldNode{
            if (self as! SKFieldNode).isEnabled == true{
                return true
            }
        }
        
        if physicsBody != nil{
            if !physicsBody!.velocity.approxEquals(CGVector.zero) {
                return true
            }
        }
        
        return false
    }

    func setPositionTo(_ x: CGFloat, _ y: CGFloat) {
        setPositionTo(CGPoint(x: x, y: y))
    }
    
    func setPositionTo(_ position: CGPoint){
        if !position.approxEquals(self.position) {
            self.position = position
        }
    }
    
    func setZPositionTo(_ zPosition: CGFloat){
        if !zPosition.approxEquals(self.zPosition){
            self.zPosition = zPosition
        }
    }
    
    func setAngleTo(radians: CGFloat){
        if !radians.approxEquals(self.zRotation) {
            self.zRotation = radians
        }
    }
    
    func setAngleTo(degrees: CGFloat) {
        setAngleTo(radians: MathsUtils.degreesToRadians(degrees))
    }
    
    func setVelocityTo(_ velocity: CGVector){
        if self.physicsBody != nil && !velocity.approxEquals(self.physicsBody!.velocity) {
            self.physicsBody!.velocity = velocity
        }
    }
    
    func performAction(_ action: SKAction){
        run(action)
    }
    
    func performAction(_ action: SKAction, completion: @escaping () -> ()){
        run(action, completion: completion)
    }
    
    func setAlphaValue(_ alpha: CGFloat){
        if !alpha.approxEquals(self.alpha) {
            self.alpha = alpha
        }
    }
    
    func setPhysicsCategories(myCategory: BitMask, collideWith: BitMask) {
        setPhysicsCategories(myCategory: myCategory, collideWith: collideWith, notifyOnContactWith: BitMask.zero)
    }
    
    func setPhysicsCategories(myCategory: BitMask, collideWith: BitMask, notifyOnContactWith: BitMask) {
        assert(myCategory.isSingleton, "myCategory must be a singleton")
        self.physicsBody!.categoryBitMask = myCategory.mask
        self.physicsBody!.collisionBitMask = collideWith.mask
        self.physicsBody!.contactTestBitMask = notifyOnContactWith.mask
    }
}
