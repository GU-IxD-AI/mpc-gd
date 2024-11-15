//
//  DragMoveController.swift
//  Engine
//
//  Created by Powley, Edward on 21/01/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class DragMoveController : ArtImageController {
    
    var dragMultiplier : CGFloat = 20
    
    unowned let fascinator : Fascinator
    var dragLocalPoint: CGPoint! = nil
    var dragWorldTargetPoint: CGPoint! = nil
    var useBoundingBoxFix = true
    var detachJointOnDrag = false
    var gridPoints: [CGPoint] = []
    
    required init(fascinator: Fascinator) {
        self.fascinator = fascinator
        if fascinator.drawingPaths.isEmpty{
            if fascinator.controllerOverlayImage != nil{
                let radius = fascinator.sceneSize.width * fascinator.controllerSize/2
                gridPoints = CharacterIconHandler.getBoundingPoints(radius: radius, collectionNum: fascinator.controllerCollectionNum, characterNum: fascinator.controllerCharacterNum)
            }
        }
        else{
            for path in fascinator.drawingPaths{
                for point in path.pathPoints{
                    let x = (point.x/2 - fascinator.sceneSize.width/2) + fascinator.deviceSimulationXOffset
                    let y = -(point.y/2 - fascinator.sceneSize.height/2) + fascinator.deviceSimulationYOffset
                    gridPoints.append(CGPoint(x: x, y: y))
                }
            }
        }
    }
    
    func convertPointSceneToLocal(_ point: CGPoint) -> CGPoint {
        let controllerPos = fascinator.artImageNode.position
        return CGPoint(x: point.x - controllerPos.x, y: point.y - controllerPos.y)
    }
    
    func convertPointLocalToScene(_ point: CGPoint) -> CGPoint {
        let controllerPos = fascinator.artImageNode.position
        return CGPoint(x: point.x + controllerPos.x, y: point.y + controllerPos.y)
    }
    
    func touchBegan(_ touchPoint: CGPoint) {
        dragLocalPoint = convertPointSceneToLocal(touchPoint)
        dragWorldTargetPoint = touchPoint
        
        if detachJointOnDrag && fascinator.attachmentJoint != nil {
            fascinator.scene.physicsWorld.remove(fascinator.attachmentJoint)
            fascinator.attachmentJoint = nil
        }
        
        if fascinator.chromosome.attachment.joint.value == .spring {
            if fascinator.artImageNode != nil && fascinator.artImageNode.physicsBody != nil{
                fascinator.artImageNode.physicsBody!.allowsRotation = false
                fascinator.artImageNode.physicsBody!.angularVelocity = 0                
            }
        }
    }
    
    func touchDragged(_ touchPoint: CGPoint) {
        if dragLocalPoint == nil {
            touchBegan(touchPoint)
        }
        else {
            if detachJointOnDrag{
                let dist = sqrt((touchPoint - dragLocalPoint).sqrMagnitude())/200
                let v = touchPoint - dragWorldTargetPoint
                dragWorldTargetPoint.x += v.dx/(10 * dist)
                dragWorldTargetPoint.y += v.dy/(10 * dist)
            }
            else{
                dragWorldTargetPoint = touchPoint
            }
        }
    }
    
    func touchEnded(_ touchPoint: CGPoint) {
        dragLocalPoint = nil
        dragWorldTargetPoint = nil
        dragMultiplier = 20
        
        if fascinator.artImageNode.physicsBody != nil && detachJointOnDrag && fascinator.chromosome.attachment.joint.value != .none {
            let oldPosition = fascinator.artImageNode.position
            fascinator.artImageNode.position = fascinator.controllerStartPosition
            let (joint, point) = fascinator.createAttachmentToScene(
                fascinator.artImageNode.physicsBody!, attachmentChromosome: fascinator.chromosome.attachment, attachmentPointArea: fascinator.sceneSize)
            fascinator.attachmentJoint = joint
            fascinator.attachmentPoint = point
            fascinator.artImageNode.position = oldPosition
        }
    }
    
    func getBoundingRectAfterRotation(_ origin: CGPoint, angle: CGFloat) -> CGRect {
        
        let transform = CGAffineTransform(rotationAngle: angle)

        var minX = CGFloat(1000)
        var maxX = CGFloat(0)
        var minY = CGFloat(1000)
        var maxY = CGFloat(0)
        for p in gridPoints{
            let p1 = p.applying(transform)
            minX = min(p1.x + origin.x, minX)
            maxX = max(p1.x + origin.x, maxX)
            minY = min(p1.y + origin.y, minY)
            maxY = max(p1.y + origin.y, maxY)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    func tick(_ currentTime: CFTimeInterval) {
        if dragLocalPoint != nil && dragWorldTargetPoint != nil {
            // Compute target velocity based on distance between the drag anchor point and the finger position
            let offset = dragWorldTargetPoint - convertPointLocalToScene(dragLocalPoint)
            var velocity = offset * dragMultiplier
            
            if fascinator.chromosome.attachment.joint.value == .slider {
                if fascinator.chromosome.attachment.sliderAxis.value == 0{
                    velocity.dy = 0
                }
                else{
                    velocity.dx = 0
                }
            }
            
            // Find the bounding box for the controller

            //var bounds = fascinator.artImageBoundingBox.offsetBy(dx: fascinator.artImageNode.position.x, dy: fascinator.artImageNode.position.y)

            // This catches the problem with the box has been rotated
            var bounds = getBoundingRectAfterRotation(fascinator.artImageNode.position, angle: fascinator.artImageNode.zRotation)
            
            // Make it a bit bigger, so the checking kicks in before the controller actually hits the wall
            bounds = bounds.insetBy(dx: -3, dy: -3)
            
            // Don't allow the controller offscreen if on a slider
         //   if fascinator.chromosome.attachment.joint.value == .slider{
         //       bounds = bounds.insetBy(dx: -bounds.width * 0.25, dy: -bounds.height * 0.25)
         //   }
            
            if useBoundingBoxFix{
                // If the controller is near the bottom wall, and being dragged downwards...
                if bounds.minY < fascinator.deviceSimulationYOffset - LAFSettings.wallOffScreenNess.1 && velocity.dy < 0 {
                    // Kill the downward velocity
                    velocity.dy = 0
                    
                    // Reset the drag anchor point under the player's finger, to prevent the distance between anchor and finger becoming too large
                    // (as this is what causes velocity spikes that glitch the balls off the top)
                    dragLocalPoint.y = convertPointSceneToLocal(dragWorldTargetPoint).y
                }
                
                // Now the same for the top...
                if bounds.maxY > fascinator.sceneSize.height + fascinator.deviceSimulationYOffset + LAFSettings.wallOffScreenNess.1 && velocity.dy > 0 {
                    velocity.dy = 0
                    dragLocalPoint.y = convertPointSceneToLocal(dragWorldTargetPoint).y
                }
                // ... and the left...
                if bounds.minX < -LAFSettings.wallOffScreenNess.0 + fascinator.deviceSimulationXOffset && velocity.dx < 0 {
                    velocity.dx = 0
                    dragLocalPoint.x = convertPointSceneToLocal(dragWorldTargetPoint).x
                }
                // ... and the right
                if bounds.maxX > fascinator.sceneSize.width + fascinator.deviceSimulationXOffset + LAFSettings.wallOffScreenNess.0 && velocity.dx > 0 {
                    velocity.dx = 0
                    dragLocalPoint.x = convertPointSceneToLocal(dragWorldTargetPoint).x
                }                
            }
            
            // Apply the velocity
            if fascinator.artImageNode.physicsBody != nil{
                fascinator.artImageNode.physicsBody!.velocity = velocity
            }
        }
    }
}
