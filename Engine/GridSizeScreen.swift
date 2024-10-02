//
//  GridSizeScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 03/04/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class GridSizeScreen: HKComponent{
    
    let sizeSlider: HKSlider

    init(size: CGSize){
        sizeSlider = HKSlider(size: CGSize(width: size.width * 0.5, height: 50))
        sizeSlider.maximumValue = 61
        sizeSlider.minimumValue = 1
        sizeSlider.position = CGPoint(x: size.width/6, y: -30)
        super.init()
        addChild(sizeSlider)
        sizeSlider.zPosition = 1010
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialiseFromMPCGDGenome(_ MPCGDGenome: MPCGDGenome){
        sizeSlider.value = Float(MPCGDGenome.gridSize)
        sizeSlider.isUserInteractionEnabled = true
    }
    
    func closeDown(){
        sizeSlider.isUserInteractionEnabled = false
    }

}
