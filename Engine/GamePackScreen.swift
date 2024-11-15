//
//  GamePackScreen.swift
//  MPCGD
//
//  Created by Simon Colton on 24/02/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

enum MovingDirection{
    case leftAndRight, upAndDown
}

class GamePackScreen: HKImage{
    
    static var allGamePacks: [GamePackScreen] = []
    
    static var mainScene: MainScene! = nil
    
    var bestLabels: [SKNode] = []
    
    var downloadText: SKMultilineLabel! = nil
    
    var cleanSlateText: SKMultilineLabel! = nil
    
    var inspirationText: SKMultilineLabel! = nil
    
    var bigDeleteButton: HKButton! = nil
    
    var normalDeletePositionX: CGFloat! = nil
    
    var packButtons: [HKButton] = []
    
    var packButtonsNode = SKNode()
    
    var ignoreTouchMove = false
    
    var cancelButton = HKButton(image: UIImage(named: "CancelButton")!)
    
    var orgButtonsSpace = CGFloat(184)
    
    var topLine: SKSpriteNode! = nil
    
    var bottomLine: SKSpriteNode! = nil
    
    var helpTextNode: SKLabelNode! = nil
    
    var unselectedPipNodes: [SKSpriteNode] = []

    var selectedPipNodes: [SKSpriteNode] = []
    
    var nodeShowing: SKNode! = nil

    var gameIDOnShow: String! = nil
    
    var newGameAddedCode: ((String?, MPCGDGenome?) -> ())! = nil

    var inspirationCode: (() -> ())! = nil
    
    var gameLogo: HKComponent! = nil
    
    var packLogo: HKComponent! = nil
    var packButton: HKComponent! = nil
    var id: String! = nil
    var alias: String! = nil

    var logoColour: UIColor! = nil
    
    var MPCGDGenomeShowingInBackground: MPCGDGenome! = nil
    
    var backgroundIsDark = false
    
    var packID: String! = nil
    
    var totalHeight = CGFloat(0)
    
    var onGameTapCode: ((String, GamePackScreen) -> ())! = nil
    
    var gameButtons: [HKButton]
    
    var gameIDs: [String]
    
    var touchDownPoint: CGPoint = CGPoint.zero
    var touchDownTime: Date! = nil
    
    var cropNode: SKCropNode
    
    var topYPos: CGFloat = 0
    
    var bottomYPos: CGFloat = 0
    
    var trayNode = SKNode()
    
    var scrollBarNode: SKSpriteNode! = nil
    
    var minScrollBarY: CGFloat! = nil
    
    var maxScrollBarY: CGFloat! = nil
    
    var scrollBarTravel: CGFloat! = nil
    
    var maxTravelDistance: CGFloat! = nil
    
    var addGameNode: SKNode! = nil

    var gameNodeButtons: [HKButton?] = []
    
    var orgButtons: [HKButton?] = []

    enum State {
        case dragging
        case opening
        case open
        case closing
        case closed
    }
    
    var gameButtonStates: [HKButton: State] = [:]
    var activeOrgGameButton: HKButton! = nil
    var activeGameButton: HKButton! = nil
    var activeDx: CGFloat = 0.0
    var activeDy: CGFloat = 0.0
    var activeDir: MovingDirection? = nil

    func setGameButtonState(_ b: HKButton!, state: State) {
        switch state {
        case .dragging, .opening, .open, .closing:
            gameButtonStates[b] = state
        case .closed:
            gameButtonStates.removeValue(forKey: b)
        }
    }
    
    func getGameButtonState(_ b: HKButton!) -> State {
        guard b != nil else { return .closed }
        if let state = gameButtonStates[b] {
            return state
        }
        return State.closed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, gameButtons: [HKButton], gameIDs: [String], packID: String){
        self.gameButtons = gameButtons
        self.gameIDs = gameIDs
        self.packID = packID
        cropNode = SKCropNode()
        let blank = UIImage(named: "BlankGraphic")!
        super.init(image: blank)
        
        let boxSize = CGSize(width: size.width - 8, height: size.height * 0.805)
        let boxImage = ImageUtils.getBlankImage(boxSize, colour: UIColor.red)
        let maskNode = SKSpriteNode(texture: SKTexture(image: boxImage))
        maskNode.position.y -= 4
        cropNode.maskNode = maskNode
        addChild(cropNode)
    
        cropNode.addChild(trayNode)
        let scrollNodeColour = UIColor.darkGray.withAlphaComponent(0.5)
        let scrollImage = ImageUtils.getBlankImage(CGSize(width: 3, height: size.height/10), colour: scrollNodeColour)
        scrollBarNode = SKSpriteNode(texture: SKTexture(image: scrollImage))
        addChild(scrollBarNode)
        loadButtons(size, gameButtons: gameButtons, gameIDs: gameIDs)
        setupAddGameNode()
        setupPips()
        nodeShowing = trayNode
        let hSize = CGSize(width: size.width - 8, height: 1)
        let gray = Colours.getColour(.antiqueWhite).withAlphaComponent(0.2)
        topLine = SKSpriteNode(color: gray, size: hSize)
        bottomLine = SKSpriteNode(color: gray, size: hSize)
        topLine.position = CGPoint(x: 0, y: 127)
        bottomLine.position = CGPoint(x: 0, y: -135)
        self.addChild(topLine)
        self.addChild(bottomLine)
        
        helpTextNode = SKLabelNode(text: "Choose a game")
        helpTextNode.fontName = "Helvetica Neue Thin"
        helpTextNode.fontColor = Colours.getColour(.antiqueWhite)
        helpTextNode.fontSize = 22
        helpTextNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        helpTextNode.position.y = size.height/2 - 8
        addChild(helpTextNode)
        
        addChild(packButtonsNode)
        packButtonsNode.isHidden = true
        packButtonsNode.addChild(cancelButton)
        cancelButton.position = CGPoint(x: 0, y: -90)
        cancelButton.turnOffUserInteraction()
    }
    
    func fadeOutCenter(_ completion: (()->())!){
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        topLine.run(fadeOut)
        bottomLine.run(fadeOut)
        trayNode.run(fadeOut)
        completion?()
    }
    
    func setupPips(){
        var x = CGFloat(-8)
        let black = Colours.getColour(.antiqueWhite).withAlphaComponent(0.8)
        let grey = Colours.getColour(.antiqueWhite).withAlphaComponent(0.2)
        for _ in 1...2{
            let pip1 = getPipNode(black)
            selectedPipNodes.append(pip1)
            pip1.position = CGPoint(x: x, y: -148)
            addChild(pip1)
            let pip2 = getPipNode(grey)
            unselectedPipNodes.append(pip2)
            pip2.position = CGPoint(x: x, y: -148)
            addChild(pip2)
            x += 17
        }
        selectPip(1)
    }
    
    func selectPip(_ pipNum: Int){
        for p in selectedPipNodes{
            p.alpha = 0
        }
        selectedPipNodes[pipNum].alpha = 1
        for p in unselectedPipNodes{
            p.alpha = 1
        }
        unselectedPipNodes[pipNum].alpha = 0
    }
    
    func getPipNode(_ colour: UIColor) -> SKSpriteNode{
        let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30))
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(colour.cgColor)
        context.fillEllipse(in: CGRect(x: 1, y: 1, width: 25, height: 25))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let pipNode = SKSpriteNode(texture: SKTexture(image: image))
        pipNode.size = CGSize(width: 10, height: 10)
        return pipNode
    }
    
    func changeShowingGameNameColour(_ newButton: HKButton){
        let ind = gameIDs.index(of: gameIDOnShow)!
        let oldButton = gameButtons[ind]
        newButton.turnOffUserInteraction()
        gameButtons[ind] = newButton
        trayNode.addChild(newButton)
        newButton.position.y = oldButton.position.y
        oldButton.removeFromParent()
        for pos in (ind * 3)...((ind * 3) + 2){
            orgButtons[pos]?.removeFromParent()
            newButton.addChild(orgButtons[pos]!)
        }
   //     helpTextNode.fontColor = logoColour
    }
    
    func changeSubcomponentsColour(_ node: SKNode){
        if node is SKLabelNode{
            (node as! SKLabelNode).fontColor = logoColour
        }
        else{
            for child in node.children{
                changeSubcomponentsColour(child)
            }
        }
    }
    
    func setupAddGameNode(){
        addGameNode = SKNode()
        cropNode.addChild(addGameNode)
        addGameNode.isHidden = true
        let labelSize = self.size
        let textColour = Colours.getColour(.antiqueWhite)
        
        let downloadButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: labelSize.width, height: 50))
        do { // DOWNLOAD
            downloadButton.isUserInteractionEnabled = false
            downloadButton.setScaleActionInterval(1.0...1.05)
            downloadButton.position.y = 85
            downloadButton.onTapStartCode = {
                self.downloadUserGame()
            }
            addGameNode.addChild(downloadButton)
            
            let downloadImage = HKButton(image: UIImage(named: "DownloadButton")!)
            downloadImage.x = -88
            downloadImage.isUserInteractionEnabled = false
            downloadButton.addChild(downloadImage)
            
            downloadText = SKMultilineLabel(
                text: "~Download game\nfrom the clipboard",
                size: labelSize,
                pos: CGPoint(x: labelSize.width / 2.0 + 30.0, y: 5.0),
                fontName: "Helvetica Neue Thin",
                altFontName: "Helvetica Neue Bold",
                fontSize: 20.0,
                fontColor: textColour,
                alignment: .left,
                spacing: 2.5
            )
            downloadText.isUserInteractionEnabled = false
            downloadImage.addChild(downloadText)
        }
        
        let cleanSlateButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: labelSize.width, height: 50))
        do { // CLEAN SLATE
            cleanSlateButton.isUserInteractionEnabled = false
            cleanSlateButton.setScaleActionInterval(1.0...1.05)
            cleanSlateButton.position.y = -5
            cleanSlateButton.onTapStartCode = {
                self.fadeOut({
                    self.newGameAddedCode?(nil, nil)
                })
            }
            addGameNode.addChild(cleanSlateButton)
            
            let cleanSlateImage = HKButton(image: UIImage(named: "CleanSlateButton")!)
            cleanSlateImage.x = -88
            cleanSlateImage.isUserInteractionEnabled = false
            cleanSlateButton.addChild(cleanSlateImage)
            
            cleanSlateText = SKMultilineLabel(
                text: "Start from a\n~clean ~slate",
                size: labelSize,
                pos: CGPoint(x: labelSize.width / 2.0 + 30.0, y: 5.0),
                fontName: "Helvetica Neue Thin",
                altFontName: "Helvetica Neue Bold",
                fontSize: 20.0,
                fontColor: textColour,
                alignment: .left,
                spacing: 2.5
            )
            cleanSlateText.isUserInteractionEnabled = false
            cleanSlateImage.addChild(cleanSlateText)
        }
        
        let inspirationButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: labelSize.width, height: 50))
        do { // INSPIRATION
            inspirationButton.isUserInteractionEnabled = false
            inspirationButton.setScaleActionInterval(1.0...1.05)
            inspirationButton.position.y = -95
            inspirationButton.onTapStartCode = {
                self.fadeOut({
                    self.inspirationCode?()
                })
            }
            addGameNode.addChild(inspirationButton)
            
            let inspirationImage = HKButton(image: UIImage(named: "InspirationButton")!)
            inspirationImage.x = -88
            inspirationImage.isUserInteractionEnabled = false
            inspirationButton.addChild(inspirationImage)
            
            inspirationText = SKMultilineLabel(
                text: "Get ~inspiration\nfor your game",
                size: labelSize,
                pos: CGPoint(x: labelSize.width / 2.0 + 30.0, y: 5.0),
                fontName: "Helvetica Neue Thin",
                altFontName: "Helvetica Neue Bold",
                fontSize: 20.0,
                fontColor: textColour,
                alignment: .left,
                spacing: 2.5
            )
            inspirationText.isUserInteractionEnabled = false
            inspirationImage.addChild(inspirationText)
        }
        
        gameNodeButtons = [downloadButton, cleanSlateButton, inspirationButton]
    }
    
    func handlePotentialBestChange(gameID: String){
        let ind = gameIDs.index(of: gameID)!
        let button = gameButtons[ind]
        button.bestLabel?.removeFromParent()
        let wG = GamePackScreen.mainScene.loadedMPCGDGenomes[gameID]!
        if let bestLabel = getBestLabel(wG: wG, gameID: gameID, buttonWidth: button.hkImage.size.width){
            button.bestLabel = bestLabel
            button.addChild(bestLabel)
        }
    }
    
    func handleRenamingOfGame(_ gameID: String, newID: String, button: HKButton){
        let ind = gameIDs.index(of: gameID)!
        button.position = gameButtons[ind].position
        gameButtons[ind].removeFromParent()
        gameButtons[ind] = button
        trayNode.addChild(button)
        button.isUserInteractionEnabled = false
        button.hkImage.isUserInteractionEnabled = false
        for _ in 1...3{
            orgButtons.remove(at: ind * 3)
        }
        addOrgButtons(button, insertOrgButtonsAt: ind * 3)
        gameIDs[ind] = newID
        gameIDOnShow = newID
        let wG = GamePackScreen.mainScene.loadedMPCGDGenomes[newID]!
        if let bestLabel = getBestLabel(wG: wG, gameID: newID, buttonWidth: button.hkImage.size.width){
            button.addChild(bestLabel)
            button.bestLabel = bestLabel
        }

    }
    
    func getOrgButton(_ imageName: String, buttonText: String, tapCode: @escaping ()->()) -> HKButton{
        let buttonSize = CGSize(width: 60, height: GamePackScreen.mainScene.gameNameSize.height)
        var buttonColour = Colours.getColour(.red)
        if buttonText == "Copy"{
            buttonColour = Colours.getColour(.gray)
        }
        else if buttonText == "Move"{
            buttonColour = Colours.getColour(.green)
        }
        let button = HKButton(image: ImageUtils.getBlankImage(buttonSize, colour: buttonColour))
        let sprite = SKSpriteNode(imageNamed: imageName)
        sprite.position.y = 10
        sprite.turnOffUserInteraction()
        button.isHidden = true
        button.addChild(sprite)
        button.isUserInteractionEnabled = false
        button.setScaleActionInterval(1.0...1.1)
        button.onTapStartCode = tapCode
        button.zPosition = 1
        let font = UIFontCache(name: "HelveticaNeue-Thin", size: 16)
        let label = SKLabelNode(font, Colours.getColour(.antiqueWhite), text: buttonText)
        label.position.y = -22
        button.addChild(label)
        label.turnOffUserInteraction()
        return button
    }

    func addOrgButtons(_ comp: HKButton, insertOrgButtonsAt: Int! = nil){
        let moveButton = getOrgButton("MoveGameButton", buttonText: "Move", tapCode: handleMoveTap)
        let copyButton = getOrgButton("AddGameButton", buttonText: "Copy", tapCode: handleCopyTap)
        let deleteButton = getOrgButton("DeleteButton", buttonText: "Delete", tapCode: {})
        deleteButton.onTapStartCode = {self.handleDeleteTap(deleteButton)}

        if insertOrgButtonsAt == nil{
            orgButtons.append(moveButton)
            orgButtons.append(copyButton)
            orgButtons.append(deleteButton)
        }
        else{
            orgButtons.insert(moveButton, at: insertOrgButtonsAt)
            orgButtons.insert(copyButton, at: insertOrgButtonsAt + 1)
            orgButtons.insert(deleteButton, at: insertOrgButtonsAt + 2)
        }
        comp.addChild(copyButton)
        comp.addChild(moveButton)
        comp.addChild(deleteButton)
        moveButton.position.x = size.width/2 + moveButton.hkImage.size.width/2
        copyButton.position.x = moveButton.position.x + copyButton.hkImage.size.width
        deleteButton.position.x = copyButton.position.x + deleteButton.hkImage.size.width
        normalDeletePositionX = deleteButton.position.x
    }
    
    func loadButtons(_ size: CGSize, gameButtons: [HKButton], gameIDs: [String]){
        if !gameButtons.isEmpty{
            orgButtons.removeAll()
            var y = CGFloat(size.height/2) - gameButtons[0].hkImage.height/2 - 35
            topYPos = y
            //bottomYPos = -CGFloat(size.height/2) + gameButtons.last!.hkImage.height/2
            bottomYPos = -135 + gameButtons.last!.hkImage.height/2
            var pos = 0
            for comp in gameButtons{
                comp.turnOffUserInteraction()
                trayNode.addChild(comp)
                comp.position.y = floor(y)
                y -= comp.hkImage.size.height
                comp.isUserInteractionEnabled = false
                comp.hkImage.isUserInteractionEnabled = false
                addOrgButtons(comp)
                let gameID = gameIDs[pos]
                let wG = GamePackScreen.mainScene.loadedMPCGDGenomes[gameID]!
                if let bestLabel = getBestLabel(wG: wG, gameID: gameID, buttonWidth: comp.hkImage.size.width){
                    comp.addChild(bestLabel)
                    comp.bestLabel = bestLabel
                }
                pos += 1
            }
            maxTravelDistance = abs(gameButtons.last!.position.y - bottomYPos)
        }
        else{
            topYPos = size.height/2 - GamePackScreen.mainScene.gameNameSize.height
        }

        self.size = imageNode.size
        cropNode.isUserInteractionEnabled = false
        self.imageNode.isUserInteractionEnabled = false
        self.turnOffUserInteraction()
        self.isUserInteractionEnabled = true
        hideOffscreenGameButtons()
        maxScrollBarY = size.height/2 - 53
        minScrollBarY = -size.height/2 + 47
        scrollBarTravel = maxScrollBarY - minScrollBarY
        scrollBarNode.position = CGPoint(x: size.width/2 - 9, y: maxScrollBarY)
        scrollBarNode.alpha = 0
        addGameNode?.isHidden = true
        trayNode.position.x = 0
        trayNode.position.y = 0
        addGameNode?.position.x = -self.size.width
        nodeShowing = trayNode
        trayNode.isHidden = false
    }
    
    func getBestLabel(wG: MPCGDGenome, gameID: String, buttonWidth: CGFloat) -> SKLabelNode!{
        let pair = wG.getBestText(gameID: gameID)
        if pair.0 != nil && SessionHandler.getSessions(gameID).count > 0{
            let bestLabel = SKLabelNode(text: pair.0)
            if pair.1 == "Completes"{
                bestLabel.text = pair.0! == "1" ? "\(pair.0!) win" : "\(pair.0!) wins"
            }
            bestLabel.fontSize = 13
            bestLabel.fontName = "Helvetica Neue Thin"
            bestLabel.fontColor = GamePackScreen.mainScene.isBackgroundDark(wG) ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
            bestLabel.horizontalAlignmentMode = .right
            bestLabel.position = CGPoint(x: buttonWidth/2 - 5, y: -25)
            bestLabel.zPosition = 1000
            return bestLabel
        }
        return nil
    }
    
    func showGamePacks(_ includeThisPack: Bool){
        let FADE_DURATION = 0.4
        trayNode.run(SKAction.fadeOut(withDuration: FADE_DURATION), completion: {
            self.trayNode.isHidden = true
            self.trayNode.alpha = 1
        })
        let packNames = GameHandler.getPackNames()
        var yPos = CGFloat(95)
        packButtons.removeAll()
        packButtonsNode.removeAllChildren()
        packButtonsNode.addChild(cancelButton)
        for name in packNames{
            let packButton = getPackButton(name)
            packButton.position = CGPoint(x: 0, y: yPos)
            packButtons.append(packButton)
            if includeThisPack || name != packID{
                packButtonsNode.addChild(packButton)
                yPos -= 40
            }
        }
        packButtonsNode.isHidden = false
        packButtonsNode.alpha = 0
        packButtonsNode.run(SKAction.fadeIn(withDuration: FADE_DURATION))
    }
    
    func getPackButton(_ packName: String) -> HKButton{
        let packButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: size.width, height: 50), colour: UIColor.clear))
        let (labels, _) = GamePackScreen.mainScene.getWordLabels(PackAlias.fetch(packName), fontSize: 28)
        for l in labels{
            packButton.addChild(l)
            l.turnOffUserInteraction()
            l.fontColor = backgroundIsDark ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
        }
        packButton.turnOffUserInteraction()
        return packButton
    }
    
    func handlePackButtonTapped(_ button: HKButton){
        let ind = packButtons.index(of: button)!
        if helpTextNode.text?.subString(0, length: 4) == "Copy"{
            copyGameToPack(ind)
        }
        else{
            moveGameToPack(ind)
        }
    }
    
    func copyGameToPack(_ packNum: Int){
        let gameIndex = gameButtons.index(of: activeOrgGameButton)!
        let gameID = gameIDs[gameIndex]
        
        let (MPCGDGenome, isLocked) = GameHandler.retrieveGame(gameID, packID: packID)
        let newPackName = GameHandler.getPackNames()[packNum]
        let gameName = gameID.components(separatedBy: "@")[0]
        let newGameID = "\(gameName)@\(Date().timeIntervalSince1970)"
        _ = GameHandler.saveGame(MPCGDGenome!, gameID: newGameID, packID: newPackName, isLocked: isLocked)
        GamePackScreen.mainScene.loadedMPCGDGenomes[newGameID] = MPCGDGenome
        GamePackScreen.mainScene.isLockedHash[newGameID] = isLocked
        GamePackScreen.allGamePacks[packNum].addGameButton(newGameID)
    }
    
    func moveGameToPack(_ packNum: Int){
        let gameIndex = gameButtons.index(of: activeOrgGameButton)!
        let gameID = gameIDs[gameIndex]

        // Added by Simon to stop a crash
        activeGameButton = activeOrgGameButton
        
        let (MPCGDGenome, isLocked) = GameHandler.retrieveGame(gameID, packID: packID)
        let newPackName = GameHandler.getPackNames()[packNum]
        let gameName = gameID.components(separatedBy: "@")[0]
        let newGameID = "\(gameName)@\(Date().timeIntervalSince1970)"
        let gameButtonToMove = activeGameButton
        SessionHandler.renameGame(oldGameID: gameID, newGameID: newGameID)
        deleteGame()
        gameButtonToMove?.removeFromParent()
        _ = GameHandler.saveGame(MPCGDGenome!, gameID: newGameID, packID: newPackName, isLocked: isLocked)
        GamePackScreen.mainScene.loadedMPCGDGenomes[newGameID] = MPCGDGenome
        GamePackScreen.mainScene.isLockedHash[newGameID] = isLocked
        GamePackScreen.allGamePacks[packNum].addGameButton(newGameID)
    }
    
    func addGameButton(_ gameID: String){
        _ = GamePackScreen.mainScene.getGamePackComponent(gameID, packID: packID, completion: { (gameButton: HKButton) in
            gameButton.turnOffUserInteraction()
            self.addOrgButtons(gameButton)
            gameButton.isUserInteractionEnabled = false
            gameButton.hkImage.isUserInteractionEnabled = false
            self.gameButtons.append(gameButton)
            self.gameIDs.append(gameID)
            self.trayNode.addChild(gameButton)
            gameButton.isHidden = false
            gameButton.alpha = 1
            let firstPos = CGFloat(self.size.height/2) - gameButton.hkImage.height/2 - 35
            let yPos = firstPos - (CGFloat(self.gameIDs.count - 1) * gameButton.hkImage.size.height)
            gameButton.position = CGPoint(x: 0, y: yPos)
            self.bottomYPos = -135 + self.gameButtons.last!.hkImage.height/2
            self.maxTravelDistance = abs(self.gameButtons.last!.position.y - self.bottomYPos)
            
            let wG = GamePackScreen.mainScene.loadedMPCGDGenomes[gameID]!
            if let bestLabel = self.getBestLabel(wG: wG, gameID: gameID, buttonWidth: gameButton.hkImage.size.width){
                gameButton.bestLabel = bestLabel
                gameButton.addChild(bestLabel)
            }
            
            if self.gameButtons.count > 4{
                self.trayNode.position.y = self.self.bottomYPos - self.gameButtons.last!.position.y
            }
            self.scrollBarNode.alpha = 1
            self.hideOffscreenGameButtons()
            self.updateScrollBarNode()
        })
    }
    
    func handleCopyTap(){
        let gameIndex = gameButtons.index(of: activeOrgGameButton)!
        let gameID = gameIDs[gameIndex]
        let gameName = gameID.components(separatedBy: "@")[0]
        changeHelpText("Copy \(gameName)")
        showGamePacks(true)
        HKDisableUserInteractions = false
    }
    
    func handleMoveTap(){
        let gameIndex = gameButtons.index(of: activeOrgGameButton)!
        let gameID = gameIDs[gameIndex]
        let gameName = gameID.components(separatedBy: "@")[0]
        changeHelpText("Move \(gameName)")
        showGamePacks(false)
        HKDisableUserInteractions = false
    }
    
    func handleDeleteTap(_ deleteButton: HKButton){
        for b in orgButtons{
            if b != deleteButton{
                b?.alpha = 0.99
            }
        }
        let moveLeft = SKAction.move(by: CGVector(dx: -60, dy: 0), duration: 0.2)
        let scaleHorizontally = SKAction.scaleX(to: 3, duration: 0.2)
        deleteButton.hkImage.run(scaleHorizontally, completion: {
            deleteButton.hkImage.xScale = 1
            deleteButton.hkImage.size = CGSize(width: deleteButton.hkImage.size.width * 3, height: deleteButton.hkImage.size.height)
            for b in self.orgButtons{
                if b != deleteButton{
                    b?.isHidden = true
                    b?.alpha = 1
                }
            }
        })
        uiRunActionOn(deleteButton, moveLeft)
        bigDeleteButton = deleteButton
        activeGameButton = nil
    }
    
    func resetTrayState() {
        activeGameButton = nil
        for (b, _) in gameButtonStates {
            b.removeAllActions()
            b.position.x = 0.0
        }
        gameButtonStates.removeAll()
        self.bigDeleteButton = nil
        self.scrollBarNode.alpha = 0
        self.addGameNode?.isHidden = true
        self.trayNode.position.x = 0
        self.trayNode.isHidden = false
    }

    func deleteGame(){
        let FADE_DURATION = 0.2
        
        let gameIndex = gameButtons.index(of: activeGameButton)!
        let gameID = gameIDs[gameIndex]
        
        activeGameButton.zPosition -= 10.0
        closeButton(activeGameButton)
        if bigDeleteButton != nil {
            bigDeleteButton.removeAllActions()
            bigDeleteButton.setScale(1.0)
            bigDeleteButton.zPosition -= 10.0
        }

        GamePackScreen.mainScene.loadedMPCGDGenomes.removeValue(forKey: gameID)
        GamePackScreen.mainScene.isLockedHash.removeValue(forKey: gameID)
        
        GameHandler.deleteGame(gameID)
        SessionHandler.clearSessions(gameID: gameID)
        gameIDs.remove(at: gameIndex)
        gameButtons.remove(at: gameIndex)

        if gameButtons.isEmpty{
            self.bottomYPos = -135
            self.maxTravelDistance = 0
        }
        else{
            self.bottomYPos = -135 + self.gameButtons.last!.hkImage.height/2
            self.maxTravelDistance = abs(self.gameButtons.last!.position.y - self.bottomYPos)
        }
        
        for _ in 1...3{
            orgButtons.remove(at: gameIndex * 3)
        }
        if !gameButtons.isEmpty{
            let moveUpBy = gameButtons[0].hkImage.size.height
            for pos in gameIndex..<gameButtons.count{
                let b = gameButtons[pos]
                b.isHidden = false
                b.run(HKEasing.moveYTo(b.position.y + moveUpBy, duration: FADE_DURATION, easingFunction: CubicEaseOut), completion: {
                    self.hideOffscreenGameButtons()
                })
            }
            let lastMoveUpBy = (gameIndex == gameButtons.count) ? 0 : moveUpBy
            if self.gameButtons.count > 4 && gameButtons.last!.position.y + lastMoveUpBy + trayNode.y > bottomYPos{
                let yDist = gameButtons.last!.position.y + lastMoveUpBy + trayNode.y - bottomYPos
                let v = CGVector(dx: 0, dy: -yDist)
                for b in gameButtons{
                    b.isHidden = false
                }
                trayNode.run(SKAction.move(by: v, duration: FADE_DURATION), completion: {
                    self.hideOffscreenGameButtons()
                    HKDisableUserInteractions = false
                })
            }
            else if self.gameButtons.count == 4{
                let yDist = trayNode.position.y
                if yDist > 0{
                    for b in gameButtons{
                        b.isHidden = false
                    }
                    let v = CGVector(dx: 0, dy: -yDist)
                    trayNode.run(SKAction.move(by: v, duration: FADE_DURATION), completion: {
                        self.hideOffscreenGameButtons()
                        HKDisableUserInteractions = false
                    })
                }
            }
        }
        let b = activeGameButton
        setGameButtonState(b, state: .closed)
        b?.run(SKAction.fadeOut(withDuration: FADE_DURATION), completion: {
            b?.removeFromParent()
            self.resetTrayState()
        })
        activeGameButton = nil
    }

    func hideOffscreenGameButtons(){
        for b in gameButtons{
            b.isHidden = true
            let bPos = b.position.y + trayNode.y
            if bPos < size.height/2 && bPos > -size.height/2{
                b.isHidden = false
                if b.isHot {
                    b.isHot = false
                    b.setScale(1.0)
                    b.zPosition = 1.0
                }
            }
        }
    }
    
    func updateScrollBarNode(){
        let prop = 1 + (gameButtons.last!.position.y + trayNode.y - bottomYPos)/maxTravelDistance
        scrollBarNode.position.y = round(maxScrollBarY - (prop * scrollBarTravel))
    }

    fileprivate func buttonHit(_ b: HKButton, _ at: CGPoint) -> Bool {
        let atSelf = CGPoint(x: at.x - self.position.x, y: at.y - self.position.y)
        let p = b.convert(atSelf, from: self)
        return !b.isHidden && b.alpha == 1.0 && b.contains(p)
    }
    
    fileprivate static let hotButtonScaleAction = SKAction.sequence([
        HKEasing.scaleTo(1.1, duration: 0.1, easingFunction: CubicEaseOut),
        HKEasing.scaleTo(1, duration: 0.1, easingFunction: CubicEaseOut)])

    fileprivate static let hotBigDeleteButtonScaleAction = SKAction.sequence([
        HKEasing.scaleTo(1.05, duration: 0.1, easingFunction: BackEaseOut),
        HKEasing.scaleTo(1, duration: 0.1, easingFunction: BackEaseOut)])

    fileprivate func buttonHot(_ b: HKButton, _ at: CGPoint, scaleAction: SKAction! = GamePackScreen.hotButtonScaleAction) -> Bool {
        guard at.y <= topLine.y && at.y >= bottomLine.y else { return false }
        if buttonHit(b, at) {
            if !b.isHot {
                b.isHot = true
                b.zPosition += 10
                b.run(scaleAction == nil ? b.scaleAction : scaleAction, completion: {
                    b.isHot = false
                    b.zPosition = 1
                })
            }
            return true
        }
        return false
    }


    // Gamebutton transition rates I plucked from the ether. Increase to make snappier.
    let unitsPerSecond: CGFloat = 184.0 * 1.75
    let scrollUnitsPerSecond: CGFloat = 184.0 * 2.0
    let swipeUnitsPerSecond: CGFloat = 184.0 * 5
    
    // TODO: See why HKEasing.moveXTo explodes with a duration of 0
    fileprivate func openButton(_ b: HKButton) {
        let state = getGameButtonState(b)
        if state != .open && state != .opening {
            setGameButtonState(b, state: .opening)
            b.removeAllActions()
            let dx = abs(b.position.x + orgButtonsSpace)
            let d = max(1.0/60.0, TimeInterval(dx / unitsPerSecond))
            b.run(HKEasing.moveXTo(-orgButtonsSpace, duration: d, easingFunction: BackEaseOut), completion: {
                b.position.x = -self.orgButtonsSpace
                self.setGameButtonState(b, state: .open)
            })
        }
    }

    fileprivate func closeButton(_ b: HKButton) {
        let state = getGameButtonState(b)
        if state != .closed && state != .closing {
            setGameButtonState(b, state: .closing)
            b.removeAllActions()
            let dx = abs(b.position.x)
            let d = max(1.0/60.0, TimeInterval(dx / unitsPerSecond))
            b.run(HKEasing.moveXTo(0, duration: d, easingFunction: BackEaseOut), completion: {
                b.position.x = 0
                self.setGameButtonState(b, state: .closed)
            })
        }
    }
    
    fileprivate func updateGameButtons() {
        for (b, state) in gameButtonStates {
            if state == .closed {
                continue
            }
            if b.position.x < -50 && b === activeGameButton && state != .closing {
                openButton(b)
            } else {
                closeButton(b)
            }
        }
        for i in 0..<gameButtons.count {
            let hidden = gameButtons[i].position.x >= -0.001
            if (orgButtons[i*3+0]?.isHidden)! && !(orgButtons[i*3+2]?.isHidden)! {
                // Big Delete is showing
                orgButtons[i*3+0]?.isHidden = true
                orgButtons[i*3+1]?.isHidden = true
                orgButtons[i*3+2]?.isHidden = hidden
                if hidden {
                    let bb = orgButtons[i*3+2]
                    bb?.hkImage.size = CGSize(width: (bb?.hkImage.size.width)!/3, height: (bb?.hkImage.size.height)!)
                    bb?.position.x = normalDeletePositionX
                }
            } else {
                orgButtons[i*3+0]?.isHidden = hidden
                orgButtons[i*3+1]?.isHidden = hidden
                orgButtons[i*3+2]?.isHidden = hidden
            }
        }
    }

    var updateGameButtonActionComplete: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard HKDisableUserInteractions == false && HKButton.lock === nil else { return }
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        guard touch.tapCount <= 1 else { return }
        
        touchDownPoint = touch.location(in: self)
        touchDownTime = Date()
        
        hideOffscreenGameButtons()

        var button: HKButton! = nil
        
        if nodeShowing === trayNode {
            if packButtonsNode.isHidden == false {
                // Game move/copy
                if !buttonHot(cancelButton, touchDownPoint) {
                    for b in packButtons{
                        if buttonHot(b, touchDownPoint){
                            break
                        }
                    }
                }
            }
            else if trayNode.isHidden == false {
                // Game Selection
                for i in 0..<gameButtons.count {
                    let b = gameButtons[i]
                    if buttonHot(b, touchDownPoint) {
                        button = b
                        break
                    }
                    let bstate = getGameButtonState(b)
                    if bstate == .open {
                        if (orgButtons[i*3+0]?.isHidden)! && !(orgButtons[i*3+2]?.isHidden)! {
                            // Big delete visible
                            if buttonHot(bigDeleteButton, touchDownPoint) {
                                // Prevent game button from closing
                                activeGameButton = b
                                button = b
                                break
                            }
                        } else {
                            // Org buttons
                            if buttonHot(orgButtons[i*3+0]!, touchDownPoint) {
                                activeGameButton = b
                                button = b
                                break
                            }
                            if buttonHot(orgButtons[i*3+1]!, touchDownPoint) {
                                activeGameButton = b
                                button = b
                                break
                            }
                            if buttonHot(orgButtons[i*3+2]!, touchDownPoint) {
                                activeGameButton = b
                                button = b
                                break
                            }
                        }
                    }
                }
            }
            if activeGameButton !== button {
                activeGameButton = nil
                updateGameButtonActionComplete = false
                run(SKAction.sequence([SKAction.wait(forDuration: 0.15), SKAction.run({
                    self.updateGameButtons()
                    self.removeAction(forKey: "updateGameButtons")
                    self.updateGameButtonActionComplete = true
                    })]), withKey: "updateGameButtons")
//                updateGameButtons()
            }
            if button != nil {
                activeGameButton = button
            }
            if activeDir == .upAndDown {
                self.trayNode.removeAllActions()
            }
            
        } else {
            // Clipboard, CleanSlate, etc
            activeGameButton = nil
            for b in gameNodeButtons {
                if buttonHot(b!, touchDownPoint) {
                    button = b
                    break
                }
            }
        }
        
        activeDir = nil
        activeDx = 0.0
        activeDy = 0.0
    }

    var touchStart: TimeInterval = 0.0
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !updateGameButtonActionComplete {
            self.removeAction(forKey: "updateGameButtons")
            updateGameButtonActionComplete = true
            updateGameButtons()
        }
        
        guard HKDisableUserInteractions == false && HKButton.lock === nil else { return }
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        guard touch.tapCount <= 1 else { return }

        let touchLocation = touch.location(in: self)
        let previousTouchLocation = touch.previousLocation(in: self)
        var dx = touchLocation.x - previousTouchLocation.x
        var dy = touchLocation.y - previousTouchLocation.y
        
        // Add small dead-zone before we can scroll/slide
        if activeDir == nil {
            let deadzone: CGFloat = 3.0
            if abs(touchLocation.x - touchDownPoint.x) <= deadzone {
                dx = 0.0
            }
            if abs(touchLocation.y - touchDownPoint.y) <= deadzone {
                dy = 0.0
            }
        }
        
        dx = min(20, max(-20, dx))
        dy = min(30, max(-30, dy))

        activeDx = dx
        activeDy = dy

        if activeDir == nil {
            if abs(dx) > abs(dy) {
                activeDir = .leftAndRight
                trayNode.removeAllActions()
                trayNode.position.x = 0
            } else if abs(dy) > abs(dx) && gameButtons.count > 4 {
                activeDir = .upAndDown
                trayNode.removeAllActions()
                if activeGameButton != nil && getGameButtonState(activeGameButton) != .closed {
                    closeButton(activeGameButton)
                }
            } else {
                return
            }
        }

        if nodeShowing !== trayNode {
            if dx < 0.0 {
                nodeShowing.x += dx
            } else {
                let tx = 1.0 - (nodeShowing.position.x / 200.0)
                nodeShowing.position.x = min(180, nodeShowing.position.x + dx * tx * tx)
            }
            return
        }
        
        if trayNode.isHidden {
            return
        }
        
        if activeDir == .upAndDown {
            // Scroll
            if dy > 0{
                dy = min(dy, abs(bottomYPos - (gameButtons.last!.position.y + trayNode.y)))
            }
            else{
                dy = -min(-dy, abs(topYPos - (gameButtons[0].position.y + trayNode.y)))
            }
            if abs(activeDy) > 0.0 {
                if gameButtons[0].position.y + trayNode.y + dy >= topYPos && gameButtons.last!.position.y + dy + trayNode.y <= bottomYPos{
                    trayNode.y += dy
                }
                hideOffscreenGameButtons()
                scrollBarNode.alpha = 1
                updateScrollBarNode()
            }
            activeDy = dy
        }
        else if activeDir == .leftAndRight && activeGameButton != nil {
            // Drag
            let b = activeGameButton
            let bstate = getGameButtonState(b)
            
            if bstate != .dragging {
                setGameButtonState(b, state: .dragging)
                b?.removeAllActions()

                if (b?.isHot)! {
                    b?.isHot = false
                    b?.setScale(1.0)
                    b?.zPosition = 1.0
                }
            }

            if dx < 0.0 {
                let tx = min((b?.position.x)! + 220, 40) / 40.0
                b?.position.x = max(-220, (b?.position.x)! + dx * tx * tx)
                if trayNode.position.x > 0 {
                    trayNode.position.x = max(0, trayNode.position.x + dx * tx * tx)
                    b?.position.x = 0
                }
            }
            else {
                b?.position.x = min(0, (b?.position.x)! + dx)
                if (b?.position.x)! + dx > 0 {
                    let tx = 1.0 - (trayNode.position.x / 200.0)
                    trayNode.position.x = min(180, trayNode.position.x + dx * tx * tx)
                }
            }

            if scrollBarNode.alpha > 0 {
                scrollBarNode.run(SKAction.fadeOut(withDuration: 0.2))
            }

            for i in 0..<gameButtons.count {
                let hidden = gameButtons[i].position.x >= -0.001
                if (orgButtons[i*3+0]?.isHidden)! && !(orgButtons[i*3+2]?.isHidden)! {
                    // Big Delete is showing
                    orgButtons[i*3+0]?.isHidden = true
                    orgButtons[i*3+1]?.isHidden = true
                    orgButtons[i*3+2]?.isHidden = hidden
                    if hidden {
                        let bb = orgButtons[i*3+2]
                        bb?.hkImage.size = CGSize(width: (bb?.hkImage.size.width)!/3, height: (bb?.hkImage.size.height)!)
                        bb?.position.x = normalDeletePositionX
                    }
                } else {
                    orgButtons[i*3+0]?.isHidden = hidden
                    orgButtons[i*3+1]?.isHidden = hidden
                    orgButtons[i*3+2]?.isHidden = hidden
                }
            }
        }
        else if activeDir == .leftAndRight && activeGameButton == nil {
            // Just drag tray
            if dx < 0.0 {
                if trayNode.position.x < 0.0 {
                    let tx = 1.0 - min(abs(trayNode.position.x), 40) / 40.0
                    trayNode.position.x = max(-40, trayNode.position.x + dx * tx * tx)
                } else {
                    trayNode.position.x += dx
                }
            }
            else {
                if trayNode.position.x > 0.0 {
                    let tx = 1.0 - (abs(trayNode.position.x) / 200.0)
                    trayNode.position.x = min(180, trayNode.position.x + dx * tx * tx)
                } else {
                    trayNode.position.x += dx
                }
            }

        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard HKDisableUserInteractions == false && HKButton.lock === nil else { return }
        guard touches.count == 1 else { return }
        guard let touch = touches.first else { return }
        guard touch.tapCount <= 1 else { return }
        
        let touchLocation = touch.location(in: self)
        let dx = touchLocation.x - touchDownPoint.x
        let dy = touchLocation.y - touchDownPoint.y
        
        var resetActiveGameButton = true
        var shouldUpdateGameButtons = true
        
        if (dx*dx + dy*dy) <= 4*4 {
            // We tapped
            if nodeShowing === trayNode {
                if packButtonsNode.isHidden == false {
                    // Game move/copy
                    if cancelButton.isHot && buttonHit(cancelButton, touchLocation){
                        hidePackButtons()
                        resetTrayState()
                        activeOrgGameButton = nil
                    } else{
                        for b in packButtons{
                            if b.isHot && buttonHit(b, touchLocation){
                                hidePackButtons()
                                handlePackButtonTapped(b)
                                resetTrayState()
                                activeOrgGameButton = nil
                            }
                        }
                    }
                }
                else if trayNode.isHidden == false {
                    // Game Selection
                    for (i, b) in gameButtons.enumerated() {
                        let bstate = getGameButtonState(b)
                        if bstate == .closed && b.isHot && buttonHit(b, touchLocation) {
                            removeAction(forKey: "updateGameButtons")
                            shouldUpdateGameButtons = false
                            HKDisableUserInteractions = true
                            gameIDOnShow = gameIDs[i]
                            onGameTapCode?(gameIDs[i], self)
                            break
                        }
                        if bstate == .open {
                            if buttonHit(b, touchLocation) {
                                activeGameButton = b
                                resetActiveGameButton = false
                                break
                            }
                            if (orgButtons[i*3+0]?.isHidden)! && !(orgButtons[i*3+2]?.isHidden)! {
                                // Big delete visible
                                if bigDeleteButton.isHot && buttonHit(bigDeleteButton, touchLocation) {
                                    deleteGame()
                                    break
                                }
                            } else {
                                // Org buttons
                                for j in 0..<3 {
                                    let o = orgButtons[i*3+j]
                                    if (o?.isHot)! && buttonHit(o!, touchLocation) {
                                        HKDisableUserInteractions = true
                                        activeOrgGameButton = b
                                        o?.onTapStartCode?()
                                        if j == 2 {
                                            activeGameButton = b
                                            resetActiveGameButton = false
                                        }
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Game add buttons
                for b in gameNodeButtons {
                    if (b?.isHot)! && buttonHit(b!, touchLocation) {
                        HKDisableUserInteractions = true
                        b?.onTapStartCode?()
                        break
                    }
                }
            }
            scrollBarNode.run(SKAction.fadeOut(withDuration: 0.2))
        }

        startXMoveBack(nodeShowing)

        var swipedLeftOrRight = false
        if activeDir == .leftAndRight {
            if activeDx > 0.0 && nodeShowing.x > 30 {
                swipedLeftOrRight = true
                handleSwipeRight()
            } else if activeDx < 0.0 && nodeShowing.x < -30 {
                swipedLeftOrRight = true
                handleSwipeLeft()
            }
        } else if activeDir == .upAndDown {
            var scrollBy = activeDy * 20
            if activeDy > 0{
                scrollBy = min(scrollBy, abs(bottomYPos - (gameButtons.last!.position.y + trayNode.y)))
            }
            else{
                scrollBy = -min(-scrollBy, abs(topYPos - (gameButtons[0].position.y + trayNode.y)))
            }
            
            let d = max(1.0/60.0, TimeInterval(abs(scrollBy) / scrollUnitsPerSecond))
            gameButtons.forEach{ $0.isHidden = false }
            self.scrollBarNode.run(SKAction.fadeIn(withDuration: 0.2))
            trayNode.run(HKEasing.moveYBy(scrollBy, duration: d, easingFunction: CubicEaseOut), completion: {
                self.scrollBarNode.run(SKAction.fadeOut(withDuration: 0.2))
            })
            startButtonHiding()
        }

        if resetActiveGameButton && activeGameButton != nil && (activeDir == .upAndDown || swipedLeftOrRight || activeDx >= 5.0) {
            closeButton(activeGameButton)
        }
        if shouldUpdateGameButtons {
            updateGameButtons()
        }
        if resetActiveGameButton {
            activeGameButton = nil
        }
        touchDownTime = nil
    }

    func uiRunActionOn(_ n: SKNode!, _ action: SKAction!, _ completion: (() -> ())? = nil) {
        HKDisableUserInteractions = true
        n.run(action, completion: {
            completion?()
            HKDisableUserInteractions = false
        })
    }

    func showTrayNode(){
        trayNode.isHidden = false
        trayNode.position.x = 0
        self.addGameNode.isHidden = true
        self.selectPip(1)
        self.nodeShowing = self.trayNode
    }
    
    func handleSwipeRight(){
        let d = max(1.0/120.0, TimeInterval(size.width / swipeUnitsPerSecond))
        let flyOutToRight = HKEasing.moveXTo(size.width, duration: d, easingFunction: BackEaseOut)
        let flyInFromLeft = HKEasing.moveXTo(0, duration: d, easingFunction: BackEaseOut)
        nodeShowing.removeAllActions()
        if nodeShowing == trayNode {
            changeHelpText("Add a new game")
            uiRunActionOn(trayNode, flyOutToRight, {
                self.addGameNode.isHidden = false
                self.addGameNode.alpha = 1.0
                self.addGameNode.position.x = -self.size.width
                self.addGameNode.run(flyInFromLeft, completion: { self.addGameNode.position.x = 0 })
                self.nodeShowing = self.addGameNode
                self.selectPip(0)
                self.trayNode.isHidden = true
                self.updateGameButtons()
            })
        }
        else if nodeShowing == addGameNode{
            startXMoveBack(addGameNode)
        }
        scrollBarNode.run(SKAction.fadeOut(withDuration: 0.2))
    }
    
    func changeHelpText(_ toString: String){
        helpTextNode.run(SKAction.fadeOut(withDuration: 0.2), completion: {
            self.helpTextNode.text = toString
            self.helpTextNode.run(SKAction.fadeIn(withDuration: 0.2))
        })
    }
    
    func handleSwipeLeft(){
        let d = max(1.0/120.0, TimeInterval(size.width / swipeUnitsPerSecond))
        let flyOutToLeft = HKEasing.moveXTo(-size.width, duration: d, easingFunction: BackEaseOut)
        let flyInFromRight = HKEasing.moveXTo(0, duration: d, easingFunction: BackEaseOut)
        nodeShowing.removeAllActions()
        if nodeShowing == addGameNode{
            changeHelpText("Choose a game")
            for b in orgButtons{
                b?.isHidden = true
            }
            uiRunActionOn(addGameNode, flyOutToLeft, {
                self.trayNode.isHidden = false
                self.trayNode.position.x = self.size.width
                self.trayNode.run(flyInFromRight, completion: { self.trayNode.position.x = 0 })
                self.addGameNode.isHidden = true
                self.selectPip(1)
                self.nodeShowing = self.trayNode
                self.updateGameButtons()
            })
        }
        else if nodeShowing == trayNode{
            startXMoveBack(nodeShowing)
        }
        scrollBarNode.run(SKAction.fadeOut(withDuration: 0.2))
    }
    
    func startXMoveBack(_ node: SKNode){
        let d = max(1.0/120.0, TimeInterval(abs(node.position.x) / unitsPerSecond))
        let moveBackAction = HKEasing.moveXTo(0, duration: d, easingFunction: BackEaseOut)
        node.run(moveBackAction, completion: { node.position.x = 0 })
    }
    
    func startButtonHiding(){
        trayNode.run(SKAction.wait(forDuration: 1/100), completion: {
            self.hideOffscreenGameButtons()
            self.startButtonHiding()
            self.updateScrollBarNode()
        })
    }
    
    func hidePackButtons(){
        let FADE_DURATION = 0.4

        packButtonsNode.run(SKAction.fadeOut(withDuration: FADE_DURATION), completion: {
            self.packButtonsNode.alpha = 1
            self.packButtonsNode.isHidden = true
        })
        trayNode.isHidden = false
        trayNode.alpha = 0
        uiRunActionOn(trayNode, SKAction.fadeIn(withDuration: FADE_DURATION))
        changeHelpText("Choose a game")
    }
    
    let fadeDuration = 0.1

    func fadeIn(_ callback: (() -> ())? = nil) {
        let n = trayNode.isHidden ? addGameNode : trayNode
        resetTrayState()
        trayNode.alpha = 1.0
        addGameNode.alpha = 1.0
        n?.alpha = 0
        HKDisableUserInteractions = true
        n?.run(SKAction.fadeIn(withDuration: fadeDuration), completion: {
            callback?()
            HKDisableUserInteractions = false
        })
    }
    
    func fadeOut(_ callback: (() -> ())? = nil) {
        let n = trayNode.isHidden ? addGameNode : trayNode
        HKDisableUserInteractions = true
        n?.run(SKAction.fadeOut(withDuration: fadeDuration), completion: {
            callback?()
            HKDisableUserInteractions = false
        })
    }
    
    func downloadUserGame() {
        let pasteBoard = UIPasteboard.general
        guard pasteBoard.string != nil else {
            MainScene.instance.showAlertNode(text: "Clipboard empty")
            return
        }
        let game = MainScene.instance.decodeShareableGame(pasteBoard.string!)
        guard game.0 != nil && game.1 != nil else {
            MainScene.instance.showAlertNode(text: "Invalid game")
            HKDisableUserInteractions = false
            return
        }
        self.fadeOut({
            self.newGameAddedCode?(game.0, game.1)
        })
    }
}
