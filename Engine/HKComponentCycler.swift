//
//  HKComponentCycler.swift
//  MPCGD
//
//  Created by Simon Colton on 26/12/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

enum CycleOrientation{
    case horizontal, vertical
}

class HKComponentCycler : HKComponent{

    var subComponentHandlingDrag: HKButton! = nil
    
    var subComponentHasHandledDrag = false
    
    var generatorScreen: GeneratorScreen! = nil
    
    var allow360 = true
    
    var additionalMovingNodes: [SKNode] = []
    
    var selectedID: String! = nil
    
    var selectedHKComponent: HKComponent! = nil
    
    var tapToCycle = true
    
    var enabled = true
    
    var pipsNode = SKNode()
    
    var selectedPipNode: SKSpriteNode! = nil
    
    var waitAtEnd: TimeInterval
    
    var imageChosenCode: (() -> ())! = nil
    
    var movementStartedCode: (() -> ())! = nil
    
    var disabledTapCode: (() -> ())! = nil
    
    var tapCode: (() -> ())! = nil
    
    var onDragCode: (() -> ())! = nil
    
    var nextSelectedID: String! = nil
    
    var nextSelectedHKComponent: HKComponent! = nil
    
    var nextSelectedIndex: Int! = nil
    
    var hkComponents: [HKComponent] = []
    
    var twinnedCycler: HKComponentCycler! = nil
    
    var ids: [String]
    
    var size: CGSize
    
    var imagePosition = 0
    
    let flyInFromLeft: SKAction

    let flyInFromRight: SKAction
    
    let flyOutToLeft: SKAction
    
    let flyOutToRight: SKAction
    
    let flyInFromBottom: SKAction
    
    let flyInFromTop: SKAction
    
    let flyOutToBottom: SKAction
    
    let flyOutToTop: SKAction
    
    var cropNode: SKCropNode! = nil
    
    var isMoving = false
    
    var touchDownXPos = CGFloat(0)
    
    var touchDownYPos = CGFloat(0)
    
    var componentName = ""
    
    var liveSubComponents: [(HKComponent, HKComponent)] = []
    
    var liveTapComponents: [(HKComponent, HKComponent)] = []
    
    var orientation: CycleOrientation
    
    var nodeForChildren: SKNode! = nil
    
    var selectedPipColour: UIColor! = nil
    
    var unselectedPipColour: UIColor! = nil
    
    init(hkComponents: [HKComponent], ids: [String], size: CGSize, tapToCycle: Bool = true, waitAtEnd: TimeInterval = 0.1, cropNode: SKCropNode! = nil, name: String = "cycler", orientation: CycleOrientation = .horizontal, noCropNode: Bool = false){
        
        // Assign values
        
        self.size = size
        self.ids = ids
        self.waitAtEnd = waitAtEnd
        self.tapToCycle = tapToCycle
        self.orientation = orientation
        self.selectedPipColour = Colours.getColour(.antiqueWhite).withAlphaComponent(0.8)
        self.unselectedPipColour = Colours.getColour(.antiqueWhite).withAlphaComponent(0.2)
        
        // Set up animations
        
        flyInFromLeft = SKAction.sequence([SKAction.wait(forDuration: 0.2), HKEasing.moveXBy(size.width, duration: TimeInterval(0.2), easingFunction: BackEaseOut)])
        flyInFromRight = SKAction.sequence([SKAction.wait(forDuration: 0.2), HKEasing.moveXBy(-size.width, duration: TimeInterval(0.2), easingFunction: BackEaseOut)])
        flyOutToLeft = SKAction.moveBy(x: -size.width, y: 0, duration: 0.2)
        flyOutToRight = SKAction.moveBy(x: size.width, y: 0, duration: 0.2)
        
        flyInFromTop = SKAction.sequence([SKAction.wait(forDuration: 0.2), HKEasing.moveYBy(-size.height, duration: TimeInterval(0.2), easingFunction: BackEaseOut)])
        flyInFromBottom = SKAction.sequence([SKAction.wait(forDuration: 0.2), HKEasing.moveYBy(size.height, duration: TimeInterval(0.2), easingFunction: BackEaseOut)])
        flyOutToTop = SKAction.moveBy(x: 0, y: size.height, duration: 0.2)
        flyOutToBottom = SKAction.moveBy(x: 0, y: -size.height, duration: 0.2)
        
        super.init()
        
        // Set up crop node
        
        if noCropNode{
            nodeForChildren = self
        }
        else{
            if cropNode == nil{
                self.cropNode = SKCropNode()
                let bounds = CGRect(origin: CGPoint.zero, size: size)
                UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
                let context = UIGraphicsGetCurrentContext()!
                context.setFillColor(UIColor.red.cgColor)
                context.fill(CGRect(origin: CGPoint.zero, size: size))
                let image = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                self.cropNode.maskNode = SKSpriteNode(texture: SKTexture(cgImage: image.cgImage!))
            }
            else{
                self.cropNode = cropNode
            }
            nodeForChildren = self.cropNode
        }

        // Add the children
        
        if !noCropNode{
            addChild(self.cropNode)
        }
        addChild(pipsNode)
        
        self.hkComponents.append(contentsOf: hkComponents)
        addHKComponents()
        isUserInteractionEnabled = true

        self.name = name
    }
    
    deinit {
        //print("!!! [DEINIT] HKComponentCycler")
    }
    
    func animatePipColourChange(_ selectedColour: UIColor!, unselectedColour: UIColor!, duration: TimeInterval, generatorScreenMoved: Bool = false, forceSelectedPipNumber: Int! = nil){
        let FADE_DURATION = duration
        let oldSelectedPipColour = self.selectedPipColour!
        let oldUnselectedPipColour = self.unselectedPipColour!
        
        if generatorScreenMoved {
            pipsNode.run(SKAction.fadeOut(withDuration: FADE_DURATION / 2.0), completion: {
                self.handleGeneratorScreenMenuMove()
                self.pipsNode.run(SKAction.fadeIn(withDuration: FADE_DURATION / 2.0))
            })
        } else {
            selectedPipNode.run(SKAction.fadeOut(withDuration: FADE_DURATION / 2.0), completion: {
                let ind = (forceSelectedPipNumber != nil) ? forceSelectedPipNumber : self.imagePosition
                self.movePip(ind!, numComponents: self.hkComponents.count)
                self.selectedPipNode.run(SKAction.fadeIn(withDuration: FADE_DURATION / 2.0))
            })
        }
        
        pipsNode.run(
            SKAction.customAction(withDuration: FADE_DURATION, actionBlock: { (node: SKNode!, elapsedTime: CGFloat) -> Void in
                let alpha = clamp(value: elapsedTime / CGFloat(FADE_DURATION), lower: 0.0, upper: 1.0)
                self.selectedPipColour = MathsUtils.lerp(alpha, c0: oldSelectedPipColour, c1: selectedColour)
                self.unselectedPipColour = MathsUtils.lerp(alpha, c0: oldUnselectedPipColour, c1: unselectedColour)
                self.updatePipColours()
            }))
    }

    func changePipsColour(_ selectedColour: UIColor, unselectedColour: UIColor){
        selectedPipColour = selectedColour
        unselectedPipColour = unselectedColour
        setUpPips(self.hkComponents.count)
        movePip(self.hkComponents.index(of: self.selectedHKComponent)!, numComponents: self.hkComponents.count)
    }
    
    func indexShowing() -> Int{
        return ids.index(of: selectedID)!
    }
    
    func getHKComponentWithID(_ id: String) -> HKComponent!{
        if let ind = ids.index(of: id){
            return hkComponents[ind]
        }
        else{
            return nil
        }
    }
    
    func setUpPips(_ numComponents: Int){
        pipsNode.removeAllChildren()
        var pipXPos = 9 + (-18 * round(CGFloat(numComponents)/2))
        if numComponents % 2 == 1{
            pipXPos += 9
        }
        selectedPipNode = makePipNode()
        selectedPipNode.color = selectedPipColour
        selectedPipNode.position = CGPoint(x: pipXPos, y: -size.height/2 - 18)
        for _ in 1...numComponents{
            let pipNode = makePipNode()
            pipNode.color = unselectedPipColour
            pipNode.position = CGPoint(x: pipXPos, y: -size.height/2 - 18)
            pipsNode.addChild(pipNode)
            pipXPos += 18
        }
        pipsNode.addChild(selectedPipNode)
    }
  
    func updatePipColours() {
        selectedPipNode.color = selectedPipColour
        for i in 0..<pipsNode.children.count-1 {
            let n = pipsNode.children[i] as? SKSpriteNode
            n?.color = unselectedPipColour
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeCurrent(_ outAction: SKAction! = nil, inAction: SKAction! = nil, completion: (() -> ())! = nil){
        if outAction == nil{
            _ = self.removeHKComponentWithID(self.selectedID)
            if completion != nil{
                completion()
            }
        }
        else{
            pipsNode.run(outAction)
            selectedHKComponent.run(outAction, completion: {
                _ = self.removeHKComponentWithID(self.selectedID)
                self.selectedHKComponent.alpha = 0
                self.selectedHKComponent.run(inAction, completion: {
                    completion()
                })
                self.pipsNode.run(inAction)
            })
        }
    }
    
    func removeHKComponentWithID(_ id: String) -> HKComponent!{
        if let ind = ids.index(of: id){
            ids.remove(at: ind)
            let comp = hkComponents[ind]
            hkComponents.remove(at: ind)
            addHKComponents(ind < ids.count ? ind: ids.count - 1)
            return comp
        }
        return nil
    }
    
    func cycleToComponent(_ id: String) -> HKComponent!{
        if let ind = ids.index(of: id){
            return cycleToComponentIndex(ind)
        }
        return nil
    }
    
    func cycleToComponentIndex(_ ind: Int) -> HKComponent!{
        hkComponents[imagePosition].isHidden = true
        imagePosition = ind
        selectedID = ids[ind]
        hkComponents[imagePosition].isHidden = false
        movePip(imagePosition, numComponents: hkComponents.count)
        selectedHKComponent = hkComponents[ind]
        return hkComponents[ind]
    }
    
    
    func addHKComponents(_ showSlot: Int = 0){
        nodeForChildren.removeAllChildren()
        var pos = 0
        for component in hkComponents{
            nodeForChildren.addChild(component)
            component.isHidden = true
            component.name = "cycle component \(pos)"
            pos += 1
        }
        selectedHKComponent = hkComponents[showSlot]
        selectedID = ids[showSlot]
        imagePosition = showSlot
        hkComponents[showSlot].isHidden = false
        setUpPips(hkComponents.count)
        movePip(showSlot, numComponents: hkComponents.count)
    }
    
    func addHKComponent(_ hkComponent: HKComponent, id: String){
        ids.append(id)
        hkComponents.append(hkComponent)
        addHKComponents()
    }
    
    func addHKComponentAtIndex(_ hkComponent: HKComponent, id: String, index: Int, cycle: Bool = false){
        ids.insert(id, at: index)
        hkComponents.insert(hkComponent, at: index)
        addHKComponents()
        if cycle{
            _ = cycleToComponent(id)
        }
    }
    
    func replaceHKComponent(_ hkComponent: HKComponent, id: String){
        if let ind = ids.index(of: id){
            hkComponents[ind] = hkComponent
        }
        else{
            addHKComponent(hkComponent, id: id)
        }
        addHKComponents()
    }
    
    func makePipNode() -> SKSpriteNode{
        let colour = UIColor.white
        let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30))
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(colour.cgColor)
        context.fillEllipse(in: CGRect(x: 1, y: 1, width: 28, height: 28))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let pipNode = SKSpriteNode(texture: SKTexture(image: image))
        pipNode.size = CGSize(width: 10, height: 10)
        pipNode.blendMode = .alpha
        pipNode.colorBlendFactor = 1.0
        pipNode.color = UIColor.purple
        return pipNode
    }

    func handledByTapComponent(_ touch: UITouch) -> HKComponent!{
        var bestZ: CGFloat = -9999999.0
        var bestC: HKComponent! = nil
        
        for (sub, parent) in liveTapComponents{
            guard parent == selectedHKComponent else { continue }

            let scenePos = touch.location(in: MainScene.instance)
            let subPos = sub.convert(scenePos, from: MainScene.instance)
            //print("scenePos=\(scenePos) -> subPos=\(subPos)")

            if parent == selectedHKComponent && sub.contains(subPos){
                if sub.zPosition >= bestZ && !sub.isHidden && sub.alpha == 1.0{
                    bestC = sub
                    bestZ = sub.zPosition
                }
            }
        }
        return bestC
    }
    
    func handledBySubComponent(_ touch: UITouch) -> HKComponent!{
        var bestZ: CGFloat = -9999999.0
        var subTouched: HKComponent! = nil
        for (sub, _) in liveSubComponents{
            if sub.isUserInteractionEnabled && sub.dragStartedHere{
                return sub
            }
        }
        for (sub, parent) in liveSubComponents{
            if sub.isUserInteractionEnabled{
                if parent == selectedHKComponent && sub.contains(touch.location(in: parent)){
                    if sub.zPosition >= bestZ && !sub.isHidden && sub.alpha == 1.0 {
                        bestZ = sub.zPosition
                        if subTouched != nil {
                            sub.dragStartedHere = false
                        }
                        sub.dragStartedHere = true
                        subTouched = sub
                    }
                }
            }
            else{
                sub.dragStartedHere = false
            }
        }
        return subTouched
    }

    var activeButtonTap: HKButton! = nil
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions || activeButtonTap != nil { return }
        if !isMoving && touches.count == 1{
            if let touch = touches.first{
                if touch.tapCount <= 1{
                    subComponentHasHandledDrag = false
                    subComponentHandlingDrag = nil
                    if let sub = handledBySubComponent(touch){
                        sub.touchesBegan(touches, with: event)
                        dragStartedHere = false
                    }
 //                   else if enabled{
                        if let sub = handledByTapComponent(touch){
                            sub.touchesBegan(touches, with: event)
                            sub.dragStartedHere = true
                            activeButtonTap = (sub as! HKButton)
                        }
                        touchDownXPos = touch.location(in: self).x
                        touchDownYPos = touch.location(in: self).y
                        dragStartedHere = true
  //                  }
                }
            }
        }
    }
    
    // SPECIFIC HACK FOR THE BIG BUTTON - DRAGGING THE CONTROLLER
    
    func subComponentHandlesDrag(_ touch: UITouch) -> Bool{
        for (sub, _) in liveSubComponents{
            if sub is HKButton && (sub as! HKButton).onTouchesMovedCode != nil{
                if sub.alpha == 1 && !sub.isHidden{
                    let touchLocation = touch.location(in: self)
                    if touchLocation.x < -30 || touchLocation.x > 110 || touchLocation.y > 100 || touchLocation.y < 0{
                        return false
                    }
                    let previousTouchLocation = touch.previousLocation(in: self)
                    let moveVector = CGVector(dx: touchLocation.x - previousTouchLocation.x, dy: touchLocation.y - previousTouchLocation.y)
                    (sub as! HKButton).onTouchesMovedCode?(moveVector)
                    subComponentHandlingDrag = (sub as! HKButton)
                    return true
                }
            }
        }
        return false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if !isMoving && touches.count == 1{
            if let touch = touches.first{
                if touch.tapCount <= 1{
                    let localHandled = subComponentHandlesDrag(touch)
                    if localHandled{
                        subComponentHasHandledDrag = true
                    }
                    if !subComponentHasHandledDrag && !localHandled{
                        if !dragStartedHere{
                            if let sub = handledBySubComponent(touch){
                                sub.touchesMoved(touches, with: event)
                            }
                        }
                        else if dragStartedHere && enabled{
                            let touchLocation = touch.location(in: self)
                            let previousTouchLocation = touch.previousLocation(in: self)
                            if orientation == .horizontal{
                                let dist = touchLocation.x - previousTouchLocation.x
                                hkComponents[imagePosition].position.x += dist
                                for node in additionalMovingNodes{
                                    node.position.x += dist
                                }
                                if twinnedCycler != nil{
                                    twinnedCycler.hkComponents[twinnedCycler.imagePosition].position.x += dist
                                }
                            }
                            else{
                                let dist = touchLocation.y - previousTouchLocation.y
                                hkComponents[imagePosition].position.y += dist
                                for node in additionalMovingNodes{
                                    node.position.y += dist
                                }
                                twinnedCycler?.hkComponents[twinnedCycler.imagePosition].position.y += dist
                            }
                            if onDragCode != nil{
                                onDragCode()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if !isMoving && touches.count == 1{
            if let touch = touches.first{
                if touch.tapCount <= 1{
                    if !dragStartedHere || subComponentHasHandledDrag{
                        if subComponentHandlingDrag != nil{
                            subComponentHandlingDrag!.onDragEndCode()
                        }
                        else if let sub = handledBySubComponent(touch){
                            sub.touchesEnded(touches, with: event)
                            sub.dragStartedHere = false
                        }
                    }
                    else if dragStartedHere && enabled{
                        dragStartedHere = false
                        isMoving = true
                        twinnedCycler?.isMoving = true
                        let touchXPos = touch.location(in: self).x
                        let touchYPos = touch.location(in: self).y
                        var movement = touchXPos - touchDownXPos
                        if orientation == .vertical{
                            movement = touchYPos - touchDownYPos
                        }
                        if abs(movement) > 50{
                            if orientation == .horizontal{
                                if movement < 0{
                                    if allow360 || ids.index(of: selectedID)! < ids.count - 1{
                                        moveLeft()
                                        twinnedCycler?.moveLeft()
                                    }
                                    else{
                                        returnToStartPosition()
                                        twinnedCycler?.returnToStartPosition()
                                    }
                                }
                                else if movement > 0{
                                    if allow360 || ids.index(of: selectedID)! > 0{
                                        moveRight()
                                        twinnedCycler?.moveRight()
                                    }
                                    else{
                                        returnToStartPosition()
                                        twinnedCycler?.returnToStartPosition()
                                    }
                                }
                            }
                            else{
                                movement < 0 ? moveDown() : moveUp()
                                movement < 0 ? twinnedCycler?.moveDown() : twinnedCycler?.moveUp()
                            }
                        }
                        else if abs(movement) < 3{
                            if let sub = handledByTapComponent(touch){
                                let b = (sub as! HKButton)
                                if b === activeButtonTap {
                                    sub.touchesEnded(touches, with: event)
                                }
                                sub.dragStartedHere = false
                                returnToStartPosition()
                                twinnedCycler?.returnToStartPosition()
                            }
                            else{
                                if tapToCycle{
                                    if orientation == .horizontal{
                                        touchXPos < 0 ? moveRight() : moveLeft()
                                        touchXPos < 0 ? twinnedCycler?.moveRight() : twinnedCycler?.moveLeft()
                                    }
                                    else{
                                        touchYPos < 0 ? moveDown() : moveUp()
                                        touchYPos < 0 ? twinnedCycler?.moveDown() : twinnedCycler?.moveUp()
                                    }
                                }
                                else{
                                    returnToStartPosition()
                                    twinnedCycler?.returnToStartPosition()
                                    if tapCode != nil{
                                        tapCode()
                                    }
                                }
                            }
                        }
                        else if abs(movement) > 0{
                            returnToStartPosition()
                            twinnedCycler?.returnToStartPosition()
                        }
                        else{
                            isMoving = false
                            twinnedCycler?.isMoving = true
                        }
                    }
                }
            }
        }
        activeButtonTap = nil
        dragStartedHere = false
    }
    
    func moveLeft(){
        let newImagePosition = (imagePosition + 1) % hkComponents.count
        if isHidden{
            moveWhenHidden(newImagePosition)
        }
        else{
            let oldImagePosition = imagePosition
            hkComponents[oldImagePosition].run(flyOutToLeft, completion: {
                self.movePip(newImagePosition, numComponents: self.hkComponents.count)
                self.hkComponents[oldImagePosition].isHidden = true
                self.hkComponents[oldImagePosition].position.x = 0
            })
            imagePosition = newImagePosition
            nextSelectedID = ids[imagePosition]
            nextSelectedHKComponent = hkComponents[imagePosition]
            nextSelectedIndex = imagePosition
            if movementStartedCode != nil{
                movementStartedCode()
            }
            hkComponents[imagePosition].isHidden = false
            hkComponents[imagePosition].position.x = size.width
            hkComponents[imagePosition].run(flyInFromRight, completion: {
                self.run(SKAction.wait(forDuration: self.waitAtEnd), completion: {
                    self.selectedID = self.ids[self.imagePosition]
                    self.selectedHKComponent = self.hkComponents[self.imagePosition]
                    if self.imageChosenCode != nil{
                        self.imageChosenCode()
                    }
                    self.isMoving = false
                })
            })
        }
    }
    
    func moveRight(){
        if generatorScreen != nil && generatorScreen.menuPosition > 0{
            hkComponents[imagePosition].run(flyOutToRight, completion: {
                self.hkComponents[self.imagePosition].position.x = -self.size.width
                self.hkComponents[self.imagePosition].run(self.flyInFromLeft, completion: {
                    self.isMoving = false
                    })
                self.generatorScreen.moveMenuBackOne()
                self.handleGeneratorScreenMenuMove()
            })
        }
        else{
            let newImagePosition = (imagePosition + hkComponents.count - 1) % hkComponents.count
            if isHidden{
                moveWhenHidden(newImagePosition)
            }
            else{
                let oldImagePosition = imagePosition
                hkComponents[oldImagePosition].run(flyOutToRight, completion: {
                    self.movePip(newImagePosition, numComponents: self.hkComponents.count)
                    self.hkComponents[oldImagePosition].isHidden = true
                    self.hkComponents[oldImagePosition].position.x = 0
                })
                imagePosition = newImagePosition
                nextSelectedID = ids[imagePosition]
                nextSelectedHKComponent = hkComponents[imagePosition]
                nextSelectedIndex = imagePosition
                if movementStartedCode != nil{
                    movementStartedCode()
                }
                hkComponents[imagePosition].position.x = -size.width
                hkComponents[imagePosition].isHidden = false
                hkComponents[imagePosition].run(flyInFromLeft, completion: {
                    if self.generatorScreen != nil && self.hkComponents.count == 4{
                        self.ids.remove(at: 3)
                        self.hkComponents.remove(at: 3)
                        self.addHKComponents(2)
                    }
                    self.run(SKAction.wait(forDuration: self.waitAtEnd), completion: {
                        self.selectedID = self.ids[self.imagePosition]
                        self.selectedHKComponent = self.hkComponents[self.imagePosition]
                        if self.imageChosenCode != nil{
                            self.imageChosenCode()
                        }
                        self.isMoving = false
                    })
                })
            }
        }
    }
    
    func moveDown(){
        let newImagePosition = (imagePosition + 1) % hkComponents.count
        if isHidden{
            moveWhenHidden(newImagePosition)
        }
        else{
            let oldImagePosition = imagePosition
            hkComponents[oldImagePosition].run(flyOutToBottom, completion: {
                self.movePip(newImagePosition, numComponents: self.hkComponents.count)
                self.hkComponents[oldImagePosition].isHidden = true
                self.hkComponents[oldImagePosition].position = CGPoint(x: 0, y: 0)
            })
            imagePosition = newImagePosition
            nextSelectedID = ids[imagePosition]
            nextSelectedIndex = imagePosition
            nextSelectedHKComponent = hkComponents[imagePosition]
            if movementStartedCode != nil{
                movementStartedCode()
            }
            hkComponents[imagePosition].isHidden = false
            hkComponents[imagePosition].position = CGPoint(x: 0, y: size.height)
            hkComponents[imagePosition].run(flyInFromTop, completion: {
                self.run(SKAction.wait(forDuration: self.waitAtEnd), completion: {
                    self.selectedID = self.ids[self.imagePosition]
                    self.selectedHKComponent = self.hkComponents[self.imagePosition]
                    if self.imageChosenCode != nil{
                        self.imageChosenCode()
                    }
                    self.isMoving = false
                })
            })
        }
    }
    
    func moveUp(){
        let newImagePosition = (imagePosition + 1) % hkComponents.count
        if isHidden{
            moveWhenHidden(newImagePosition)
        }
        else{
            let oldImagePosition = imagePosition
            hkComponents[oldImagePosition].run(flyOutToTop, completion: {
                self.movePip(newImagePosition, numComponents: self.hkComponents.count)
                self.hkComponents[oldImagePosition].isHidden = true
                self.hkComponents[oldImagePosition].position = CGPoint(x: 0, y: 0)
            })
            imagePosition = newImagePosition
            nextSelectedID = ids[imagePosition]
            nextSelectedIndex = imagePosition
            nextSelectedHKComponent = hkComponents[imagePosition]
            if movementStartedCode != nil{
                movementStartedCode()
            }
            hkComponents[imagePosition].isHidden = false
            hkComponents[imagePosition].position = CGPoint(x: 0, y: -size.height)
            hkComponents[imagePosition].run(flyInFromBottom, completion: {
                self.run(SKAction.wait(forDuration: self.waitAtEnd), completion: {
                    self.selectedID = self.ids[self.imagePosition]
                    self.selectedHKComponent = self.hkComponents[self.imagePosition]
                    if self.imageChosenCode != nil{
                        self.imageChosenCode()
                    }
                    self.isMoving = false
                })
            })
        }
    }
    
    func moveWhenHidden(_ newImagePosition: Int){
        hkComponents[imagePosition].isHidden = true
        imagePosition = newImagePosition
        self.movePip(imagePosition, numComponents: hkComponents.count)
        self.selectedID = ids[imagePosition]
        self.selectedHKComponent = hkComponents[imagePosition]
        hkComponents[imagePosition].isHidden = false
        if imageChosenCode != nil{
            imageChosenCode()
        }
        isMoving = false
        if generatorScreen != nil{
            setUpPips(hkComponents.count)
            movePip(hkComponents.count - 1, numComponents: hkComponents.count)
        }
    }

    func movePip(_ newImagePosition: Int, numComponents: Int){
        var xPos: CGFloat = 9
        xPos = xPos + (-18 * round(CGFloat(numComponents) / 2))
        xPos = xPos + 18 * CGFloat(newImagePosition)
        if numComponents % 2 == 1 {
            xPos += 9
        }
        selectedPipNode.position = CGPoint(x: xPos, y: -size.height/2 - 18)
    }
    
    func returnToStartPosition(){
        if isHidden{
            for node in additionalMovingNodes{
                node.position.x = 0
            }
            hkComponents[imagePosition].position = CGPoint(x: 0, y: 0)
        }
        else{
            var moveBack = HKEasing.moveXTo(0, duration: 0.2, easingFunction: BackEaseOut)
            if orientation == .vertical{
                moveBack = HKEasing.moveYTo(0, duration: 0.2, easingFunction: BackEaseOut)
            }
            hkComponents[imagePosition].run(moveBack, completion: {
                self.isMoving = false
            })
            for node in additionalMovingNodes{
                node.run(moveBack)
            }
        }
    }
    
    func handleGeneratorScreenMenuMove(){
        setUpPips(hkComponents.count + generatorScreen.menuPosition)
        movePip(hkComponents.count + generatorScreen.menuPosition - 1, numComponents: hkComponents.count + generatorScreen.menuPosition)
    }
    
}
