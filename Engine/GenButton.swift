//
//  GenButton.swift
//  MPCGD
//
//  Created by Simon Colton on 23/01/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class GenButton: HKButton{
    
    var buttonSet: ButtonSetEnum! = nil
    
    var buttonNum = -1
    
    weak var textNode: SKLabelNode! = nil

    weak var secondTextNode: SKLabelNode! = nil
    
    init(buttonSize: CGSize){
        let image = ImageUtils.getBlankImage(buttonSize, colour: UIColor.clear)
        super.init(image: image, useTempHighlight: true)
        self.setScaleActionInterval(1.0...1.0)
    }
    
    func setImageAndText(_ image: UIImage, text: String){
        hkImage.imageNode.texture = SKTexture(image: image)
        textNode.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
