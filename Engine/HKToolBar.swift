//
//  HKToolBar.swift
//  MPCGD
//
//  Created by Simon Colton on 10/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class HKToolBar: HKComponent{
    
    var onDragCode: (() -> ())! = nil
    
    fileprivate var hkComponents: [HKImage]
    
    fileprivate var trayNode = SKNode()
    
    fileprivate var isMoving = false
    
    fileprivate var dragNode = SKSpriteNode()
    
    fileprivate var xTouchDownPos: CGFloat = 0
    
    fileprivate var sizeRect: CGRect! = nil
    
    init(hkComponents: [HKImage], size: CGSize, separatorWidth: CGFloat = 5){
        self.hkComponents = hkComponents
        dragNode.size = size
        super.init()
        var x = CGFloat(0)
        for comp in hkComponents{
            trayNode.addChild(comp)
            comp.position = CGPoint(x: x, y: comp.y)
            x += separatorWidth + comp.size.width
        }
        addChild(dragNode)
        addChild(trayNode)
        sizeRect = CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        hideComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if touches.count == 1{
            if let touch = touches.first {
                if touch.tapCount <= 1{
                    xTouchDownPos = touch.location(in: self).x
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if touches.count == 1{
            if let touch = touches.first {
                if touch.tapCount <= 1{
                    let touchLocation = touch.location(in: trayNode)
                    let previousTouchLocation = touch.previousLocation(in: trayNode)
                    let xMove = touchLocation.x - previousTouchLocation.x
                    trayNode.position.x += xMove
                    if trayNode.position.x > 0{
                        trayNode.position.x = 0
                    }
                    if hkComponents.last!.position.x + trayNode.x < 0{
                        trayNode.position.x -= xMove
                    }
                    hideComponents()
                    if onDragCode != nil{
                        onDragCode()
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if HKDisableUserInteractions { return }
        if touches.count == 1{
            if let touch = touches.first {
                if touch.tapCount <= 1{
                    if abs(touch.location(in: self).x - xTouchDownPos) >= 3{
                        var closestComp: HKImage! = nil
                        var minDist = CGFloat(10000)
                        for comp in hkComponents{
                            let dist = abs(trayNode.position.x + comp.position.x)
                            if dist < minDist{
                                minDist = abs(trayNode.position.x + comp.position.x)
                                closestComp = comp
                            }
                        }
                        moveToCentreComponent(closestComp)
                    }
                    else{
                        let p = CGPoint(x: touch.location(in: trayNode).x, y: 0)
                        for comp in hkComponents{
                            if comp.contains(p){
                                moveToCentreComponent(comp)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func hideComponents(){
        for comp in hkComponents{
            var f = comp.frame
            f.origin.x += trayNode.position.x
            comp.isHidden = f.intersects(sizeRect) ? false : true
        }
    }
    
    func moveToCentreComponent(_ comp: HKImage){
        let xMove = -(comp.position.x + trayNode.position.x)
        for comp in hkComponents{
            comp.isHidden = false
        }
        trayNode.run(HKEasing.moveXBy(xMove, duration: 0.3, easingFunction: BackEaseOut), completion: {
            self.hideComponents()
        })
    }
    
}
