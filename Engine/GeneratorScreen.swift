//
//  GeneratorScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 22/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class GeneratorScreen: HKComponent{
    
    var zoneScoreNode: SKLabelNode! = nil
    
    var zoneScoreLabelNode: SKLabelNode! = nil
    
    var spawnHighlightNodes: [SKSpriteNode] = []
    
    var ambiancePlayTypeLabel: SKLabelNode! = nil
    
    var ambianceCategoryShowing = 0
    
    var ambianceChoicesAreShowing = false
    
    var equaliserSlidersChangeTempo = false
    
    var clustersScreen: ClustersScreen! = nil
    
    var whiteBallCollectionChosen: Int! = nil
    
    var blueBallCollectionChosen: Int! = nil
    
    var ambianceChannelShowing: Int! = nil
    
    var ambianceCategoryHighlighter: SKSpriteNode! = nil

    var ambianceChoiceHighlighter: SKSpriteNode! = nil
    
    var ambianceCategoryLabels: [SKLabelNode] = []
    
    var ambianceChoiceLabels: [SKLabelNode] = []

    var oldControllerSize: CGFloat! = nil
    
    var helpScreen: GeneratorHelpScreen! = nil
    
    var crossHairsNode = SKNode()
    
    var tinyControllerCircleNode = SKNode()
    
    var tallButtonScreenSize: CGSize! = nil
    
    var bigButtonScreenSize: CGSize! = nil
    
    var bigButtonGridBounds: CGRect! = nil
    
    var bigButtonGridNode: SKSpriteNode! = nil

    var isLocked = false
    
    var helpButton: HKButton! = nil
    
    var lockButton: HKButton! = nil
    
    var bestLabel: SKNode! = nil
    
    var extraHorizontalLine: SKSpriteNode! = nil
    
    var secondExtraHLine: SKSpriteNode! = nil
    
    let tapBallSize = CGSize(width: 18, height: 18)
    
    let smallTapBallSize = CGSize(width: 11, height: 11)
    
    var buttonSize: CGSize! = nil
    
    var squareWidth: CGFloat! = nil
    
    var squareHeight: CGFloat! = nil
    
    var horizontalLines: [SKSpriteNode] = []

    var verticalLines: [SKSpriteNode] = []
    
    var horizontalLinePositions: [CGPoint] = []
    
    var verticalLinePositions: [CGPoint] = []
    
    var trayNode = SKNode()
    
    var changeBackgroundCode: (() -> ())! = nil
    
    let textXPos = CGFloat(18)
    
    static var backgroundIconsIPad: [[UIImage]] = []
    
    static var backgroundIconsIPhone: [[UIImage]] = []

    let nilImage = ImageUtils.getBlankImage(CGSize(width: 10, height: 10), colour: UIColor.clear)
    
    var audioEqualiserScreen: AudioEqualiserScreen! = nil
    
    var volumesScreen: VolumesScreen! = nil
    
    var ballChoiceScreen: BallChoiceScreen! = nil
    
    var whiteBehavioursScreen: BallBehavioursScreen! = nil

    var blueBehavioursScreen: BallBehavioursScreen! = nil
    
    var controllerCollisionsScreen: ControllerCollisionsScreen! = nil
    
    var whiteTapScreen: BallTapScreen! = nil
    
    var blueTapScreen: BallTapScreen! = nil
    
    var gridSizeScreen: GridSizeScreen! = nil
    
    var gameEndingsScreen: GameEndingsScreen! = nil
    
    var whiteSpawnScreen: SpawnScreen! = nil
    
    var blueSpawnScreen: SpawnScreen! = nil
    
    var whiteZoneScreen: ZoneScoreScreen! = nil
    
    var blueZoneScreen: ZoneScoreScreen! = nil
    
    var overlays: [SKNode] = []
    
    var onGameAlterationCode: ((MPCGDGenome, Bool) -> ())! = nil
    
    let gridControlImageNames = ["None", "Move", "Float", "Teleport", "Rotate", "UpDown", "LeftRight", "Chase", "Grid"]
    
    let sfxIconNames = ["SFXBounce", "SFXGainPoints", "SFXLosePoints", "SFXTap", "SFXWinGame", "SFXLoseGame", "SFXExplode", "SFXLoseLife"]
    
    let sfxIconColours = [
        UIColor(red: 54/255, green: 95/255, blue: 179/255, alpha: 1), // Bounce
        UIColor(red: 115/255, green: 230/255, blue: 230/255, alpha: 1), // Gain points
        UIColor(red: 255/255, green: 191/255, blue: 128/255, alpha: 1), // Lose points
        UIColor(red: 255/255, green: 179/255, blue: 255/255, alpha: 1), // Tap
        UIColor(red: 191/255, green: 255/255, blue: 128/255, alpha: 1), // Win Game
        UIColor(red: 255/255, green: 128/255, blue: 128/255, alpha: 1), // Lose Game
        UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1), // Explode
        UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1) // Lose Life
    ]
    
    let orientations = [0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    let grains = [3, 1, 3, 4, 4, 5, 3, 4, 0, 0, 0]
    
    let gg = GridGenerator()
    
    var ticks: [HKImage] = []
    
    var tappedButtonNumbers: [Int] = []
    
    var generateButton: HKButton! = nil
    
    var helpTextNode: SKLabelNode! = nil
    
    var isAnimating = false
    
    var liveMPCGDGenome = MPCGDGenome()
    
    var tapCode: (() -> ())! = nil
    
    var buttons: [GenButton] = []
    
    var bigButton: GenButton! = nil
    
    var tallButton: GenButton! = nil
    
    var size: CGSize
    
    let whiteColour = Colours.getColour(.antiqueWhite)
    
    let blueColour = Colours.getColour(.steelBlue)
    
    var buttonSetTapped: ButtonSetEnum = .top
    
    var buttonNumTapped = -1
    
    let lineColour: UIColor
    
    weak var cycler: HKComponentCycler! = nil
    
    var menuPosition = 0
    
    var gameID: String! = nil
    
    init(size: CGSize, lineColour: UIColor, showGameDesignLabel: Bool = true, includeLock: Bool = true, isLocked: Bool, includeHelpButton: Bool = true, includeBest: Bool = true, gameID: String){
        self.lineColour = lineColour
        self.size = size
        self.isLocked = isLocked
        self.gameID = gameID
        
        super.init()
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 22)
        helpTextNode = SKLabelNode(font, Colours.getColour(.antiqueWhite), text: "Game design")
        helpTextNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        helpTextNode.position.y = size.height/2 - 8
        if showGameDesignLabel{
            addChild(helpTextNode)
        }
        initialise(includeLock, includeHelpButton: includeHelpButton, includeBest: includeBest)
    }
    
    deinit {
        //print("!!! [DEINIT] GeneratorScreen")
        helpTextNode.removeAllActions()
        helpTextNode.removeFromParent()
    }
    
    static func populateBackgroundIcons(){
        for backgroundID in MainScene.backgroundIDs{
            var iPadImageSet: [UIImage] = []
            var iPhoneImageSet: [UIImage] = []
            for pos in 0...8{ //FIXME: this is too specific for iphones and ipads which does not make sense
                let iPadIcon = UIImage(named: "\(backgroundID)\(pos)")!
                let iPhoneIcon = UIImage(named: "\(backgroundID)\(pos)")!
                iPadImageSet.append(iPadIcon)
                iPhoneImageSet.append(iPhoneIcon)
            }
            GeneratorScreen.backgroundIconsIPad.append(iPadImageSet)
            GeneratorScreen.backgroundIconsIPhone.append(iPhoneImageSet)
        }
    }
    
    func makeButtonsCold(){
        for button in buttons{
            button.isHot = false
        }
    }
    
    func disableButtons(){
        for button in buttons{
            button.enabled = false
            button.textNode.alpha = 0.5
            button.secondTextNode.alpha = 0.5
            helpTextNode.alpha = 0.5
        }
    }
    
    func enableButtons(){
        for button in buttons{
            button.hkImage.run(SKAction.fadeIn(withDuration: 0.5), completion: {
                button.enabled = true
            })
            button.textNode.run(SKAction.fadeIn(withDuration: 0.5))
            button.secondTextNode.run(SKAction.fadeIn(withDuration: 0.5))
        }
        helpTextNode.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    func alterForDeviceSimulation(){
        let bS = buttons[0].buttonSet!
        
        var screenCode: (() -> ())! = nil
        
        switch bS {
        case .top: screenCode = alterButtonsForLiveMPCGDGenome
        case .backgroundChoice: screenCode = loadBackgroundChoiceOptions
        case .backgroundShade: screenCode = loadBackgroundShadeOptions
        case .gridTop: screenCode = loadGridTop
        case .gridShape: screenCode = loadGridShapes
        case .gridOrientation: screenCode = loadGridOrientations
        case .gridGrain: screenCode = loadGridGrains
        case .gridSize: screenCode = loadGridSizes
        case .gridColour: screenCode = loadGridColours
        case .gridShade: screenCode = loadGridShades
        case .whiteSpawn: screenCode = loadWhiteSpawnOptions
        case .blueSpawn: screenCode = loadBlueSpawnOptions
        case .whiteScoreZone: screenCode = loadWhiteZoneOptions
        case .blueScoreZone: screenCode = loadBlueZoneOptions
        case .gameEndChoice: screenCode = loadGameEndChoices
        default: screenCode = nil
        }
        
        if screenCode != nil{
            returnLinesToNormal()
            lockButton?.isHidden = (bS != .top)
            helpButton?.isHidden = (bS != .top)
            bestLabel?.isHidden = (bS != .top)
            bigButton.isHidden = true
            tallButton.isHidden = true
            clustersScreen.alpha = 0
            clustersScreen.closeDown()
            ballChoiceScreen.alpha = 0
            ballChoiceScreen.closeDown()
            whiteBehavioursScreen.alpha = 0
            whiteBehavioursScreen.closeDown()
            blueBehavioursScreen.alpha = 0
            blueBehavioursScreen.closeDown()
            gridSizeScreen.alpha = 0
            gridSizeScreen.closeDown()
            gameEndingsScreen.alpha = 0
            gameEndingsScreen.closeDown()
            controllerCollisionsScreen.alpha = 0
            whiteTapScreen.alpha = 0
            whiteTapScreen.closeDown()
            blueTapScreen.alpha = 0
            blueTapScreen.closeDown()
            audioEqualiserScreen.alpha = 0
            audioEqualiserScreen.closeDown()
            volumesScreen.alpha = 0
            volumesScreen.closeDown()
            whiteSpawnScreen.alpha = 0
            whiteSpawnScreen.closeDown()
            blueSpawnScreen.alpha = 0
            blueSpawnScreen.closeDown()
            whiteZoneScreen.alpha = 0
            whiteZoneScreen.closeDown()
            blueSpawnScreen.alpha = 0
            blueSpawnScreen.closeDown()
            tappedButtonNumbers.removeAll()
            showTicks()
            removeOverlays()
            screenCode()
        }
    }
    
    func initialise(_ includeLock: Bool = true, includeHelpButton: Bool = true, includeBest: Bool = true){

        addChild(trayNode)
        
        let topMargin = CGFloat(35)
        let bottomMargin = CGFloat(25)
        
        let centralWidth = size.width
        let buttonWidth = centralWidth/3 - 3
        let centralHeight = size.height - (topMargin + bottomMargin)
        let buttonHeight = centralHeight/3
        squareWidth = buttonWidth
        squareHeight = buttonHeight
        
        buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
        let gray = lineColour.withAlphaComponent(0.2)
        let hSize = CGSize(width: size.width - 8, height: 1)
        let vSize = CGSize(width: 1, height: size.height - topMargin - bottomMargin)
        
        var x = -size.width/2 + buttonWidth/2 + 4
        var y = size.height/2 - topMargin - buttonHeight/2
        var inCol = 0
        var inRow = 0
        
        let l = SKSpriteNode(color: gray, size: hSize)
        l.position = CGPoint(x: 0, y: y + buttonHeight/2)
        addChild(l)
        horizontalLines.append(l)
        horizontalLinePositions.append(l.position)
        
        let l1 = SKSpriteNode(color: gray, size: vSize)
        l1.position = CGPoint(x: -size.width/2 + 4, y: -5)
        addChild(l1)
        verticalLines.append(l1)
        verticalLinePositions.append(l1.position)

        extraHorizontalLine = SKSpriteNode(color: gray, size: CGSize(width: hSize.width/3, height: hSize.height))
        extraHorizontalLine.isHidden = true
        addChild(extraHorizontalLine)
        
        secondExtraHLine = SKSpriteNode(color: gray, size: CGSize(width: hSize.width * 0.66, height: hSize.height))
        secondExtraHLine.isHidden = true
        secondExtraHLine.position = CGPoint(x: buttonSize.width/2, y: -7)
        addChild(secondExtraHLine)
        
        let bigButtonSize = CGSize(width: buttonWidth * 2, height: buttonHeight * 1.5)
        bigButton = GenButton(buttonSize: bigButtonSize)
        trayNode.addChild(bigButton)

        bigButton.onTouchesMovedCode = { [unowned self] (v: CGVector) -> () in
            self.handleBigButtonDrag(v)
        }
        bigButton.onDragEndCode = { [unowned self] () -> () in
            self.handleBigButtonDragEnd()
        }

        bigButton.zPosition = 1000
        bigButton.highlightSize = bigButtonSize
        bigButton.hkImage.size = bigButtonSize
        bigButton.position = CGPoint(x: buttonWidth/2, y: buttonHeight/2 + 17)
        bigButton.isHidden = true
        
        let tallButtonSize = CGSize(width: buttonWidth, height: buttonHeight * 2)
        tallButton = GenButton(buttonSize: tallButtonSize)
        trayNode.addChild(tallButton)
        tallButton.onTapStartCode = { [unowned self] () -> () in
            self.handleTallButtonTap()
        }
        
        tallButton.zPosition = 1000
        tallButton.highlightSize = tallButtonSize
        tallButton.hkImage.size = tallButtonSize
        tallButton.position = CGPoint(x: 0, y: buttonHeight/2 - 5)
        tallButton.isHidden = true
        
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 22)
        for pos in 0...8{
            let button = GenButton(buttonSize: buttonSize * 1.2)
            button.buttonNum = pos
            button.position = CGPoint(x: x, y: y)
            button.highlightSize = CGSize(width: buttonWidth, height: buttonHeight)
            
            let textNode = SKLabelNode(font, whiteColour)
            textNode.horizontalAlignmentMode = .center
            textNode.verticalAlignmentMode = .center
            textNode.position = CGPoint(x: textXPos, y: 0)
            button.textNode = textNode
            button.hkImage.addChild(textNode)

            let secondTextNode = SKLabelNode(font, whiteColour)
            secondTextNode.horizontalAlignmentMode = .center
            secondTextNode.verticalAlignmentMode = .center
            secondTextNode.position = CGPoint(x: textXPos, y: -20)
            button.secondTextNode = secondTextNode
            button.hkImage.addChild(secondTextNode)
            
            buttons.append(button)
            trayNode.addChild(button)
            button.onTapStartCode = { [unowned self, unowned button] () -> () in
                if button.enabled{
                    self.buttonSetTapped = button.buttonSet
                    self.buttonNumTapped = button.buttonNum
                    self.handleButtonTap()
                    self.showTicks()
                }
            }
            button.hkImage.size = buttonSize
            button.hkImage.imageNode.setScale(0.8)

            if inRow == 0 && inCol < 2{
                let l = SKSpriteNode(color: gray, size: vSize)
                l.position = CGPoint(x: x + buttonWidth/2 + 1, y: -(topMargin - bottomMargin)/2)
                addChild(l)
                verticalLines.append(l)
                verticalLinePositions.append(l.position)
            }
            
            x += buttonWidth
            inCol += 1
            if inCol == 3{
                let l = SKSpriteNode(color: gray, size: hSize)
                l.position = CGPoint(x: 0, y: y - buttonHeight/2)
                addChild(l)
                horizontalLines.append(l)
                horizontalLinePositions.append(l.position)
                x = -size.width/2 + buttonWidth/2 + 4
                y -= buttonHeight
                inCol = 0
                inRow += 1
            }
        }

        let l2 = SKSpriteNode(color: gray, size: vSize)
        l2.position = CGPoint(x: size.width/2 - 4, y: -5)
        addChild(l2)
        verticalLines.append(l2)
        verticalLinePositions.append(l2.position)
        
        extraHorizontalLine.position = CGPoint(x: buttonSize.width, y: horizontalLines[1].position.y)

        initialiseBallChoiceScreen()
        initialiseWhiteBehavioursScreen()
        initialiseBlueBehavioursScreen()
        initialiseGridSizeScreen()
        initialiseGameEndingsScreen()
        initialiseHelpScreen()
        initialiseControllerCollisionsScreen()
        initialiseClustersScreen()
        initialiseWhiteTapScreen()
        initialiseBlueTapScreen()
        initialiseAudioEqualiserScreen()
        initialiseVolumesScreen()
        initialiseWhiteSpawnScreen()
        initialiseBlueSpawnScreen()
        initialiseWhiteZoneScreen()
        initialiseBlueZoneScreen()
        
        if includeLock{
            let lockImage = isLocked ? "LockClosed" : "LockOpen"
            lockButton = HKButton(image: UIImage(named: lockImage)!, dilateTapBy: CGSize(width: 2, height: 2))
            addChild(lockButton)
            lockButton.position.x = -size.width/2 + 30
            lockButton.position.y = size.height/2 - 18
            lockButton.onTapStartCode = { [unowned self] () -> () in
                self.handleLockTap()
            }
            lockButton.zPosition = 1000
        }
        
        if includeBest{
            bestLabel = SKNode()
            addChild(bestLabel)
            bestLabel.position.x = size.width/2 - 40
            bestLabel.position.y = size.height/2 - 18
        }
        
        // CHANGE FOR TESTFLIGHT
        
        if !MainScene.isTestFlight && includeHelpButton{
            helpButton = HKButton(image: UIImage(named: "HelpButton")!, dilateTapBy: CGSize(width: 2, height: 2))
            addChild(helpButton)
            helpButton.position.x = size.width/2 - 30
            helpButton.position.y = size.height/2 - 18
            helpButton.onTapStartCode = { [unowned self] () -> () in
                self.handleHelpTap()
            }
            helpButton.zPosition = 1000
        }

        ambianceCategoryHighlighter = SKSpriteNode(color: HKButton.highlightColour, size: CGSize(width: squareWidth, height: squareHeight/2 + 7))
        ambianceChoiceHighlighter = SKSpriteNode(color: HKButton.highlightColour, size: CGSize(width: squareWidth, height: squareHeight/2 + 14))
        ambianceCategoryHighlighter.isHidden = true
        ambianceChoiceHighlighter.isHidden = true
        addChild(ambianceCategoryHighlighter)
        addChild(ambianceChoiceHighlighter)
        ambianceCategoryHighlighter.position.x = -squareWidth
    }
    
    func updateBestLabel(){
        if bestLabel != nil{
            bestLabel.removeAllChildren()
        }
        else{
            return
        }
        let pair = liveMPCGDGenome.getBestText(gameID: gameID)
        if pair.0 != nil{
            let bestText = SKLabelNode(text: "Best")
            if pair.1 == "Completes"{
                bestText.text = "Wins"
            }
            bestText.fontSize = 12
            bestText.fontColor = Colours.getColour(.antiqueWhite)
            bestText.fontName = "Helvetica Neue Thin"
            bestText.verticalAlignmentMode = .bottom
            bestText.horizontalAlignmentMode = .left
            bestLabel.addChild(bestText)
            bestText.zPosition = 1000
            let bestScoreText = SKLabelNode(text: pair.0)
            bestScoreText.fontSize = 12
            bestScoreText.fontColor = Colours.getColour(.antiqueWhite)
            bestScoreText.fontName = "Helvetica Neue Thin"
            bestScoreText.verticalAlignmentMode = .top
            bestScoreText.horizontalAlignmentMode = .center
            bestText.position = CGPoint(x: -2, y: 0)
            bestScoreText.position = CGPoint(x: 10, y: 0)
            bestLabel.addChild(bestScoreText)
        }
    }
    
    func handleBigButtonDragEnd(){
        if buttons[0].buttonSet == .gridSize && liveMPCGDGenome.controllerPack != 0{
            let xProp = (bigButtonGridNode.position.x/bigButtonScreenSize.width) + 0.5
            let yProp = (bigButtonGridNode.position.y/bigButtonScreenSize.height) + 0.5
            let x = Int(floor(xProp * 61))
            let y = Int(floor(yProp * 61))
            liveMPCGDGenome.gridStartX = x
            liveMPCGDGenome.gridStartY = y
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            setCrossHairAlphas()
        }
    }
    
    func handleBigButtonDrag(_ dragVector: CGVector){
        if liveMPCGDGenome.controllerPack == 0 || buttons[0].buttonSet != .gridSize{
            return
        }
        
        let newRightmost = bigButtonGridNode.position.x + bigButtonGridBounds.width/2 + dragVector.dx
        let newLeftmost = bigButtonGridNode.position.x - bigButtonGridBounds.width/2 + dragVector.dx
        let newTopmost = bigButtonGridNode.position.y + bigButtonGridBounds.height/2 + dragVector.dy
        let newBottommost = bigButtonGridNode.position.y - bigButtonGridBounds.height/2 + dragVector.dy
        if newRightmost < bigButtonScreenSize.width/2 && newLeftmost > -bigButtonScreenSize.width/2{
            bigButtonGridNode.position.x += dragVector.dx
        }
        if newTopmost < bigButtonScreenSize.height/2 && newBottommost > -bigButtonScreenSize.height/2{
            bigButtonGridNode.position.y += dragVector.dy
        }
        setCrossHairAlphas()
    }
    
    func setCrossHairAlphas(){
        crossHairsNode.children[0].alpha = round(bigButtonGridNode.x) == 0 ? 1 : 0.5
        crossHairsNode.children[1].alpha = round(bigButtonGridNode.y) == 0 ? 1 : 0.5
    }
    
    func initialiseWhiteBehavioursScreen(){
        whiteBehavioursScreen = BallBehavioursScreen(size: size)
        whiteBehavioursScreen.alpha = 0
        whiteBehavioursScreen.speedSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.whiteSpeed = Int(round(self.whiteBehavioursScreen.speedSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        whiteBehavioursScreen.bounceSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.whiteBounce = Int(round(self.whiteBehavioursScreen.bounceSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        whiteBehavioursScreen.noiseSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.whiteNoise = Int(round(self.whiteBehavioursScreen.noiseSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        whiteBehavioursScreen.initialiseFromMPCGDGenome(liveMPCGDGenome, speed: liveMPCGDGenome.whiteSpeed, noise: liveMPCGDGenome.whiteNoise, bounce: liveMPCGDGenome.whiteBounce, charType: "White")
        trayNode.addChild(whiteBehavioursScreen)
    }
    
    func initialiseBlueBehavioursScreen(){
        blueBehavioursScreen = BallBehavioursScreen(size: size)
        blueBehavioursScreen.alpha = 0
        blueBehavioursScreen.speedSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.blueSpeed = Int(round(self.blueBehavioursScreen.speedSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        blueBehavioursScreen.bounceSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.blueBounce = Int(round(self.blueBehavioursScreen.bounceSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        blueBehavioursScreen.noiseSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.blueNoise = Int(round(self.blueBehavioursScreen.noiseSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        blueBehavioursScreen.initialiseFromMPCGDGenome(liveMPCGDGenome, speed: liveMPCGDGenome.blueSpeed, noise: liveMPCGDGenome.blueNoise, bounce: liveMPCGDGenome.blueBounce, charType: "Blue")
        trayNode.addChild(blueBehavioursScreen)
    }
    
    func initialiseControllerCollisionsScreen(){
        controllerCollisionsScreen = ControllerCollisionsScreen(size: size)
        controllerCollisionsScreen.alpha = 0
        
        controllerCollisionsScreen.whiteScoreSlider.touchEndCode = { [unowned self] () -> () in
            let pos = Int(round(self.controllerCollisionsScreen.whiteScoreSlider.value))
            self.liveMPCGDGenome.whiteControllerCollisionScore = MPCGDGenome.collisionScores[pos]
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        controllerCollisionsScreen.blueScoreSlider.touchEndCode = { [unowned self] () -> () in
            let pos = Int(round(self.controllerCollisionsScreen.blueScoreSlider.value))
            self.liveMPCGDGenome.blueControllerCollisionScore = MPCGDGenome.collisionScores[pos]
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(controllerCollisionsScreen)
    }
    
    func initialiseClustersScreen(){
        clustersScreen = ClustersScreen(size: size)
        clustersScreen.alpha = 0
        clustersScreen.clusterSizeSlider.touchEndCode = { [unowned self] () -> () in
            let val = Int(round(self.clustersScreen.clusterSizeSlider.value))
            if self.clustersScreen.stem == "White"{
                self.liveMPCGDGenome.whiteCriticalClusterSize = val
            }
            else if self.clustersScreen.stem == "Blue"{
                self.liveMPCGDGenome.blueCriticalClusterSize = val
            }
            else if self.clustersScreen.stem == "Mixed"{
                self.liveMPCGDGenome.mixedCriticalClusterSize = val
            }
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        clustersScreen.clusterSizeSlider.onDragCode = { [unowned self] () -> () in
            self.handleClusterSizeDrag()
        }
        clustersScreen.clusterScoreSlider.touchEndCode = { [unowned self] () -> () in
            let val = Int(round(self.clustersScreen.clusterScoreSlider.value))
            if self.clustersScreen.stem == "White"{
                self.liveMPCGDGenome.whiteExplodeScore = MPCGDGenome.clusterExplodeScores[val]
            }
            else if self.clustersScreen.stem == "Blue"{
                self.liveMPCGDGenome.blueExplodeScore = MPCGDGenome.clusterExplodeScores[val]
            }
            else if self.clustersScreen.stem == "Mixed"{
                self.liveMPCGDGenome.mixedExplodeScore = MPCGDGenome.clusterExplodeScores[val]
            }
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(clustersScreen)
    }
    
    func handleClusterSizeDrag(){
        let stem = clustersScreen.stem
        let clusterSize = Int(round(clustersScreen.clusterSizeSlider.value))
        let visNode = getClusterNode(stem, clusterSize: clusterSize, xOffset: 0)
        clustersScreen.clusterVisNodeHolder.removeAllChildren()
        clustersScreen.clusterVisNodeHolder.addChild(visNode)
        clustersScreen.clusterSizeValLabel.text = "\(clusterSize)"
    }
    
    func initialiseWhiteTapScreen(){
        whiteTapScreen = BallTapScreen(size: size)
        whiteTapScreen.alpha = 0
        whiteTapScreen.tapScoreSlider.touchEndCode = { [unowned self] () -> () in
            let pos = Int(round(self.whiteTapScreen.tapScoreSlider.value))
            self.liveMPCGDGenome.whiteTapScore = MPCGDGenome.tapScores[pos]
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(whiteTapScreen)
    }
    
    func initialiseBlueTapScreen(){
        blueTapScreen = BallTapScreen(size: size)
        blueTapScreen.alpha = 0
        blueTapScreen.tapScoreSlider.touchEndCode = { [unowned self] () -> () in
            let pos = Int(round(self.blueTapScreen.tapScoreSlider.value))
            self.liveMPCGDGenome.blueTapScore = MPCGDGenome.tapScores[pos]
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(blueTapScreen)
    }
    
    func initialiseAudioEqualiserScreen(){
        audioEqualiserScreen = AudioEqualiserScreen(size: size)
        audioEqualiserScreen.alpha = 0
        for pos in 0..<audioEqualiserScreen.sliders.count{
            audioEqualiserScreen.sliders[pos].touchEndCode = { [unowned self] () -> () in
                self.handleEqualiserChange(channelNum: pos + 1)
            }
        }
        trayNode.addChild(audioEqualiserScreen)
    }

    func initialiseVolumesScreen(){
        volumesScreen = VolumesScreen(size: size)
        volumesScreen.alpha = 0
        volumesScreen.soundtrackVolumeSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.soundtrackMasterVolume = Int(round(self.volumesScreen.soundtrackVolumeSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            let offOKImage = self.liveMPCGDGenome.getSpawnImage(self.buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: (self.liveMPCGDGenome.sfxVolume == 0 && self.liveMPCGDGenome.soundtrackMasterVolume == 0))
            self.buttons[8].setImageAndText(offOKImage, text: "")
            self.handleMasterVolumeChange()
        }
        volumesScreen.sfxVolumeSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.sfxVolume = Int(round(self.volumesScreen.sfxVolumeSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            let offOKImage = self.liveMPCGDGenome.getSpawnImage(self.buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: (self.liveMPCGDGenome.sfxVolume == 0 && self.liveMPCGDGenome.soundtrackMasterVolume == 0))
            self.buttons[8].setImageAndText(offOKImage, text: "")
            self.handleSFXVolumeChange()
        }
        trayNode.addChild(volumesScreen)
    }
    
    func handleEqualiserChange(channelNum: Int){
        if equaliserSlidersChangeTempo{
            changeAudioTempo(channel: channelNum, tempo: CGFloat(self.audioEqualiserScreen.sliders[channelNum - 1].value))
        }
        else{
            changeAudioVolume(channel: channelNum, volume: CGFloat(self.audioEqualiserScreen.sliders[channelNum - 1].value))
        }
    }
    
    func handleMasterVolumeChange(){
        let vols = [liveMPCGDGenome.channelVolume1, liveMPCGDGenome.channelVolume2, liveMPCGDGenome.channelVolume3, liveMPCGDGenome.channelVolume4, liveMPCGDGenome.channelVolume5]
        let ambiances = [liveMPCGDGenome.ambiance1, liveMPCGDGenome.ambiance2, liveMPCGDGenome.ambiance3, liveMPCGDGenome.ambiance4, liveMPCGDGenome.ambiance5]
        
        for channelNum in 1...5{
            if liveMPCGDGenome.soundtrackPack != 2 || ambiances[channelNum - 1] > 0{
                changeAudioVolume(channel: channelNum, volume: CGFloat(vols[channelNum - 1]))
            }
            else{
                changeAudioVolume(channel: channelNum, volume: CGFloat(0))
            }
        }
    }
    
    func handleSFXVolumeChange(){
        let vol = CGFloat(liveMPCGDGenome.sfxVolume)/CGFloat(30)
        MPCGDAudio.playSound(path: MPCGDSounds.bounce, volume: Float(vol), rate: 1)
    }
    
    func changeAudioVolume(channel: Int, volume: CGFloat){
        let v = Int(round(volume))
        switch channel{
        case 1: liveMPCGDGenome.channelVolume1 = v
        case 2: liveMPCGDGenome.channelVolume2 = v
        case 3: liveMPCGDGenome.channelVolume3 = v
        case 4: liveMPCGDGenome.channelVolume4 = v
        case 5: liveMPCGDGenome.channelVolume5 = v
        default: liveMPCGDGenome.channelVolume1 = 0
        }
        onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        let mult = CGFloat(liveMPCGDGenome.soundtrackMasterVolume)/CGFloat(30)
        MPCGDAudioPlayer.setVolume(channelNum: channel, volume: CGFloat(volume/30.0) * mult)
    }
    
    func changeAudioTempo(channel: Int, tempo: CGFloat){
        var t = Int(round(tempo))
        if t >= 14 && t <= 16{
            t = 15
        }
        switch channel{
        case 1: liveMPCGDGenome.channelTempo1 = t
        case 2: liveMPCGDGenome.channelTempo2 = t
        case 3: liveMPCGDGenome.channelTempo3 = t
        case 4: liveMPCGDGenome.channelTempo4 = t
        case 5: liveMPCGDGenome.channelTempo5 = t
        default: liveMPCGDGenome.channelTempo1 = 0
        }
        onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        let rate = MPCGDAudioPlayer.calculateRate(genomeTempo: t)
        MPCGDAudioPlayer.setTempo(channelNum: channel, tempo: CGFloat(rate))
    }
    
    func initialiseBallChoiceScreen(){
        ballChoiceScreen = BallChoiceScreen(size: size)
        ballChoiceScreen.alpha = 0
        ballChoiceScreen.slider1.touchEndCode = { [unowned self] in
            self.liveMPCGDGenome.whiteMaxOnScreen = Int(round(self.ballChoiceScreen.slider1.value))
            self.ballChoiceScreen.updateLabels()
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        ballChoiceScreen.slider2.touchEndCode = { [unowned self] in
            self.liveMPCGDGenome.blueMaxOnScreen = Int(round(self.ballChoiceScreen.slider2.value))
            self.ballChoiceScreen.updateLabels()
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        ballChoiceScreen.initialiseFromMPCGDGenome(liveMPCGDGenome)
        trayNode.addChild(ballChoiceScreen)
    }
    
    func initialiseGridSizeScreen(){
        gridSizeScreen = GridSizeScreen(size: size)
        gridSizeScreen.alpha = 0
        gridSizeScreen.sizeSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.gridSize = Int(round(self.gridSizeScreen.sizeSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        gridSizeScreen.initialiseFromMPCGDGenome(liveMPCGDGenome)
        trayNode.addChild(gridSizeScreen)
        
        gridSizeScreen.sizeSlider.onDragCode = { [unowned self] () -> () in
            self.updateControllerSize()
        }
    }
    
    func updateControllerSize(){
        let sizeSlider = gridSizeScreen.sizeSlider

        let newSize = Int(round(sizeSlider.value))
        let bb = gg.getBoundingBox(bigButtonScreenSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: newSize, reflectionID: liveMPCGDGenome.gridReflection, useIconSize: true)
        
        let xOffset = bigButtonGridNode.position.x
        let yOffset = bigButtonGridNode.position.y
        
        let newRightmost = (xOffset) + bb.width/2
        let newLeftmost = (xOffset) - bb.width/2
        let newTopmost = (yOffset) + bb.height/2
        let newBottommost = (yOffset) - bb.height/2
        if newRightmost < bigButtonScreenSize.width/2 && newLeftmost > -bigButtonScreenSize.width/2 && newTopmost < bigButtonScreenSize.height/2 && newBottommost > -bigButtonScreenSize.height/2{
            
            let gridColour = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
            
            let gridImage = gg.getGridIcon(iconSize: buttonSize * (DeviceType.isIPad ? 2.0 * 3.0 / 4.0 : 2.05), controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: newSize, colour: gridColour, includeBorder: false)
            
            bigButtonGridNode.texture = SKTexture(image: gridImage)
            oldControllerSize = CGFloat(sizeSlider.value)
            liveMPCGDGenome.gridSize = newSize
            bigButtonGridBounds = gg.getBoundingBox(bigButtonScreenSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, reflectionID: liveMPCGDGenome.gridReflection, useIconSize: true)
            tinyControllerCircleNode.isHidden = liveMPCGDGenome.gridSize > 5
            bigButtonGridNode.size = buttonSize * (2.15 * (DeviceType.isIPad ? 3.0 / 4.0 : 1.0))
        }
        else if oldControllerSize != nil{
            sizeSlider.value = Float(oldControllerSize)
        }
    }
    
    func initialiseGameEndingsScreen(){
        gameEndingsScreen = GameEndingsScreen(size: size)
        gameEndingsScreen.alpha = 0
        gameEndingsScreen.winningPointsSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.pointsToWin = MPCGDGenome.winningScores[Int(round(self.gameEndingsScreen.winningPointsSlider.value))]
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        gameEndingsScreen.gameDurationSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.gameDuration = MPCGDGenome.gameDurations[Int(round(self.gameEndingsScreen.gameDurationSlider.value))]
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            if self.liveMPCGDGenome.gameDuration == 0{
                self.liveMPCGDGenome.dayNightCycle = 0
                self.changeBackgroundCode()
            }
        }
        gameEndingsScreen.livesSlider.touchEndCode = { [unowned self] () -> () in
            self.liveMPCGDGenome.numLives = Int(round(self.gameEndingsScreen.livesSlider.value))
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(gameEndingsScreen)
    }
    
    func initialiseHelpScreen(){
        helpScreen = GeneratorHelpScreen(size: size, horizontalLines: horizontalLines, verticalLines: verticalLines)
        helpScreen.isHidden = true
        addChild(helpScreen)
    }
    
    func initialiseWhiteSpawnScreen(){
        whiteSpawnScreen = SpawnScreen(size: size)
        whiteSpawnScreen.alpha = 0
        whiteSpawnScreen.rateSlider.touchEndCode = { [unowned self] () -> () in
            let pos = Int(round(self.whiteSpawnScreen.rateSlider.value))
            self.liveMPCGDGenome.whiteSpawnRate = pos
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(whiteSpawnScreen)
    }
    
    func initialiseBlueSpawnScreen(){
        blueSpawnScreen = SpawnScreen(size: size)
        blueSpawnScreen.alpha = 0
        blueSpawnScreen.rateSlider.touchEndCode = { [unowned self] () -> () in
            let pos = Int(round(self.blueSpawnScreen.rateSlider.value))
            self.liveMPCGDGenome.blueSpawnRate = pos
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(blueSpawnScreen)
    }
    
    func initialiseWhiteZoneScreen(){
        whiteZoneScreen = ZoneScoreScreen(size: size)
        whiteZoneScreen.alpha = 0
        whiteZoneScreen.scoreSlider.touchEndCode = { [unowned self] () -> () in
            let pos = Int(round(self.whiteZoneScreen.scoreSlider.value))
            self.liveMPCGDGenome.whiteZoneScore = MPCGDGenome.zoneScores[pos]
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(whiteZoneScreen)
    }
    
    func initialiseBlueZoneScreen(){
        blueZoneScreen = ZoneScoreScreen(size: size)
        blueZoneScreen.alpha = 0
        blueZoneScreen.scoreSlider.touchEndCode = { [unowned self] () -> () in
            let pos = Int(round(self.blueZoneScreen.scoreSlider.value))
            self.liveMPCGDGenome.blueZoneScore = MPCGDGenome.zoneScores[pos]
            self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        trayNode.addChild(blueZoneScreen)
    }
    
    func handleLockTap(){
        isLocked = !isLocked
        let lockImage = isLocked ? "LockClosed" : "LockOpen"
        lockButton.hkImage.imageNode.texture = SKTexture(imageNamed: lockImage)
        onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
    }
    
    func handleHelpTap(){
        HKDisableUserInteractions = true
        if helpScreen.isHidden{
            helpScreen.isHidden = false
            helpScreen.alpha = 0
            helpScreen.run(SKAction.fadeIn(withDuration: 0.3), completion: {
                HKDisableUserInteractions = false
            })
            helpScreen.showOpeningInfo(getWhiteName(), char2Name: getBlueName())
            showHelpText("Help")
            for b in buttons{
                b.highlightSize = CGSize(width: 1,height: 1)
                b.zPosition = 0
            }
        }
        else{
            for b in buttons{
                b.zPosition = 0
                b.highlightSize = b.hkImage.size
            }
            helpScreen.run(SKAction.fadeOut(withDuration: 0.3), completion: {
                self.helpScreen.isHidden = true
                HKDisableUserInteractions = false
            })
            showHelpText("Game design")
        }
    }
    
    func runLoadingAnimation(){
        isAnimating = true
        var delay = CGFloat(0.1)
        for b in buttons{
            b.alpha = 0
            let fade = SKAction.sequence([SKAction.wait(forDuration: TimeInterval(delay)), SKAction.fadeIn(withDuration: 0.2)])
            if b == buttons.last!{
                b.run(fade, completion:{
                    self.isAnimating = false
                })
            }
            else{
                b.run(fade)
            }
            delay += 0.1
        }
    }
    
    func showHelpText(_ helpText: String){
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        helpTextNode.run(fadeOut, completion: {
            self.helpTextNode.text = helpText
            self.helpTextNode.run(SKAction.fadeIn(withDuration: 0.1))
        })
    }
    
    func showTicks(){
        for button in buttons{
            button.removeHighlight()
        }
        for buttonNum in tappedButtonNumbers{
            buttons[buttonNum].showHighlight()
        }
    }
    
    func handleScoreZoneTap(){
        if buttonNumTapped < 5{
            if tappedButtonNumbers.contains(buttonNumTapped){
                tappedButtonNumbers.remove(buttonNumTapped)
            }
            else{
                tappedButtonNumbers.append(buttonNumTapped)
            }
            showTicks()
            toggleOffOK(5)
            var numID = CGFloat(0)
            for buttonNum in 0...4{
                if tappedButtonNumbers.contains(buttonNum){
                    numID += exp2(CGFloat(buttonNum))
                }
            }
            if buttonSetTapped == .whiteScoreZone{
                liveMPCGDGenome.whiteScoreZones = Int(numID)
            }
            else{
                liveMPCGDGenome.blueScoreZones = Int(numID)
            }
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
    }
    
    func moveMenuBackOne(){
        if isAnimating{
            return
        }
        bigButton.isHidden = true
        tallButton.isHidden = true
        extraHorizontalLine.isHidden = true
        secondExtraHLine.isHidden = true
        for button in buttons{
            button.hkImage.position.x = 0
            button.hkImage.imageNode.position.y = 0
            button.hkImage.imageNode.position.x = 0
            button.hkImage.imageNode.setScale(0.8)
            button.textNode.horizontalAlignmentMode = .center
            button.secondTextNode.horizontalAlignmentMode = .center
            button.textNode.position.x = textXPos
            button.secondTextNode.position.x = textXPos
            button.enabled = true
            button.useTempHighlight = true
        }
        ambianceCategoryHighlighter.isHidden = true
        ambianceChoiceHighlighter.isHidden = true
        removeOverlays()

        menuPosition -= 1
        if menuPosition == 0{
            alterButtonsForLiveMPCGDGenome()
        }
        else{
            let currentButtonSet = buttons[0].buttonSet
            for button in buttons{
                button.removeHighlight()
            }
            if currentButtonSet == .blueTapAction {
                showHelpText("\(getWhiteName()) tap score")
                loadTapActionOptions(.whiteTapAction)
                blueTapScreen.alpha = 0
                blueTapScreen.closeDown()
            }
            else if currentButtonSet == .blueSize || currentButtonSet == .whiteSize{
                showHelpText("Characters")
                loadCharacterOptions()
            }
            else if currentButtonSet == .blueBehaviours{
                showHelpText("\(getWhiteName()) movement")
                returnLinesToNormal()
                blueBehavioursScreen.alpha = 0
                loadWhiteBehaviours()
            }
            else if currentButtonSet == .gridShape{
                showHelpText("Controller shape")
                loadGridShapesTop()
            }
            else if currentButtonSet == .gridShapeTop || currentButtonSet == .gridSize || currentButtonSet == .gridColour ||
                currentButtonSet == .gridControl{
                gridSizeScreen.alpha = 0
                loadGridTop()
            }
            else if currentButtonSet == .gridCharacterCollections{
                showHelpText("Controller type")
                loadGridShapesTop()
            }
            else if currentButtonSet == .gridCharacterChoice{
                showHelpText("Controller character")
                loadGridCharacterCollections()
            }
            else if currentButtonSet == .gridOrientation{
                showHelpText("Controller shape")
                loadGridShapes()
            }
            else if currentButtonSet == .gridGrain{
                showHelpText("Controller style")
                loadGridOrientations()
            }
            else if currentButtonSet == .gridShade{
                showHelpText("Colour")
                loadGridColours()
            }
            else if currentButtonSet == .blueSpawn{
                showHelpText("\(getWhiteName()) spawn")
                loadWhiteSpawnOptions()
            }
            else if currentButtonSet == .whiteScoreZone{
                showHelpText("\(getBlueName()) spawn")
                loadBlueSpawnOptions()
            }
            else if currentButtonSet == .blueScoreZone{
                showHelpText("\(getWhiteName()) score zones")
                loadWhiteZoneOptions()
            }
            else if currentButtonSet == .backgroundChoice{
                loadGridTop()
            }
            else if currentButtonSet == .backgroundShade{
                showHelpText("Background")
                loadBackgroundChoiceOptions()
            }
            else if currentButtonSet == .characters{
                alterButtonsForLiveMPCGDGenome()
            }
            else if currentButtonSet == .blueBallCollectionChoice{
                showHelpText("Characters")
                loadCharacterOptions()
            }
            else if currentButtonSet == .whiteBallCollectionChoice{
                showHelpText("Characters")
                loadCharacterOptions()
            }
            else if currentButtonSet == .blueBallChoice{
                showHelpText("First Characters")
                loadBlueCharacterCollectionOptions()
            }
            else if currentButtonSet == .whiteBallChoice{
                showHelpText("Second Characters")
                loadWhiteCharacterCollectionOptions()
            }
            else if currentButtonSet == .audio{
                showHelpText("Audio")
                loadAudioTop()
            }
            else if currentButtonSet == .sfxPack{
                showHelpText("Audio")
                loadAudioTop()
            }
            else if currentButtonSet == .sfxBooleans{
                showHelpText("Sound effects")
                loadSFXPacks()
            }
            else if currentButtonSet == .audioChoice{
                showHelpText("Soundtrack Volumes")
                loadAudio()
            }
            else if currentButtonSet == .ambiance{
                showHelpText("Tracks")
                loadAudioChoices()
            }
        }
    }
    
    func handleTallButtonTap(){
        if isAnimating{
            return
        }
        isAnimating = true
        hideButtons({
            for button in self.buttons{
                button.textNode.position = CGPoint(x: self.textXPos, y: 0)
                button.hkImage.imageNode.position.x = 0
                button.removeHighlight()
            }
            self.removeOverlays()
            self.showHelpText("Background")
            self.menuPosition = 2
            self.loadBackgroundChoiceOptions()
            self.bigButton.isHidden = true
            self.tallButton.isHidden = true
            self.showButtons({
                //self.onGameAlterationCode?(self.liveMPCGDGenome)
            })
            self.isAnimating = false
            if self.cycler != nil {
                self.cycler.handleGeneratorScreenMenuMove()
            }
        })
    }
    
    func rotateLock(){
        lockButton.run(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1))
    }
    
    func handleButtonTap(){

        if !helpScreen.isHidden{
            if buttons[buttonNumTapped].zPosition > 0{
                if isLocked{
                    rotateLock()
                    return
                }
                HKDisableUserInteractions = true
                helpScreen.run(SKAction.fadeOut(withDuration: 0.3), completion: {
                    HKDisableUserInteractions = false
                    self.helpScreen.isHidden = true
                    for button in self.buttons{
                        button.textNode.position = CGPoint(x: self.textXPos, y: 0)
                        button.hkImage.imageNode.position.x = 0
                        button.highlightSize = button.hkImage.size
                        button.removeHighlight()
                        button.zPosition = 0
                    }
                    _ = self.changeMenu()
                })
                return
            }
            helpScreen.handleButtonTap(buttonNumTapped, liveMPCGDGenome: liveMPCGDGenome)
            buttons[buttonNumTapped].zPosition = 10000
            buttons[buttonNumTapped].alpha = 0.3
            buttons[buttonNumTapped].highlightSize = buttons[buttonNumTapped].hkImage.size
            HKDisableUserInteractions = true
            buttons[buttonNumTapped].run(SKAction.fadeIn(withDuration: 0.3), completion: {
                HKDisableUserInteractions = false
            })
            for pos in 0..<9{
                if pos != buttonNumTapped{
                    if  buttons[pos].zPosition > 0{
                        buttons[pos].run(SKAction.fadeAlpha(to: 0.2, duration: 0.3), completion: {
                            self.buttons[pos].alpha = 1
                            self.buttons[pos].zPosition = 0
                        })
                    }
                    buttons[pos].highlightSize = CGSize(width: 1, height: 1)
                }
            }
            return
        }

        if isLocked{
            rotateLock()
            return
        }
        
        if buttonSetTapped == .top && buttonNumTapped == 3 && liveMPCGDGenome.controllerPack == 0{
            return
        }
        
        if buttonSetTapped == .controllerCollisions && buttonNumTapped == 2{
            switch liveMPCGDGenome.ballControllerExplosions{
            case 0: liveMPCGDGenome.ballControllerExplosions = 1
            case 1: liveMPCGDGenome.ballControllerExplosions = 0
            case 2: liveMPCGDGenome.ballControllerExplosions = 3
            case 3: liveMPCGDGenome.ballControllerExplosions = 2
            default: liveMPCGDGenome.ballControllerExplosions = 0
            }
            buttons[2].hkImage.imageNode.removeAllChildren()
            addControllerCollisionIcon("White", buttonNum: 2)
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            return
        }
        else if buttonSetTapped == .controllerCollisions && buttonNumTapped == 5{
            switch liveMPCGDGenome.ballControllerExplosions{
            case 0: liveMPCGDGenome.ballControllerExplosions = 2
            case 1: liveMPCGDGenome.ballControllerExplosions = 3
            case 2: liveMPCGDGenome.ballControllerExplosions = 0
            case 3: liveMPCGDGenome.ballControllerExplosions = 1
            default: liveMPCGDGenome.ballControllerExplosions = 0
            }
            buttons[5].hkImage.imageNode.removeAllChildren()
            addControllerCollisionIcon("Blue", buttonNum: 5)
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            return
        }
        
        for button in buttons{
            button.hkImage.position.x = 0
            button.enabled = true
        }
        
        if buttonSetTapped == .whiteTapAction && buttonNumTapped < 6{
            tappedButtonNumbers.removeAll()
            if liveMPCGDGenome.whiteTapAction == 0{
                liveMPCGDGenome.whiteTapAction = buttonNumTapped + 1
                tappedButtonNumbers.append(buttonNumTapped)
            }
            else if liveMPCGDGenome.whiteTapAction == buttonNumTapped + 1{
                liveMPCGDGenome.whiteTapAction = 0
            }
            else{
                liveMPCGDGenome.whiteTapAction = buttonNumTapped + 1
                tappedButtonNumbers.append(buttonNumTapped)
            }
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            let offOKImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: liveMPCGDGenome.whiteTapAction == 0)
            buttons[8].setImageAndText(offOKImage, text: "")
            showTicks()
        }
        else if buttonSetTapped == .blueTapAction && buttonNumTapped < 6{
            tappedButtonNumbers.removeAll()
            if liveMPCGDGenome.blueTapAction == 0{
                liveMPCGDGenome.blueTapAction = buttonNumTapped + 1
                tappedButtonNumbers.append(buttonNumTapped)
            }
            else if liveMPCGDGenome.blueTapAction == buttonNumTapped + 1{
                liveMPCGDGenome.blueTapAction = 0
            }
            else{
                liveMPCGDGenome.blueTapAction = buttonNumTapped + 1
                tappedButtonNumbers.append(buttonNumTapped)
            }
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            let offOKImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: liveMPCGDGenome.blueTapAction == 0)
            buttons[8].setImageAndText(offOKImage, text: "")
            showTicks()
        }
        else if buttonSetTapped == .whiteBehaviours && buttonNumTapped != 8{
            tappedButtonNumbers.removeAll()
            if buttonNumTapped == 6{
                if liveMPCGDGenome.whiteRotation == 0 || liveMPCGDGenome.whiteRotation == 2{
                    liveMPCGDGenome.whiteRotation = 1
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                    tappedButtonNumbers.append(6)
                }
                else if liveMPCGDGenome.whiteRotation == 1{
                    liveMPCGDGenome.whiteRotation = 0
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
            }
            else if buttonNumTapped == 7{
                if liveMPCGDGenome.whiteRotation == 0 || liveMPCGDGenome.whiteRotation == 1{
                    liveMPCGDGenome.whiteRotation = 2
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                    tappedButtonNumbers.append(7)
                }
                else if liveMPCGDGenome.whiteRotation == 2{
                    liveMPCGDGenome.whiteRotation = 0
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
            }
            showTicks()
        }
        else if buttonSetTapped == .blueBehaviours && buttonNumTapped != 8{
            tappedButtonNumbers.removeAll()
            if buttonNumTapped == 6{
                if liveMPCGDGenome.blueRotation == 0 || liveMPCGDGenome.blueRotation == 2{
                    liveMPCGDGenome.blueRotation = 1
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                    tappedButtonNumbers.append(6)
                }
                else if liveMPCGDGenome.blueRotation == 1{
                    liveMPCGDGenome.blueRotation = 0
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
            }
            else if buttonNumTapped == 7{
                if liveMPCGDGenome.blueRotation == 0 || liveMPCGDGenome.blueRotation == 1{
                    liveMPCGDGenome.blueRotation = 2
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                    tappedButtonNumbers.append(7)
                }
                else if liveMPCGDGenome.blueRotation == 2{
                    liveMPCGDGenome.blueRotation = 0
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
            }
            showTicks()
        }
        else if buttonNumTapped != 5 && (buttonSetTapped == .whiteScoreZone || buttonSetTapped == .blueScoreZone){
            handleScoreZoneTap()
        }
        else if buttonNumTapped != 8 && (buttonSetTapped == .whiteSpawn || buttonSetTapped == .blueSpawn){
            var q = (2, 3)
            switch buttonNumTapped{
            case 0: q = (0, 1)
            case 1: q = (4, 5)
            case 2: q = (8, 9)
            case 3: q = (2, 3)
            case 4: q = (6, 7)
            case 5: q = (10, 11)
            default: q = (2, 3)
            }
            let p = buttons[buttonNumTapped].tappedAt.x < 0 ? q.0 : q.1
            spawnHighlightNodes[p].isHidden = !spawnHighlightNodes[p].isHidden
            var hasSpawning = false
            var num = CGFloat(0)
            for pos in 0...3{
                if spawnHighlightNodes[pos].isHidden == false{
                    num += exp2(CGFloat(pos))
                }
            }
            hasSpawning = (num > 0)
            if buttonSetTapped == .whiteSpawn{
                liveMPCGDGenome.whiteEdgeSpawnPositions = Int(round(num))
            }
            else{
                liveMPCGDGenome.blueEdgeSpawnPositions = Int(round(num))
            }
            
            num = CGFloat(0)
            for pos in 4...7{
                if spawnHighlightNodes[pos].isHidden == false{
                    num += exp2(CGFloat(pos - 4))
                }
            }
            hasSpawning = hasSpawning || (num > 0)
            if buttonSetTapped == .whiteSpawn{
                liveMPCGDGenome.whiteMidSpawnPositions = Int(round(num))
            }
            else{
                liveMPCGDGenome.blueMidSpawnPositions = Int(round(num))
            }
            
            num = CGFloat(0)
            for pos in 8...11{
                if spawnHighlightNodes[pos].isHidden == false{
                    num += exp2(CGFloat(pos - 8))
                }
            }
            hasSpawning = hasSpawning || (num > 0)
            if buttonSetTapped == .whiteSpawn{
                liveMPCGDGenome.whiteCentralSpawnPositions = Int(round(num))
            }
            else{
                liveMPCGDGenome.blueCentralSpawnPositions = Int(round(num))
            }
            
            let okText = hasSpawning ? "OK" : "Off"
            setOKText(buttons[8], text: okText)
            onGameAlterationCode?(liveMPCGDGenome, self.isLocked)
        }
        else if buttonNumTapped != 8 && (buttonSetTapped == .whiteSize || buttonSetTapped == .blueSize){
            if tappedButtonNumbers.contains(buttonNumTapped){
                if tappedButtonNumbers.count > 1{
                    tappedButtonNumbers.remove(buttonNumTapped)
                }
            }
            else{
                tappedButtonNumbers.append(buttonNumTapped)
            }
            if buttonSetTapped == .whiteSize{
                liveMPCGDGenome.whiteSizes = getBinaryButtonNumber()
            }
            else{
                liveMPCGDGenome.blueSizes = getBinaryButtonNumber()
            }
            toggleOffOK()
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        else if buttonSetTapped == .whiteClusters && buttonNumTapped == 7 && liveMPCGDGenome.whiteCriticalClusterSize == 0{
            liveMPCGDGenome.whiteCriticalClusterSize = 2
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            clustersScreen.makeLive()
            let visNode = getClusterNode("White", clusterSize: 2, xOffset: 0)
            clustersScreen.clusterVisNodeHolder.removeAllChildren()
            clustersScreen.clusterVisNodeHolder.addChild(visNode)
        }
        else if buttonSetTapped == .blueClusters && buttonNumTapped == 7 && liveMPCGDGenome.blueCriticalClusterSize == 0{
            liveMPCGDGenome.blueCriticalClusterSize = 2
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            clustersScreen.makeLive()
            let visNode = getClusterNode("Blue", clusterSize: 2, xOffset: 0)
            clustersScreen.clusterVisNodeHolder.removeAllChildren()
            clustersScreen.clusterVisNodeHolder.addChild(visNode)
        }
        else if buttonSetTapped == .mixedClusters && buttonNumTapped == 7 && liveMPCGDGenome.mixedCriticalClusterSize == 0{
            liveMPCGDGenome.mixedCriticalClusterSize = 2
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            clustersScreen.makeLive()
            let visNode = getClusterNode("Mixed", clusterSize: 2, xOffset: 0)
            clustersScreen.clusterVisNodeHolder.removeAllChildren()
            clustersScreen.clusterVisNodeHolder.addChild(visNode)
        }
        else if buttonSetTapped == .gridSize && buttonNumTapped != 8{
            let pRID = liveMPCGDGenome.gridReflection
            let positions = [0, 3, 6, 7]
            let pos = positions.index(of: buttonNumTapped)
            if pos != nil{
                liveMPCGDGenome.gridReflection = pos!
                for p in tappedButtonNumbers{
                    buttons[p].removeHighlight()
                }
                tappedButtonNumbers.removeAll()
                tappedButtonNumbers.append(buttonNumTapped)
                buttons[buttonNumTapped].showHighlight()
                CharacterIconHandler.alterNodeOrientation(isGrid: liveMPCGDGenome.controllerPack == 1, collectionNum: liveMPCGDGenome.gridShape, characterNum: liveMPCGDGenome.gridOrientation, reflectionID: liveMPCGDGenome.gridReflection, node: bigButtonGridNode)
                handleControllerReflectionChange(previousReflectionID: pRID)
                onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            }
        }
        else if buttonNumTapped == 2 && buttonSetTapped == .audio{
            equaliserSlidersChangeTempo = !equaliserSlidersChangeTempo
            let lwg = liveMPCGDGenome
            if equaliserSlidersChangeTempo{
                let tempos = [lwg.channelTempo1, lwg.channelTempo2, lwg.channelTempo3, lwg.channelTempo4, lwg.channelTempo5]
                for pos in 0...4{
                    audioEqualiserScreen.sliders[pos].value = Float(tempos[pos])
                }
                showHelpText("Soundtrack Tempos")
                changeAudioToggleButton(show: "Volumes")
                audioEqualiserScreen.isShowingTempos = true
                audioEqualiserScreen.updateAllValuesShown()
            }
            else{
                let volumes = [lwg.channelVolume1, lwg.channelVolume2, lwg.channelVolume3, lwg.channelVolume4, lwg.channelVolume5]
                for pos in 0...4{
                    audioEqualiserScreen.sliders[pos].value = Float(volumes[pos])
                }
                showHelpText("Soundtrack Volumes")
                changeAudioToggleButton(show: "Tempos")
                audioEqualiserScreen.isShowingTempos = false
                audioEqualiserScreen.updateAllValuesShown()
            }
        }
        else if buttonNumTapped < 6 && buttonSetTapped == .audioChoice{
            buttons[buttonNumTapped].showHighlight()
            tappedButtonNumbers = [buttonNumTapped]
            liveMPCGDGenome.soundtrackPack = 1
            liveMPCGDGenome.musicChoice = buttonNumTapped
            liveMPCGDGenome.channelTempo1 = 15
            liveMPCGDGenome.channelTempo2 = 15
            liveMPCGDGenome.channelTempo3 = 15
            liveMPCGDGenome.channelTempo4 = 15
            liveMPCGDGenome.channelTempo5 = 15
            MPCGDAudioPlayer.handleGenomeChange(MPCGDGenome: liveMPCGDGenome)
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        }
        else if buttonNumTapped != 8 && buttonSetTapped == .sfxBooleans{
            if tappedButtonNumbers.contains(buttonNumTapped){
                tappedButtonNumbers.remove(buttonNumTapped)
            }
            else{
                tappedButtonNumbers.append(buttonNumTapped)
            }
            liveMPCGDGenome.sfxBooleans = getBinaryButtonNumber()
            for pos in tappedButtonNumbers{
                MPCGDSounds.soundsAllowed.append(MPCGDSounds.sounds[pos])
            }
            if tappedButtonNumbers.contains(buttonNumTapped){
                MPCGDAudioPlayer.loadAndPlaySoundEffect(effectName: MPCGDSounds.sounds[buttonNumTapped])
            }
            onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
            showTicks()
        }
        else if (buttonNumTapped == 2 || buttonNumTapped == 5) && buttonSetTapped == .gridTop{
            if buttonNumTapped == 2{
                if liveMPCGDGenome.dayNightCycle == 1{
                    liveMPCGDGenome.dayNightCycle = 0
                    buttons[2].removeHighlight()
                    tappedButtonNumbers = []
                    changeBackgroundCode?()
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
                else{
                    liveMPCGDGenome.dayNightCycle = 1
                    tappedButtonNumbers = [2]
                    changeBackgroundCode?()
                    setUpTallButton()
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
                setUpTallButton()
            }
            else if buttonNumTapped == 5{
                if liveMPCGDGenome.dayNightCycle == 2{
                    liveMPCGDGenome.dayNightCycle = 0
                    tappedButtonNumbers = []
                    changeBackgroundCode?()
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
                else{
                    liveMPCGDGenome.dayNightCycle = 2
                    tappedButtonNumbers = [5]
                    changeBackgroundCode?()
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
                setUpTallButton()
            }
        }
        else if buttonNumTapped != 8 && buttonSetTapped == .ambiance{
            if buttonNumTapped == 7{
                toggleSoloAmbiance()
            }
            else{
                handleAmbianceButtonTap(buttonNum: buttonNumTapped)
            }
        }
        else{
            if isAnimating{
                return
            }
            isAnimating = true
            hideButtons({
                for button in self.buttons{
                    button.textNode.position = CGPoint(x: self.textXPos, y: 0)
                    button.hkImage.imageNode.position.x = 0
                    button.removeHighlight()
                }
                let requiresSave = self.changeMenu()
                self.showButtons({
                    if requiresSave{
                        self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                    }
                })
                self.isAnimating = false
            })
        }
    }
    
    func setOKText(_ button: GenButton, text: String){
        button.hkImage.imageNode.removeAllChildren()
        let textNode = SKLabelNode(text: text)
        textNode.verticalAlignmentMode = .center
        textNode.fontName = "Helvetica Neue Thin"
        textNode.fontColor = Colours.getColour(.antiqueWhite)
        textNode.fontSize = 28
        button.hkImage.imageNode.addChild(textNode)
        overlays.append(textNode)
    }
    
    func toggleOffOK(_ buttonNum: Int! = 8){
        let onImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        let offImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: true)
        if tappedButtonNumbers.isEmpty{
            buttons[buttonNum].setImageAndText(offImage, text: "")
        }
        else{
            buttons[buttonNum].setImageAndText(onImage, text: "")
        }
    }
    
    func handleControllerReflectionChange(previousReflectionID: Int){
        
        checkAndAlterGridSize()
        self.onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
        
        let gridColour = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
        
        let gridImage = gg.getGridIcon(iconSize: buttonSize * 2.05, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, colour: gridColour, includeBorder: false)
        
        bigButtonGridBounds = gg.getBoundingBox(bigButtonScreenSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, reflectionID: liveMPCGDGenome.gridReflection, useIconSize: true)
        tinyControllerCircleNode.isHidden = liveMPCGDGenome.gridSize > 5
        
        bigButtonGridNode.texture = SKTexture(image: gridImage)
        gridSizeScreen.sizeSlider.value = Float(liveMPCGDGenome.gridSize)
    }
    
    func returnLinesToNormal(){
        for lpos in 0..<verticalLines.count{
            verticalLines[lpos].position = verticalLinePositions[lpos]
            verticalLines[lpos].setScale(1)
            verticalLines[lpos].alpha = 1
        }
        for lpos in 0..<horizontalLines.count{
            horizontalLines[lpos].position = horizontalLinePositions[lpos]
            horizontalLines[lpos].setScale(1)
            horizontalLines[lpos].alpha = 1
        }
        extraHorizontalLine.isHidden = true
        secondExtraHLine.isHidden = true
    }
    
    func changeMenu() -> Bool{
        var requiresSave = false
        bigButton.isHidden = true
        tallButton.isHidden = true
        extraHorizontalLine.isHidden = true
        secondExtraHLine.isHidden = true
        var needsPipUpdate = true
        var needsBackgroundChange = false
        removeOverlays()
        for b in buttons{
            b.hkImage.imageNode.position.x = 0
            b.hkImage.imageNode.position.y = 0
            b.hkImage.imageNode.setScale(0.8)
            b.textNode.horizontalAlignmentMode = .center
            b.secondTextNode.horizontalAlignmentMode = .center
            b.textNode.position.x = textXPos
            b.secondTextNode.position.x = textXPos
            b.enabled = true
            b.useTempHighlight = true
            b.removeHighlight()
        }
        if buttonSetTapped == .top{
            handleTopButtonTap()
            needsPipUpdate = false
        }
        else if buttonSetTapped == .controllerCollisions && buttonNumTapped == 7{
            alterButtonsForLiveMPCGDGenome()
        }
        else if buttonSetTapped == .clusterTop{
            if buttonNumTapped == 3{
                loadClusters(stem: "White")
            }
            else if buttonNumTapped == 4{
                loadClusters(stem: "Blue")
            }
            else if buttonNumTapped == 5{
                loadClusters(stem: "Mixed")
            }
        }
        else if (buttonSetTapped == .whiteClusters || buttonSetTapped == .blueClusters || buttonSetTapped == .mixedClusters) && buttonNumTapped == 8{
            alterButtonsForLiveMPCGDGenome()
        }
        else if buttonSetTapped == .whiteTapAction && buttonNumTapped == 8{
            showHelpText("\(getBlueName()) tap")
            whiteTapScreen.alpha = 0
            whiteTapScreen.closeDown()
            loadTapActionOptions(.blueTapAction)
            menuPosition = 2
        }
        else if buttonSetTapped == .blueTapAction && buttonNumTapped == 8{
            alterButtonsForLiveMPCGDGenome()
        }
        else if buttonSetTapped == .whiteSize && buttonNumTapped == 8{
            liveMPCGDGenome.whiteSizes = getBinaryButtonNumber()
            showHelpText("Characters")
            menuPosition = 1
            loadCharacterOptions()
        }
        else if buttonSetTapped == .blueSize && buttonNumTapped == 8{
            liveMPCGDGenome.blueSizes = getBinaryButtonNumber()
            showHelpText("Characters")
            menuPosition = 1
            loadCharacterOptions()
        }
        else if buttonSetTapped == .characters && buttonNumTapped == 0{
            showHelpText("First characters")
            menuPosition = 2
            loadWhiteCharacterCollectionOptions()
        }
        else if buttonSetTapped == .characters && buttonNumTapped == 3{
            showHelpText("Second characters")
            menuPosition = 2
            loadBlueCharacterCollectionOptions()
        }
        else if buttonSetTapped == .whiteBallCollectionChoice{
            whiteBallCollectionChosen = buttonNumTapped
            showHelpText(CharacterIconHandler.getCollectionName(buttonNumTapped))
            menuPosition = 3
            loadWhiteCharacterOptions(buttonNumTapped)
        }
        else if buttonSetTapped == .blueBallCollectionChoice{
            blueBallCollectionChosen = buttonNumTapped
            showHelpText(CharacterIconHandler.getCollectionName(buttonNumTapped))
            menuPosition = 3
            loadBlueCharacterOptions(buttonNumTapped)
        }
        else if buttonSetTapped == .whiteBallChoice{
            liveMPCGDGenome.whiteBallCollection = whiteBallCollectionChosen
            liveMPCGDGenome.whiteBallChoice = buttonNumTapped
            showHelpText("Characters")
            loadCharacterOptions()
            menuPosition = 1
            requiresSave = true
        }
        else if buttonSetTapped == .blueBallChoice{
            liveMPCGDGenome.blueBallCollection = blueBallCollectionChosen
            liveMPCGDGenome.blueBallChoice = buttonNumTapped
            showHelpText("Characters")
            loadCharacterOptions()
            menuPosition = 1
            requiresSave = true
        }
        else if buttonSetTapped == .characters && buttonNumTapped == 8{
            alterButtonsForLiveMPCGDGenome()
        }
        else if buttonSetTapped == .characters && buttonNumTapped == 6{
            showHelpText("\(getWhiteName()) sizes")
            menuPosition = 2
            loadWhiteSizeOptions()
            loadTapPositions(liveMPCGDGenome.whiteSizes)
            showTicks()
            toggleOffOK()
        }
        else if buttonSetTapped == .characters && buttonNumTapped == 7{
            showHelpText("\(getBlueName()) sizes")
            menuPosition = 2
            self.loadBlueSizeOptions()
            loadTapPositions(liveMPCGDGenome.blueSizes)
            showTicks()
            toggleOffOK()
        }
        else if buttonSetTapped == .whiteClusters && buttonNumTapped == 7{
            if liveMPCGDGenome.whiteCriticalClusterSize != 0{
                liveMPCGDGenome.whiteCriticalClusterSize = 0
                requiresSave = true
                alterButtonsForLiveMPCGDGenome()
            }
        }
        else if buttonSetTapped == .blueClusters && buttonNumTapped == 7{
            if liveMPCGDGenome.blueCriticalClusterSize != 0{
                liveMPCGDGenome.blueCriticalClusterSize = 0
                requiresSave = true
                alterButtonsForLiveMPCGDGenome()
            }
        }
        else if buttonSetTapped == .mixedClusters && buttonNumTapped == 7{
            if liveMPCGDGenome.mixedCriticalClusterSize != 0{
                liveMPCGDGenome.mixedCriticalClusterSize = 0
                requiresSave = true
                alterButtonsForLiveMPCGDGenome()
            }
        }
        else if buttonSetTapped == .backgroundChoice{
            liveMPCGDGenome.backgroundChoice = buttonNumTapped
            requiresSave = true
            if liveMPCGDGenome.dayNightCycle == 0{
                menuPosition = 3
                showHelpText("Night & day")
                loadBackgroundShadeOptions()
            }
            else{
                menuPosition = 1
                loadGridTop()
            }
            needsBackgroundChange = true
        }
        else if buttonSetTapped == .backgroundShade{
            liveMPCGDGenome.backgroundShade = buttonNumTapped
            requiresSave = true
            showHelpText("Controller & scene")
            menuPosition = 1
            loadGridTop()
            needsBackgroundChange = true
        }
        else if buttonSetTapped == .gridTop{
            if buttonNumTapped == 0{
                showHelpText("Controller shape")
                menuPosition = 2
                loadGridShapesTop()
            }
            else if buttonNumTapped == 3{
                showHelpText("Size")
                menuPosition = 2
                loadGridSizes()
            }
            else if buttonNumTapped == 6 {
                showHelpText("Colour")
                menuPosition = 2
                loadGridColours()
            }
            else if buttonNumTapped == 7{
                showHelpText("Control")
                menuPosition = 2
                loadGridControls()
            }
            else if buttonNumTapped == 8{
                alterButtonsForLiveMPCGDGenome()
            }
        }
        else if buttonSetTapped == .audioTop{
            if buttonNumTapped == 8{
                alterButtonsForLiveMPCGDGenome()
            }
            else if buttonNumTapped == 6{
                showHelpText("Audio")
                menuPosition = 2
                loadAudio()
            }
            else if buttonNumTapped == 7{
                showHelpText("Sound effects")
                menuPosition = 2
                loadSFXPacks()
            }
        }
        else if buttonSetTapped == .audio{
            if buttonNumTapped == 8{
                alterButtonsForLiveMPCGDGenome()
            }
            if buttonNumTapped == 5{
                menuPosition = 2
                loadAudioChoices()
            }
        }
        else if buttonSetTapped == .audioChoice{
            if buttonNumTapped == 8{
                menuPosition = 1
                loadAudio()
            }
            else if buttonNumTapped == 7{
                liveMPCGDGenome.soundtrackPack = 0
                onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                MPCGDAudioPlayer.handleGenomeChange(MPCGDGenome: liveMPCGDGenome)
                menuPosition = 1
                loadAudio()
            }
            else if buttonNumTapped == 6{
                let wasAlready = (liveMPCGDGenome.soundtrackPack == 2)
                if !wasAlready{
                    liveMPCGDGenome.soundtrackPack = 2
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                    MPCGDAudioPlayer.handleGenomeChange(MPCGDGenome: liveMPCGDGenome)
                }
                menuPosition = 3
                loadAmbiance()
            }
        }
        else if buttonSetTapped == .ambiance{
            if buttonNumTapped == 8{
                loadAudio()
            }
        }
        else if buttonSetTapped == .sfxPack{
            liveMPCGDGenome.sfxPack = buttonNumTapped
            MPCGDSounds.precache(packName: MPCGDSounds.sfxPackNames[liveMPCGDGenome.sfxPack])
            requiresSave = true
            loadSFXBooleans()
            menuPosition = 3
        }
        else if buttonSetTapped == .sfxBooleans{
            if buttonNumTapped == 8{
                alterButtonsForLiveMPCGDGenome()
            }
        }
        else if buttonSetTapped == .gridShapeTop{
            if buttonNumTapped == 5{
                liveMPCGDGenome.controllerPack = 0
                requiresSave = true
                menuPosition = 1
                showHelpText("Controller & scene")
                loadGridTop()
            }
            else if buttonNumTapped == 3{
                liveMPCGDGenome.controllerPack = 1
                requiresSave = true
                menuPosition = 3
                showHelpText("Controller shape")
                loadGridShapes()
            }
            else if buttonNumTapped == 4{
                liveMPCGDGenome.controllerPack = 2
                requiresSave = true
                menuPosition = 3
                showHelpText("Controller emoji")
                loadGridCharacterCollections()
            }
        }
        else if buttonSetTapped == .gridShape{
            liveMPCGDGenome.gridShape = buttonNumTapped
            checkAndAlterGridSize()
            requiresSave = true
            loadGridOrientations()
            showHelpText("Controller style")
            menuPosition = 3
        }
        else if buttonSetTapped == .gridCharacterCollections{
            liveMPCGDGenome.gridShape = buttonNumTapped
            checkAndAlterGridSize()
            requiresSave = true
            loadGridCharacterOptions()
            showHelpText(CharacterIconHandler.collectionNames[liveMPCGDGenome.gridShape])
            menuPosition = 4
        }
        else if buttonSetTapped == .gridCharacterChoice{
            liveMPCGDGenome.gridOrientation = buttonNumTapped
            checkAndAlterGridSize()
            requiresSave = true
            showHelpText("Controller & scene")
            loadGridTop()
            menuPosition = 1
        }
        else if buttonSetTapped == .gridOrientation{
            requiresSave = true
            liveMPCGDGenome.gridOrientation = buttonNumTapped
            checkAndAlterGridSize()
            if liveMPCGDGenome.controllerPack == 2{
                showHelpText("Controller & scene")
                loadGridTop()
                menuPosition = 1
            }
            else{
                showHelpText("Controller grain")
                menuPosition = 4
                loadGridGrains()
            }
        }
        else if buttonSetTapped == .gridGrain{
            requiresSave = true
            liveMPCGDGenome.gridGrain = buttonNumTapped
            checkAndAlterGridSize()
            menuPosition = 1
            loadGridTop()
        }
        else if buttonSetTapped == .gridSize && buttonNumTapped == 8{
            requiresSave = false
            menuPosition = 1
            loadGridTop()
        }
        else if buttonSetTapped == .gridColour{
            requiresSave = true
            liveMPCGDGenome.gridColour = buttonNumTapped
            showHelpText("Night & day")
            menuPosition = 3
            if buttonNumTapped == 8 && liveMPCGDGenome.controllerPack == 2{
                loadGridTop()
            }
            else{
                loadGridShades()
            }
        }
        else if buttonSetTapped == .gridShade{
            requiresSave = true
            liveMPCGDGenome.gridShade = buttonNumTapped
            menuPosition = 1
            loadGridTop()
        }
        else if buttonSetTapped == .gridControl{
            requiresSave = true
            liveMPCGDGenome.gridControl = buttonNumTapped
            menuPosition = 1
            loadGridTop()
        }
        else if buttonSetTapped == .whiteBehaviours && buttonNumTapped == 8{
            showHelpText("\(getBlueName()) movement")
            loadBlueBehaviours()
            menuPosition = 2
        }
        else if buttonSetTapped == .blueBehaviours && buttonNumTapped == 8{
            alterButtonsForLiveMPCGDGenome()
        }
        else if buttonSetTapped == .whiteSpawn{
            if buttonNumTapped == 8{
                showHelpText("\(getBlueName()) spawn")
                loadBlueSpawnOptions()
                menuPosition = 2
            }
        }
        else if buttonSetTapped == .blueSpawn{
            if buttonNumTapped == 8{
                showHelpText("\(getWhiteName()) score zones")
                loadWhiteZoneOptions()
                menuPosition = 3
            }
        }
        else if buttonSetTapped == .whiteScoreZone && buttonNumTapped == 5{
            showHelpText("\(getBlueName()) score zones")
            loadBlueZoneOptions()
            menuPosition = 4
        }
        else if buttonSetTapped == .blueScoreZone && buttonNumTapped == 5{
            tappedButtonNumbers.removeAll()
            showTicks()
            alterButtonsForLiveMPCGDGenome()
        }
        else if buttonSetTapped == .gameEndChoice && buttonNumTapped == 8{
            alterButtonsForLiveMPCGDGenome()
        }

        if needsBackgroundChange{
            changeBackgroundCode?()
            //let logoTextColour = liveMPCGDGenome.backgroundShade > 4 ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
     //       cycler.animatePipColourChange(logoTextColour.withAlphaComponent(0.8), unselectedColour: logoTextColour.withAlphaComponent(0.2), duration: 0.5, generatorScreenMoved: needsPipUpdate)
        }
        if cycler != nil && needsPipUpdate && !needsBackgroundChange {
            self.cycler.handleGeneratorScreenMenuMove()
        }
        return requiresSave
    }
    
    func loadTapPositions(_ numID: Int){
        tappedButtonNumbers.removeAll()
        for pos in 0...7{
            if Int(exp2(Double(pos))) & numID != 0{
                tappedButtonNumbers.append(pos)
            }
        }
    }
    
    func getBinaryButtonNumber() -> Int{
        var numID = CGFloat(0)
        for buttonNum in tappedButtonNumbers{
            numID += exp2(CGFloat(buttonNum))
        }
        return Int(numID)
    }
    
    func checkAndAlterGridSize(){
        print("Changing from: \(liveMPCGDGenome.gridSize)")
        var bb = gg.getBoundingBox(size, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, reflectionID: liveMPCGDGenome.gridReflection)
        let xPos = CGFloat(liveMPCGDGenome.gridStartX)/60 * size.width
        let yPos = CGFloat(liveMPCGDGenome.gridStartY)/60 * size.height
        
        while xPos + bb.width/2 > size.width - 15 && liveMPCGDGenome.gridSize > 1{
            liveMPCGDGenome.gridSize -= 1
            bb = gg.getBoundingBox(size, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, reflectionID: liveMPCGDGenome.gridReflection)
        }
        while xPos - bb.width/2 < 15 && liveMPCGDGenome.gridSize > 1{
            liveMPCGDGenome.gridSize -= 1
            bb = gg.getBoundingBox(size, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, reflectionID: liveMPCGDGenome.gridReflection)
        }
        while yPos + bb.height/2 > size.height - 15 && liveMPCGDGenome.gridSize > 1{
            liveMPCGDGenome.gridSize -= 1
            bb = gg.getBoundingBox(size, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, reflectionID: liveMPCGDGenome.gridReflection)
        }
        while yPos - bb.height/2 < 15 && liveMPCGDGenome.gridSize > 1{
            liveMPCGDGenome.gridSize -= 1
            bb = gg.getBoundingBox(size, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, reflectionID: liveMPCGDGenome.gridReflection)
        }
        print("To: \(liveMPCGDGenome.gridSize)")
    }
    
    func handleTopButtonTap(){
        
        lockButton?.isHidden = true
        helpButton?.isHidden = true
        bestLabel?.isHidden = true
        
        if self.buttonNumTapped == 0{
            showHelpText("Characters")
            self.loadCharacterOptions()
        }
        else if self.buttonNumTapped == 1{
            showHelpText("\(getWhiteName()) tap")
            self.loadTapActionOptions(.whiteTapAction)
        }
        else if self.buttonNumTapped == 2{
            showHelpText("\(getWhiteName()) movement")
            self.loadWhiteBehaviours()
        }
        else if self.buttonNumTapped == 3{
            if liveMPCGDGenome.controllerPack != 0{
                showHelpText("Controller collisions")
                self.loadControllerCollisions()
            }
        }
        else if self.buttonNumTapped == 4{
            showHelpText("Clusters")
            self.loadClusterTop()
        }
        else if self.buttonNumTapped == 5{
            showHelpText("Soundtrack Volumes")
            self.loadAudioTop()
        }
        else if self.buttonNumTapped == 6{
            showHelpText("Grid")
            self.loadGridTop()
        }
        else if self.buttonNumTapped == 7{
            showHelpText("\(getWhiteName()) spawn")
            self.loadWhiteSpawnOptions()
        }
        else if self.buttonNumTapped == 8{
            showHelpText("Winning and losing")
            loadGameEndChoices()
        }
        if cycler != nil{
            menuPosition = 1
            self.cycler.handleGeneratorScreenMenuMove()
        }
    }
    
    func hideButtons(_ completion: @escaping ()->()){
        let moveAction = SKAction.move(by: CGVector(dx: -buttonSize.width, dy: 0), duration: 0.1)
        trayNode.run(moveAction, completion: completion)
        trayNode.run(SKAction.fadeOut(withDuration: 0.1))
    }
    
    func showButtons(_ completion: @escaping ()->()){
        let moveAction = SKAction.move(by: CGVector(dx: buttonSize.width, dy: 0), duration: 0.1)
        trayNode.run(moveAction)
        trayNode.run(SKAction.fadeIn(withDuration: 0.1), completion: completion)
    }
    
    func removeOverlays(){
        for o in overlays{
            o.removeFromParent()
        }
        overlays.removeAll()
    }

    func loadWhiteSpawnOptions(){
        blueSpawnScreen.closeDown()
        blueSpawnScreen.alpha = 0
        loadSpawnHighlights(buttonType: .whiteSpawn)
        loadSpawnButtons(buttonType: .whiteSpawn)
        whiteSpawnScreen.alpha = 1
        whiteSpawnScreen.initialiseFromMPCGDGenome(rate: liveMPCGDGenome.whiteSpawnRate)
    }
    
    func loadBlueSpawnOptions(){
        whiteZoneScreen.closeDown()
        whiteZoneScreen.alpha = 0
        whiteSpawnScreen.closeDown()
        whiteSpawnScreen.alpha = 0
        loadSpawnHighlights(buttonType: .blueSpawn)
        loadSpawnButtons(buttonType: .blueSpawn)
        blueSpawnScreen.alpha = 1
        blueSpawnScreen.initialiseFromMPCGDGenome(rate: liveMPCGDGenome.blueSpawnRate)
    }
    
    func loadSpawnHighlights(buttonType: ButtonSetEnum){
        spawnHighlightNodes.removeAll()
        let nums = buttonType == .whiteSpawn ? [liveMPCGDGenome.whiteEdgeSpawnPositions, liveMPCGDGenome.whiteMidSpawnPositions, liveMPCGDGenome.whiteCentralSpawnPositions] : [liveMPCGDGenome.blueEdgeSpawnPositions, liveMPCGDGenome.blueMidSpawnPositions, liveMPCGDGenome.blueCentralSpawnPositions]

        let bNums = [0, 0, 3, 3, 1, 1, 4, 4, 2, 2, 5, 5]
        var bins = getSpawnAts(nums[0], nums[1], nums[2])

        var hasSpawning = false
        for pos in 0..<12{
            let hNode = SKSpriteNode(color: GenButton.highlightColour, size: CGSize(width: buttonSize.width/2, height: buttonSize.height))
            hNode.position.x = (pos % 2 == 0) ? -21 : 21
            buttons[bNums[pos]].addChild(hNode)
            overlays.append(hNode)
            spawnHighlightNodes.append(hNode)
            hNode.isHidden = (bins[pos] == false)
            hasSpawning = hasSpawning || bins[pos] == true
        }
        
        let okText = hasSpawning ? "OK" : "Off"
        setOKText(buttons[8], text: okText)
    }
    
    func loadSpawnButtons(buttonType: ButtonSetEnum){

        returnLinesToNormal()
        let gray = lineColour.withAlphaComponent(0.2)
        for pos in 0...2{
            let l = SKSpriteNode(color: gray, size: CGSize(width: 1, height: squareHeight * 2))
            buttons[pos].addChild(l)
            overlays.append(l)
            l.position = CGPoint(x: 0, y: -buttonSize.height/2)
        }
        verticalLines[1].yScale = 0.66
        verticalLines[1].position.y += squareHeight/2
        
        for button in buttons{
            button.setImageAndText(nilImage, text: "")
            button.secondTextNode.text = ""
            button.buttonSet = buttonType
            button.enabled = true
            button.useTempHighlight = false
        }
        
        var nodes: [SKNode] = []
        var numID = 1
        var spawnAts = [false, false, false, false, false, false, false, false, false, false, false, false]
        let bNums = [0, 0, 3, 3, 1, 1, 4, 4, 2, 2, 5, 5]
        for pos in 0..<12{
            spawnAts[pos] = true
            if pos > 0{
                spawnAts[pos - 1] = false
            }
            let node = getSpawnNode(spawnAt: spawnAts, type: "White", includeScores: false, includeCharacterIcon: false)
            nodes.append(node)
            overlays.append(node)
            node.position.x = (pos % 2 == 0) ? -26 : 26
            buttons[bNums[pos]].hkImage.imageNode.addChild(node)
            numID *= 2
        }

        buttons[6].enabled = false
        buttons[7].enabled = false
    }
        
    func loadWhiteZoneOptions(){
        blueSpawnScreen.closeDown()
        blueSpawnScreen.alpha = 0
        blueZoneScreen.closeDown()
        blueZoneScreen.alpha = 0
        returnLinesToNormal()
        verticalLines[1].yScale = 0.66
        verticalLines[1].position.y += squareHeight/2
        verticalLines[2].yScale = 0.66
        verticalLines[2].position.y += squareHeight/2

        for buttonNum in 0...8{
            buttons[buttonNum].buttonSet = .whiteScoreZone
        }
        var numID = 1
        for pos in 0...3{
            let image = liveMPCGDGenome.getSpawnImage(buttons[pos].hkImage.size, whiteSpawnNum: numID, blueSpawnNum: nil)
            buttons[pos].setImageAndText(image, text: "")
            buttons[pos].secondTextNode.text = ""
            numID *= 2
        }
        let image = liveMPCGDGenome.getCornerSpawnImage(buttons[4].hkImage.size)
        buttons[4].setImageAndText(image, text: "")
        buttons[4].secondTextNode.text = ""
        
        loadTapPositions(liveMPCGDGenome.whiteScoreZones)
        showTicks()
        toggleOffOK(5)
        buttons[6].enabled = false
        buttons[7].enabled = false
        whiteZoneScreen.initialiseFromMPCGDGenome(score: liveMPCGDGenome.whiteZoneScore)
        whiteZoneScreen.alpha = 1
    }
    
    func loadBlueZoneOptions(){
        whiteZoneScreen.closeDown()
        whiteZoneScreen.alpha = 0
        for buttonNum in 0...8{
            buttons[buttonNum].buttonSet = .blueScoreZone
        }
        var numID = 1
        for pos in 0...3{
            let image = liveMPCGDGenome.getSpawnImage(buttons[pos].hkImage.size, whiteSpawnNum: 0, blueSpawnNum: numID)
            buttons[pos].setImageAndText(image, text: "")
            buttons[pos].secondTextNode.text = ""
            numID *= 2
        }
        let image = liveMPCGDGenome.getCornerSpawnImage(buttons[4].hkImage.size)
        buttons[4].setImageAndText(image, text: "")
        buttons[4].secondTextNode.text = ""

        loadTapPositions(liveMPCGDGenome.blueScoreZones)
        showTicks()
        toggleOffOK(5)
        buttons[6].enabled = false
        buttons[7].enabled = false
        blueZoneScreen.initialiseFromMPCGDGenome(score: liveMPCGDGenome.blueZoneScore)
        blueZoneScreen.alpha = 1
    }
    
    func loadGridTop(){
        returnLinesToNormal()
        showHelpText("Controller & scene")
        gridSizeScreen.alpha = 0
        horizontalLines[1].xScale = 0.33
        horizontalLines[1].position.x -= squareWidth
        
        extraHorizontalLine.isHidden = false
        for pos in 0...8{
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].secondTextNode.text = ""
            buttons[pos].buttonSet = .gridTop
            buttons[pos].enabled = [1, 4].contains(pos) ? false : true
        }
        
        let gridColour = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
        
        let gridSizeImage = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, colour: MPCGDGenome.gridColours[0], includeBorder: true)
        _ = addGridLabelAndImage(buttons[3], text: "Size/Place", image: gridSizeImage)
        
        addLowerLabel(buttons[7], text: "Control")
        let imageNode = SKSpriteNode(imageNamed: gridControlImageNames[liveMPCGDGenome.gridControl])
        imageNode.position.y += 12
        buttons[7].hkImage.imageNode.addChild(imageNode)
        overlays.append(imageNode)

        if liveMPCGDGenome.controllerPack == 0{
            for p in [3, 6, 7]{
                buttons[p].enabled = false
                buttons[p].alpha = 0.3
            }
            let font = UIFontCache(name: "HelveticaNeue-Thin", size: 21)
            let label = SKLabelNode(font, whiteColour)
            label.text = "Controller"
            label.position = CGPoint(x: 0, y: 0)
            label.verticalAlignmentMode = .center
            buttons[0].hkImage.imageNode.addChild(label)
            overlays.append(label)
        }
        else{
            let gridShapeImage = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 58, colour: MPCGDGenome.gridColours[0], includeBorder: false)
            _ = addGridLabelAndImage(buttons[0], text: "Controller", image: gridShapeImage)
        }

        let gridColourImage = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack,    shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 58, colour: gridColour, includeBorder: false)
        let node = addGridLabelAndImage(buttons[6], text: "Colour", image: gridColourImage)
        if liveMPCGDGenome.controllerPack == 2{
            if liveMPCGDGenome.gridColour < 8{
                node.colorBlendFactor = 0.5
                node.color = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
            }
        }
        _ = setUpBigButton()
        setUpTallButton()
        
        bigButton.isHidden = true
        tallButton.isHidden = false
        
        let iconImage1 = DeviceType.simulationIs == .iPad ? GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][0] : GeneratorScreen.backgroundIconsIPhone[liveMPCGDGenome.backgroundChoice][0]
        
        let iconImage2 = DeviceType.simulationIs == .iPad ? GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][8] : GeneratorScreen.backgroundIconsIPhone[liveMPCGDGenome.backgroundChoice][8]
        
        let icon1 = SKSpriteNode(texture: SKTexture(image: iconImage1))
        if DeviceType.simulationIs == .iPhone { //TODO: custom reshaping to fit the screen
            icon1.height = icon1.height * 1.33
        }
        icon1.size = icon1.size * 0.1
        
        icon1.position.x = -23
        buttons[2].hkImage.imageNode.addChild(icon1)
        overlays.append(icon1)
        
        
        let icon2 = SKSpriteNode(texture: SKTexture(image: iconImage2))
        if DeviceType.simulationIs == .iPhone { //TODO: custom reshaping to fit the screen
            icon2.height = icon2.height * 1.33
        }
        icon2.size = icon2.size * 0.1
        icon2.position.x = 26
        buttons[2].hkImage.imageNode.addChild(icon2)
        overlays.append(icon2)
        
        let icon3 = SKSpriteNode(texture: SKTexture(image: iconImage1))
        if DeviceType.simulationIs == .iPhone { //TODO: custom reshaping to fit the screen
            icon3.height = icon3.height * 1.33
        }
        icon3.size = icon3.size * 0.1
        icon3.position.x = -23
        buttons[5].hkImage.imageNode.addChild(icon3)
        overlays.append(icon3)
        
        let icon4 = SKSpriteNode(texture: SKTexture(image: iconImage2))
        if DeviceType.simulationIs == .iPhone { //TODO: custom reshaping to fit the screen
            icon4.height = icon4.height * 1.33
        }
        icon4.size = icon4.size * 0.1
        icon4.position.x = 26
        buttons[5].hkImage.imageNode.addChild(icon4)
        overlays.append(icon4)
        
        let lrIcon = SKSpriteNode(imageNamed: "LRArrow")
        buttons[2].addChild(lrIcon)
        lrIcon.position.x = 1
        overlays.append(lrIcon)
        
        let loopingIcon = SKSpriteNode(imageNamed: "LoopingArrow")
        buttons[5].addChild(loopingIcon)
        loopingIcon.position.x = 1
        overlays.append(loopingIcon)

        
        if liveMPCGDGenome.gameDuration == 0{
            buttons[2].enabled = false
            buttons[2].alpha = 0.3
            buttons[5].enabled = false
            buttons[5].alpha = 0.3
        }
        else{
            if liveMPCGDGenome.dayNightCycle == 1{
                tappedButtonNumbers = [2]
            }
            else if liveMPCGDGenome.dayNightCycle == 2{
                tappedButtonNumbers = [5]
            }
            else{
                tappedButtonNumbers = []
            }
            showTicks()
        }

        let okImage = liveMPCGDGenome.getSpawnImage(buttons[8].hkImage.size, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
    }
    
    func setUpTallButton(){
        
        tallButton.hkImage.imageNode.removeAllChildren()
        let gridColour = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
        
        var backgroundIcon: UIImage! = nil
        backgroundIcon = liveMPCGDGenome.dayNightCycle == 0 ? GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][liveMPCGDGenome.backgroundShade] : GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][0]
        
        
        
        let backgroundNode = SKSpriteNode(texture: SKTexture(image: backgroundIcon!))
        if DeviceType.simulationIs == .iPhone{
            backgroundNode.height = backgroundNode.height * 1.33
        }
        backgroundNode.size = backgroundNode.size * 0.1
        tallButtonScreenSize = GridGenerator.getScreenSizeForButton(buttonSize * (DeviceType.isIPad ? 3.0 / 4.0 : 1.0))

        tallButton.hkImage.imageNode.addChild(backgroundNode)
        overlays.append(backgroundNode)
        
        let gridImage = gg.getGridIcon(iconSize: buttonSize * 2, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, colour: gridColour, includeBorder: false           )
        
        let gridNode = SKSpriteNode(texture: SKTexture(image: gridImage))

        if liveMPCGDGenome.controllerPack == 2 && liveMPCGDGenome.gridColour < 8{
            gridNode.colorBlendFactor = 0.5
            gridNode.color = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
        }

        if liveMPCGDGenome.controllerPack != 0{
            tallButton.hkImage.imageNode.addChild(gridNode)
            overlays.append(gridNode)
        }
        gridNode.size = buttonSize * 2.15 * (DeviceType.simulationIs == .iPad ? (3.0 / 4.0) : 1.0)
        gridNode.isUserInteractionEnabled = false
        gridNode.position.y = 0
        CharacterIconHandler.alterNodeOrientation(isGrid: liveMPCGDGenome.controllerPack == 1, collectionNum: liveMPCGDGenome.gridShape, characterNum: liveMPCGDGenome.gridOrientation, reflectionID: liveMPCGDGenome.gridReflection, node:gridNode)
        backgroundNode.position.y = 0
        
        gridNode.position.x = (CGFloat(liveMPCGDGenome.gridStartX)/60 - 0.5) * tallButtonScreenSize.width
        gridNode.position.y = (CGFloat(liveMPCGDGenome.gridStartY)/60 - 0.5) * tallButtonScreenSize.height
        
        let circleName = liveMPCGDGenome.backgroundShade > 4 && liveMPCGDGenome.dayNightCycle == 0 ? "TinyControllerCircleWhite" : "TinyControllerCircleBlack"
        let tinyCCNode = SKSpriteNode(imageNamed: circleName)
        gridNode.addChild(tinyCCNode)
        tinyCCNode.isHidden = liveMPCGDGenome.gridSize > 5
    }
    
    func setUpBigButton() -> SKSpriteNode{
        
        let gridColour = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]

        var backgroundIcon: UIImage! = nil
        backgroundIcon = liveMPCGDGenome.dayNightCycle == 0 ? GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][liveMPCGDGenome.backgroundShade] : GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][0]
        
        let backgroundNode = SKSpriteNode(texture: SKTexture(image: backgroundIcon!))
        if DeviceType.simulationIs == .iPhone{

            backgroundNode.height = backgroundNode.height * 1.33
        }
        
        backgroundNode.size = backgroundNode.size * 0.1
        bigButton.hkImage.imageNode.addChild(backgroundNode)
        overlays.append(backgroundNode)

        bigButtonScreenSize = GridGenerator.getScreenSizeForButton(buttonSize * 1.025 * (DeviceType.isIPad ? 3.0 / 4.0 : 1.0))
        
        let gridImage = gg.getGridIcon(iconSize: buttonSize * 2.05, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, colour: gridColour, includeBorder: false)
        
        bigButtonGridBounds = gg.getBoundingBox(bigButtonScreenSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, reflectionID: liveMPCGDGenome.gridReflection, useIconSize: true)
        
        let gridNode = SKSpriteNode(texture: SKTexture(image: gridImage))
        if liveMPCGDGenome.controllerPack == 2 && liveMPCGDGenome.gridColour < 8{
            gridNode.colorBlendFactor = 0.5
            gridNode.color = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
        }

        if liveMPCGDGenome.controllerPack != 0{
            bigButton.hkImage.imageNode.addChild(gridNode)
            overlays.append(gridNode)
        }
        bigButtonGridNode = gridNode
        gridNode.size = buttonSize * (DeviceType.simulationIs == .iPad ? 2.15 * (3.0 / 4.0) : 2.15)
        gridNode.isUserInteractionEnabled = false
        gridNode.position.y = 0
        CharacterIconHandler.alterNodeOrientation(isGrid: liveMPCGDGenome.controllerPack == 1, collectionNum: liveMPCGDGenome.gridShape, characterNum: liveMPCGDGenome.gridOrientation, reflectionID: liveMPCGDGenome.gridReflection, node: bigButtonGridNode)
        backgroundNode.position.y = 0
        
        gridNode.position.x = (CGFloat(liveMPCGDGenome.gridStartX)/60 - 0.5) * bigButtonScreenSize.width
        gridNode.position.y = (CGFloat(liveMPCGDGenome.gridStartY)/60 - 0.5) * bigButtonScreenSize.height
        
        let circleName = liveMPCGDGenome.backgroundShade > 4 ? "TinyControllerCircleWhite" : "TinyControllerCircleBlack"
        tinyControllerCircleNode = SKSpriteNode(imageNamed: circleName)
        gridNode.addChild(tinyControllerCircleNode)
        tinyControllerCircleNode.isHidden = liveMPCGDGenome.gridSize > 5

        return backgroundNode
    }
    
    func addGridLabelAndImage(_ button: GenButton, text: String, image: UIImage) -> SKSpriteNode{
        addLowerLabel(button, text: text)
        let imageNode = SKSpriteNode(texture: SKTexture(image: image))
        imageNode.size = buttonSize
        imageNode.position = CGPoint(x: 0, y: 12)
        button.hkImage.imageNode.addChild(imageNode)
        overlays.append(imageNode)
        return imageNode
    }
    
    func addLowerLabel(_ button: GenButton, text: String){
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 20)
        let label = SKLabelNode(font, whiteColour)
        label.text = text
        label.position = CGPoint(x: 0, y: -45)
        button.hkImage.imageNode.addChild(label)
        overlays.append(label)
    }
    
    func loadGridShapesTop(){
        returnLinesToNormal()
        verticalLines[1].yScale = 0.33
        verticalLines[2].yScale = 0.33
        for pos in 0...8{
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].buttonSet = .gridShapeTop
            buttons[pos].secondTextNode.text = ""
            buttons[pos].alpha = 1
            buttons[pos].enabled = false
        }
        buttons[3].enabled = true
        buttons[4].enabled = true
        buttons[5].enabled = true

        let charImage = gg.getGridIcon(iconSize: buttonSize, controllerPack: 2, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 58, colour: MPCGDGenome.gridColours[0], includeBorder: false)
        let charNode = SKSpriteNode(texture: SKTexture(image: charImage))
        charNode.size = charNode.size * 0.5
        overlays.append(charNode)
        buttons[4].hkImage.imageNode.addChild(charNode)
        charNode.position.y = 10

        let shapeNum = (liveMPCGDGenome.controllerPack == 1) ? liveMPCGDGenome.gridShape : 1
        let orientationNum2 = (liveMPCGDGenome.controllerPack == 1) ? liveMPCGDGenome.gridOrientation : 0
        let grainNum = (liveMPCGDGenome.controllerPack == 1) ? liveMPCGDGenome.gridGrain : 5
        let gridImage = gg.getGridIcon(iconSize: buttonSize, controllerPack: 1, shape: shapeNum, orientation: orientationNum2, grain: grainNum, size: 58, colour: MPCGDGenome.gridColours[0], includeBorder: false)
        let gridNode = SKSpriteNode(texture: SKTexture(image: gridImage))
        gridNode.size = gridNode.size * 0.5
        buttons[3].hkImage.imageNode.addChild(gridNode)
        overlays.append(gridNode)
        gridNode.position.y = 10
        
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: true)
        buttons[5].setImageAndText(okImage, text: "")
        
        addLowerLabel(buttons[3], text: "Shape")
        addLowerLabel(buttons[4], text: "Emoji")
        if liveMPCGDGenome.controllerPack == 0{
            buttons[5].showHighlight()
        }
        else if liveMPCGDGenome.controllerPack == 1{
            buttons[3].showHighlight()
        }
        else if liveMPCGDGenome.controllerPack == 2{
            buttons[4].showHighlight()
        }
    }
    
    func loadGridShapes(){
        returnLinesToNormal()
        for pos in 0...8{
//            let orientation = (pos == liveMPCGDGenome.gridShape) ? liveMPCGDGenome.gridOrientation : orientations[pos]
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].buttonSet = .gridShape
            buttons[pos].secondTextNode.text = ""
            buttons[pos].alpha = 1
            let fourNode = getFourGridNode(shape: pos)
            buttons[pos].addChild(fourNode)
            fourNode.position.y = 10
            overlays.append(fourNode)
            addLowerLabel(buttons[pos], text: GridGenerator.controllerShapePackNames[pos])
        }
        if liveMPCGDGenome.controllerPack == 1{
            buttons[liveMPCGDGenome.gridShape].showHighlight()
        }
    }
    
    func getFourGridNode(shape: Int, orientation: Int! = nil) -> SKNode{
        let fourNode = SKNode()
        let size = (orientation == nil) ? 70 : 76
        for p in 0...3{
            let grain = (orientation == nil) ? 4 : p + 3
            let ori = (orientation == nil) ? p : orientation!
            let gridImage = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: shape, orientation: ori, grain: grain, size: size, colour: MPCGDGenome.gridColours[0], includeBorder: false)
            let node = SKSpriteNode(texture: SKTexture(image: gridImage))
            node.size = CGSize(width: CGFloat(size)/2, height: CGFloat(size)/2 * gridImage.size.height/gridImage.size.width)
            fourNode.addChild(node)
            node.position.x = (p % 2 == 0) ? -15 : 15
            node.position.y = (p > 1) ? -15 : 15
            if orientation != nil{
                node.position.x = (p % 2 == 0) ? -18 : 18
                node.position.y = (p > 1) ? -18 : 18
            }
        }
        return fourNode
    }
    
    func loadGridOrientations(){
        for pos in 0...8{
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].buttonSet = .gridOrientation
            buttons[pos].secondTextNode.text = ""
            let fourNode = getFourGridNode(shape: liveMPCGDGenome.gridShape, orientation: pos)
            buttons[pos].addChild(fourNode)
            overlays.append(fourNode)
            buttons[pos].alpha = 1
        }
        buttons[liveMPCGDGenome.gridOrientation].showHighlight()
    }
    
    func loadGridGrains(){
        for pos in 0...8{
            let image = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: pos, size: 80, colour: MPCGDGenome.gridColours[0], includeBorder: false)
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].buttonSet = .gridGrain
            buttons[pos].secondTextNode.text = ""
            buttons[pos].alpha = 1
            let node = SKSpriteNode(texture: SKTexture(image: image))
            node.size = CGSize(width: 80, height: 80 * (image.size.height/image.size.width))
            buttons[pos].addChild(node)
            overlays.append(node)
        }
        buttons[liveMPCGDGenome.gridGrain].showHighlight()
    }
    
    func loadGridSizes(){
        returnLinesToNormal()
        horizontalLines[1].xScale = 0.33
        horizontalLines[1].position.x -= squareWidth
        verticalLines[2].yScale = 0.33
        verticalLines[2].position.y -= squareHeight
        extraHorizontalLine.isHidden = true
        secondExtraHLine.isHidden = false
        
        showHelpText("Controller size/place")
        gridSizeScreen.alpha = 0
        
        for pos in 0...8{
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].buttonSet = .gridSize
            buttons[pos].secondTextNode.text = ""
            buttons[pos].enabled = false
            buttons[pos].alpha = 1
        }
        buttons[8].enabled = true
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
        
        let backgroundNode = setUpBigButton()
        gridSizeScreen.initialiseFromMPCGDGenome(liveMPCGDGenome)
        gridSizeScreen.alpha = 1
        
        crossHairsNode = SKNode()
        let screenSize = GridGenerator.getScreenSizeForButton(buttonSize * (DeviceType.isIPad ? 3.0 / 4.0 : 1.025))

        let crossHairsColour = liveMPCGDGenome.dayNightCycle == 0 && liveMPCGDGenome.backgroundShade > 4 ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
        crossHairsNode.addChild(SKSpriteNode(color: crossHairsColour, size: CGSize(width: 0.5, height: screenSize.height)))
        crossHairsNode.addChild(SKSpriteNode(color: crossHairsColour, size: CGSize(width: screenSize.width, height: 0.5)))
        if liveMPCGDGenome.controllerPack != 0{
            backgroundNode.addChild(crossHairsNode)
        }
        
        let image = gg.getGridIcon(iconSize: buttonSize * 2, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 61, colour: MPCGDGenome.gridColours[0], includeBorder: false)

        var pos = 0
        for buttonPos in [0, 3, 6, 7]{
            let rotNode = SKSpriteNode(texture: SKTexture(image: image))
            rotNode.size = buttonSize * 1.6
            buttons[buttonPos].hkImage.imageNode.addChild(rotNode)
            overlays.append(rotNode)
            CharacterIconHandler.alterNodeOrientation(isGrid: liveMPCGDGenome.controllerPack == 1, collectionNum: liveMPCGDGenome.gridShape, characterNum: liveMPCGDGenome.gridOrientation, reflectionID: pos, node: rotNode)
            buttons[buttonPos].enabled = true
            if pos == liveMPCGDGenome.gridReflection{
                buttons[buttonPos].showHighlight()
            }
            pos += 1
        }

        bigButton.alpha = 1
        bigButton.isHidden = false
        setCrossHairAlphas()
    }
    
    func loadGridColours(){
        returnLinesToNormal()
        for pos in 0...8{
            if liveMPCGDGenome.controllerPack == 2{
                let image = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 100, colour: MPCGDGenome.gridColours[pos], includeBorder: false)
                let node = SKSpriteNode(texture: SKTexture(image: image))
                overlays.append(node)
                buttons[pos].hkImage.imageNode.addChild(node)
                if pos < 8{
                    node.colorBlendFactor = 0.5
                    node.color = MPCGDGenome.gridColours[pos]
                }
                else{
                    addLowerLabel(buttons[pos], text: "Original")
                }
                node.size = node.size * 0.5
                buttons[pos].setImageAndText(nilImage, text: "")
            }
            else{
                let image = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 58, colour: MPCGDGenome.gridColours[pos], includeBorder: false)
                buttons[pos].setImageAndText(image, text: "")
            }
            buttons[pos].buttonSet = .gridColour
            buttons[pos].secondTextNode.text = ""
            buttons[pos].alpha = 1
        }
        buttons[liveMPCGDGenome.gridColour].showHighlight()
    }
    
    func loadGridShades(){
        let names = ["Dark colours", "Light colours", "Red & purples", "Orange & browns", "Yellows", "Greens", "Blues", "Pink & violets", "Grayscale"]
        showHelpText(names[liveMPCGDGenome.gridColour])
        let shades = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)
        for pos in 0...8{
            if liveMPCGDGenome.controllerPack == 2{
                let image = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 100, colour: shades[pos], includeBorder: false)
                let node = SKSpriteNode(texture: SKTexture(image: image))
                overlays.append(node)
                buttons[pos].hkImage.imageNode.addChild(node)
                node.colorBlendFactor = 0.5
                node.color = shades[pos]
                node.size = node.size * 0.5
                buttons[pos].setImageAndText(nilImage, text: "")
            }
            else{
                let image = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 58, colour: shades[pos], includeBorder: false)
                buttons[pos].setImageAndText(image, text: "")
            }

            buttons[pos].buttonSet = .gridShade
            buttons[pos].secondTextNode.text = ""
            buttons[pos].alpha = 1
        }
        buttons[liveMPCGDGenome.gridShade].showHighlight()
    }
    
    func loadGridControls(){
        returnLinesToNormal()
        let labels = ["None", "Move", "Float", "Teleport", "Rotate", "Up/Down", "Left/Right", "Chase", "Grid"]
        for pos in 0...8{
            buttons[pos].buttonSet = .gridControl
            buttons[pos].setImageAndText(nilImage, text: "")
            let buttonImage = UIImage(named: gridControlImageNames[pos])!
            addLowerLabel(buttons[pos], text: labels[pos])
            let imageNode = SKSpriteNode(texture: SKTexture(image: buttonImage))
            imageNode.position.y += 12
            buttons[pos].hkImage.imageNode.addChild(imageNode)
            overlays.append(imageNode)
            buttons[pos].alpha = 1
        }
        buttons[liveMPCGDGenome.gridControl].showHighlight()
    }
    
    func loadWhiteSizeOptions(){
        returnLinesToNormal()
        ballChoiceScreen.closeDown()
        ballChoiceScreen.alpha = 0
        for pos in 0...7{
            let s = MPCGDGenome.sizeNums[pos] * 2
            let ballNode = getWhiteBall(CGSize(width: s, height: s))
            buttons[pos].hkImage.imageNode.addChild(ballNode)
            overlays.append(ballNode)
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].secondTextNode.text = ""
            buttons[pos].buttonSet = .whiteSize
            let sText = SKLabelNode(text: "\(pos + 1)")
            sText.fontName = "Helvetica Neue Thin"
            sText.fontSize = 17
            sText.fontColor = Colours.getColour(.antiqueWhite)
            sText.verticalAlignmentMode = .top
            sText.horizontalAlignmentMode = .left
            sText.position = CGPoint(x: -buttonSize.width/2 + 5, y: buttonSize.height/2 - 3)
            buttons[pos].addChild(sText)
            overlays.append(sText)
        }
        buttons[8].buttonSet = .whiteSize
    }
    
    func loadBlueSizeOptions(){
        returnLinesToNormal()
        ballChoiceScreen.closeDown()
        ballChoiceScreen.alpha = 0
        for pos in 0...7{
            let s = MPCGDGenome.sizeNums[pos] * 2
            let ballNode = getBlueBall(CGSize(width: s, height: s))
            buttons[pos].hkImage.imageNode.addChild(ballNode)
            overlays.append(ballNode)
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].secondTextNode.text = ""
            buttons[pos].buttonSet = .blueSize
            let sText = SKLabelNode(text: "\(pos + 1)")
            sText.fontName = "Helvetica Neue Thin"
            sText.fontSize = 17
            sText.fontColor = Colours.getColour(.antiqueWhite)
            sText.verticalAlignmentMode = .top
            sText.horizontalAlignmentMode = .left
            sText.position = CGPoint(x: -buttonSize.width/2 + 5, y: buttonSize.height/2 - 3)
            buttons[pos].addChild(sText)
            overlays.append(sText)
        }
        buttons[8].buttonSet = .blueSize
    }
    
    func loadWhiteBehaviours(){
        returnLinesToNormal()
        horizontalLines[1].alpha = 0
        verticalLines[1].yScale = 0.33
        verticalLines[1].position.y -= squareHeight
        verticalLines[2].yScale = 0.33
        verticalLines[2].position.y -= squareHeight

        whiteBehavioursScreen.run(SKAction.fadeIn(withDuration: 0.5))
        for button in buttons{
            button.setImageAndText(nilImage, text: "")
            button.enabled = false
            button.buttonSet = .whiteBehaviours
            button.secondTextNode.text = ""
        }
        
        buttons[6].enabled = true
        let rotateIconNode = SKSpriteNode(imageNamed: "BallRotate")
        rotateIconNode.position.y = 12
        buttons[6].hkImage.imageNode.addChild(rotateIconNode)
        overlays.append(rotateIconNode)
        addLowerLabel(buttons[6], text: "Rotating")
        let ballNode1 = getWhiteBall(CGSize(width: 30, height: 30))
        ballNode1.position.y = 12
        buttons[6].hkImage.imageNode.addChild(ballNode1)
        overlays.append(ballNode1)
        if liveMPCGDGenome.whiteRotation == 1{
            buttons[6].showHighlight()
        }
        
        buttons[7].enabled = true
        let noRotateIconNode = SKSpriteNode(imageNamed: "BallNoRotate")
        noRotateIconNode.position.y = 12
        buttons[7].hkImage.imageNode.addChild(noRotateIconNode)
        overlays.append(noRotateIconNode)
        addLowerLabel(buttons[7], text: "Rigid")
        let ballNode2 = getWhiteBall(CGSize(width: 30, height: 30))
        ballNode2.position.y = 12
        buttons[7].hkImage.imageNode.addChild(ballNode2)
        overlays.append(ballNode2)
        if liveMPCGDGenome.whiteRotation == 2{
            buttons[7].showHighlight()
        }
        
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
        buttons[8].enabled = true
        whiteBehavioursScreen.initialiseFromMPCGDGenome(liveMPCGDGenome, speed: liveMPCGDGenome.whiteSpeed, noise: liveMPCGDGenome.whiteNoise, bounce: liveMPCGDGenome.whiteBounce, charType: "White")
    }
    
    func loadBlueBehaviours(){
        whiteBehavioursScreen.alpha = 0
        blueBehavioursScreen.run(SKAction.fadeIn(withDuration: 0.5))
        for button in buttons{
            button.setImageAndText(nilImage, text: "")
            button.enabled = false
            button.buttonSet = .blueBehaviours
            button.secondTextNode.text = ""
        }
        
        buttons[6].enabled = true
        let rotateIconNode = SKSpriteNode(imageNamed: "BallRotate")
        rotateIconNode.position.y = 12
        buttons[6].hkImage.imageNode.addChild(rotateIconNode)
        overlays.append(rotateIconNode)
        addLowerLabel(buttons[6], text: "Rotating")
        let ballNode1 = getBlueBall(CGSize(width: 30, height: 30))
        ballNode1.position.y = 12
        buttons[6].hkImage.imageNode.addChild(ballNode1)
        overlays.append(ballNode1)
        if liveMPCGDGenome.blueRotation == 1{
            buttons[6].showHighlight()
        }
        
        buttons[7].enabled = true
        let noRotateIconNode = SKSpriteNode(imageNamed: "BallNoRotate")
        noRotateIconNode.position.y = 12
        buttons[7].hkImage.imageNode.addChild(noRotateIconNode)
        overlays.append(noRotateIconNode)
        addLowerLabel(buttons[7], text: "Rigid")
        let ballNode2 = getBlueBall(CGSize(width: 30, height: 30))
        ballNode2.position.y = 12
        buttons[7].hkImage.imageNode.addChild(ballNode2)
        overlays.append(ballNode2)
        if liveMPCGDGenome.blueRotation == 2{
            buttons[7].showHighlight()
        }

        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        
        buttons[8].setImageAndText(okImage, text: "")
        buttons[8].enabled = true
        blueBehavioursScreen.initialiseFromMPCGDGenome(liveMPCGDGenome, speed: liveMPCGDGenome.blueSpeed, noise: liveMPCGDGenome.blueNoise, bounce: liveMPCGDGenome.blueBounce, charType: "Blue")
    }
    
    func loadGridCharacterCollections(){
        returnLinesToNormal()
        var buttonNum = 0
        for button in buttons{
            let fourCharNode = CharacterIconHandler.getFourCharacterNode(nodeSize: buttonSize, collectionNum: buttonNum)
            button.hkImage.imageNode.addChild(fourCharNode)
            overlays.append(fourCharNode)
            button.setImageAndText(nilImage, text: "")
            button.enabled = true
            button.buttonSet = .gridCharacterCollections
            button.secondTextNode.text = ""
            buttonNum += 1
        }
        buttons[liveMPCGDGenome.gridShape].showHighlight()
    }
    
    func loadGridCharacterOptions(){
        for buttonPos in 0...8{
            buttons[buttonPos].setImageAndText(nilImage, text: "")
            let charNode = CharacterIconHandler.getCharacterNode(nodeSize: buttonSize, collectionNum: liveMPCGDGenome.gridShape, characterNum: buttonPos)
            overlays.append(charNode)
            buttons[buttonPos].hkImage.imageNode.addChild(charNode)
            buttons[buttonPos].buttonSet = .gridCharacterChoice
            buttons[buttonPos].enabled = true
        }
        buttons[liveMPCGDGenome.gridOrientation].showHighlight()
    }
    
    func loadWhiteCharacterCollectionOptions(){
        returnLinesToNormal()
        ballChoiceScreen.alpha = 0
        var buttonNum = 0
        for button in buttons{
            let fourCharNode = CharacterIconHandler.getFourCharacterNode(nodeSize: buttonSize, collectionNum: buttonNum)
            button.hkImage.imageNode.addChild(fourCharNode)
            overlays.append(fourCharNode)
            button.setImageAndText(nilImage, text: "")
            button.enabled = true
            button.buttonSet = .whiteBallCollectionChoice
            button.secondTextNode.text = ""
            button.alpha = 1
            buttonNum += 1
        }
        buttons[liveMPCGDGenome.whiteBallCollection].showHighlight()
    }
    
    func loadBlueCharacterCollectionOptions(){
        returnLinesToNormal()
        ballChoiceScreen.alpha = 0
        var buttonNum = 0
        for button in buttons{
            let fourCharNode = CharacterIconHandler.getFourCharacterNode(nodeSize: buttonSize, collectionNum: buttonNum)
            button.hkImage.imageNode.addChild(fourCharNode)
            overlays.append(fourCharNode)
            button.setImageAndText(nilImage, text: "")
            button.enabled = true
            button.alpha = 1
            button.buttonSet = .blueBallCollectionChoice
            button.secondTextNode.text = ""
            buttonNum += 1
        }
        buttons[liveMPCGDGenome.blueBallCollection].showHighlight()
    }
    
    func loadWhiteCharacterOptions(_ collectionNum: Int){
        for buttonPos in 0...8{
            buttons[buttonPos].setImageAndText(nilImage, text: "")
            let charNode = CharacterIconHandler.getCharacterNode(nodeSize: buttonSize, collectionNum: whiteBallCollectionChosen, characterNum: buttonPos)
            overlays.append(charNode)
            buttons[buttonPos].hkImage.imageNode.addChild(charNode)
            buttons[buttonPos].buttonSet = .whiteBallChoice
            buttons[buttonPos].enabled = true
            if collectionNum == liveMPCGDGenome.blueBallCollection && buttonPos == liveMPCGDGenome.blueBallChoice{
                buttons[buttonPos].enabled = false
                buttons[buttonPos].alpha = 0.3
            }
        }
        if collectionNum == liveMPCGDGenome.whiteBallCollection{
            buttons[liveMPCGDGenome.whiteBallChoice].showHighlight()
        }
    }
    
    func loadBlueCharacterOptions(_ collectionNum: Int){
        for buttonPos in 0...8{
            buttons[buttonPos].setImageAndText(nilImage, text: "")
            let charNode = CharacterIconHandler.getCharacterNode(nodeSize: buttonSize, collectionNum: blueBallCollectionChosen, characterNum: buttonPos)
            overlays.append(charNode)
            buttons[buttonPos].hkImage.imageNode.addChild(charNode)
            buttons[buttonPos].buttonSet = .blueBallChoice
            buttons[buttonPos].enabled = true
            if collectionNum == liveMPCGDGenome.whiteBallCollection && buttonPos == liveMPCGDGenome.whiteBallChoice{
                buttons[buttonPos].enabled = false
                buttons[buttonPos].alpha = 0.3
            }
       }
        if collectionNum == liveMPCGDGenome.blueBallCollection{
            buttons[liveMPCGDGenome.blueBallChoice].showHighlight()
        }
    }
    
    func loadCharacterOptions(){
        returnLinesToNormal()
        verticalLines[2].yScale = 0.33
        verticalLines[2].position.y -= squareHeight

        ballChoiceScreen.initialiseFromMPCGDGenome(liveMPCGDGenome)
        ballChoiceScreen.alpha = 1
        for b in buttons{
            b.buttonSet = .characters
            b.setImageAndText(nilImage, text: "")
            b.secondTextNode.text = ""
            b.enabled = false
            b.alpha = 1
        }
        
        let whiteBallNode = getWhiteBall(CGSize(width: 50, height: 50))
        buttons[0].hkImage.imageNode.addChild(whiteBallNode)
        overlays.append(whiteBallNode)
        
        let blueBallNode = getBlueBall(CGSize(width: 50, height: 50))
        blueBallNode.size = CGSize(width: 50, height: 50)
        buttons[3].hkImage.imageNode.addChild(blueBallNode)
        overlays.append(blueBallNode)

        buttons[0].enabled = true
        buttons[3].enabled = true
        buttons[6].enabled = true
        buttons[7].enabled = true
        buttons[8].enabled = true
        
        let (whiteBallSizeNode, blueBallSizeNode) = getBallSizesNodes()
        whiteBallSizeNode.position.y = 20
        blueBallSizeNode.position.y = 20
        buttons[6].hkImage.imageNode.addChild(whiteBallSizeNode)
        buttons[7].hkImage.imageNode.addChild(blueBallSizeNode)
        overlays.append(whiteBallSizeNode)
        overlays.append(blueBallSizeNode)

        let whiteBallSizeTextNode = getBallSizesTextNode(liveMPCGDGenome.whiteSizes, includeSizeText: true)
        whiteBallSizeTextNode.position.y = -25
        buttons[6].addChild(whiteBallSizeTextNode)
        overlays.append(whiteBallSizeTextNode)
        
        let blueBallSizeTextNode = getBallSizesTextNode(liveMPCGDGenome.blueSizes, includeSizeText: true)
        blueBallSizeTextNode.position.y = -25
        buttons[7].addChild(blueBallSizeTextNode)
        overlays.append(blueBallSizeTextNode)

        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
    }
    
    func getBallSizesTextNode(_ ballSizes: Int, includeSizeText: Bool, numBalls: String = "") -> SKLabelNode{
        var minSize = 8
        var maxSize = 0
        var sizes: [Int] = []
        for pos in 0...7{
            if ballSizes & Int(exp2(Double(pos))) != 0{
                minSize = min(pos + 1, minSize)
                maxSize = max(pos + 1, maxSize)
                sizes.append(pos + 1)
            }
        }
        var addOn = includeSizeText ? "Size: " : ""
        if includeSizeText && sizes.count > 1{
            addOn = "Sizes: "
        }
        var nodeText = (sizes.count == 1) ? "\(addOn)\(minSize)" : "\(addOn)\(minSize)-\(maxSize)"
        if numBalls != ""{
            nodeText += " x " + numBalls
        }
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 16)
        let sizeTextNode = SKLabelNode(font, Colours.getColour(.antiqueWhite))
        sizeTextNode.text = nodeText
        return sizeTextNode
    }
    
    func loadBackgroundChoiceOptions(){//TODO: needs potential checking due to background image
        returnLinesToNormal()
        for pos in 0...8{
            buttons[pos].alpha = 1
            buttons[pos].buttonSet = .backgroundChoice
            buttons[pos].setImageAndText(nilImage, text: "")
            let backgroundIcon = (DeviceType.simulationIs == .iPad) ? GeneratorScreen.backgroundIconsIPad[pos][0] : GeneratorScreen.backgroundIconsIPhone[pos][0]
            let backgroundSprite = SKSpriteNode(texture: SKTexture(image: backgroundIcon))
            backgroundSprite.size = (DeviceType.simulationIs == .iPad) ? backgroundIcon.size * 0.095 : backgroundIcon.size * 0.075
            buttons[pos].hkImage.imageNode.addChild(backgroundSprite)
            overlays.append(backgroundSprite)
            buttons[pos].secondTextNode.text = ""
            buttons[pos].enabled = true
        }
        buttons[liveMPCGDGenome.backgroundChoice].showHighlight()
    }
    
    func loadBackgroundShadeOptions(){
        for pos in 0...8{
            buttons[pos].buttonSet = .backgroundShade
            buttons[pos].setImageAndText(nilImage, text: "")
            let backgroundIcon = (DeviceType.simulationIs == .iPad) ? GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][pos] : GeneratorScreen.backgroundIconsIPhone[liveMPCGDGenome.backgroundChoice][pos]
            let backgroundSprite = SKSpriteNode(texture: SKTexture(image: backgroundIcon))
            backgroundSprite.size = (DeviceType.simulationIs == .iPad) ? backgroundIcon.size * 0.095 : backgroundIcon.size * 0.075
            buttons[pos].hkImage.imageNode.addChild(backgroundSprite)
            overlays.append(backgroundSprite)
            buttons[pos].secondTextNode.text = ""
            buttons[pos].enabled = true
        }
        buttons[liveMPCGDGenome.backgroundShade].showHighlight()
    }
    
    func loadAmbiance(){
        returnLinesToNormal()
        ambianceChannelShowing = nil
        verticalLines[2].yScale = 0.33
        verticalLines[2].position.y -= squareHeight
        horizontalLines[1].alpha = 0
        horizontalLines[2].xScale = 0.66
        horizontalLines[2].position.x += squareWidth/2
        showHelpText("Ambience")
        tappedButtonNumbers.removeAll()
        for pos in 0...8{
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].buttonSet = .ambiance
            if pos < 7{
                buttons[pos].useTempHighlight = false
            }
        }

        var yPos = CGFloat(squareHeight - 3)
        let gap = CGFloat(58)

        updateAmbianceChannelLabels()
        
        ambianceChoiceLabels.removeAll()
        for pos in 0...5{
            let label = SKLabelNode(text: "")
            addChild(label)
            label.verticalAlignmentMode = .center
            ambianceChoiceLabels.append(label)
            label.fontName = "Helvetica Neue Thin"
            label.fontSize = 17
            label.fontColor = Colours.getColour(.antiqueWhite)
            let xPos = (pos % 2 == 0) ? 0 : squareWidth
            label.position = CGPoint(x: xPos!, y: yPos)
            overlays.append(label)
            if pos % 2 == 1{
                yPos -= gap
            }
        }
        
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
        
        let label = SKLabelNode(text: "Play")
        label.fontName = "Helvetica Neue Thin"
        label.fontSize = 21
        label.fontColor = Colours.getColour(.antiqueWhite)
        label.position.y = 7
        buttons[7].hkImage.imageNode.addChild(label)
        overlays.append(label)
        
        ambiancePlayTypeLabel = SKLabelNode(text: "Solo")
        ambiancePlayTypeLabel.fontName = "Helvetica Neue Thin"
        ambiancePlayTypeLabel.fontSize = 20
        ambiancePlayTypeLabel.fontColor = Colours.getColour(.antiqueWhite)
        ambiancePlayTypeLabel.position.y = -23
        buttons[7].hkImage.imageNode.addChild(ambiancePlayTypeLabel)
        overlays.append(ambiancePlayTypeLabel)
    }
    
    func updateAmbianceChannelLabels(){
        for a in ambianceCategoryLabels{
            a.removeFromParent()
        }
        ambianceCategoryLabels.removeAll()
        let gap = CGFloat(53)
        var yPos = CGFloat(squareHeight + 2)

        let nums = [liveMPCGDGenome.ambiance1, liveMPCGDGenome.ambiance2, liveMPCGDGenome.ambiance3, liveMPCGDGenome.ambiance4, liveMPCGDGenome.ambiance5]
        let trackNames = MPCGDAudioPlayer.getAmbianceTrackNames()
        for pos in 0...4{
            let label = SKLabelNode(text: "Sound\(pos + 1)")
            addChild(label)
            label.verticalAlignmentMode = .center
            ambianceCategoryLabels.append(label)
            label.fontName = "Helvetica Neue Thin"
            label.fontSize = 12
            label.fontColor = Colours.getColour(.antiqueWhite)
            label.position = CGPoint(x: -squareWidth, y: yPos + 20)
            overlays.append(label)
            
            let label2 = SKLabelNode(text: trackNames[nums[pos]])
            label2.fontName = "Helvetica Neue Thin"
            label2.fontSize = 17
            label2.fontColor = Colours.getColour(.antiqueWhite)
            label2.position = CGPoint(x: 0, y: -23)
            label.addChild(label2)
            
            yPos -= gap
        }
    }
    
    func toggleSoloAmbiance(){
        if ambianceChannelShowing != nil{
            if ambiancePlayTypeLabel.text == "Solo"{
                ambiancePlayTypeLabel.text = "Ambience"
                MPCGDAudioPlayer.playSoloChannel(channelNum: ambianceChannelShowing)
            }
            else{
                ambiancePlayTypeLabel.text = "Solo"
                MPCGDAudioPlayer.handleGenomeChange(MPCGDGenome: liveMPCGDGenome)
            }
        }
    }
    
    func handleAmbianceButtonTap(buttonNum: Int){
        if buttonNum == 0 || buttonNum == 3 || buttonNum == 6{
            var tapPos = buttons[buttonNum].tappedAt.y + squareHeight
            if buttonNum == 3{
                tapPos -= squareHeight
            }
            else if buttonNum == 6{
                tapPos -= (squareHeight * 2)
            }
            var categoryNum = 0
            var closest: SKLabelNode! = nil
            var smallestDist = CGFloat(1000)
            var newAmbianceChannelShowing = -1
            for label in ambianceCategoryLabels{
                let yPos = label.position.y
                let dist = abs(yPos - tapPos)
                if dist < smallestDist{
                    closest = label
                    smallestDist = dist
                    newAmbianceChannelShowing = categoryNum + 1
                }
                categoryNum += 1
            }
            ambianceCategoryHighlighter.position.y = closest.position.y - 9
            ambianceCategoryHighlighter.isHidden = false
            
            ambianceChannelShowing = newAmbianceChannelShowing
            loadAmbianceCategories()
            ambianceChoicesAreShowing = false
            if ambiancePlayTypeLabel.text == "Ambience"{
                toggleSoloAmbiance()
            }
        }
        else if [1, 2, 4, 5].contains(buttonNum){
            var tapPos = buttons[buttonNum].tappedAt.y
            if buttonNum == 1 || buttonNum == 2{
                tapPos += squareHeight
            }
            var smallestDist = CGFloat(1000)
            var rowChosen = 0
            var row = 0
            for label in [ambianceChoiceLabels[0], ambianceChoiceLabels[2], ambianceChoiceLabels[4]]{
                let yPos = label.position.y + 10
                let dist = abs(yPos - tapPos)
                if dist < smallestDist{
                    smallestDist = dist
                    rowChosen = row
                }
                row += 1
            }
            rowChosen = min(rowChosen, 2)
            let addOn = [2, 5].contains(buttonNum) ? 1 : 0
            if !ambianceChoicesAreShowing{
                let choice = (rowChosen * 2) + addOn
                if choice < 5{
                    ambianceCategoryShowing = choice
                    loadAmbianceCategory(category: ambianceCategoryShowing)
                    ambianceChoicesAreShowing = true
                }
                else{
                    switch ambianceChannelShowing{
                    case 1: liveMPCGDGenome.ambiance1 = 0
                    case 2: liveMPCGDGenome.ambiance2 = 0
                    case 3: liveMPCGDGenome.ambiance3 = 0
                    case 4: liveMPCGDGenome.ambiance4 = 0
                    case 5: liveMPCGDGenome.ambiance5 = 0
                    default: liveMPCGDGenome.ambiance1 = 0
                    }
                    MPCGDAudioPlayer.setVolume(channelNum: ambianceChannelShowing, volume: 0)
                    for b in ambianceChoiceLabels{
                        b.isHidden = true
                    }
                    ambianceChoiceHighlighter.isHidden = true
                    updateAmbianceChannelLabels()
                    ambianceCategoryHighlighter.isHidden = true
                    ambianceChannelShowing = nil
                    onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                }
            }
            else{
                let addOn = [2, 5].contains(buttonNum) ? 1 : 0
                var trackNum = (rowChosen * 2) + addOn
                trackNum = (ambianceCategoryShowing * 6) + trackNum + 1
                switch ambianceChannelShowing{
                case 1: liveMPCGDGenome.ambiance1 = trackNum
                case 2: liveMPCGDGenome.ambiance2 = trackNum
                case 3: liveMPCGDGenome.ambiance3 = trackNum
                case 4: liveMPCGDGenome.ambiance4 = trackNum
                case 5: liveMPCGDGenome.ambiance5 = trackNum
                default: liveMPCGDGenome.ambiance1 = 0
                }
                onGameAlterationCode?(self.liveMPCGDGenome, self.isLocked)
                ambianceChoiceHighlighter.isHidden = false
                let trackName = MPCGDAudioPlayer.getAmbianceTrackNames()[trackNum] + ".m4a"
                let lwg = liveMPCGDGenome
                let vol = Float([lwg.channelVolume1, lwg.channelVolume2, lwg.channelVolume3, lwg.channelVolume4, lwg.channelVolume5][ambianceChannelShowing - 1])/Float(30)
                let tempo = [lwg.channelTempo1, lwg.channelTempo2, lwg.channelTempo3, lwg.channelTempo4, lwg.channelTempo5][ambianceChannelShowing - 1]
                let rate = MPCGDAudioPlayer.calculateRate(genomeTempo: tempo)
                MPCGDAudioPlayer.loadAndPlayAudio(trackName: trackName, channelNum: ambianceChannelShowing, volume: vol, rate: rate)
                ambianceChoiceHighlighter.position = ambianceChoiceLabels[(trackNum - 1) % 6].position
                ambianceChoiceHighlighter.position.y += 12
                updateAmbianceChannelLabels()
            }
        }
    }
    
    func loadAmbianceCategories(){
        let categoryNames = MPCGDAudioPlayer.getAmbianceCategoryNames()
        for pos in 0...4{
            ambianceChoiceLabels[pos].text = categoryNames[pos]
            ambianceChoiceLabels[pos].isHidden = false
            ambianceChoiceLabels[pos].removeAllChildren()
            
            var choiceNames = MPCGDAudioPlayer.getAmbianceTrackNames()
            let s = 1 + (pos * 6)
            let e = 1 + ((pos + 1) * 6)
            choiceNames = Array(choiceNames[s..<e])

            for iPos in [0, 1, 2]{
                let icon = PDFImage(named: "Audio" + choiceNames[iPos], size: CGSize(width: 20, height: 20))!
                let node = SKSpriteNode(texture: SKTexture(image: icon))
                node.colorBlendFactor = 1
                node.color = Colours.getColour(.antiqueWhite)
                ambianceChoiceLabels[pos].addChild(node)
                node.position.x = -24 + (24 * CGFloat(iPos))
                node.position.y = 23
            }

        }
        ambianceChoiceLabels[5].text = "Off"
        ambianceChoiceLabels[5].isHidden = false
        ambianceChoiceLabels[5].removeAllChildren()
        let offNode = SKSpriteNode(imageNamed: "None")
        offNode.size = CGSize(width: 25, height: 30)
        ambianceChoiceLabels[5].addChild(offNode)
        offNode.position.y = 23
        
        var cNum = 0
        switch ambianceChannelShowing{
        case 1: cNum = liveMPCGDGenome.ambiance1
        case 2: cNum = liveMPCGDGenome.ambiance2
        case 3: cNum = liveMPCGDGenome.ambiance3
        case 4: cNum = liveMPCGDGenome.ambiance4
        case 5: cNum = liveMPCGDGenome.ambiance5
        default: cNum = 0
        }
        ambianceChoiceHighlighter.isHidden = false
        if cNum > 0{
            let pos = Int(floor(CGFloat(cNum - 1)/6))
            ambianceChoiceHighlighter.position = ambianceChoiceLabels[pos].position
            ambianceChoiceHighlighter.position.y += 12
        }
        else{
            ambianceChoiceHighlighter.position = ambianceChoiceLabels[5].position
            ambianceChoiceHighlighter.position.y += 12
        }
        
    }
    
    func loadAmbianceCategory(category: Int){
        ambianceCategoryShowing = category
        var choiceNames = MPCGDAudioPlayer.getAmbianceTrackNames()
        let s = 1 + (category * 6)
        let e = 1 + ((category + 1) * 6)
        choiceNames = Array(choiceNames[s..<e])
        for pos in 0...5{
            ambianceChoiceLabels[pos].text = choiceNames[pos]
            ambianceChoiceLabels[pos].removeAllChildren()
            let icon = PDFImage(named: "Audio" + choiceNames[pos], size: CGSize(width: 23, height: 23))!
            let node = SKSpriteNode(texture: SKTexture(image: icon))
            node.colorBlendFactor = 1
            node.color = Colours.getColour(.antiqueWhite)
            ambianceChoiceLabels[pos].addChild(node)
            node.position.y = 23
        }
        var cNum = 0
        switch ambianceChannelShowing{
        case 1: cNum = liveMPCGDGenome.ambiance1
        case 2: cNum = liveMPCGDGenome.ambiance2
        case 3: cNum = liveMPCGDGenome.ambiance3
        case 4: cNum = liveMPCGDGenome.ambiance4
        case 5: cNum = liveMPCGDGenome.ambiance5
        default: cNum = 0
        }
        
        ambianceChoiceHighlighter.isHidden = true
        if cNum > 0{
            if Int(floor(CGFloat(cNum - 1)/6)) == category{
                ambianceChoiceHighlighter.isHidden = false
                let pos = (cNum - 1) % 6
                ambianceChoiceHighlighter.position = ambianceChoiceLabels[pos].position
                ambianceChoiceHighlighter.position.y += 12
            }
            if ambiancePlayTypeLabel.text == "Ambience"{
                MPCGDAudioPlayer.playSoloChannel(channelNum: ambianceChannelShowing)
            }
        }
    }

    func loadAudioChoices(){
        returnLinesToNormal()
        showHelpText("Tracks")
        audioEqualiserScreen.alpha = 0
        audioEqualiserScreen.closeDown()
        for pos in 0...8{
            buttons[pos].buttonSet = .audioChoice
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].alpha = 1
            buttons[pos].enabled = true
            buttons[pos].secondTextNode.text = ""
            let trackNames = ["track1", "track2", "track3", "track4", "track5", "track6"]
            if pos < 6{
                addLowerLabel(buttons[pos], text: MPCGDAudioPlayer.musicNames[pos])
                let musicNode = SKSpriteNode(texture: SKTexture(image: PDFImage(named: trackNames[pos], size: CGSize(width: 60, height: 60))!))
                musicNode.colorBlendFactor = 1
                musicNode.color = Colours.getColour(.antiqueWhite)
                buttons[pos].hkImage.imageNode.addChild(musicNode)
                overlays.append(musicNode)
                musicNode.position.y = 10
            }
        }
        let yingyangNode = SKSpriteNode(imageNamed: "YingYang")
        buttons[6].hkImage.imageNode.addChild(yingyangNode)
        overlays.append(yingyangNode)
        yingyangNode.position.y = 10
        addLowerLabel(buttons[6], text: "Ambience")
        let offImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: true)
        buttons[7].setImageAndText(offImage, text: "")
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
        if liveMPCGDGenome.soundtrackPack == 1{
            tappedButtonNumbers = [liveMPCGDGenome.musicChoice]
            buttons[liveMPCGDGenome.musicChoice].showHighlight()
        }
        else if liveMPCGDGenome.soundtrackPack == 2{
            tappedButtonNumbers = [6]
            buttons[6].showHighlight()
        }
        else if liveMPCGDGenome.soundtrackPack == 0{
            tappedButtonNumbers = [7]
            buttons[7].showHighlight()
        }
    }
    
    func showExplodeScoreOptions(_ imageStem: String, clusterSize: Int, newButtonSet: ButtonSetEnum, chosenPosition: Int){
        for pos in 0...8{
            let score = clusterSize * (pos - 4)
            var s = "\(score)"
            if score > 0{
                s = "+\(score)"
            }
            buttons[pos].setImageAndText(nilImage, text: "\(s)")
            buttons[pos].buttonSet = newButtonSet
            buttons[pos].secondTextNode.text = ""
            buttons[pos].textNode.position.y = 0
            buttons[pos].hkImage.position.x -= 4
            let explodePositions = getExplodePositions(clusterSize)
            var ppos = 0
            for p in explodePositions{
                if imageStem == "White"{
                    addWhiteBall(buttons[pos], size: 15, position: p)
                }
                else if imageStem == "Blue"{
                    addBlueBall(buttons[pos], size: 15, position: p)
                }
                else if ppos % 2 == 0{
                    addWhiteBall(buttons[pos], size: 15, position: p)
                }
                else{
                    addBlueBall(buttons[pos], size: 15, position: p)
                }
                ppos += 1
            }
            if clusterSize >= 2{
                let explodeY = CGFloat(7) + CGFloat(clusterSize * 5)
                let topExplodeNode = SKSpriteNode(imageNamed: "ExplodeGraphic")
                let bottomExplodeNode = SKSpriteNode(imageNamed: "ExplodeGraphic")
                bottomExplodeNode.zRotation = CGFloat.pi
                buttons[pos].hkImage.imageNode.addChild(topExplodeNode)
                buttons[pos].hkImage.imageNode.addChild(bottomExplodeNode)
                topExplodeNode.position = CGPoint(x: 0, y: explodeY)
                bottomExplodeNode.position = CGPoint(x: 0, y: -explodeY)
                if explodePositions.count == 2{
                    topExplodeNode.position.x = -12
                    bottomExplodeNode.position.x = -11
                }
                else if explodePositions.count > 2 && explodePositions.count % 2 == 1{
                    topExplodeNode.position.x = -20
                    bottomExplodeNode.position.x = -21
                }
                else{
                    topExplodeNode.position.x = -10
                    bottomExplodeNode.position.x = -20
                }
                if explodePositions.count == 9{
                    topExplodeNode.position.y -= 3
                    bottomExplodeNode.position.y += 3
                }
                overlays.append(topExplodeNode)
                overlays.append(bottomExplodeNode)
            }

            if clusterSize == 0{
                let bounceNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "ClusterBounce")!))
                buttons[pos].hkImage.imageNode.addChild(bounceNode)
                bounceNode.position.x -= 4
                overlays.append(bounceNode)
            }

        }
        buttons[chosenPosition].showHighlight()
    }
    
    func loadControllerCollisions(){
        returnLinesToNormal()
        verticalLines[1].yScale = 0.33
        verticalLines[1].position.y -= squareHeight
        
        for b in buttons{
            b.buttonSet = .controllerCollisions
            b.setImageAndText(nilImage, text: "")
            b.secondTextNode.text = ""
            b.enabled = false
            b.hkImage.position.x = 0
        }
        buttons[2].enabled = true
        buttons[5].enabled = true
        buttons[7].enabled = true
        controllerCollisionsScreen.alpha = 1
        controllerCollisionsScreen.initialiseFromMPCGDGenome(liveMPCGDGenome, whiteCharName: getWhiteName(), blueCharName: getBlueName())
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[7].setImageAndText(okImage, text: "")
        addControllerCollisionIcon("White", buttonNum: 2)
        addControllerCollisionIcon("Blue", buttonNum: 5)
    }
    
    func loadClusterTop(){
        for b in buttons{
            b.buttonSet = .clusterTop
            b.setImageAndText(nilImage, text: "")
            b.secondTextNode.text = ""
            b.enabled = false
            b.hkImage.position.x = 0
        }

        var pos = 3
        for stem in ["White", "Blue", "Mixed"]{
            let clusterSize = (pos == 3) ? liveMPCGDGenome.whiteCriticalClusterSize : ((pos == 4) ? liveMPCGDGenome.blueCriticalClusterSize : liveMPCGDGenome.mixedCriticalClusterSize)
            let clusterNode = getClusterNode(stem, clusterSize: clusterSize, xOffset: 0)
            if clusterSize != 0{
                clusterNode.setScale(0.75)
                clusterNode.position.y = CGFloat(12)
            }
            buttons[pos].hkImage.imageNode.addChild(clusterNode)
            overlays.append(clusterNode)

            let clusterScore = (pos == 3) ? liveMPCGDGenome.whiteExplodeScore : ((pos == 4) ? liveMPCGDGenome.blueExplodeScore : liveMPCGDGenome.mixedExplodeScore)

            if clusterSize > 0{
                let s = clusterScore == -90 ? MPCGDGenome.deathSymbol : "\(clusterScore)"
                let label = SKLabelNode(text: s)
                buttons[pos].addChild(label)
                label.fontName = "Helvetica Neue Thin"
                label.fontSize = 14
                label.fontColor = whiteColour
                label.position.y = -33
                label.verticalAlignmentMode = .center
                overlays.append(label)
            }
            
            buttons[pos].enabled = true
            pos += 1
        }
    }
    
    func loadAudioTop(){
        returnLinesToNormal()
        verticalLines[1].yScale = 0.33
        verticalLines[1].position.y -= squareHeight
        verticalLines[2].yScale = 0.33
        verticalLines[2].position.y -= squareHeight
        audioEqualiserScreen.alpha = 0
        audioEqualiserScreen.closeDown()
        volumesScreen.closeDown()
        volumesScreen.alpha = 0
        showHelpText("Audio")
        for pos in 0...8{
            buttons[pos].buttonSet = .audioTop
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].enabled = [6, 7, 8].contains(pos) ? true : false
            buttons[pos].secondTextNode.text = ""
            buttons[pos].removeHighlight()
        }
        var pos = 6
        for s in ["Sound track", "Sound effects"]{
            let parts = s.components(separatedBy: " ")
            let label = SKLabelNode(text: parts[0])
            label.fontName = "Helvetica Neue Thin"
            label.fontColor = Colours.getColour(.antiqueWhite)
            label.fontSize = 19
            label.verticalAlignmentMode = .center
            label.position.y = -15
            buttons[pos].hkImage.imageNode.addChild(label)
            overlays.append(label)
            let label2 = SKLabelNode(text: parts[1])
            label2.fontName = "Helvetica Neue Thin"
            label2.fontColor = Colours.getColour(.antiqueWhite)
            label2.fontSize = 19
            label2.verticalAlignmentMode = .center
            label2.position.y = -35
            buttons[pos].hkImage.imageNode.addChild(label2)
            overlays.append(label2)
            pos += 1
        }
        let mixerNode = SKSpriteNode(texture: SKTexture(image: PDFImage(named: "mixer", size: CGSize(width: 40, height: 40))!))
        buttons[6].addChild(mixerNode)
        mixerNode.colorBlendFactor = 1
        mixerNode.color = Colours.getColour(.antiqueWhite)
        mixerNode.position.y = 18
        overlays.append(mixerNode)

        let explosionNode = SKSpriteNode(texture: SKTexture(image: PDFImage(named: "SFXExplode", size: CGSize(width: 40, height: 40))!))
        explosionNode.colorBlendFactor = 1
        explosionNode.color = Colours.getColour(.antiqueWhite)
        buttons[7].addChild(explosionNode)
        explosionNode.position.y = 19
        overlays.append(explosionNode)
        
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
        volumesScreen.initialiseFromMPCGDGenome(MPCGDGenome: liveMPCGDGenome)
        volumesScreen.alpha = 1
    }
    
    func loadSFXPacks(){
        returnLinesToNormal()
        volumesScreen.closeDown()
        volumesScreen.alpha = 0
        for pos in 0...8{
            buttons[pos].buttonSet = .sfxPack
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].enabled = true
            buttons[pos].secondTextNode.text = ""
            addLowerLabel(buttons[pos], text: MPCGDSounds.sfxPackNames[pos].capitalized)
            
            let iconName = "SFXCollection" + MPCGDSounds.sfxPackNames[pos].capitalized
            let iconNode = SKSpriteNode(texture: SKTexture(image: PDFImage(named: iconName, size: CGSize(width: 50, height: 50))!))
            iconNode.colorBlendFactor = 1
            iconNode.color = Colours.getColour(.antiqueWhite)
            iconNode.position.y = 10
            overlays.append(iconNode)
            buttons[pos].hkImage.imageNode.addChild(iconNode)
        }
        tappedButtonNumbers = [liveMPCGDGenome.sfxPack]
        showTicks()
    }
    
    func loadSFXBooleans(){
        tappedButtonNumbers.removeAll()
        showHelpText("\(MPCGDSounds.sfxPackNames[liveMPCGDGenome.sfxPack].capitalized) SFX")
        returnLinesToNormal()
        for pos in 0...8{
            buttons[pos].buttonSet = .sfxBooleans
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].enabled = true
            buttons[pos].secondTextNode.text = ""
        }
        var pos = 0
        let binBs = liveMPCGDGenome.getBinaryBreakdown(liveMPCGDGenome.sfxBooleans)
        
        for s in ["Bounce", "Gain pts",  "Lose pts", "Tap", "Win game", "Lose game", "Explode", "Lose life"]{
            let label = SKLabelNode(text: s)
            label.fontName = "Helvetica Neue Thin"
            label.fontColor = Colours.getColour(.antiqueWhite)
            label.fontSize = 21
            label.verticalAlignmentMode = .center
            //buttons[pos].hkImage.imageNode.addChild(label)
            //overlays.append(label)
            addLowerLabel(buttons[pos], text: s)
            if binBs[pos] == true{
                buttons[pos].showHighlight()
                tappedButtonNumbers.append(pos)
            }
            let iconName = sfxIconNames[pos] + "Outline"
            let iconNode = SKSpriteNode(texture: SKTexture(image: PDFImage(named: iconName,size: CGSize(width: 50, height: 50))!))
            iconNode.colorBlendFactor = 1
            iconNode.color = sfxIconColours[pos]
            iconNode.position.y = 10
            overlays.append(iconNode)
            buttons[pos].hkImage.imageNode.addChild(iconNode)
            pos += 1
        }
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
    }
    
    func loadAudio(){
        returnLinesToNormal()
        volumesScreen.closeDown()
        volumesScreen.alpha = 0
        equaliserSlidersChangeTempo = false
        showHelpText("Soundtrack Volumes")
        ambianceChoiceHighlighter.isHidden = true
        ambianceCategoryHighlighter.isHidden = true
        tappedButtonNumbers.removeAll()
        for pos in 0...8{
            buttons[pos].buttonSet = .audio
            buttons[pos].setImageAndText(nilImage, text: "")
            buttons[pos].enabled = [2, 5, 8].contains(pos) ? true : false
            buttons[pos].secondTextNode.text = ""
            buttons[pos].removeHighlight()
        }
        verticalLines[1].alpha = 0
        horizontalLines[1].xScale = 0.33
        horizontalLines[1].position.x += squareWidth
        horizontalLines[2].xScale = 0.33
        horizontalLines[2].position.x += squareWidth
        
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
        
        changeAudioToggleButton(show: "Tempos")

        if liveMPCGDGenome.soundtrackPack > 0{
            audioEqualiserScreen.alpha = 1
            audioEqualiserScreen.isHidden = false
            audioEqualiserScreen.initialiseFromMPCGDGenome(MPCGDGenome: liveMPCGDGenome)
            buttons[2].alpha = 1
        }
        else{
            let offText = SKMultilineLabel(text: "Soundtrack\nOff", size: CGSize(width: 150, height: 150), pos: CGPoint(x: -size.width/6, y: 0), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Thin", fontSize: 25, fontColor: Colours.getColour(.antiqueWhite), leading: 2, alignment: .center, shouldShowBorder: false, spacing: 15)
            buttons[4].hkImage.imageNode.addChild(offText)
            overlays.append(offText)
            buttons[2].alpha = 0.3
            buttons[2].enabled = false
        }
        
        let musicNode = SKSpriteNode(texture: SKTexture(image: PDFImage(named: "track1", size: CGSize(width: 40, height: 40))!))
        buttons[5].hkImage.imageNode.addChild(musicNode)
        overlays.append(musicNode)
        musicNode.position = CGPoint(x: -20, y: 22)
        let yingyangNode = SKSpriteNode(imageNamed: "YingYang")
        buttons[5].hkImage.imageNode.addChild(yingyangNode)
        overlays.append(yingyangNode)
        yingyangNode.position = CGPoint(x: 20, y: 22)

        var y = CGFloat(-22)
        for s in ["Choose", "Tracks"]{
            let label = SKLabelNode(text: s)
            label.fontName = "Helvetica Neue Thin"
            label.fontSize = 20
            label.fontColor = Colours.getColour(.antiqueWhite)
            label.position.y = y
            overlays.append(label)
            buttons[5].hkImage.imageNode.addChild(label)
            y -= 20
        }
    }
    
    func changeAudioToggleButton(show: String){
        
        buttons[2].hkImage.imageNode.removeAllChildren()
        
        let iconName = (show == "Tempos") ? "tempo" : "volume"
            
        let iconNode = SKSpriteNode(texture: SKTexture(image: PDFImage(named: iconName, size: CGSize(width: 40, height: 40))!))
        buttons[2].hkImage.imageNode.addChild(iconNode)
        overlays.append(iconNode)
        iconNode.position.y = 25
        iconNode.colorBlendFactor = 1
        iconNode.color = Colours.getColour(.antiqueWhite)

        var y = CGFloat(-22)
        for s in ["Show", show]{
            let label = SKLabelNode(text: s)
            label.fontName = "Helvetica Neue Thin"
            label.fontSize = 20
            label.fontColor = Colours.getColour(.antiqueWhite)
            label.position.y = y
            overlays.append(label)
            buttons[2].hkImage.imageNode.addChild(label)
            y -= 20
        }

    }
    
    func loadClusters(stem: String){
        let charName = (stem == "White") ? getWhiteName() : ((stem == "Blue") ? getBlueName() : "Mixed")
        
        var clusterID = ButtonSetEnum.whiteClusters
        if stem == "Blue"{
            clusterID = .blueClusters
        }
        else if stem == "Mixed"{
            clusterID = .mixedClusters
        }
        showHelpText("\(charName) clusters")
        returnLinesToNormal()
        verticalLines[1].yScale = 0.33
        verticalLines[1].position.y -= squareHeight
        verticalLines[2].yScale = 0.33
        verticalLines[2].position.y -= squareHeight
        
        for b in buttons{
            b.buttonSet = clusterID
            b.setImageAndText(nilImage, text: "")
            b.secondTextNode.text = ""
            b.enabled = false
            b.hkImage.position.x = 0
        }
        buttons[7].enabled = true
        let bounceNode = getClusterNode(stem, clusterSize: 0, xOffset: 0)
        bounceNode.position.x = -30
        buttons[7].hkImage.imageNode.addChild(bounceNode)
        overlays.append(bounceNode)
        var y = CGFloat(10)
        for s in ["No", "Clusters"]{
            let l = SKLabelNode(text: s)
            l.fontName = "Helvetica Neue Thin"
            l.fontSize = 17
            l.fontColor = Colours.getColour(.antiqueWhite)
            buttons[7].hkImage.imageNode.addChild(l)
            l.position.x = 14
            l.position.y = y
            overlays.append(l)
            y -= 30
        }

        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
        buttons[8].enabled = true
        
        let clusterSize = (stem == "White") ? liveMPCGDGenome.whiteCriticalClusterSize : (stem == "Blue") ? liveMPCGDGenome.blueCriticalClusterSize : liveMPCGDGenome.mixedCriticalClusterSize
        let visNode = getClusterNode(stem, clusterSize: clusterSize, xOffset: 0)
        clustersScreen.initialiseFromMPCGDGenome(mpcgdGenome: liveMPCGDGenome, stem: stem, clusterVisNode: visNode)
        clustersScreen.alpha = 1
        
        if clusterSize == 0{
            buttons[7].showHighlight()
        }
    }
    
    func addControllerCollisionIcon(_ stem: String, buttonNum: Int, xOffset: CGFloat = 0){
    
        let gridImage = gg.getGridIcon(iconSize: buttonSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: 61, colour: MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade], includeBorder: false)
        
        let gridNode = SKSpriteNode(texture: SKTexture(image: gridImage))
        CharacterIconHandler.alterNodeOrientation(isGrid: liveMPCGDGenome.controllerPack == 1, collectionNum: liveMPCGDGenome.gridShape, characterNum: liveMPCGDGenome.gridOrientation, reflectionID: liveMPCGDGenome.gridReflection, node: gridNode)
        buttons[buttonNum].hkImage.imageNode.addChild(gridNode)
        
        if liveMPCGDGenome.controllerPack == 2 && liveMPCGDGenome.gridColour < 8{
            gridNode.colorBlendFactor = 0.5
            gridNode.color = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
        }
        
        gridNode.size = gridNode.size * (liveMPCGDGenome.gridReflection > 1 ? 0.175 : 0.3)
        
        gridNode.position.x = xOffset
        gridNode.position.y = -10
        let ballSize = CGSize(width: 16, height: 16)
        let ballNode = stem == "White" ? getWhiteBall(ballSize) : getBlueBall(ballSize)
        ballNode.position.y = 17
        ballNode.position.x = xOffset
        buttons[buttonNum].hkImage.imageNode.addChild(ballNode)
        let standAlone = (stem == "White") ? 1 : 2
        if liveMPCGDGenome.ballControllerExplosions == standAlone || liveMPCGDGenome.ballControllerExplosions == 3{
            ballNode.position.y = 16
            let explode1 = SKSpriteNode(imageNamed: "ExplodeGraphic")
            explode1.position = CGPoint(x: xOffset, y: 28)
            buttons[buttonNum].hkImage.imageNode.addChild(explode1)
            overlays.append(explode1)
            gridNode.position.y = -8
        }
        else{
            let bounceNode = SKSpriteNode(imageNamed: "ControllerBounce")
            buttons[buttonNum].hkImage.imageNode.addChild(bounceNode)
            bounceNode.position.x = xOffset
            overlays.append(bounceNode)
        }
        overlays.append(ballNode)
        overlays.append(gridNode)
    }
    
    func getExplodePositions(_ num: Int) -> [CGPoint]{
        var positions: [CGPoint] = []
        if num == 0{
            positions.append(CGPoint(x: 0, y: -11))
            positions.append(CGPoint(x: 0, y: 11))
        }
        else if num == 2{
            positions.append(CGPoint(x: 0, y: -7))
            positions.append(CGPoint(x: 0, y: 7))
        }
        else{
            var y = 5 - CGFloat(10 * num)/2
            for pos in 0..<num{
                let x = pos % 2 == 0 ? CGFloat(-5) : CGFloat(5)
                positions.append(CGPoint(x: x, y: y))
                y += 10
            }
        }
        return positions
    }
    
    func loadExplodeImages(_ stem: String, buttonSet: ButtonSetEnum, chosenPosition: Int){
        var pos = 0
        var explodeY = CGFloat(12)
        for buttonNum in 0...8{
            buttons[buttonNum].buttonSet = buttonSet
            let clusterSize = (buttonNum == 0) ? 0 : buttonNum + 1
            let explodePositions = getExplodePositions(clusterSize)
            var ppos = 0
            for p in explodePositions{
                if stem == "White"{
                    addWhiteBall(buttons[pos], size: 15, position: p)
                }
                else if stem == "Blue"{
                    addBlueBall(buttons[pos], size: 15, position: p)
                }
                else if ppos % 2 == 0{
                    addWhiteBall(buttons[pos], size: 15, position: p)
                }
                else{
                    addBlueBall(buttons[pos], size: 15, position: p)
                }
                ppos += 1
            }
            if buttonNum > 0{
                let topExplodeNode = SKSpriteNode(imageNamed: "ExplodeGraphic")
                let bottomExplodeNode = SKSpriteNode(imageNamed: "ExplodeGraphic")
                bottomExplodeNode.zRotation = CGFloat.pi
                buttons[pos].hkImage.imageNode.addChild(topExplodeNode)
                buttons[pos].hkImage.imageNode.addChild(bottomExplodeNode)
                topExplodeNode.position = CGPoint(x: 0, y: explodeY)
                bottomExplodeNode.position = CGPoint(x: 0, y: -explodeY)
                if explodePositions.count == 2{
                    topExplodeNode.position.x = 0
                    bottomExplodeNode.position.x = 1
                }
                else if explodePositions.count > 2 && explodePositions.count % 2 == 1{
                    topExplodeNode.position.x = -5
                    bottomExplodeNode.position.x = -6
                }
                else{
                    topExplodeNode.position.x = 5
                    bottomExplodeNode.position.x = -5
                }
                if explodePositions.count == 9{
                    topExplodeNode.position.y -= 3
                    bottomExplodeNode.position.y += 3
                }
                overlays.append(topExplodeNode)
                overlays.append(bottomExplodeNode)
            }
            buttons[pos].hkImage.imageNode.texture = SKTexture(image: nilImage)
            buttons[pos].textNode.position = CGPoint(x: textXPos, y: 0)
            buttons[pos].textNode.text = ""//"\(buttonNum)"
            buttons[pos].textNode.position.y = 0
            buttons[pos].secondTextNode.text = ""
            //buttons[pos].hkImage.position.x += 16
            if buttonNum == 0{
                let bounceNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "ClusterBounce")!))
                buttons[pos].hkImage.imageNode.addChild(bounceNode)
                //bounceNode.position.x -= 1
                overlays.append(bounceNode)
            }
            explodeY += 5
            pos += 1
        }
        buttons[chosenPosition].showHighlight()
    }
    
    func addChangeOverlay(_ button: GenButton, charType: String, x: CGFloat, y: CGFloat, size: CGSize){
        let changerNode = charType == "White" ? getWhiteBall(size) : getBlueBall(size)
        changerNode.size = size
        changerNode.position = CGPoint(x: x, y: y)
        button.hkImage.imageNode.addChild(changerNode)
        overlays.append(changerNode)
    }
    
    func loadTapActionOptions(_ buttonSet: ButtonSetEnum){
        
        returnLinesToNormal()
        verticalLines[1].yScale = 0.66
        verticalLines[1].position.y += squareHeight/2

        var charType = ""
        
        if buttonSet == .whiteTapAction{
            whiteTapScreen.initialiseFromMPCGDGenome(liveMPCGDGenome, tapScore: liveMPCGDGenome.whiteTapScore)
            whiteTapScreen.alpha = 1
            charType = "Blue" // not a mistake!
        }
        else{
            blueTapScreen.initialiseFromMPCGDGenome(liveMPCGDGenome, tapScore: liveMPCGDGenome.blueTapScore)
            blueTapScreen.alpha = 1
            charType = "White" // not a mistake!
        }
        
        for b in buttons{
            b.setImageAndText(nilImage, text: "")
            b.buttonSet = buttonSet
        }
        
        for buttonNum in 0...5{
            buttons[buttonNum].setImageAndText(nilImage, text: "")
            buttons[buttonNum].textNode.position.y = 18
            buttons[buttonNum].secondTextNode.text = ""
            
            let ballNode = (buttonSet == .whiteTapAction) ? getWhiteBall(tapBallSize) : getBlueBall(tapBallSize)
            ballNode.position = CGPoint(x: -2, y: 30)
            buttons[buttonNum].hkImage.imageNode.addChild(ballNode)
            overlays.append(ballNode)
            
            let tapNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "TapHand")!))
            buttons[buttonNum].hkImage.imageNode.addChild(tapNode)
            overlays.append(tapNode)

            if buttonNum == 3{
                addChangeOverlay(buttons[3], charType: charType, x: 24, y: 29, size: tapBallSize)
            }
            
            let tapName = "Tap\(MPCGDGenome.tapActions[buttonNum + 1])"
            let overlayImageNode = HKImage(image: UIImage(named: tapName)!)
            buttons[buttonNum].hkImage.imageNode.addChild(overlayImageNode)
            overlays.append(overlayImageNode)
            addLowerLabel(buttons[buttonNum], text: MPCGDGenome.tapActions[buttonNum + 1])
        }
        buttons[6].enabled = false
        buttons[7].enabled = false
        let tapIsOff = (buttonSet == .whiteTapAction) ? (liveMPCGDGenome.whiteTapAction == 0) : (liveMPCGDGenome.blueTapAction == 0)
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: tapIsOff)
        buttons[8].setImageAndText(okImage, text: "")

        let tapAction = (buttonSet == .whiteTapAction) ? liveMPCGDGenome.whiteTapAction : liveMPCGDGenome.blueTapAction
        if tapAction > 0{
            buttons[tapAction - 1].showHighlight()
        }
    }
    
    func loadGameEndChoices(){
        returnLinesToNormal()
        verticalLines[1].alpha = 0
        verticalLines[2].position.y -= squareHeight
        verticalLines[2].yScale = 0.33

        for b in buttons{
            b.setImageAndText(nilImage, text: "")
            b.secondTextNode.text = ""
            b.buttonSet = .gameEndChoice
            b.enabled = false
        }
        gameEndingsScreen.initialiseFromMPCGDGenome(liveMPCGDGenome)
        gameEndingsScreen.alpha = 1
        buttons[8].enabled = true
        
        let okImage = liveMPCGDGenome.getSpawnImage(buttonSize, whiteSpawnNum: 256, blueSpawnNum: nil, isOff: false)
        buttons[8].setImageAndText(okImage, text: "")
        
        buttons[2].enabled = false
        buttons[5].enabled = false
    }
    
    func addExplosionButtons(){
        
        let mixedXOffset = (liveMPCGDGenome.mixedCriticalClusterSize == 0 || liveMPCGDGenome.mixedExplodeScore == 0) ? CGFloat(0) : CGFloat(-10)
        
        let wes: Int! = (liveMPCGDGenome.whiteCriticalClusterSize == 0) ? nil : liveMPCGDGenome.whiteExplodeScore
        let bes: Int! = (liveMPCGDGenome.blueCriticalClusterSize == 0) ? nil : liveMPCGDGenome.blueExplodeScore
        let mes: Int! = (mixedXOffset == 0) ? nil : liveMPCGDGenome.mixedExplodeScore
        
        let explodeXOffset = (liveMPCGDGenome.controllerPack == 0) ? CGFloat(0) : CGFloat(-10)
        let whiteClusterNode = getClusterNode("White", clusterSize: liveMPCGDGenome.whiteCriticalClusterSize, xOffset: explodeXOffset)
        buttons[3].addChild(whiteClusterNode)
        overlays.append(whiteClusterNode)
        
        let blueClusterNode = getClusterNode("Blue", clusterSize: liveMPCGDGenome.blueCriticalClusterSize, xOffset: explodeXOffset)
        buttons[4].addChild(blueClusterNode)
        overlays.append(blueClusterNode)
        
        let mixedClusterNode = getClusterNode("Mixed", clusterSize: liveMPCGDGenome.mixedCriticalClusterSize, xOffset: mixedXOffset)
        buttons[5].addChild(mixedClusterNode)
        overlays.append(mixedClusterNode)
        
        if liveMPCGDGenome.controllerPack != 0 {
            addControllerCollisionIcon("White", buttonNum: 3, xOffset: 17)
            addControllerCollisionIcon("Blue", buttonNum: 4, xOffset: 17)
        }
        
        addExplodeScoreTexts(button: buttons[3], explodeScore: wes, collisionScore: liveMPCGDGenome.whiteControllerCollisionScore)
        addExplodeScoreTexts(button: buttons[4], explodeScore: bes, collisionScore: liveMPCGDGenome.blueControllerCollisionScore)
        addExplodeScoreTexts(button: buttons[5], explodeScore: mes, explodeScoreXOffset: 60)
    }
    
    func addBallTapButton(){
        
        let whiteTapText = (liveMPCGDGenome.whiteTapAction == 0) ? "Off" : (liveMPCGDGenome.whiteTapScore == -90) ? MPCGDGenome.deathSymbol : "\(liveMPCGDGenome.whiteTapScore)"
        let blueTapText = (liveMPCGDGenome.blueTapAction == 0) ? "Off" : (liveMPCGDGenome.blueTapScore == -90) ? MPCGDGenome.deathSymbol : "\(liveMPCGDGenome.blueTapScore)"
        
        buttons[1].setImageAndText(nilImage, text: whiteTapText)
        buttons[1].textNode.position.x = 5
        buttons[1].secondTextNode.position.x = 5
        
        let whiteBallNode = getWhiteBall(smallTapBallSize)
        whiteBallNode.position = CGPoint(x: -21, y: 38)
        buttons[1].hkImage.imageNode.addChild(whiteBallNode)
        overlays.append(whiteBallNode)

        if liveMPCGDGenome.whiteTapAction > 0{
            
            if liveMPCGDGenome.whiteTapAction == 4{
                addChangeOverlay(buttons[1], charType: "Blue", x: -3, y: 38, size: smallTapBallSize)
            }
            
            let tapName1 = "Tap\(MPCGDGenome.tapActions[liveMPCGDGenome.whiteTapAction])"
            let whiteTapActionNode = HKImage(image: UIImage(named: tapName1)!)
            whiteTapActionNode.position = CGPoint(x: -20, y: 19)
            whiteTapActionNode.setScale(0.65)
            buttons[1].hkImage.imageNode.addChild(whiteTapActionNode)
            overlays.append(whiteTapActionNode)
        }
        
        let whiteHandNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "TapHand")!))
        whiteHandNode.setScale(0.65)
        whiteHandNode.position = CGPoint(x: -20, y: 18)
        buttons[1].hkImage.imageNode.addChild(whiteHandNode)
        overlays.append(whiteHandNode)
        
        let blueBallNode = getBlueBall(smallTapBallSize)
        blueBallNode.position = CGPoint(x: -21, y: -11)
        buttons[1].hkImage.imageNode.addChild(blueBallNode)
        overlays.append(blueBallNode)

        if liveMPCGDGenome.blueTapAction > 0{
            if liveMPCGDGenome.blueTapAction == 4{
                addChangeOverlay(buttons[1], charType: "White", x: -3, y: -10, size: smallTapBallSize)
            }
            
            let tapName2 = "Tap\(MPCGDGenome.tapActions[liveMPCGDGenome.blueTapAction])"
            let blueTapActionNode = HKImage(image: UIImage(named: tapName2)!)
            blueTapActionNode.position = CGPoint(x: -20, y: -30)
            blueTapActionNode.setScale(0.65)
            buttons[1].hkImage.imageNode.addChild(blueTapActionNode)
            overlays.append(blueTapActionNode)
        }
        
        let blueHandNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "TapHand")!))
        blueHandNode.setScale(0.65)
        blueHandNode.position = CGPoint(x: -20, y: -30)
        buttons[1].hkImage.imageNode.addChild(blueHandNode)
        overlays.append(blueHandNode)
        
        buttons[1].secondTextNode.text = blueTapText
        buttons[1].textNode.position = CGPoint(x: textXPos, y: 18)
        buttons[1].secondTextNode.position = CGPoint(x: textXPos, y: -18)
    }
    
    func addCharactersButton(){
        
        let (whiteBallSizeNode, blueBallSizeNode) = getBallSizesNodes()
        buttons[0].hkImage.imageNode.addChild(whiteBallSizeNode)
        whiteBallSizeNode.y = 15
        buttons[0].hkImage.imageNode.addChild(blueBallSizeNode)
        blueBallSizeNode.y = -15
        overlays.append(whiteBallSizeNode)
        overlays.append(blueBallSizeNode)
        buttons[0].setImageAndText(nilImage, text: "")
        let whiteBallTextNode = getBallSizesTextNode(liveMPCGDGenome.whiteSizes, includeSizeText: false, numBalls: "\(liveMPCGDGenome.whiteMaxOnScreen)")
        let blueBallTextNode = getBallSizesTextNode(liveMPCGDGenome.blueSizes, includeSizeText: false, numBalls: "\(liveMPCGDGenome.blueMaxOnScreen)")
        whiteBallTextNode.verticalAlignmentMode = .bottom
        blueBallTextNode.verticalAlignmentMode = .top
        whiteBallTextNode.position.y = 25
        blueBallTextNode.position.y = -25
        buttons[0].addChild(whiteBallTextNode)
        buttons[0].addChild(blueBallTextNode)
        overlays.append(whiteBallTextNode)
        overlays.append(blueBallTextNode)
    }
    
    func getBallSizesNodes() -> (SKNode, SKNode){
        let (wSizes, wWidth, wHeight) = getBallSizeDetails(liveMPCGDGenome.whiteSizes)
        let (bSizes, bWidth, bHeight) = getBallSizeDetails(liveMPCGDGenome.blueSizes)
        let whiteWidthMultiplier = buttonSize.width/wWidth
        let blueWidthMultiplier = buttonSize.width/bWidth
        let widthMultiplier = min(whiteWidthMultiplier, blueWidthMultiplier)
        let whiteHeightMultiplier = (buttonSize.height * 0.25)/wHeight
        let blueHeightMultiplier = (buttonSize.height * 0.25)/bHeight
        let heightMultiplier = min(whiteHeightMultiplier, blueHeightMultiplier)
        let multiplier = min(widthMultiplier, heightMultiplier)
        let whiteBallSizesNode = getBallSizeNode(sizes: wSizes, multiplier: multiplier, width: wWidth, ballType: "White")
        let blueBallSizesNode = getBallSizeNode(sizes: bSizes, multiplier: multiplier, width: bWidth, ballType: "Blue")
        return (whiteBallSizesNode, blueBallSizesNode)
    }
    
    func getBallSizeNode(sizes: [CGFloat], multiplier: CGFloat, width: CGFloat, ballType: String) -> SKNode{
        let ballSizeNode = SKNode()
        var x = -(width * multiplier)/2 + (sizes[0] * multiplier)/2
        var pos = 0
        for s in sizes{
            let ballSize = s * multiplier
            let bSize = CGSize(width: ballSize, height: ballSize)
            let ballNode = ballType == "White" ? getWhiteBall(bSize) : getBlueBall(bSize)
            ballNode.position.x = x
            ballSizeNode.addChild(ballNode)
            if pos < sizes.count - 1{
                x += ballSize/2 + (sizes[pos + 1] * multiplier)/2
            }
            pos += 1
        }
        return ballSizeNode
    }
    
    func getBallSizeDetails(_ ballSizesInt: Int) -> ([CGFloat], CGFloat, CGFloat){
        var ballSizes: [CGFloat] = []
        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        for pos in 0...7{
            let ballSize = CGFloat(MPCGDGenome.sizeNums[pos])
            if ballSizesInt & Int(exp2(Double(pos))) != 0{
                let size = CGFloat(MPCGDGenome.sizeNums[pos])
                ballSizes.append(ballSize)
                totalWidth += size
                maxHeight = max(maxHeight, size)
            }
        }
        return (ballSizes, totalWidth, maxHeight)
    }
    
    func addBehavioursButton(){
        
        buttons[2].secondTextNode.text = ""
        buttons[2].textNode.position.y = 25
        buttons[2].secondTextNode.position.y = -0
        buttons[2].setImageAndText(nilImage, text: "")
        
        if liveMPCGDGenome.whiteRotation == 0 && liveMPCGDGenome.blueRotation == 0{
            addDynamic("Speed", wVal: liveMPCGDGenome.whiteSpeed, bVal: liveMPCGDGenome.blueSpeed, y: 37)
            addDynamic("Noise", wVal: liveMPCGDGenome.whiteNoise, bVal: liveMPCGDGenome.blueNoise, y: 2)
            addDynamic("Bounce", wVal: liveMPCGDGenome.whiteBounce, bVal: liveMPCGDGenome.blueBounce, y: -35)
        }
        else{
            addDynamic("Speed", wVal: liveMPCGDGenome.whiteSpeed, bVal: liveMPCGDGenome.blueSpeed, y: 20)
            addDynamic("Noise", wVal: liveMPCGDGenome.whiteNoise, bVal: liveMPCGDGenome.blueNoise, y: -10)
            addDynamic("Bounce", wVal: liveMPCGDGenome.whiteBounce, bVal: liveMPCGDGenome.blueBounce, y: -37)
        }
        
        if liveMPCGDGenome.whiteRotation > 0{
            let iconNode = liveMPCGDGenome.whiteRotation == 1 ? SKSpriteNode(imageNamed: "BallRotateSmall") : SKSpriteNode(imageNamed: "BallNoRotateSmall")
            iconNode.position = CGPoint(x: -25, y: 40)
            buttons[2].hkImage.imageNode.addChild(iconNode)
            overlays.append(iconNode)
            let ballNode = getWhiteBall(CGSize(width: 10, height: 10))
            ballNode.position = iconNode.position
            buttons[2].hkImage.imageNode.addChild(ballNode)
            overlays.append(ballNode)
        }
        
        if liveMPCGDGenome.blueRotation > 0{
            let iconNode = liveMPCGDGenome.blueRotation == 1 ? SKSpriteNode(imageNamed: "BallRotateSmall") : SKSpriteNode(imageNamed: "BallNoRotateSmall")
            iconNode.position = CGPoint(x: 25, y: 40)
            buttons[2].hkImage.imageNode.addChild(iconNode)
            overlays.append(iconNode)
            let ballNode = getBlueBall(CGSize(width: 10, height: 10))
            ballNode.position = iconNode.position
            buttons[2].hkImage.imageNode.addChild(ballNode)
            overlays.append(ballNode)
        }
    }
    
    func addAudioButton(){
        
        if liveMPCGDGenome.soundtrackPack > 0{
            let equaliserNode = AudioEqualiserScreen.getNodeForGenome(size: CGSize(width: 68, height:87), MPCGDGenome: liveMPCGDGenome, fontSize: 15)
            buttons[5].hkImage.imageNode.addChild(equaliserNode)
            equaliserNode.position.y = 8
            overlays.append(equaliserNode)
            if liveMPCGDGenome.soundtrackPack == 2{
                let tracks = [liveMPCGDGenome.ambiance1, liveMPCGDGenome.ambiance2, liveMPCGDGenome.ambiance3, liveMPCGDGenome.ambiance4, liveMPCGDGenome.ambiance5]
                var noTracks = true
                for t in tracks{
                    if t > 0{
                        noTracks = false
                    }
                }
                if noTracks{
                    var y = 28
                    for s in ["No", "tracks", "chosen"]{
                        let label = SKLabelNode(text: s)
                        label.fontName = "Helvetica Neue Thin"
                        label.fontSize = 17
                        label.fontColor = Colours.getColour(.antiqueWhite)
                        buttons[5].hkImage.imageNode.addChild(label)
                        label.position = CGPoint(x: 0, y: y)
                        overlays.append(label)
                        y -= 20
                    }
                }
            }
        }
        else{
            var y = 20
            for s in ["Soundtrack", "off"]{
                let label = SKLabelNode(text: s)
                label.fontName = "Helvetica Neue Thin"
                label.fontSize = 19
                label.fontColor = Colours.getColour(.antiqueWhite)
                buttons[5].hkImage.imageNode.addChild(label)
                label.position = CGPoint(x: 0, y: y)
                overlays.append(label)
                y -= 27
            }
        }
        
        
        let volIcon = SKSpriteNode(texture: SKTexture(image: PDFImage(named: "volume", size: CGSize(width: 12, height: 12))!))
        buttons[5].hkImage.imageNode.addChild(volIcon)
        overlays.append(volIcon)
        let vols = "\(liveMPCGDGenome.soundtrackMasterVolume) / \(liveMPCGDGenome.sfxVolume)"
        let volText = SKLabelNode(text: vols)
        volText.fontName = "Helvetica Neue Thin"
        volText.fontColor = Colours.getColour(.antiqueWhite)
        volText.fontSize = 12
        buttons[5].hkImage.imageNode.addChild(volText)
        overlays.append(volText)
        volIcon.position = CGPoint(x: -18, y: -34)
        volText.position = CGPoint(x: 12, y: -34)
        volText.verticalAlignmentMode = .center

        let bBins = liveMPCGDGenome.getBinaryBreakdown(liveMPCGDGenome.sfxBooleans)
        let sfxIconsNode = SKNode()
        let iconName = "SFXCollection" + MPCGDSounds.sfxPackNames[liveMPCGDGenome.sfxPack].capitalized
        let iconNode = SKSpriteNode(texture: SKTexture(image: PDFImage(named: iconName, size: CGSize(width: 12, height: 12))!))

        iconNode.colorBlendFactor = 1
        iconNode.color = Colours.getColour(.antiqueWhite)
        iconNode.position.x = 5
        sfxIconsNode.addChild(iconNode)

        var xPos = CGFloat(16)
        var isEmpty = true
        for pos in 0...7{
            if bBins[pos] == true{
                let icon = SKSpriteNode(texture: SKTexture(image: PDFImage(named: sfxIconNames[pos], size: CGSize(width: 12, height: 12))!))
                icon.colorBlendFactor = 1
                icon.color = sfxIconColours[pos]
                //icon.color = Colours.getColour(.antiqueWhite)
                icon.position.x = xPos
                sfxIconsNode.addChild(icon)
                xPos += 11
                isEmpty = false
            }
        }
        if !isEmpty{
            buttons[5].hkImage.imageNode.addChild(sfxIconsNode)
            sfxIconsNode.position.y = -46
            sfxIconsNode.position.x = -(xPos-11)/2
            overlays.append(sfxIconsNode)
        }
        else{
            volIcon.position.y -= 5
            volText.position.y -= 5
        }
    }
    
    func addControllerButton(){
        let gridImageSize = buttonSize * (DeviceType.isIPad ? 1.425 * (3.0 / 4.0) : 1.47)
        let gridImage = gg.getGridIcon(iconSize: gridImageSize, controllerPack: liveMPCGDGenome.controllerPack, shape: liveMPCGDGenome.gridShape, orientation: liveMPCGDGenome.gridOrientation, grain: liveMPCGDGenome.gridGrain, size: liveMPCGDGenome.gridSize, colour: MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade], includeBorder: false)
        
        var backgroundIcon: UIImage! = nil

        backgroundIcon = liveMPCGDGenome.dayNightCycle == 0 ? GeneratorScreen.backgroundIconsIPhone[liveMPCGDGenome.backgroundChoice][liveMPCGDGenome.backgroundShade] : GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][0]

        
        let backingNode = SKSpriteNode(texture: SKTexture(image: backgroundIcon))
        //TODO: custom reshaping to fit the screen
        backingNode.size = backingNode.size * 0.1
        if DeviceType.simulationIs == .iPhone {
            backingNode.height = backingNode.height * 1.33
        }
        
        backingNode.position.x = 23
        overlays.append(backingNode)
        buttons[6].hkImage.imageNode.addChild(backingNode)
        let gridNode = SKSpriteNode(texture: SKTexture(image: gridImage))
        buttons[6].hkImage.imageNode.addChild(gridNode)
        gridNode.position.x = 23
        gridNode.size = gridNode.size * 0.505
        CharacterIconHandler.alterNodeOrientation(isGrid: liveMPCGDGenome.controllerPack == 1, collectionNum: liveMPCGDGenome.gridShape, characterNum: liveMPCGDGenome.gridOrientation, reflectionID: liveMPCGDGenome.gridReflection, node: gridNode)
        
        gridNode.position.x += (CGFloat(liveMPCGDGenome.gridStartX)/60 - 0.5) * backingNode.size.width
        gridNode.position.y += (CGFloat(liveMPCGDGenome.gridStartY)/60 - 0.5) * backingNode.size.height
        
        if liveMPCGDGenome.controllerPack == 2 && liveMPCGDGenome.gridColour < 8{
            gridNode.colorBlendFactor = 0.5
            gridNode.color = MPCGDGenome.getGridShades(liveMPCGDGenome.gridColour)[liveMPCGDGenome.gridShade]
        }
        
        overlays.append(gridNode)
        if liveMPCGDGenome.controllerPack != 0{
            let controlNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: gridControlImageNames[liveMPCGDGenome.gridControl])!))
            buttons[6].hkImage.imageNode.addChild(controlNode)
            controlNode.size = controlNode.size * 0.5
            controlNode.position.x = -26
            controlNode.position.y = liveMPCGDGenome.dayNightCycle == 0 ? 0 : 15
            overlays.append(controlNode)
            
            if liveMPCGDGenome.gridSize <= 5{
                let circleName = liveMPCGDGenome.backgroundShade > 4 && liveMPCGDGenome.dayNightCycle == 0 ? "TinyControllerCircleWhite" : "TinyControllerCircleBlack"
                let tinyCCNode = SKSpriteNode(imageNamed: circleName)
                gridNode.addChild(tinyCCNode)
            }

        }
        else if liveMPCGDGenome.dayNightCycle == 0{
            backingNode.position.x = 0
            
            // CHECK THIS!!!
            
            gridNode.position.x = 0
        }
        
        if liveMPCGDGenome.dayNightCycle > 0{
            
            let iconImage1 = DeviceType.simulationIs == .iPad ? GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][0] : GeneratorScreen.backgroundIconsIPhone[liveMPCGDGenome.backgroundChoice][0]
            let iconImage2 = DeviceType.simulationIs == .iPad ? GeneratorScreen.backgroundIconsIPad[liveMPCGDGenome.backgroundChoice][8] : GeneratorScreen.backgroundIconsIPhone[liveMPCGDGenome.backgroundChoice][8]
            
            let icon1 = SKSpriteNode(texture: SKTexture(image: iconImage1))
            if DeviceType.simulationIs == .iPhone {
                icon1.height = icon1.height * 1.33
            }
            icon1.size = icon1.size * 0.04
            icon1.position = CGPoint(x: -40, y: -25)
            buttons[6].hkImage.imageNode.addChild(icon1)
            overlays.append(icon1)
            

            let icon2 = SKSpriteNode(texture: SKTexture(image: iconImage2))
            if DeviceType.simulationIs == .iPhone {
                icon2.height = icon2.height * 1.33
            }
            icon2.size = icon2.size * 0.04
            icon2.position = CGPoint(x: -10, y: -25)
            buttons[6].hkImage.imageNode.addChild(icon2)
            overlays.append(icon2)
            
            let arrowImageName = liveMPCGDGenome.dayNightCycle == 1 ? "LRArrow" : "LoopingArrow"
            let lrIcon = SKSpriteNode(imageNamed: arrowImageName)
            buttons[6].addChild(lrIcon)
            lrIcon.position = CGPoint(x: -20, y: -20)
            overlays.append(lrIcon)
        }
    }

    func addSpawnButton(){
        let leftSpawnAts = getSpawnAts(liveMPCGDGenome.whiteEdgeSpawnPositions, liveMPCGDGenome.whiteMidSpawnPositions, liveMPCGDGenome.whiteCentralSpawnPositions)
        let rightSpawnAts = getSpawnAts(liveMPCGDGenome.blueEdgeSpawnPositions, liveMPCGDGenome.blueMidSpawnPositions, liveMPCGDGenome.blueCentralSpawnPositions)
        let leftSpawnNode = getSpawnNode(spawnAt: leftSpawnAts, type: "White", includeScores: true)
        let rightSpawnNode = getSpawnNode(spawnAt: rightSpawnAts, type: "Blue", includeScores: true)
        buttons[7].hkImage.imageNode.addChild(leftSpawnNode)
        leftSpawnNode.position = CGPoint(x: -24, y: 10)
        rightSpawnNode.position = CGPoint(x: 26, y: 10)
        buttons[7].hkImage.imageNode.addChild(rightSpawnNode)
        overlays.append(leftSpawnNode)
        overlays.append(rightSpawnNode)
        
        buttons[7].setImageAndText(nilImage, text: "")
        buttons[7].secondTextNode.text = ""
    }
    
    func getSpawnAts(_ n1: Int, _ n2: Int, _ n3: Int) -> [Bool]{
        var spawnAts: [Bool] = []
        for n in [n1, n2, n3]{
            let firstFour = liveMPCGDGenome.getBinaryBreakdown(n)[0...3]
            spawnAts.append(contentsOf: firstFour)
        }
        return spawnAts
    }
    
    func getSpawnNode(spawnAt: [Bool], type: String, includeScores: Bool, includeCharacterIcon: Bool = true) -> SKNode{
        
        let node = SKNode()

        let c = Colours.getColour(.antiqueWhite)
        let w = CGFloat(25)
        let prop = DeviceType.simulationIs == .iPhone ? CGFloat(16)/CGFloat(9) : CGFloat(4)/CGFloat(3)
        let h = w * prop
        
        node.addChild(getVLine(t: 1, h: h, c: c, x: -w/2))
        node.addChild(getVLine(t: 1, h: h, c: c, x: w/2))
        node.addChild(getHLine(t: 1, w: w, c: c, y: h/2))
        node.addChild(getHLine(t: 1, w: w, c: c, y: -h/2))
        
        let bT = CGFloat(6)
        
        // Whole Edge
        if spawnAt[0]{node.addChild(getHLine(t: bT, w: w, c: c, y: h/2 - bT/2))}
        if spawnAt[1]{node.addChild(getHLine(t: bT, w: w, c: c, y: -h/2 + bT/2))}
        if spawnAt[2]{node.addChild(getVLine(t: bT, h: h, c: c, x: -w/2 + bT/2))}
        if spawnAt[3]{node.addChild(getVLine(t: bT, h: h, c: c, x: w/2 - bT/2))}
        
        // Mid
        if spawnAt[4]{node.addChild(getHLine(t: bT, w: w/3, c: c, y: h/2 - bT/2))}
        if spawnAt[5]{node.addChild(getHLine(t: bT, w: w/3, c: c, y: -h/2 + bT/2))}
        if spawnAt[6]{node.addChild(getVLine(t: bT, h: h/3, c: c, x: -w/2 + bT/2))}
        if spawnAt[7]{node.addChild(getVLine(t: bT, h: h/3, c: c, x: w/2 - bT/2))}

        // Central
        if spawnAt[8]{node.addChild(getHLine(t: bT, w: 5, c: c, y: h/2 - bT/2))}
        if spawnAt[9]{node.addChild(getHLine(t: bT, w: 5, c: c, y: -h/2 + bT/2))}
        if spawnAt[10]{node.addChild(getVLine(t: bT, h: 5, c: c, x: -w/2 + bT/2))}
        if spawnAt[11]{node.addChild(getVLine(t: bT, h: 5, c: c, x: w/2 - bT/2))}

        if includeCharacterIcon{
            let ballSize = CGSize(width: 15, height: 15)
            let ball = type == "White" ? getWhiteBall(ballSize) : getBlueBall(ballSize)
            ball.position = CGPoint(x: -10, y: -50)
            node.addChild(ball)
            let t = type == "White" ? liveMPCGDGenome.whiteSpawnRate : liveMPCGDGenome.blueSpawnRate
            let rate = MPCGDGenome.spawnRates[t]
            let l = SKLabelNode(text: "\(rate)")
            l.fontName = "Helvetica Neue Thin"
            l.fontSize = 15
            l.fontColor = Colours.getColour(.antiqueWhite)
            l.horizontalAlignmentMode = .left
            l.position = CGPoint(x: 0, y: -52)
            l.verticalAlignmentMode = .center
            node.addChild(l)
        }
        
        let scoreZones = type == "White" ? liveMPCGDGenome.whiteScoreZones : liveMPCGDGenome.blueScoreZones
        let s = type == "White" ? liveMPCGDGenome.whiteZoneScore : liveMPCGDGenome.blueZoneScore
        var scoreAt: [Bool] = [false, false, false, false, false]
        if includeScores{
            for pos in 0...3{
                if Int(exp2(Double(pos))) & scoreZones != 0{
                    scoreAt[pos] = true
                }
            }
            if (16 & scoreZones != 0){
                scoreAt[4] = true
            }
        }
        
        let fS = CGFloat(14)
        if scoreAt[0]{node.addChild(getHScore(s: s, fS: fS, x: 0, y: h/2 + 1))}
        if scoreAt[1]{node.addChild(getVScore(s: s, fS: fS, x: w/2 + 1, y: 0))}
        if scoreAt[2]{node.addChild(getHScore(s: s, fS: fS, x: 0, y: -h/2 - 1))}
        if scoreAt[3]{node.addChild(getVScore(s: s, fS: fS, x: -w/2 - 1, y: 0))}
        
        if scoreAt[4]{
            if abs(s) < 10{
                node.addChild(getHScore(s: s, fS: fS, x: w/2 + 1, y: h/2 + 1))
                node.addChild(getHScore(s: s, fS: fS, x: w/2 + 1, y: -h/2 - 1))
                node.addChild(getHScore(s: s, fS: fS, x: -w/2 - 3, y: h/2 + 1))
                node.addChild(getHScore(s: s, fS: fS, x: -w/2 - 3, y: -h/2 - 1))
            }
            else{
                node.addChild(getVScore(s: s, fS: fS, x: w/2 + 1, y: h/2 + 1))
                node.addChild(getVScore(s: s, fS: fS, x: w/2 + 1, y: -h/2 - 1))
                node.addChild(getVScore(s: s, fS: fS, x: -w/2 - 1, y: h/2 + 1))
                node.addChild(getVScore(s: s, fS: fS, x: -w/2 - 1, y: -h/2 - 1))
            }
        }
        
        return node
    }
    
    func getHScore(s: Int, fS: CGFloat, x: CGFloat, y: CGFloat) -> SKNode{
        let sc = s == -90 ? MPCGDGenome.deathSymbol : "\(s)"
        let scoreNode = SKLabelNode(text: sc)
        scoreNode.fontName = "Helvetica Neue Thin"
        scoreNode.fontSize = s == -90 ? fS - 4 : fS
        scoreNode.fontColor = Colours.getColour(.antiqueWhite)
        scoreNode.position = CGPoint(x: x, y: y)
        scoreNode.verticalAlignmentMode = y < 0 ? .top : .bottom
        return scoreNode
    }
    
    func getVScore(s: Int, fS: CGFloat, x: CGFloat, y: CGFloat) -> SKNode{
        let testNode = SKLabelNode(text: "\(abs(s))")
        testNode.fontSize = s == -90 ? fS - 4 : fS
        testNode.fontName = "Helvetica Neue Thin"
        let w = testNode.frame.width
        
        let sc = s == -90 ? MPCGDGenome.deathSymbol : "\(s)"
        let scoreNode = SKLabelNode(text: sc)
        scoreNode.fontName = "Helvetica Neue Thin"
        scoreNode.fontSize = s == -90 ? fS - 4 : fS

        scoreNode.fontColor = Colours.getColour(.antiqueWhite)
        scoreNode.position = CGPoint(x: x, y: y)
        scoreNode.horizontalAlignmentMode = x < 0 ? .right : .left
        if abs(s) > 9 && s != -90{
            scoreNode.zRotation = x < 0 ? (CGFloat.pi / 2) : -(CGFloat.pi / 2)
            scoreNode.position.y += w/2
        }
        else{
            scoreNode.position.x += (x < 0) ? 1 : -1
            if s == -90{
                scoreNode.position.x += (x < 0) ? 1 : -1
            }
            scoreNode.verticalAlignmentMode = .center
        }
        return scoreNode
    }
    
    func getVLine(t: CGFloat, h: CGFloat, c: UIColor, x: CGFloat) -> SKSpriteNode{
        let lineNode = SKSpriteNode(color: c, size: CGSize(width: t, height: h))
        lineNode.position.x = x
        return lineNode
    }
    
    func getHLine(t: CGFloat, w: CGFloat, c: UIColor, y: CGFloat) -> SKSpriteNode{
        let lineNode = SKSpriteNode(color: c, size: CGSize(width: w, height: t))
        lineNode.position.y = y
        return lineNode
    }
    
    func addGameEndButton(){
        
        buttons[8].setImageAndText(nilImage, text: "")
        buttons[8].secondTextNode.text = ""
        let winloseFont = UIFontCache(name: "HelveticaNeue-Thin", size: 18)
        var labels: [SKLabelNode] = []

        if liveMPCGDGenome.pointsToWin > 0{
            let winText = "Win: \(liveMPCGDGenome.pointsToWin)pts"
            let winLabel = SKLabelNode(winloseFont, Colours.getColour(.antiqueWhite))
            winLabel.text = winText
            labels.append(winLabel)
        }
        
        if liveMPCGDGenome.gameDuration > 0{
            var wOrL = liveMPCGDGenome.numLives > 0 ? "Win" : "Lose"
            if liveMPCGDGenome.numLives == 0 && liveMPCGDGenome.pointsToWin == 0{
                wOrL = "Ends"
            }
            if liveMPCGDGenome.pointsToWin > 0{
                wOrL = "Ends"
            }
            let durationLabel = SKLabelNode(winloseFont, Colours.getColour(.antiqueWhite))
            durationLabel.text = "\(wOrL): \(liveMPCGDGenome.gameDuration)s"
            labels.append(durationLabel)
        }

        if liveMPCGDGenome.numLives > 0{
            let livesLabel = SKLabelNode(winloseFont, Colours.getColour(.antiqueWhite))
            livesLabel.text = "Lives: \(liveMPCGDGenome.numLives)"
            labels.append(livesLabel)
        }
        
        for l in labels{
            l.verticalAlignmentMode = .center
            buttons[8].hkImage.imageNode.addChild(l)
            overlays.append(l)
        }
        
        if labels.isEmpty{
            var y = CGFloat(10)
            for s in ["Game", "never", "ends"]{
                let label = SKLabelNode(winloseFont, Colours.getColour(.antiqueWhite))
                label.text = s
                label.verticalAlignmentMode = .bottom
                buttons[8].hkImage.imageNode.addChild(label)
                label.position.y = y
                overlays.append(label)
                y -= 20
            }

        }
        else if labels.count == 2{
            labels[0].position.y = 20
            labels[1].position.y = -20
        }
        else if labels.count == 3{
            labels[0].position.y = 30
            labels[1].position.y = 0
            labels[2].position.y = -30
        }
    }

    func alterButtonsForLiveMPCGDGenome(){
        returnLinesToNormal()
        lockButton?.isHidden = false
        helpButton?.isHidden = false
        bestLabel?.isHidden = false
        bigButton.isHidden = true
        tallButton.isHidden = true
        clustersScreen.alpha = 0
        clustersScreen.closeDown()
        ballChoiceScreen.alpha = 0
        ballChoiceScreen.closeDown()
        whiteBehavioursScreen.alpha = 0
        whiteBehavioursScreen.closeDown()
        blueBehavioursScreen.alpha = 0
        blueBehavioursScreen.closeDown()
        gridSizeScreen.closeDown()
        gridSizeScreen.alpha = 0
        gameEndingsScreen.closeDown()
        gameEndingsScreen.alpha = 0
        controllerCollisionsScreen.alpha = 0
        controllerCollisionsScreen.closeDown()
        whiteTapScreen.alpha = 0
        whiteTapScreen.closeDown()
        blueTapScreen.alpha = 0
        blueTapScreen.closeDown()
        audioEqualiserScreen.alpha = 0
        audioEqualiserScreen.closeDown()
        ambianceCategoryHighlighter.isHidden = true
        ambianceChoiceHighlighter.isHidden = true
        volumesScreen.alpha = 0
        volumesScreen.closeDown()
        whiteSpawnScreen.alpha = 0
        whiteSpawnScreen.closeDown()
        blueSpawnScreen.alpha = 0
        blueSpawnScreen.closeDown()
        whiteZoneScreen.alpha = 0
        whiteZoneScreen.closeDown()
        blueZoneScreen.alpha = 0
        blueZoneScreen.closeDown()
        helpScreen.alpha = 0
        tappedButtonNumbers.removeAll()
        showTicks()
        updateBestLabel()
        for pos in 0...3{
            buttons[pos].secondTextNode.text = ""
            buttons[pos].textNode.position.y = 0
        }
        for b in buttons{
            b.alpha = 1
            b.setImageAndText(nilImage, text: "")
            b.textNode.position = CGPoint(x: textXPos, y: 0)
            b.secondTextNode.position = CGPoint(x: textXPos, y: -20)
            b.textNode.horizontalAlignmentMode = .center
            b.secondTextNode.horizontalAlignmentMode = .center
            b.textNode.position.x = textXPos
            b.secondTextNode.position.x = textXPos
            b.hkImage.imageNode.position = CGPoint(x: 0, y: 0)
            b.enabled = true
            b.useTempHighlight = true
        }
        
        removeOverlays()
        
        addCharactersButton()
        addBallTapButton()
        addBehavioursButton()
        addControllerCollisionButton()
        addClustersButton()
        addAudioButton()
        addControllerButton()
        addSpawnButton()
        addGameEndButton()

        changeButtonSet(.top)
        showHelpText("Game design")
        menuPosition = 0
    }
    
    func addClustersButton(){
        let whiteClusterNode = getClusterNode("White", clusterSize: liveMPCGDGenome.whiteCriticalClusterSize, xOffset: 0)
        whiteClusterNode.position.x = -30
        buttons[4].hkImage.imageNode.addChild(whiteClusterNode)
        overlays.append(whiteClusterNode)
        let blueClusterNode = getClusterNode("Blue", clusterSize: liveMPCGDGenome.blueCriticalClusterSize, xOffset: 0)
        overlays.append(blueClusterNode)
        buttons[4].hkImage.imageNode.addChild(blueClusterNode)
        let mixedClusterNode = getClusterNode("Mixed", clusterSize: liveMPCGDGenome.mixedCriticalClusterSize, xOffset: 0)
        mixedClusterNode.position.x = 30
        overlays.append(mixedClusterNode)
        buttons[4].hkImage.imageNode.addChild(mixedClusterNode)
        let y = (liveMPCGDGenome.whiteCriticalClusterSize == 0 && liveMPCGDGenome.blueCriticalClusterSize == 0 && liveMPCGDGenome.mixedCriticalClusterSize == 0) ? 0 : 10
        if y != 0{
            for node in [whiteClusterNode, blueClusterNode, mixedClusterNode]{
                node.setScale(0.8)
                node.position.y = CGFloat(y)
            }
        }
        var x = CGFloat(-26)
        let sizes = [liveMPCGDGenome.whiteCriticalClusterSize, liveMPCGDGenome.blueCriticalClusterSize, liveMPCGDGenome.mixedCriticalClusterSize]
        var pos = 0
        for score in [liveMPCGDGenome.whiteExplodeScore, liveMPCGDGenome.blueExplodeScore, liveMPCGDGenome.mixedExplodeScore]{
            if sizes[pos] > 0{
                let s = score == -90 ? MPCGDGenome.deathSymbol : "\(score)"
                let label = SKLabelNode(text: s)
                buttons[4].addChild(label)
                label.fontName = "Helvetica Neue Thin"
                label.fontSize = 14
                label.fontColor = whiteColour
                label.position.y = -36
                label.position.x = x
                label.verticalAlignmentMode = .center
                overlays.append(label)
            }
            x += 26
            pos += 1
        }
    }
    
    func addControllerCollisionButton(){
        if liveMPCGDGenome.controllerPack != 0 {
            addControllerCollisionIcon("White", buttonNum: 3, xOffset: -15)
            addControllerCollisionIcon("Blue", buttonNum: 3, xOffset: 15)
            var x = -38
            for s in [liveMPCGDGenome.whiteControllerCollisionScore, liveMPCGDGenome.blueControllerCollisionScore]{
                let s2 = (s == -90) ? MPCGDGenome.deathSymbol : "\(s)"
                let label = SKLabelNode(text: s2)
                label.fontName = "Helvetica Neue Thin"
                label.fontSize = 18
                label.fontColor = Colours.getColour(.antiqueWhite)
                label.verticalAlignmentMode = .center
                label.position = CGPoint(x: x, y: 0)
                buttons[3].hkImage.imageNode.addChild(label)
                overlays.append(label)
                x += 76
            }
        }
        else{
            var y = CGFloat(20)
            for s in ["No", "controller", "collisions"]{
                let label = SKLabelNode(text: s)
                label.fontName = "Helvetica Neue Thin"
                label.fontSize = 18
                label.fontColor = Colours.getColour(.antiqueWhite)
                label.verticalAlignmentMode = .center
                buttons[3].hkImage.imageNode.addChild(label)
                overlays.append(label)
                label.position.y = y
                y -= 20
            }
        }
    }
    
    
    func addExplodeScoreTexts(button: GenButton, explodeScore: Int!, collisionScore: Int! = nil, explodeScoreXOffset: CGFloat = 0){

        if explodeScore != nil{
            let es = (explodeScore == 0) ? "" : "\(explodeScore!)"
            let text1 = SKLabelNode(text: es)
            text1.fontName = "Helvetica Neue Thin"
            text1.fontSize = 16
            text1.fontColor = whiteColour
            text1.position = CGPoint(x: -37 + explodeScoreXOffset, y: 0)
            text1.verticalAlignmentMode = .center
            button.hkImage.imageNode.addChild(text1)
            overlays.append(text1)
        }

        if collisionScore != nil{
            let cs = (collisionScore == 0) ? "" : "\(collisionScore!)"
            let text2 = SKLabelNode(text: cs)
            text2.fontName = "Helvetica Neue Thin"
            text2.fontSize = 16
            text2.fontColor = whiteColour
            text2.position = CGPoint(x: 37, y: 0)
            button.hkImage.imageNode.addChild(text2)
            overlays.append(text2)
            text2.verticalAlignmentMode = .center
        }

    }
    
    func getWhiteColour() -> UIColor{
        return CharacterIconHandler.getCharacterColour(collectionNum: liveMPCGDGenome.whiteBallCollection, characterNum: liveMPCGDGenome.whiteBallChoice)
    }
    
    func getBlueColour() -> UIColor{
        return CharacterIconHandler.getCharacterColour(collectionNum: liveMPCGDGenome.blueBallCollection, characterNum: liveMPCGDGenome.blueBallChoice)
    }
    
    func getWhiteName() -> String{
        return CharacterIconHandler.getCharacterName(collectionNum: liveMPCGDGenome.whiteBallCollection, characterNum: liveMPCGDGenome.whiteBallChoice)
    }
    
    func getBlueName() -> String{
        return CharacterIconHandler.getCharacterName(collectionNum: liveMPCGDGenome.blueBallCollection, characterNum: liveMPCGDGenome.blueBallChoice)
    }
    
    func addWhiteBall(_ button: GenButton, size: CGFloat, position: CGPoint){
        let node = getWhiteBall(CGSize(width: size, height: size))
        button.hkImage.imageNode.addChild(node)
        node.position = position
        overlays.append(node)
    }
    
    func addBlueBall(_ button: GenButton, size: CGFloat, position: CGPoint){
        let node = getBlueBall(CGSize(width: size, height: size))
        button.hkImage.imageNode.addChild(node)
        node.position = position
        overlays.append(node)
    }
    
    func getBlueBall(_ size: CGSize) -> SKSpriteNode{
        let imageName = CharacterIconHandler.getCharacterName(collectionNum: liveMPCGDGenome.blueBallCollection, characterNum: liveMPCGDGenome.blueBallChoice)
        let image = PDFImage(named: imageName, size: size)!
        return SKSpriteNode(texture: SKTexture(image: image))
    }
    
    func getWhiteBall(_ size: CGSize) -> SKSpriteNode{
        let imageName = CharacterIconHandler.getCharacterName(collectionNum: liveMPCGDGenome.whiteBallCollection, characterNum: liveMPCGDGenome.whiteBallChoice)
        let image = PDFImage(named: imageName, size: size)!
        return SKSpriteNode(texture: SKTexture(image: image))
    }
    
    func addDynamic(_ imageName: String, wVal: Int, bVal: Int, y: CGFloat){
        let dImage = UIImage(named: imageName)!
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 22)

        let wNode = SKSpriteNode(texture: SKTexture(image: dImage))
        let x = (imageName == "Speed") ? -25 : -37
        wNode.position = CGPoint(x: CGFloat(x), y: y)
        buttons[2].hkImage.imageNode.addChild(wNode)
        let wLabel = SKLabelNode(font, whiteColour)
        wLabel.text = "\(wVal)"
        wLabel.verticalAlignmentMode = .center
        wLabel.horizontalAlignmentMode = .center
        wLabel.position = CGPoint(x: -15, y: y)
        buttons[2].hkImage.imageNode.addChild(wLabel)
        overlays.append(wLabel)
        overlays.append(wNode)
        wLabel.horizontalAlignmentMode = .left
        let ball1Node = getWhiteBall(CGSize(width: 15, height: 15))
        let ballX = (imageName == "Speed") ? -38 : -22
        let ballY = (imageName == "Speed") ? y : y + 10
        ball1Node.position = CGPoint(x: CGFloat(ballX), y: ballY)
        buttons[2].hkImage.imageNode.addChild(ball1Node)
        overlays.append(ball1Node)
        
        let bNode = SKSpriteNode(texture: SKTexture(image: dImage))
        let x2 = (imageName == "Speed") ? 27 : 15
        bNode.position = CGPoint(x: CGFloat(x2), y: y)
        buttons[2].hkImage.imageNode.addChild(bNode)
        let bLabel = SKLabelNode(font, whiteColour)
        bLabel.horizontalAlignmentMode = .center
        bLabel.verticalAlignmentMode = .center
        bLabel.text = "\(bVal)"
        bLabel.position = CGPoint(x: 35, y: y)
        buttons[2].hkImage.imageNode.addChild(bLabel)
        overlays.append(bLabel)
        overlays.append(bNode)
        bLabel.horizontalAlignmentMode = .left

        let ball2Node = getBlueBall(CGSize(width: 15, height: 15))
        let ballX2 = (imageName == "Speed") ? 10 : 28
        ball2Node.position = CGPoint(x: CGFloat(ballX2), y: ballY)
        buttons[2].hkImage.imageNode.addChild(ball2Node)
        overlays.append(ball2Node)
    }
    
    func addXLabel(_ position: CGPoint, genButton: GenButton){
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 22)
        let label1 = SKLabelNode(font, Colours.getColour(.antiqueWhite))
        label1.text = "x"
        label1.position = position
        label1.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        genButton.hkImage.imageNode.addChild(label1)
        overlays.append(label1)
    }

    func changeButtonSet(_ newSetName: ButtonSetEnum){
        for button in buttons{
            button.buttonSet = newSetName
        }
    }
    
    func getClusterNode(_ imageStem: String, clusterSize: Int, xOffset: CGFloat) -> SKNode{
        
        let clusterPositions = getExplodePositions(clusterSize)

        let clusterNode = SKNode()
        
        if clusterSize >= 2{
            let topExplodeNode = SKSpriteNode(imageNamed: "ExplodeGraphic")
            let bottomExplodeNode = SKSpriteNode(imageNamed: "ExplodeGraphic")
            bottomExplodeNode.zRotation = CGFloat.pi
            clusterNode.addChild(topExplodeNode)
            clusterNode.addChild(bottomExplodeNode)
            let explodeY = CGFloat(7) + CGFloat(clusterSize * 5)
            topExplodeNode.position = CGPoint(x: 0, y: explodeY)
            bottomExplodeNode.position = CGPoint(x: 0, y: -explodeY)
            if clusterPositions.count == 2{
                topExplodeNode.position.x = 0 + xOffset
                bottomExplodeNode.position.x = 1 + xOffset
            }
            else if clusterPositions.count > 2 && clusterPositions.count % 2 == 1{
                topExplodeNode.position.x = -5 + xOffset
                bottomExplodeNode.position.x = -6 + xOffset
            }
            else{
                topExplodeNode.position.x = 5 + xOffset
                bottomExplodeNode.position.x = -5 + xOffset
            }
            if clusterPositions.count == 9{
                topExplodeNode.position.y -= 3
                bottomExplodeNode.position.y += 3
            }
        }

        var ppos = 0
        for p in clusterPositions{
            let p2 = CGPoint(x: p.x + xOffset, y: p.y)
            if imageStem == "White" || (imageStem == "Mixed" && ppos % 2 == 0){
                let whiteBall = getWhiteBall(CGSize(width: 15, height: 15))
                whiteBall.position = p2
                clusterNode.addChild(whiteBall)
            }
            else if imageStem == "Blue" || (imageStem == "Mixed" && ppos % 2 == 1) {
                let blueBall = getBlueBall(CGSize(width: 15, height: 15))
                blueBall.position = p2
                clusterNode.addChild(blueBall)
            }
            ppos += 1
        }
        if clusterSize == 0{
            let bounceNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "ClusterBounce")!))
            clusterNode.addChild(bounceNode)
            bounceNode.position.x = xOffset
        }
        return clusterNode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
