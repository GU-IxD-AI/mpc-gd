//
//  CGFloatExtension.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

extension CGFloat {
    static let approxEpsilon: CGFloat = 1.0e-5
    
    func approxEquals(_ x: CGFloat) -> Bool {
        return abs(self - x) < CGFloat.approxEpsilon
    }
}
