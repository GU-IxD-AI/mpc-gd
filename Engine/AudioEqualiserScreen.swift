//
//  AudioEqualiserScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 09/05/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class AudioEqualiserScreen: HKComponent{
    
    let size: CGSize
    
    var sliders: [HKSlider] = []
    
    var channelNameLabels: [SKLabelNode] = []
    
    var valueLabels: [SKLabelNode] = []
    
    var isShowingTempos = false
    
    let noneText: SKMultilineLabel
    
    init(size: CGSize){
        self.size = size
        self.noneText = SKMultilineLabel(text: "No\ntracks\nchosen", size: CGSize(width: 100, height: 100), pos: CGPoint(x: -size.width/6, y: 0), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Thin", fontSize: 25, fontColor: Colours.getColour(.antiqueWhite), leading: 2, alignment: .center, shouldShowBorder: false, spacing: 15)
        super.init()
        let volumeSliderSize = CGSize(width: size.width/2, height: 50)
        var yPos = size.height/2 - 80
        var labels: [SKLabelNode] = []
        for pos in 0...4{
            let slider = HKSlider(size: volumeSliderSize)
            slider.minimumValue = 0
            slider.maximumValue = 30
            slider.position = CGPoint(x: -size.width/4 + 23, y: yPos)
            sliders.append(slider)
            addChild(slider)
            
            let channelNameLabel = SKLabelNode(text: "")
            labels.append(channelNameLabel)
            channelNameLabels.append(channelNameLabel)
            channelNameLabel.position = CGPoint(x: -size.width/2 + 15, y: yPos + 20)
            channelNameLabel.fontSize = 14
            channelNameLabel.horizontalAlignmentMode = .left
            channelNameLabel.fontColor = Colours.getColour(.antiqueWhite)
            channelNameLabel.fontName = "Helvetica Neue Thin"
            addChild(channelNameLabel)
            
            let valueLabel = SKLabelNode(text: "")
            valueLabels.append(valueLabel)
            valueLabel.position = CGPoint(x: size.width/3 - 55, y: yPos + 20)
            valueLabel.fontSize = 14
            valueLabel.fontName = "Helvetica Neue Thin"
            valueLabel.horizontalAlignmentMode = .right
            valueLabel.fontColor = Colours.getColour(.antiqueWhite)
            valueLabel.alpha = 1
            valueLabel.zPosition = 1000
            addChild(valueLabel)
            
            slider.onDragCode = { [unowned self] () -> () in
                self.updateValueShown(pos: pos)
            }
            
            yPos -= 50
        }
        for label in labels{
            label.fontName = "Helvetica Neue Thin"
            label.fontColor = Colours.getColour(.antiqueWhite)
        }
        addChild(noneText)
        noneText.alpha = 0
    }
    
    func updateValueShown(pos: Int){
        var val = sliders[pos].value
        var s = "\(Int(round(val)))"
        if self.isShowingTempos{
            val = MPCGDAudioPlayer.calculateRate(genomeTempo: Int(round(val)))
            s = String(format: "%.1f", val)
        }
        valueLabels[pos].text = "\(s)"
    }
    
    func updateAllValuesShown(){
        for p in 0...4{
            updateValueShown(pos: p)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialiseFromMPCGDGenome(MPCGDGenome: MPCGDGenome){
        isShowingTempos = false
        sliders[0].value = Float(MPCGDGenome.channelVolume1)
        sliders[1].value = Float(MPCGDGenome.channelVolume2)
        sliders[2].value = Float(MPCGDGenome.channelVolume3)
        sliders[3].value = Float(MPCGDGenome.channelVolume4)
        sliders[4].value = Float(MPCGDGenome.channelVolume5)
        for v in sliders{
            v.isUserInteractionEnabled = true
        }
        
        var channelNames = MPCGDAudioPlayer.getMusicChannelNames(MPCGDGenome: MPCGDGenome)
        let nums = [MPCGDGenome.ambiance1, MPCGDGenome.ambiance2, MPCGDGenome.ambiance3, MPCGDGenome.ambiance4, MPCGDGenome.ambiance5]
        
        var labelsShowing: [SKLabelNode] = []
        var valueLabelsShowing: [SKLabelNode] = []
        var slidersShowing: [HKSlider] = []
        for pos in 0...4{
            updateValueShown(pos: pos)
            if MPCGDGenome.soundtrackPack == 2{
                channelNames = MPCGDAudioPlayer.getAmbianceTrackNames()
                channelNameLabels[pos].text = channelNames[nums[pos]]
                sliders[pos].isUserInteractionEnabled = (nums[pos] > 0)
                sliders[pos].alpha = nums[pos] == 0 ? 0 : 1
                channelNameLabels[pos].alpha = nums[pos] == 0 ? 0 : 1
                valueLabels[pos].alpha = nums[pos] == 0 ? 0 : 1
                if sliders[pos].alpha == 1{
                    slidersShowing.append(sliders[pos])
                    labelsShowing.append(channelNameLabels[pos])
                    valueLabelsShowing.append(valueLabels[pos])
                }
            }
            else{
                channelNameLabels[pos].text = channelNames[pos]
                sliders[pos].alpha = 1
                channelNameLabels[pos].alpha = 1
                valueLabels[pos].alpha = 1
                slidersShowing.append(sliders[pos])
                labelsShowing.append(channelNameLabels[pos])
                valueLabelsShowing.append(valueLabels[pos])
            }
        }
        if labelsShowing.isEmpty{
            noneText.alpha = 1
        }
        else{
            noneText.alpha = 0
            var y = CGFloat(0)
            var addOn = CGFloat(0)
            switch labelsShowing.count{
            case 2:
                y = 40
                addOn = 100
            case 3:
                y = 65
                addOn = 80
            case 4:
                y = 82
                addOn = 64
            case 5:
                y = 88
                addOn = 50
            default:
                y = 0
            }
            for pos in 0..<labelsShowing.count{
                labelsShowing[pos].position.y = y + 20
                valueLabelsShowing[pos].position.y = y + 20
                valueLabelsShowing[pos].alpha = 1
                slidersShowing[pos].position.y = y
                y -= addOn
            }
        }
    }
    
    func closeDown(){
        for v in sliders{
            v.isUserInteractionEnabled = false
        }
    }
    
    static func getNodeForGenome(size: CGSize, MPCGDGenome: MPCGDGenome, fontSize: Int = 10, haveGap: Bool = true) -> SKNode{
        let node = SKNode()
        
        let boxHeight = size.height * 0.17
        let addOn = (size.height * 0.03/5) - 2
        let yAddOn = ((size.height * 0.2) + addOn)
        var yPos = size.height/2 - boxHeight/2
        let tracks = [MPCGDGenome.ambiance1, MPCGDGenome.ambiance2, MPCGDGenome.ambiance3, MPCGDGenome.ambiance4, MPCGDGenome.ambiance5]
        var pos = 0
        let tempos = [MPCGDGenome.channelTempo1, MPCGDGenome.channelTempo2, MPCGDGenome.channelTempo3, MPCGDGenome.channelTempo4, MPCGDGenome.channelTempo5]
        var numOff = 0
        for volume in [MPCGDGenome.channelVolume1, MPCGDGenome.channelVolume2, MPCGDGenome.channelVolume3, MPCGDGenome.channelVolume4, MPCGDGenome.channelVolume5]{
            var isOn = true
            if MPCGDGenome.soundtrackPack == 2 && tracks[pos] == 0{
                isOn = false
                numOff += 1
            }
            
            if volume > 0 && isOn{
                let prop = CGFloat(volume)/CGFloat(30)
                let subBox = getGradientNode(prop: prop, type: "Equaliser")
                node.addChild(subBox)
                subBox.position = CGPoint(x: 20, y: yPos + boxHeight/4)
            }
            if isOn{
                let prop = CGFloat(tempos[pos])/CGFloat(30)
                let subBox = getGradientNode(prop: prop, type: "Tempo")
                node.addChild(subBox)
                subBox.position = CGPoint(x: 20, y: yPos - boxHeight/4 + 1)
                let channelNames = MPCGDGenome.soundtrackPack == 1 ? MPCGDAudioPlayer.getMusicChannelNames(MPCGDGenome: MPCGDGenome) : MPCGDAudioPlayer.getAmbianceTrackNames()
                let channelText = MPCGDGenome.soundtrackPack == 1 ? channelNames[pos] : channelNames[tracks[pos]]
                let label = SKLabelNode(text: channelText)
                label.fontSize = CGFloat(fontSize)
                label.fontColor = Colours.getColour(.antiqueWhite)
                label.fontName = "Helvetica Neue Thin"
                label.verticalAlignmentMode = .center
                label.horizontalAlignmentMode = .left
                label.position.x = -45
                label.position.y = yPos
                label.zPosition = 1000
                node.addChild(label)
                yPos -= yAddOn
            }
            pos += 1
        }
        let dist = -(CGFloat(numOff) * yAddOn)/2
        for c in node.children{
            c.position.y += dist
        }
        
        return node
    }
    
    static func getGradientNode(prop: CGFloat, type: String) -> SKSpriteNode{
        let node = SKSpriteNode()
        let colours = [UIColor(red: 130/255, green: 227/255, blue: 26/255, alpha: 1),
                       UIColor(red: 176/255, green: 228/255, blue: 26/255, alpha: 1),
                       UIColor(red: 211/255, green: 245/255, blue: 30/255, alpha: 1),
                       UIColor(red: 248/255, green: 246/255, blue: 28/255, alpha: 1),
                       UIColor(red: 250/255, green: 200/255, blue: 23/255, alpha: 1),
                       UIColor(red: 248/255, green: 92/255, blue: 6, alpha: 1)]
        var w = 0
        var pos = 0
        let mW = Int(round(CGFloat(30) * prop))
        let maxWidth = (type == "Equaliser") ? mW : 5 + Int(round(CGFloat(25) * prop))
        
        while w + 5 <= maxWidth{
            let c = (type == "Equaliser") ? colours[pos] : Colours.getColour(.antiqueWhite)
            let bar = SKSpriteNode(color: c, size: CGSize(width: 3, height: 5))
            node.addChild(bar)
            bar.position.x = CGFloat(pos * 5)
            w += 5
            pos += 1
        }
        return node
    }
    
}
