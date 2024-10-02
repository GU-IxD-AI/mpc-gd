//
//  MainScene.swift
//  Engine
//
//  Created by Simon Colton on 12/09/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

#if os(iOS)
    import CoreMotion
#endif

class BaseScene: SKScene{
    
    var touchDownPoint: CGPoint! = nil
    
    var previousTouchPoint: CGPoint! = nil
    
    var currentTouchPoint: CGPoint! = nil

    var ignoreUser = false
    
    var dragType: DragType! = nil
    
    var isDraggingHorizontally = false
    
    var isDraggingVertically = false
    
    override init() {
        super.init()
        print("[\(Unmanaged.passUnretained(self).toOpaque())] Creating \(type(of: self))()")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        print("[\(Unmanaged.passUnretained(self).toOpaque())] Creating \(type(of: self))(size: \(size))")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("[\(Unmanaged.passUnretained(self).toOpaque())] Creating \(type(of: self))(coder: \(coder))")
    }
    
    deinit {
        print("[\(Unmanaged.passUnretained(self).toOpaque())] Destroying \(type(of: self))")
    }
    
    override func didMove(to view: SKView) {
       // view.multipleTouchEnabled = true
        
        let pauseGesture = UISwipeGestureRecognizer(target: self, action: #selector(BaseScene.onPauseGesture))
        pauseGesture.direction = UISwipeGestureRecognizerDirection.down
        pauseGesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(pauseGesture)
        //BaseScene.enableGyro()
    }
    
    static var motionManager: CMMotionManager! = nil
    static var gyroEnabled = false
    static var deviceShakeCount = 0

    static func enableGyro() {
        if BaseScene.gyroEnabled {
            return
        }
        if BaseScene.motionManager == nil {
            BaseScene.motionManager = CMMotionManager()
        }
        BaseScene.motionManager.startGyroUpdates()
        BaseScene.deviceShakeCount = 0
        BaseScene.gyroEnabled = true
    }
    
    static func disableGyro() {
        BaseScene.deviceShakeCount = 0
        if BaseScene.gyroEnabled {
            BaseScene.motionManager.stopGyroUpdates()
            BaseScene.gyroEnabled = false
        }
    }
    
    #if os(iOS)
    
        final override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if touches.count > 1{
                return
            }
            if !ignoreUser{
                touchDownPoint = touches.first!.location(in: view)
                touchDownPoint = convertPoint(fromView: touchDownPoint)
                previousTouchPoint = touchDownPoint
                touchesBegan(touchDownPoint)
            }
        }
        
        final override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if touches.count > 1{
                return
            }
            if !ignoreUser{
                currentTouchPoint = touches.first!.location(in: view)
                currentTouchPoint = convertPoint(fromView: currentTouchPoint)
                if previousTouchPoint != nil{
                    let dragVector = CGVector(dx: currentTouchPoint.x - previousTouchPoint.x, dy: currentTouchPoint.y - previousTouchPoint.y)
                    if dragType == DragType.xAndYStraight && !isDraggingHorizontally && !isDraggingVertically{
                        if abs(dragVector.dx) > abs(dragVector.dy){
                            isDraggingHorizontally = true
                        }
                        else if abs(dragVector.dx) < abs(dragVector.dy){
                            isDraggingVertically = true
                        }
                    }
                    var clampedDragVector = CGVector(dx: dragVector.dx, dy: dragVector.dy)
                    if isDraggingVertically{
                        clampedDragVector.dx = 0
                    }
                    else if isDraggingHorizontally{
                        clampedDragVector.dy = 0
                    }
                    touchesDragged(currentTouchPoint, clampedDragVector: clampedDragVector, dragVector: dragVector)
                }
                previousTouchPoint = touches.first!.location(in: view)
                previousTouchPoint = convertPoint(fromView: previousTouchPoint)
            }
        }
        
        final override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            if touches.count > 1{
                return
            }
            if !ignoreUser{
                if previousTouchPoint != nil{
                    let touch = touches.first!
                    currentTouchPoint = touch.location(in: view)
                    currentTouchPoint = convertPoint(fromView: currentTouchPoint)

                    if touch.tapCount == 1 && touch.phase == UITouchPhase.ended{
                        tapAt(currentTouchPoint)
                    }
                    else if touch.tapCount == 2{
                        doubleTapAt(currentTouchPoint)
                    }
                    
                    touchesEnded(currentTouchPoint)
                }
                touchDownPoint = nil
                previousTouchPoint = nil
                currentTouchPoint = nil
                isDraggingHorizontally = false
                isDraggingVertically = false
            }
        }
    
    #elseif os(OSX)
    
        final override func mouseDown(theEvent: NSEvent) {
            if !ignoreUser{
                touchDownPoint = theEvent.locationInWindow
                touchDownPoint = convertPointFromView(touchDownPoint)
                previousTouchPoint = touchDownPoint
                touchesBegan(touchDownPoint)
            }
        }
        
        final override func mouseDragged(theEvent: NSEvent) {
            if !ignoreUser{
                currentTouchPoint = theEvent.locationInWindow
                currentTouchPoint = convertPointFromView(currentTouchPoint)
                if previousTouchPoint != nil{
                    let dragVector = CGVectorMake(currentTouchPoint.x - previousTouchPoint.x, currentTouchPoint.y - previousTouchPoint.y)
                    if dragType == DragType.XAndYStraight && !isDraggingHorizontally && !isDraggingVertically{
                        if abs(dragVector.dx) > abs(dragVector.dy){
                            isDraggingHorizontally = true
                        }
                        else{
                            isDraggingVertically = true
                        }
                    }
                    var clampedDragVector = CGVectorMake(dragVector.dx, dragVector.dy)
                    if isDraggingVertically{
                        clampedDragVector.dx = 0
                    }
                    else if isDraggingHorizontally{
                        clampedDragVector.dy = 0
                    }
                    touchesDragged(currentTouchPoint, clampedDragVector: clampedDragVector, dragVector: dragVector)
                }
                previousTouchPoint = theEvent.locationInWindow
                previousTouchPoint = convertPointFromView(previousTouchPoint)
            }
        }
        
        final override func mouseUp(theEvent: NSEvent) {
            if !ignoreUser{
                if previousTouchPoint != nil{
                    currentTouchPoint = theEvent.locationInWindow
                    currentTouchPoint = convertPointFromView(currentTouchPoint)
                    
                    if theEvent.clickCount == 1 {
                        tapAt(currentTouchPoint)
                    }
                    else if theEvent.clickCount == 2 {
                        doubleTapAt(currentTouchPoint)
                    }
                    
                    touchesEnded(currentTouchPoint)
                }
                touchDownPoint = nil
                previousTouchPoint = nil
                currentTouchPoint = nil
                isDraggingHorizontally = false
                isDraggingVertically = false
            }
        }
    
    #endif
    
    func handleGyroMotion(_ data: CMGyroData){
        if abs(data.rotationRate.x) > 15{
            deviceShaken()
        }
    }
    
    func setBackground(_ image: UIImage) -> SKSpriteNode{
        let bgTexture = SKTexture(cgImage: image.cgImage!)
        let bg = SKSpriteNode(texture: bgTexture, size: (view?.frame.size)!)
        bg.position = CGPoint(x: (view?.frame.size.width)! * 0.5, y: (view?.frame.size.height)! * 0.5)
        bg.zPosition = -1 // Put it at the back
        addChild(bg)
        return bg
    }
    
    func crossFadeToScene(_ scene: BaseScene, duration: TimeInterval){
        self.view!.isPaused = false
        self.view!.presentScene(scene, transition: SKTransition.crossFade(withDuration: duration))
    }
    
    func switchToScene(_ scene: BaseScene){
        self.view?.presentScene(scene)
    }
    
    // FUNCTIONS TO OVERRIDE //
    
    func touchesBegan(_ touchPoint: CGPoint){

    }
    
    func touchesDragged(_ touchPoint: CGPoint, clampedDragVector: CGVector, dragVector: CGVector){
        
    }
    
    func tapAt(_ touchPoint: CGPoint){
        
    }
    
    func doubleTapAt(_ touchPoint: CGPoint){
        
    }
    
    func touchesEnded(_ touchPoint: CGPoint){

    }
    
    func deviceShaken(){
    }
    
    func deviceRotated(_ data: CMGyroData){
        
    }
    
    @objc func onPauseGesture() {
        
    }
    
}
