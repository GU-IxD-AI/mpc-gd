        //
//  SKMultilineLabel.swift
//
//  Created by Craig on 10/04/2015
//  Modified by Christopher Klapp on 11/21/2015 for line breaks \n for paragraphs
//  Copyright (c) 2015 Interactive Coconut. All rights reserved.
//
/*   USE:
 (most component parameters have defaults)
 let multiLabel = SKMultilineLabel(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", labelWidth: 250, pos: CGPoint(x: size.width / 2, y: size.height / 2))
 self.addChild(multiLabel)
 */

import SpriteKit

class SKMultilineLabel: SKNode {
    //props
    var labelWidth:Int {didSet {update()}}
    var labelHeight:Int = 0
    var text:String {didSet {update()}}
    var fontName:String {didSet {update()}}
    var altFontName:String {didSet {update()}}
    var fontSize:CGFloat {didSet {update()}}
    var pos:CGPoint {didSet {update()}}
    var fontColor:UIColor {didSet {update()}}
    var leading:Int {didSet {update()}}
    var alignment:SKLabelHorizontalAlignmentMode {didSet {update()}}
    var dontUpdate = false
    var shouldShowBorder:Bool = false {didSet {update()}}
    //display objects
    var rect:SKShapeNode?
    var spacing : CGFloat
    var labels:[SKLabelNode] = []

    init(text:String, size: CGSize, pos:CGPoint, fontName:String="Helvetica", altFontName:String="Helvetica Bold", fontSize:CGFloat=15,fontColor:UIColor=Colours.getColour(ColourNames.black),leading:Int=10, alignment:SKLabelHorizontalAlignmentMode = .center, shouldShowBorder:Bool = false, spacing : CGFloat = 1.2)
    {
        self.text = text
        self.labelWidth = Int(size.width)
        self.pos = pos
        self.fontName = fontName
        self.altFontName = altFontName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.leading = leading
        self.shouldShowBorder = shouldShowBorder
        self.alignment = alignment
        self.spacing = spacing
        super.init()

        self.isUserInteractionEnabled = false
        
        self.update()
        position = CGPoint(x: 0, y: CGFloat(labelHeight/2))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //if you want to change properties without updating the text field,
    //  set dontUpdate to false and call the update method manually.
    func wordInfo(_ w: String) -> (String, Int) {
        if w.count == 0 || w[w.startIndex] != "~" {
            return (w, 0)
        }
        return (String(w[w.index(w.startIndex, offsetBy: 1)..<w.endIndex]), 1)
    }
    
    func update() {
        if (dontUpdate) {return}
        if (labels.count>0) {
            for label in labels {
                label.removeFromParent()
            }
            labels = []
        }
        let separators = CharacterSet.whitespacesAndNewlines
        let lineSeparators = CharacterSet.newlines
        let paragraphs = text.components(separatedBy: lineSeparators)
        
        var lineCount = 0
        var fontIndex = 1
        var fontNames = [fontName, altFontName]

        var lineLength = CGFloat(0)
        var lineString = ""
        var startNewLine = true

        var spaceSize: CGFloat = 0.0
        
        for (_, paragraph) in paragraphs.enumerated() {
            let words = paragraph.components(separatedBy: separators)
            
            var finalLine = false
            var wordCount = -1
            var lineLabelStart = labels.count
            
            while true {
                if startNewLine {
                    if lineCount > 0 {
                        let n = labels.count - lineLabelStart
                        
                        // Need to determine size of " " as SK ignores leading/trailing spaces!
                        if n > 1 && spaceSize == 0.0 {
                            let tmp = SKLabelNode(fontNamed: fontNames[fontIndex])
                            tmp.fontSize = fontSize
                            tmp.text = "a b"
                            let smax = tmp.frame.size.width
                            tmp.text = "ab"
                            let smin = tmp.frame.size.width
                            spaceSize = smax - smin
                        }
                        
                        var totalLineWidth: CGFloat = n > 1 ? -spaceSize : 0.0
                        for i in lineLabelStart..<labels.count {
                            totalLineWidth += spaceSize
                            totalLineWidth += labels[i].frame.size.width
                        }
                        var linePos = CGPoint(x: pos.x, y: pos.y)
                        if (alignment == .left) {
                            linePos.x -= CGFloat(labelWidth / 2)
                        } else if (alignment == .right) {
                            linePos.x += CGFloat(labelWidth / 2)
                        } else if n > 1 {
                            linePos.x -= totalLineWidth / 2.0
                        }
                        linePos.y += CGFloat(-leading * lineCount) * spacing
                        
                        for i in lineLabelStart..<labels.count {
                            labels[i].position = linePos
                            if n > 1 {
                                labels[i].horizontalAlignmentMode = .left
                                linePos.x += spaceSize
                            }
                            linePos.x += labels[i].frame.size.width
                        }
                        if finalLine {
                            break
                        }
                    }
                    lineCount += 1
                    lineLength = 0.0
                    lineLabelStart = labels.count
                }
                lineString = ""
                var lineStringBeforeAddingWord = lineString
                var wi = wordInfo(words[wordCount + 1])
                fontIndex = wi.1
                
                // creation of the SKLabelNode itself
                let label = SKLabelNode(fontNamed: fontNames[fontIndex])
                // name each label node so you can animate it if u wish
                label.name = "line\(lineCount)"
                label.horizontalAlignmentMode = alignment
                label.fontSize = fontSize
                label.fontColor = fontColor
                
                while lineLength < CGFloat(labelWidth)
                {
                    wordCount+=1
                    if wordCount > words.count-1
                    {
                        //label.text = "\(lineString) \(words[wordCount])"
                        finalLine = true
                        break
                    }
                    else
                    {
                        wi = wordInfo(words[wordCount])
                        if wi.1 != fontIndex {
                            break
                        }
                        lineStringBeforeAddingWord = lineString
                        lineString = "\(lineString) \(wi.0)"
                        label.text = lineString
                        lineLength = label.frame.size.width
                    }
                }
                if lineLength > 0 {
                    wordCount-=1
                    if wi.1 == fontIndex && !finalLine {
                        lineString = lineStringBeforeAddingWord
                    }
                    label.text = lineString + " "
                    self.addChild(label)
                    labels.append(label)
                    startNewLine = wi.1 == fontIndex
                }
            }
        }
        labelHeight = Int(CGFloat(lineCount * leading) * spacing)
        showBorder()
    }
    
    func showBorder() {
        if (!shouldShowBorder) {return}
        if let rect = self.rect {
            self.removeChildren(in: [rect])
        }
        self.rect = SKShapeNode(rectOf: CGSize(width: CGFloat(labelWidth) * 1.1, height: CGFloat(labelHeight) * 1.1))
        if let rect = self.rect {
            rect.strokeColor = fontColor
            rect.lineWidth = 1
            rect.position = CGPoint(x: pos.x, y: pos.y - (CGFloat(labelHeight) / 2.0))
            self.addChild(rect)
        }
    }
}
