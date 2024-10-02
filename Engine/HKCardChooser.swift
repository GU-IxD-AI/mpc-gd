//
//  HKCardChooser.swift
//  HUDKitDemo
//
//  Created by Simon Colton on 06/12/2016.
//  Copyright © 2016 Saunders, Rob. All rights reserved.
//

import Foundation
import SpriteKit

class HKCardChooser: HKComponent, HKAnimatedComponent{
    
    var selectedCardIDs: [String] = []{
        willSet(newSelectedCardIDs){
            for pos in 0..<numCards{
                isSelected[pos] = newSelectedCardIDs.contains(cardIDs[pos])
            }
        }
    }
    
    // Code to call
    
    var nonSelectingTapCode: (() -> ())! = nil
    
    var tapCode: (() -> ())! = nil
    
    var onDragCode: (() -> ())! = nil
    
    var onScrollStartCode: (() -> ())! = nil

    var onScrollEndCode: (() -> ())! = nil
    
    var centralValueChangedCode: (() -> ())! = nil
    
    // Juicing parameters
    
    fileprivate let outOfZoneStickiness = CGFloat(4) // How sticky the dragging the tray out of the normal zone is
    
    fileprivate let moveBackDuration = CGFloat(0.4) // How long in seconds the bounce back scroll action takes
    
    fileprivate let normalScrollDuration = CGFloat(0.75) // How long in seconds a normal scroll action takes
    
    fileprivate let scrollMovementMultiplier = CGFloat(10) // How far a normal scroll should multiply the drag
    
    fileprivate let maxScrollDistance = CGFloat(150) // The furthest distance a scroll animation can go
    
    fileprivate let maxDragDistance = CGFloat(30) // The maximum the user can drag the tray in one go
    
    // Animation actions
    
    fileprivate let fadeInAction = HKEasing.fadeTo(1.0, duration: 0.01, easingFunction: LinearInterpolation)
    
    fileprivate let fadeOutAction = SKAction.sequence([SKAction.wait(forDuration: 0.1), HKEasing.fadeTo(0.0, duration: 0.2, easingFunction: LinearInterpolation)])
    
    fileprivate var scaleAction = SKAction.sequence([HKEasing.scaleTo(1.15, duration: 0.1, easingFunction: BackEaseOut), HKEasing.scaleTo(1.0, duration: 0.1, easingFunction: BackEaseOut), SKAction.wait(forDuration: 0.1)])

    fileprivate let fadeIn = HKEasing.fadeTo(1.0, duration: 0.1, easingFunction: LinearInterpolation)

    fileprivate let fadeOut = HKEasing.fadeTo(0.0, duration: 0.1, easingFunction: LinearInterpolation)
    
    // Selection variables
    
    internal var numCards = 0
    
    fileprivate var cardIDs: [String] = []
    
    internal var unselectedImages: [HKImage] = []
    
    internal var selectedImages: [HKImage] = []
    
    fileprivate var isSelected: [Bool] = []
    
    fileprivate var chooserType: ChooserType
    
    // SKNodes
    
    fileprivate var surroundNode: SKSpriteNode
    
    fileprivate var cropNode: SKCropNode
    
    var trayNode: SKSpriteNode
    
    fileprivate var scrollBarNode: SKSpriteNode!
    
    fileprivate var leftVerticalBarNode: HKImage
    
    fileprivate var rightVerticalBarNode: HKImage
    
    // Look and feel
    
    fileprivate var separatorWidth: CGFloat
    
    fileprivate var size: CGSize
    
    // Rectangles for events
    
    fileprivate var tapRect: CGRect
    
    fileprivate var unHiddenRect: CGRect
    
    // Variables for handling interaction and movement
    
    fileprivate var isAlreadyTapping = false
    
    fileprivate var trayIsMovingBack = false
    
    internal var trayWidth: CGFloat
    
    fileprivate var acknowledgeDrag = true
    
    fileprivate var timeOfLastMove: Date! = nil
    
    fileprivate var timeOfTouchesStart: Date! = nil
    
    fileprivate var touchDownPoint: CGPoint! = nil
    
    var canScroll: Bool
    
    fileprivate var maxScrollBarMovement: CGFloat! = nil
    
    internal var maxTrayMovement: CGFloat
    
    internal var leftMostTrayX: CGFloat
    
    internal var rightMostTrayX: CGFloat
    
    fileprivate var leftMostScrollBarX: CGFloat! = nil
    
    fileprivate var rightMostScrollBarX: CGFloat! = nil
    
    fileprivate var xMoves: [CGFloat] = []
    
    fileprivate var timeBetweenTaps: TimeInterval
    
    fileprivate var sizeRect: CGRect! = nil
    
    fileprivate var snapToCentre = false
    
    var centralValuePosition = 0
    
    var runUpdateCentralValueThread = false
    
    init(cardIDs: [String], size: CGSize, cardSize: CGSize! = nil, separatorWidth: CGFloat, separatorAtStart: Bool, unselectedImages: [UIImage], selectedImages: [UIImage], chooserType: ChooserType, verticalBarImage: UIImage, scrollBarImage: UIImage, scrollBarType: ScrollBarType, timeBetweenTaps: TimeInterval = TimeInterval(0.5), useCropNode: Bool = true, snapToCentre: Bool = false){
        
        // Copy in values
        
        self.cardIDs = cardIDs
        self.size = size
        self.separatorWidth = separatorWidth
        self.chooserType = chooserType
        self.timeBetweenTaps = timeBetweenTaps
        self.snapToCentre = snapToCentre
        numCards = unselectedImages.count
        sizeRect = CGRect(x: -size.width/2, y: 0, width: size.width, height: size.height)
        
        // Add the crop node
        
        cropNode = SKCropNode()
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        cropNode.maskNode = SKSpriteNode(texture: SKTexture(cgImage: image.cgImage!))
        
        // Set up the tray of images
        
        var xPos = -size.width/2
        if !unselectedImages.isEmpty{
            xPos += unselectedImages[0].size.width/2
        }
        if cardSize != nil{
            xPos = -size.width/2 + cardSize.width/2
        }
        trayWidth = 0
        if separatorAtStart{
            trayWidth = separatorWidth
            xPos += separatorWidth
        }
        trayNode = SKSpriteNode()
//        trayNode.color = UIColor.redColor()
        var cW = size.width/2
        if cardSize != nil{
            cW -= cardSize.width/2
        }
        if snapToCentre{
            xPos += cW
        }
        for pos in 0..<numCards{
            isSelected.append(false)
            let unselectedImage = HKImage(image: unselectedImages[pos])
            if cardSize != nil{
                unselectedImage.size = cardSize
            }
            unselectedImage.position = CGPoint(x: xPos, y: 0)
            self.unselectedImages.append(unselectedImage)
            trayNode.addChild(unselectedImage)
            if cardSize != nil{
                trayWidth = trayWidth + cardSize.width + separatorWidth
            }
            else{
                trayWidth = trayWidth + unselectedImages[pos].size.width + separatorWidth
            }
            let selectedImage = HKImage(image: selectedImages[pos])
            self.selectedImages.append(selectedImage)
            selectedImage.position = CGPoint(x: xPos, y: 0)
            trayNode.addChild(selectedImage)
            if cardSize != nil{
                unselectedImage.size = cardSize
                selectedImage.size = cardSize
                xPos += cardSize.width + separatorWidth
            }
            else{
                if pos < numCards - 1{
                    xPos += unselectedImages[pos].size.width/2 + separatorWidth + unselectedImages[pos + 1].size.width/2
                }
            }
        }
        trayWidth = trayWidth - separatorWidth
        
        if snapToCentre{
            trayWidth += size.width - cardSize.width
        }

        trayNode.size = CGSize(width: trayWidth, height: size.height)
        rightMostTrayX = 0
        maxTrayMovement = trayWidth - size.width
        leftMostTrayX = floor(-maxTrayMovement)
        canScroll = (trayWidth > size.width)// && scrollBarType != .None
        if snapToCentre{
            canScroll = true
        }
        
        tapRect = CGRect(x: -size.width/2 - 50, y: -size.height/2 - 50, width: size.width + 100, height: size.height + 100)
        unHiddenRect = CGRect(x: -size.width/2 - 50, y: -size.height/2, width: size.width + 100, height: size.height)
        
        // Set up the scroll bar
        
        if canScroll{
            scrollBarNode = SKSpriteNode(texture: SKTexture(image: scrollBarImage))
            let xPos = -size.width/2 + scrollBarImage.size.width/2
            if scrollBarType == .top{
                scrollBarNode.position = CGPoint(x: xPos, y: size.height/2 - scrollBarImage.size.height/2)
            }
            else if scrollBarType == .bottom{
                scrollBarNode.position = CGPoint(x: xPos, y: -size.height/2 + scrollBarImage.size.height/2)
            }
            leftMostScrollBarX = scrollBarNode.position.x
            rightMostScrollBarX = size.width/2 - scrollBarImage.size.width/2
            maxScrollBarMovement = rightMostScrollBarX - leftMostScrollBarX
            scrollBarNode.alpha = 0
        }
        
        // Set up vertical bars
        
        leftVerticalBarNode = HKImage(image: verticalBarImage)
        leftVerticalBarNode.position = CGPoint(x: -size.width/2, y: 0)
        rightVerticalBarNode = HKImage(image: verticalBarImage)
        rightVerticalBarNode.position = CGPoint(x: size.width/2, y: 0)

        // Set up the surround node
        surroundNode = SKSpriteNode()
        surroundNode.size = size * 1.4
        
        super.init()
        
        // Set up scene
        
        if useCropNode{
            addChild(cropNode)
        }
        addChild(leftVerticalBarNode)
        addChild(rightVerticalBarNode)
        
        if scrollBarNode != nil{
            addChild(scrollBarNode)
        }
        if useCropNode{
            cropNode.addChild(trayNode)
        }
        else{
            addChild(trayNode)
        }
        addChild(surroundNode)
        
        updateCardAlphas()
        setCardVisibilities()
        setVerticalBarVisibilities()
        leftVerticalBarNode.alpha = 0
    }
    
    func updateAfterValuesChanged() {
        var firstSelectedX: CGFloat! = nil
        for pos in 0..<numCards{
            if isSelected[pos]{
                firstSelectedX = selectedImages[pos].position.x
                break
            }
        }
        trayNode.removeAllActions()
        xMoves.removeAll()
        if firstSelectedX != nil && canScroll{
            var newPosition = -firstSelectedX
            newPosition = max(newPosition, leftMostTrayX)
            newPosition = min(newPosition, rightMostTrayX)
            trayNode.position.x = newPosition
        }
        else{
            trayNode.position.x = rightMostTrayX
        }
        
        if scrollBarNode != nil{
            scrollBarNode.removeAllActions()
            scrollBarNode.alpha = 0
        }
        setVerticalBarVisibilities()
        updateCardAlphas()
        setCardVisibilities()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if touches.count == 1{
            acknowledgeDrag = false
            if let touch = touches.first {
                if touch.tapCount <= 1{
                    self.runUpdateCentralValueThread = false
                    touchDownPoint = touch.location(in: self)
                    xMoves.removeAll()
                    timeOfLastMove = Date()
                    timeOfTouchesStart = Date()
                    if canScroll && !trayIsMovingBack{
                        trayNode.removeAllActions()
                        if scrollBarNode != nil{
                            scrollBarNode.removeAction(forKey: "Movement")
                        }
                    }
                    if trayNode.contains(touch.location(in: self)){
                        acknowledgeDrag = true
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if touches.count == 1{
            if let touch = touches.first {
                if canScroll && acknowledgeDrag && touch.tapCount <= 1{
                    let touchLocation = touch.location(in: self)
                    let previousTouchLocation = touch.previousLocation(in: self)
                    if tapRect.contains(touchLocation) && tapRect.contains(previousTouchLocation){
                        var dx = touchLocation.x - previousTouchLocation.x
                        if abs(dx) > maxDragDistance{
                            dx = dx < 0 ? -maxDragDistance : maxDragDistance
                        }
                        addXMove(dx)
                        if abs(dx) >= 1{
                            timeOfLastMove = Date()
                            let moveBy = stickyMovement(dx)
                            trayNode.position.x += moveBy
                            updateScrollBarPosition(dx)
                            if !trayIsOutOfCentralZone() && scrollBarNode != nil && scrollBarNode.alpha < 1{
                                fadeIn(scrollBarNode)
                            }
                            if trayIsOutOfCentralZone() && scrollBarNode != nil && scrollBarNode.alpha > 0{
                                fadeOut(scrollBarNode)
                            }
                            fadeVerticalBars()
                            setCardVisibilities()
                        }
                    }
                    else{
                        if scrollBarNode != nil && scrollBarNode.alpha > 0{
                            fadeOut(scrollBarNode)
                        }
                        if !trayIsMovingBack && trayIsOutOfCentralZone(){
                            let dx = touchLocation.x - touch.previousLocation(in: self).x
                            startTrayMovement(dx)
                        }
                    }
                    if onDragCode != nil{
                        onDragCode()
                    }
                    updateCentralValue()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if touches.count == 1{
            if let touch = touches.first {
                if touch.tapCount <= 1 && acknowledgeDrag{
                    let timeSinceLastMove = abs(timeOfLastMove.timeIntervalSinceNow)
                    var hasStartedMovement = false
                    let dx = getAverageOfXMoves()
                    if canScroll{
                        if (timeSinceLastMove < 0.075 && acknowledgeDrag && abs(dx) > 2) || (acknowledgeDrag && trayIsOutOfCentralZone()){
                            if scrollBarNode != nil{
                                fadeIn(scrollBarNode)
                            }
                            startTrayMovement(dx)
                            hasStartedMovement = true
                        }
                        else if scrollBarNode != nil{
                            fadeOut(scrollBarNode)
                        }
                    }
                    if timeOfTouchesStart != nil{
                        let timeSinceTouchesStart = abs(timeOfTouchesStart.timeIntervalSinceNow)
                        if !hasStartedMovement && !trayIsMovingBack && timeSinceTouchesStart < 0.25 && abs(dx) <= 2 {
                            let p = touch.location(in: self).x
                            if p > -size.width/2 && p < size.width/2{
                                trayNode.removeAllActions()
                                handleTap()
                                if scrollBarNode != nil{
                                    fadeOut(scrollBarNode)
                                }
                            }
                        }
                    }
                }
                acknowledgeDrag = false
            }
        }
    }
    
    fileprivate func addXMove(_ dx: CGFloat){
        xMoves.append(dx)
        if xMoves.count > 5{
            xMoves.removeFirst()
        }
    }
    
    fileprivate func getAverageOfXMoves() -> CGFloat{
        if xMoves.isEmpty{
            return CGFloat(1)
        }
        else{
            var av = CGFloat(0)
            for xMove in xMoves{
                av += xMove
            }
            return av/CGFloat(xMoves.count)
        }
    }
    
    fileprivate func setCardVisibilities(){
        for pos in 0..<numCards{
            let selectedImage = selectedImages[pos]
            let unselectedImage = unselectedImages[pos]
            let x = selectedImage.position.x + trayNode.position.x - selectedImage.size.width/2
            let rect = CGRect(x: x, y: -10, width: selectedImage.size.width, height: 20)
            if !selectedImage.isHidden && !rect.intersects(unHiddenRect){
                selectedImage.isHidden = true
                unselectedImage.isHidden = true
            }
            else{
                selectedImage.isHidden = false
                unselectedImage.isHidden = false
            }
        }
    }
    
    fileprivate func updateCardAlphas(){
        for pos in 0..<numCards{
            if isSelected[pos]{
                selectedImages[pos].alpha = 1
                unselectedImages[pos].alpha = 0
            }
            else{
                selectedImages[pos].alpha = 0
                unselectedImages[pos].alpha = 1
            }
        }
    }
    
    fileprivate func updateScrollBarPosition(_ dx: CGFloat){
        if scrollBarNode != nil{
            scrollBarNode.removeAction(forKey: "Movement")
            if dx > 0 && trayNode.position.x > rightMostTrayX{
                scrollBarNode.position.x = leftMostScrollBarX
            }
            else if dx < 0 && trayNode.position.x < leftMostTrayX{
                scrollBarNode.position.x = rightMostScrollBarX
            }
            else if dx != 0{
                let proportion = abs(trayNode.position.x)/maxTrayMovement
                var newScrollBarX = leftMostScrollBarX + (proportion * maxScrollBarMovement)
                newScrollBarX = min(rightMostScrollBarX, newScrollBarX)
                newScrollBarX = max(leftMostScrollBarX, newScrollBarX)
                scrollBarNode.position.x = newScrollBarX
            }
        }
    }
    
    fileprivate func trayIsOutOfCentralZone() -> Bool{
        if trayNode.position.x < leftMostTrayX || trayNode.position.x > rightMostTrayX{
            return true
        }
        return false
    }
    
    fileprivate func stickyMovement(_ dx: CGFloat) -> CGFloat{
        if dx < 0{
            return trayNode.position.x <= leftMostTrayX ? dx/outOfZoneStickiness : dx
        }
        else if dx > 0{
            return trayNode.position.x >= rightMostTrayX ? dx/outOfZoneStickiness : dx
        }
        return 0
    }
    
    fileprivate func getBackMovement(_ totalMovement: CGFloat) -> CGFloat!{
        if trayNode.position.x < leftMostTrayX{
            return leftMostTrayX - trayNode.position.x
        }
        else if trayNode.position.x > rightMostTrayX{
            return rightMostTrayX - trayNode.position.x
        }
        return nil
    }
    
    func constrainMovement(_ dx: CGFloat) -> CGFloat{
        if dx > 0{
            return min(rightMostTrayX - trayNode.position.x, dx)
        }
        else if dx < 0{
            return max(leftMostTrayX - trayNode.position.x, dx)
        }
        return 0
    }
    
    fileprivate func startTrayMovement(_ dx: CGFloat){
        trayNode.removeAllActions()
        var totalMovement = scrollMovementMultiplier * getAverageOfXMoves()
        if totalMovement > 0{
            totalMovement = min(maxScrollDistance, totalMovement)
        }
        else{
            totalMovement = max(-maxScrollDistance, totalMovement)
        }
        if abs(totalMovement) >= 1{
            for pos in 0..<numCards{
                selectedImages[pos].isHidden = false
                unselectedImages[pos].isHidden = false
            }
            if let backMovement = getBackMovement(totalMovement){
                if scrollBarNode != nil{
                    fadeOut(scrollBarNode)
                }
                let moveBackAction = HKEasing.moveXBy(backMovement, duration: TimeInterval(moveBackDuration), easingFunction: BackEaseOut)
                trayIsMovingBack = true
                runUpdateCentralValueThread = true
                startUpdateCentralValueThread()
                trayNode.run(moveBackAction, completion: {
                    self.trayNode.position.x = CGFloat(round(self.trayNode.position.x))
                    self.fadeVerticalBars()
                    self.setCardVisibilities()
                    self.trayIsMovingBack = false
                    self.updateCentralValue()
                    if self.onScrollEndCode != nil{
                        self.onScrollEndCode()
                    }
                    self.runUpdateCentralValueThread = false
                })
            }
            else {
                let movement = constrainMovement(totalMovement)
                if abs(movement) >= 1{
                    let duration = TimeInterval(normalScrollDuration * abs(movement)/abs(totalMovement))
                    var moveAction = HKEasing.moveXBy(movement, duration: duration, easingFunction: QuadraticEaseOut)
                    if movement != totalMovement{
                        moveAction = HKEasing.moveXBy(movement, duration: duration, easingFunction: BackEaseOut)
                    }
                    runUpdateCentralValueThread = true
                    startUpdateCentralValueThread()
                    trayNode.run(moveAction, completion: {
                        self.trayNode.position.x = CGFloat(round(self.trayNode.position.x))
                        self.fadeVerticalBars()
                        self.setCardVisibilities()
                        if self.scrollBarNode != nil{
                            self.fadeOut(self.scrollBarNode)
                        }
                        self.updateCentralValue()
                        if self.onScrollEndCode != nil{
                            self.onScrollEndCode()
                        }
                        self.runUpdateCentralValueThread = false
                    })
                    let newTrayX = trayNode.position.x + movement
                    let proportion = abs(newTrayX)/maxTrayMovement
                    let newScrollBarX = leftMostScrollBarX + (proportion * maxScrollBarMovement)
                    let scrollBarMoveAction = HKEasing.moveXTo(newScrollBarX, duration: duration, easingFunction: QuadraticEaseOut)
                    if scrollBarNode != nil{
                        scrollBarNode.run(scrollBarMoveAction, withKey: "Movement")
                    }
                }
            }
            if onScrollStartCode != nil{
                onScrollStartCode()
            }
        }
    }
    
    func startUpdateCentralValueThread(){
        if runUpdateCentralValueThread{
            trayNode.run(SKAction.wait(forDuration: 0.1), completion: {
                self.updateCentralValue()
                self.startUpdateCentralValueThread()
            })
        }
    }
    
    func updateCentralValue(){
        let newCentralValuePosition = getCentralValuePosition()
        if newCentralValuePosition != centralValuePosition{
            centralValuePosition = newCentralValuePosition
            if centralValueChangedCode != nil{
                centralValueChangedCode()
            }
        }
    }
    
    func getCentralValuePosition() -> Int{
        var closestPos = 0
        var minDist = CGFloat(10000)
        var pos = 0
        for comp in selectedImages{
            let dist = abs(trayNode.position.x + comp.position.x)
            if dist < minDist{
                minDist = abs(trayNode.position.x + comp.position.x)
                closestPos = pos
            }
            pos += 1
        }
        return closestPos
    }
    
    fileprivate func handleTap(){
        if !isAlreadyTapping{
            isAlreadyTapping = true
            var tapPosition: Int! = nil
            let point = CGPoint(x: touchDownPoint.x - trayNode.position.x, y: touchDownPoint.y)
            for pos in 0..<numCards{
                if unselectedImages[pos].contains(point) {
                    tapPosition = pos
                }
            }
            if tapPosition != nil{
                handleCardTap(tapPosition)
            }
            else{
                isAlreadyTapping = false
            }
            if nonSelectingTapCode != nil{
                nonSelectingTapCode()
                isAlreadyTapping = false
            }
        }
    }
    
    fileprivate func handleCardTap(_ pos: Int){
        if chooserType == .exactlyOne || chooserType == .oneOrNone{
            if !isSelected[pos]{
                toggleImageSelection(pos)
            }
            else{
                if chooserType == .exactlyOne{
                    selectedImages[pos].run(scaleAction, completion: {
                        if self.tapCode != nil{
                            self.tapCode()
                        }
                        self.run(SKAction.wait(forDuration: self.timeBetweenTaps), completion: {
                            self.isAlreadyTapping = false
                        })
                    })
                }
                else{
                    toggleImageSelection(pos)
                }
            }
        }
        else if chooserType == .multiple{
            toggleImageSelection(pos)
        }
    }
    
    fileprivate func deselectAll(){
        for pos in 0..<numCards{
            isSelected[pos] = false
        }
        selectedCardIDs = []
    }
    
    fileprivate func toggleImageSelection(_ imagePos: Int){
        let completionBlock = {
            let isSelected = self.isSelected[imagePos]
            if self.chooserType == .exactlyOne || self.chooserType == .oneOrNone{
                self.deselectAll()
            }
            self.isSelected[imagePos] = !isSelected
            var newSelectedCardIDs: [String] = []
            for pos in 0..<self.numCards{
                if self.isSelected[pos]{
                    newSelectedCardIDs.append(self.cardIDs[pos])
                }
            }
            self.updateCardAlphas()
            self.selectedCardIDs = newSelectedCardIDs
            if self.tapCode != nil{
                self.tapCode()
            }
            self.run(SKAction.wait(forDuration: self.timeBetweenTaps), completion: {
                self.isAlreadyTapping = false
            })
        }
        if !isSelected[imagePos]{
            unselectedImages[imagePos].run(scaleAction, completion: completionBlock)
            selectedImages[imagePos].alpha = 0
            selectedImages[imagePos].run(scaleAction)
            selectedImages[imagePos].run(fadeIn)
            unselectedImages[imagePos].run(fadeOut)
            if chooserType == .exactlyOne {
                for pos in 0..<numCards{
                    if isSelected[pos]{
                        selectedImages[pos].alpha = 0
                        unselectedImages[pos].alpha = 1
                    }
                }
            }
        }
        else{
            selectedImages[imagePos].run(scaleAction, completion: completionBlock)
        }
    }
    
    fileprivate func fadeVerticalBars(){
        if trayNode.position.x <= leftMostTrayX || trayNode.position.x >= rightMostTrayX{
            fadeOut(leftVerticalBarNode)
            fadeOut(rightVerticalBarNode)
        }
        if trayNode.position.x < rightMostTrayX{
            fadeIn(leftVerticalBarNode)
        }
        if trayNode.position.x > leftMostTrayX{
            fadeIn(rightVerticalBarNode)
        }
    }
    
    fileprivate func fadeIn(_ node: SKNode!){
        if node != nil{
            node.removeAction(forKey: "FadeOut")
            if node.alpha < 1{
                node.run(fadeInAction, withKey: "FadeIn")
            }
        }
    }
    
    fileprivate func fadeOut(_ node: SKNode!){
        if node != nil{
            node.removeAction(forKey: "FadeIn")
            if node.alpha > 0{
                node.run(fadeOutAction, withKey: "FadeOut")
            }
        }
    }
    
    fileprivate func setVerticalBarVisibilities(){
        if canScroll {
            leftVerticalBarNode.removeAllActions()
            rightVerticalBarNode.removeAllActions()
            if trayNode.position.x < rightMostTrayX{
                leftVerticalBarNode.alpha = 1
            }
            if trayNode.position.x > leftMostTrayX{
                rightVerticalBarNode.alpha = 1
            }
        }
        else{
            leftVerticalBarNode.alpha = 0
            rightVerticalBarNode.alpha = 0
        }
    }
    
    func hideComponents(){
        for comp in unselectedImages{
            var f = comp.frame
            f.origin.x += trayNode.position.x
            comp.isHidden = f.intersects(sizeRect) ? false : true
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
