//
//  AutoSizedLabelNode.swift
//  Engine
//
//  Created by Powley, Edward on 22/03/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class AutoSizedLabelNode : SKNode {
    
    fileprivate var lines : [SKLabelNode] = []
    
    var size : CGSize { didSet { reformat() } }
    var text : String { didSet { reformat() } }
    var baseFont : UIFont { didSet { reformat() } }
    var maxFontSize: CGFloat {didSet { reformat() } }
    
    var fontColor : UIColor = UIColor.black {
        didSet {
            for line in lines {
                line.fontColor = fontColor
            }
        }
    }
    
    var fontSize: CGFloat {
        didSet {
            for line in lines {
                let maxFont = FontUtils.getFontToFillRect(line.text!, baseFont: Fonts.primaryFont, size: size)
                line.fontSize = min(maxFont.pointSize, fontSize)
            }
        }
    }
    
    var verticalAlignmentMode : SKLabelVerticalAlignmentMode = .center { didSet { reformat() } }
    var horizontalAlignmentMode : SKLabelHorizontalAlignmentMode = .center { didSet { reformat() } }
    var oneLine = false
    
    init(text: String, size: CGSize, oneLine: Bool) {
        self.text = text
        self.size = size
        self.oneLine = oneLine
        self.baseFont = Fonts.primaryFont
        self.maxFontSize = Fonts.midFont.pointSize
        self.fontSize = Fonts.smallFont.pointSize
        super.init()
        reformat()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.size = CGSize(width: 1, height: 1)
        self.baseFont = Fonts.primaryFont
        self.maxFontSize = Fonts.midFont.pointSize
        self.fontSize = Fonts.smallFont.pointSize
        super.init(coder: aDecoder)
        reformat()
    }
    
    func reformat() {
        // Remove existing text
        removeChildren(in: lines)
        lines = []
        
        if text != "" {
            // Split the string into words
            let words = text.components(separatedBy: " ")
            
            if words.count == 1 || oneLine{
                let line = SKLabelNode(text: text)
                line.fontSize = FontUtils.getFontToFillRect(text, baseFont: Fonts.primaryFont, size: size).pointSize
                line.fontColor = Colours.foreground
                line.fontName = Fonts.primaryFont.familyName
                line.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
                lines.append(line)
                addChild(line)
            }
            else{
                
                // Get the text height from the font
                let textHeight = baseFont.lineHeight
                
                // Get the width of each word
                let wordWidths = words.map({ word in FontUtils.textSize(word, font: baseFont).width })
                
                // Get the width of a space character
                let spaceWidth = FontUtils.textSize(" ", font: baseFont).width
                
                // Can't use a wrap width less than the length of the longest word
                let longestWordWidth = wordWidths.max()!
                
                // Find candidate wrap lengths
                // Candidates are the widths of every sequence of 1, 2, 3, ... consecutive words in the string
                var candidateWrapWidths : [CGFloat] = []
                for window in 1 ... words.count {
                    for i in 0 ... words.count - window {
                        var candidate = spaceWidth * CGFloat(window - 1)
                        for j in i ..< i+window {
                            candidate += wordWidths[j]
                        }
                        if candidate >= longestWordWidth {
                            candidateWrapWidths.append(candidate)
                        }
                    }
                }
                
                // Find the "best" wrap width
                // This is the one which results in the largest font size when fitting to the target rectangle
                var bestWrapWidth : CGFloat = longestWordWidth
                var bestScaleFactor : CGFloat = 0
                
                for wrapWidth in candidateWrapWidths {
                    var lineWidth : CGFloat = -spaceWidth
                    var boxWidth : CGFloat = 0
                    var boxHeight : CGFloat = textHeight
                    
                    for wordWidth in wordWidths {
                        if lineWidth + spaceWidth + wordWidth <= wrapWidth {
                            // No word wrap
                            lineWidth += spaceWidth + wordWidth
                        }
                        else {
                            // Word wrap here
                            boxWidth = max(boxWidth, lineWidth)
                            lineWidth = wordWidth
                            boxHeight += textHeight
                        }
                    }
                    boxWidth = max(boxWidth, lineWidth)
                    
                    let scaleFactor = min(size.width / boxWidth, size.height / boxHeight)
                    if scaleFactor > bestScaleFactor && (baseFont.pointSize * scaleFactor) <= maxFontSize{
                        bestWrapWidth = wrapWidth
                        bestScaleFactor = scaleFactor
                    }
                }
                
                // Found the best font size!
                let fontSize = baseFont.pointSize * bestScaleFactor
                
                // Now to wrap the text and create the label nodes
                var currentLine = ""
                var lineWidth : CGFloat = -spaceWidth
                
                for i in 0 ..< words.count {
                    let word = words[i]
                    let wordWidth = wordWidths[i]
                    if lineWidth + spaceWidth + wordWidth <= bestWrapWidth {
                        // No word wrap
                        currentLine += " " + word
                        lineWidth += spaceWidth + wordWidth
                        //           assert(lineWidth * bestScaleFactor <= size.width)
                    }
                    else {
                        // Word wrap here
                        _ = addLineNode(currentLine, fontSize: fontSize)
                        currentLine = word
                        lineWidth = wordWidth
                    }
                }
                
                // Don't forget the last line!
                _ = addLineNode(currentLine, fontSize: fontSize)
                
                // Finally, set the y positions of the lines
                let scaledLineHeight = textHeight * bestScaleFactor
                var y : CGFloat
                
                // y will be the baseline position of the first line of text
                switch self.verticalAlignmentMode {
                case .top:
                    y = bestScaleFactor * -baseFont.ascender
                case .center:
                    y = CGFloat(lines.count - 1) * scaledLineHeight * 0.5 - bestScaleFactor * (baseFont.ascender - 0.5 * (baseFont.ascender - baseFont.descender))
                case .baseline:
                    y = 0
                case .bottom:
                    y = CGFloat(lines.count - 1) * scaledLineHeight - bestScaleFactor * baseFont.descender
                }
                
                for line in lines {
                    line.position = CGPoint(x: 0, y: y)
                    y -= scaledLineHeight
                }
            }
        }
    }
    
    func addLineNode(_ text: String, fontSize: CGFloat) -> SKLabelNode {
        let lineNode = SKLabelNode(text: text)
        lineNode.fontColor = self.fontColor
        lineNode.fontSize = fontSize
        lineNode.fontName = self.baseFont.fontName
        lineNode.horizontalAlignmentMode = self.horizontalAlignmentMode
        lineNode.verticalAlignmentMode = .baseline
        lineNode.fontColor = Colours.foreground
        lines.append(lineNode)
        self.addChild(lineNode)
        return lineNode
    }
}
