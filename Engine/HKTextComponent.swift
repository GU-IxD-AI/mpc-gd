//
//  HKTextComponent.swift
//  MPCGD
//
//  Created by Simon Colton on 05/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class HKTextComponent: HKComponent{
    
    var size: CGSize
    
    init(size: CGSize, text: String, font: UIFont = Fonts.primaryFont, colour: UIColor = Colours.getColour(.black), alignment: SKLabelHorizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left, spacing: CGFloat = 1.5){
        self.size = size
        let text = SKMultilineLabel(text: text, size: size * 0.9, pos: CGPoint(x: 0, y: 0), fontName: font.fontName , fontSize: font.pointSize, fontColor: colour, alignment: alignment, shouldShowBorder : false, spacing: spacing)
        super.init()
        addChild(text)
        text.position.y += 5
        let dragNode = SKSpriteNode()
        dragNode.size = size
        addChild(dragNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
