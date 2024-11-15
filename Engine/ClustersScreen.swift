//
//  ClustersScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 13/05/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class ClustersScreen: HKComponent{
    
    let clusterSizeLabel = SKLabelNode(text: "Cluster size:")
    
    let clusterSizeValLabel = SKLabelNode(text: "")
    
    let clusterScoreLabel = SKLabelNode(text: "Cluster score:")
    
    let clusterScoreValLabel = SKLabelNode(text: "")
    
    let clusterSizeSlider: HKSlider
    
    let clusterScoreSlider: HKSlider
    
    var clusterVisNodeHolder = SKNode()
    
    var stem = ""
    
    init(size: CGSize){
        clusterSizeSlider = HKSlider(size: CGSize(width: size.width * 0.6, height: 50))
        clusterSizeSlider.minimumValue = 2
        clusterSizeSlider.maximumValue = 9
        clusterSizeSlider.position = CGPoint(x: -20, y: 60)

        clusterScoreSlider = HKSlider(size: CGSize(width: size.width * 0.8, height: 50))
        clusterScoreSlider.minimumValue = 0
        clusterScoreSlider.maximumValue = 61
        clusterScoreSlider.position = CGPoint(x: 0, y: -28)
    
        super.init()
        
        for l in [clusterSizeLabel, clusterSizeValLabel, clusterScoreLabel, clusterScoreValLabel]{
            l.fontSize = 20
            l.fontName = "Helvetica Neue Thin"
            l.fontColor = Colours.getColour(.antiqueWhite)
            addChild(l)
        }
        
        clusterSizeLabel.horizontalAlignmentMode = .left
        clusterScoreLabel.horizontalAlignmentMode = .left
        clusterSizeValLabel.horizontalAlignmentMode = .right
        clusterScoreValLabel.horizontalAlignmentMode = .right
        
        clusterSizeLabel.position = CGPoint(x: -size.width/2 + 20, y: 95)
        clusterScoreLabel.position = CGPoint(x: -size.width/2 + 20, y: 5)
        clusterSizeValLabel.position = CGPoint(x: size.width * 0.25 - 3, y: 95)
        clusterScoreValLabel.position = CGPoint(x: size.width * 0.5 - 20, y: 5)
    
        clusterVisNodeHolder.position = CGPoint(x: 94, y: 83)
        
        addChild(clusterSizeSlider)
        addChild(clusterScoreSlider)
        addChild(clusterVisNodeHolder)
        
        clusterVisNodeHolder.setScale(0.75)
    
        clusterScoreSlider.onDragCode = { [unowned self] () -> () in
            let val = Int(round(self.clusterScoreSlider.value))
            let v = MPCGDGenome.clusterExplodeScores[val]
            self.clusterScoreValLabel.text = v == -90 ? MPCGDGenome.deathSymbol : "\(v)"
        }
        clusterScoreSlider.addDeathSymbolOnLeft()
    }
    
    func initialiseFromMPCGDGenome(mpcgdGenome: MPCGDGenome, stem: String, clusterVisNode: SKNode){
        self.stem = stem
        clusterVisNodeHolder.removeAllChildren()
        clusterVisNodeHolder.addChild(clusterVisNode)
        clusterSizeSlider.isUserInteractionEnabled = true
        clusterScoreSlider.isUserInteractionEnabled = true
        var sizeVal = 0
        var scoreVal = 0
        if stem == "White"{
            sizeVal = mpcgdGenome.whiteCriticalClusterSize
            scoreVal = MPCGDGenome.clusterExplodeScores.index(of: mpcgdGenome.whiteExplodeScore)!
        }
        else if stem == "Blue"{
            sizeVal = mpcgdGenome.blueCriticalClusterSize
            scoreVal = MPCGDGenome.clusterExplodeScores.index(of: mpcgdGenome.blueExplodeScore)!
        }
        else if stem == "Mixed"{
            sizeVal = mpcgdGenome.mixedCriticalClusterSize
            scoreVal = MPCGDGenome.clusterExplodeScores.index(of: mpcgdGenome.mixedExplodeScore)!
        }
        if sizeVal == 0{
            clusterSizeSlider.alpha = 0.3
            clusterScoreSlider.alpha = 0.3
            clusterSizeSlider.value = Float(0)
            clusterScoreSlider.value = Float(scoreVal)
            clusterSizeLabel.alpha = 0.3
            clusterSizeValLabel.isHidden = true
            clusterScoreLabel.alpha = 0.3
            clusterScoreValLabel.isHidden = true
            clusterScoreSlider.isUserInteractionEnabled = false
            clusterSizeSlider.isUserInteractionEnabled = false
            clusterVisNodeHolder.isHidden = true
            clusterScoreSlider.value = Float(scoreVal)
        }
        else{
            clusterSizeSlider.alpha = 1
            clusterScoreSlider.alpha = 1
            clusterSizeLabel.alpha = 1
            clusterScoreLabel.alpha = 1
            clusterSizeSlider.value = Float(sizeVal)
            clusterScoreSlider.value = Float(scoreVal)
            clusterSizeValLabel.text = "\(sizeVal)"
            let v = MPCGDGenome.clusterExplodeScores[scoreVal]
            clusterScoreValLabel.text = v == -90 ? MPCGDGenome.deathSymbol : "\(v)"
            clusterVisNodeHolder.isHidden = false
            clusterSizeValLabel.isHidden = false
            clusterVisNodeHolder.isHidden = false
        }
    }
    
    func makeLive(){
        clusterSizeSlider.alpha = 1
        clusterScoreSlider.alpha = 1
        clusterSizeSlider.value = Float(2)
        clusterSizeLabel.alpha = 1
        clusterSizeValLabel.isHidden = false
        clusterScoreLabel.alpha = 1
        clusterScoreValLabel.isHidden = false
        clusterScoreSlider.isUserInteractionEnabled = true
        clusterSizeSlider.isUserInteractionEnabled = true
        clusterVisNodeHolder.isHidden = false
        clusterSizeValLabel.text = "2"
        clusterScoreValLabel.text = "0"
    }
    
    func closeDown(){
        clusterSizeSlider.isUserInteractionEnabled = false
        clusterScoreSlider.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
