//
//  TeleportController.swift
//  MPCGD
//
//  Created by Simon Colton on 08/05/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class TeleportController: ArtImageController{
    
    unowned let fascinator : Fascinator
    
    required init(fascinator: Fascinator) {
        self.fascinator = fascinator
    }
    
    func touchBegan(_ touchPoint: CGPoint) {
        
    }
    
    func touchDragged(_ touchPoint: CGPoint) {
        
    }
    
    func touchEnded(_ touchPoint: CGPoint) {
        fascinator.teleportControllerTo = touchPoint
    }
    
    func tick(_ currentTime: CFTimeInterval) {
        
    }
    
}
