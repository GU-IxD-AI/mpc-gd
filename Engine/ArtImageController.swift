//
//  ArtImageController.swift
//  Engine
//
//  Created by Powley, Edward on 21/01/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

protocol ArtImageController {
    
    init(fascinator: Fascinator)
    
    func touchBegan(_ touchPoint: CGPoint)
    func touchDragged(_ touchPoint: CGPoint)
    func touchEnded(_ touchPoint: CGPoint)
    func tick(_ currentTime: CFTimeInterval)
}
