
//
//  MainScene.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//
// Another dummy commit

import Foundation
import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FontCache {
    struct Entry {
        var size: CGFloat
        var name: String
        var font: UIFont!
        
        init(_ n: String, _ s: CGFloat, _ f: UIFont!) {
            size = s
            name = n
            font = f
        }
    }
    static var entries: [Entry] = []
    
    static func findOrAdd(_ name: String, _ size: CGFloat) -> UIFont! {
        for e in entries {
            if e.size == size && e.name == name {
                return e.font
            }
        }
        let font = UIFont(name: name, size: size)!
        //print(">>> FONTCACHE[\(entries.count)]: \(name)@\(size)")
        entries.append(Entry(name, size, font))
        return font
    }
}

func UIFontCache(_ dummy: Int=0, name: String, size: CGFloat) -> UIFont! {
    return FontCache.findOrAdd(name, size)
}

extension SKLabelNode {
    convenience init(_ font: UIFont!, _ color: UIColor? = nil) {
        self.init(fontNamed: font.fontName)
        self.fontSize = font.pointSize
        if color != nil {
            self.fontColor = color!
        }
    }

    convenience init(_ font: UIFont!, _ color: UIColor? = nil, text: String!) {
        self.init(fontNamed: font.fontName)
        self.fontSize = font.pointSize
        if color != nil {
            self.fontColor = color!
        }
        self.text = text
    }
}

class PDFCache {
    static var entries: [String : CGDataProvider?] = [:]
    
    static func request(_ name: String) -> CGDataProvider? {
        
        if let provider = entries[name] {
            return provider
        }
        
        guard let path = Bundle.main.path(forResource: name, ofType: "pdf") else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let provider = CGDataProvider(url: url as CFURL) else { return nil }
        //        print(">> PDF File \(name) size = \(CFDataGetLength(provider.data!))")
        entries[name] = provider
        return provider
    }
}

func PDFImages(named name: String, sizes: [CGSize]) -> [UIImage]? {
    guard let provider = PDFCache.request(name) else { return nil }
    //guard let path = Bundle.main.path(forResource: name, ofType: "pdf") else { return nil }
    //let url = URL(fileURLWithPath: path)
    //guard let pdf = CGPDFDocument(url as CFURL) else { return nil }
    //let startTime = CFAbsoluteTimeGetCurrent()
    guard let pdf = CGPDFDocument(provider) else { return nil }
    guard let page = pdf.page(at: 1) else { return nil }
    let cropBox = page.getBoxRect(.cropBox)
    var images: [UIImage] = []
    
    for size in sizes {
        
        let dstRect = CGRect(origin: CGPoint.zero, size: size)
        let scale = size.height / cropBox.height
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.fill(dstRect)
        ctx.translateBy(x: 0.0, y: size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsPushContext(ctx)
        var xfrm = page.getDrawingTransform(.cropBox, rect: dstRect, rotate: 0, preserveAspectRatio: true)
        if scale > 1 {
            xfrm = xfrm.translatedBy(x: cropBox.midX, y: cropBox.midY)
            xfrm = xfrm.scaledBy(x: scale, y: scale)
            xfrm = xfrm.translatedBy(x: -cropBox.midX, y: -cropBox.midY)
        }
        ctx.concatenate(xfrm)
        ctx.drawPDFPage(page)
        UIGraphicsPopContext()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        images.append(image!)
    }
    
    //print("\(name).pdf @ \(sizes.count) sizes took \(1000.0 * (CFAbsoluteTimeGetCurrent() - startTime))ms")
    return images
}

func PDFImage(named name: String, size: CGSize) -> UIImage? {
    guard let images = PDFImages(named: name, sizes: [size]) else { return nil }
    return images[0]
}

class BackgroundTextureCache {
    struct Entry {
        let choice: Int
        let shade: Int
        let texture: SKTexture?
        let name: String?
        
        init(_ choice: Int, _ shade: Int, _ texture: SKTexture?, _ name: String?) {
            self.choice = choice
            self.shade = shade
            self.texture = texture
            self.name = name
        }
    }
    static let maxEntries = 12
    static let queue = DispatchQueue(label: "locker", attributes: .concurrent)
    static let semaphore = DispatchSemaphore(value: maxEntries)

    static var slots: [Int] = []
    static var entries: [Entry] = []
    static var locks: [DispatchSemaphore] = []
    
    static private var dimension: CGSize = CGSize.zero
    
    static func initialize(backgroundSize: CGSize) {
        slots.removeAll()
        entries.removeAll()
        locks.removeAll()
        for i in 0..<maxEntries {
            slots.append(i)
            entries.append(Entry(-1, -1, nil, nil))
            locks.append(DispatchSemaphore(value: 1))
        }
        dimension = backgroundSize
    }
    
    static private func dump(_ msg: String) {
        print(">>>>>>>>>>>>>> BackgroundImageCache: \(msg)")
        print(slots)
        for (i, e) in entries.enumerated() {
            print("\(i): \(e.name!)")
        }
    }

    static private func touch(_ slot: Int) {
        var i: Int = 0
        while i < maxEntries {
            if slots[i] == slot {
                break
            }
            i += 1
        }
        while i < maxEntries - 1 {
            slots[i] = slots[i+1]
            i += 1
        }
        slots[i] = slot
    }

    static func request(_ choice: Int, _ shade: Int, completion block: @escaping (SKTexture?) -> Swift.Void) {

        var slot = 0
        while slot < maxEntries {
            if entries[slot].choice == choice && entries[slot].shade == shade {
                touch(slot)
                locks[slot].wait()
                queue.sync {
                    autoreleasepool {
                        block(entries[slot].texture)
                    }
                }
                locks[slot].signal()
                return
            }
            slot += 1
        }
        
        // Not found... Kick out LRU entry
        semaphore.wait()
        slot = slots[0]
        touch(slot)
        let lock = locks[slot]
        lock.wait()
        queue.sync(flags: .barrier) {
            entries[slot] = Entry(choice, shade, nil, nil)
        }

        DispatchQueue.global(qos: .userInteractive).async(flags: .barrier) {
            autoreleasepool {
                let name = "\(MainScene.backgroundIDs[choice])\(shade)"
                let image = PDFImage(named: name, size: dimension)
                let texture = SKTexture(image: image!)
                block(texture)
                queue.async(flags: .barrier) {
                    entries[slot] = Entry(choice, shade, texture, name)
                    lock.signal()
                    semaphore.signal()
                }
            }
        }
    }
}

class MainScene: BaseScene, UITextFieldDelegate{
    
    static let isTestFlight = true
    
    var pauseNode: SKLabelNode! = nil
    
    var backgroundSize: CGSize! = nil

    static let backgroundIDs = ["City", "Desert", "Farm", "Forest", "Island", "Jungle", "Meadow", "Mountain", "Volcano"]
    
    var numTimesTwoFingersShown = 0
    
    var currentParticleEmitterBackgroundNum = -1
    
    var currentParticleEmitterBackgroundShade = -1
    
    var cycleBackgroundShade: Int = 0
    
    var cycleBackgroundShadePos: Int = 0
    
    var topLetterBoxNode = SKSpriteNode()
    
    var bottomLetterBoxNode = SKSpriteNode()
    
    var leftLetterBoxNode = SKSpriteNode()
    
    var rightLetterBoxNode = SKSpriteNode()
    
    let iPhoneLabel = SKLabelNode(UIFontCache(name: "HelveticaNeue-Thin", size: 17), Colours.getColour(.black), text: "iPhone")
    
    let iPadLabel = SKLabelNode(UIFontCache(name: "HelveticaNeue-Thin", size: 17), Colours.getColour(.black), text: "iPad")
    
    var iPhoneButton: HKButton! = nil
    
    var iPadButton: HKButton! = nil
    
    var testGameLabel: SKMultilineLabel! = nil

    var shareTexts: [[SKNode]] = []
    
    var deviceTickNode: SKSpriteNode! = nil
    
    var backgroundNode = SKSpriteNode()
    
    var backgroundMaskNode = SKSpriteNode()
    
    var oldBackgroundChoice: Int = -1
    
    var oldBackgroundShade: Int = -1
    
    var oldDayNightChoice: Int = -1
    
    var gameNameSize: CGSize! = nil
    
    var centralBoxSize: CGSize! = nil
    
    var transGraphic: UIImage! = nil
    
    let blackColour = Colours.getColour(.black)
    
    let whiteColour = Colours.getColour(.white)
    
    var openGames: [String:GeneratorScreen] = [:]
    
    var currentGamePack: GamePackScreen! = nil
    
    var gamePacks: [GamePackScreen] = []

    var allPackIDs = GameHandler.getPackNames()
    
    var canPressPlay = false
    
    var scoreNode: SKNode! = nil
    
    var isAnimatingOpening = false
    
    var isAnimatingTutorial = false
    
    var isShaking = false
    
    var okButton: HKButton! = nil
    
    var openingScreenNum = 0
    
    var startInfoNode: SKSpriteNode! = nil
    
    var hideTutorialNode: SKLabelNode! = nil
    
    var tutorialNode: SKNode! = nil
    
    var showingTutorial: Int! = nil
    
    let infoPipsAddOn = CGFloat(12)
    
    var darkBlueColour = UIColor(red: CGFloat(68)/CGFloat(256), green: CGFloat(94)/CGFloat(256), blue: CGFloat(156)/CGFloat(256), alpha: 1)
    
    var unselectedPipColor = Colours.getColour(.steelBlue).withAlphaComponent(0.3)
    
    var LISGenomeString: String = ""
    
    var loadedMPCGDGenomes: [String: MPCGDGenome] = [:]
    
    var isLockedHash: [String : Bool] = [:]
    
    var savedGamesStartSlot = 0

    var gameNameTextBox: HKTextBox! = nil
    
    var dolceVitaFont = UIFontCache(name: "Dolce Vita", size: 45)!

    var dolceVitaLightFont = UIFontCache(name: "Dolce Vita Light", size: 45)!

    var dolceVitaHeavyFont = UIFontCache(name: "Dolce Vita Heavy", size: 45)!
    
    var textField: UITextField! = nil
    var textFieldStartText: String = ""
    var textFieldCompletionHandler: ((String) -> ())! = nil

    var keepGoingButton: HKButton! = nil
    
    var startOverButton: HKButton! = nil
    
    var quitThisButton: HKButton! = nil
    
    var backgroundParticleEmitter: SKEmitterNode! = nil
    
    var aboutButton: HKButton! = nil
    
    var creditsButton: HKButton! = nil

    var labelFont = UIFontCache(name: "HelveticaNeue-Thin", size: 20)!
    
    var wIconNode: SKSpriteNode! = nil
    
    var infoCyclers: [String:HKComponentCycler] = [:]
    
    var logoImageCycler: HKComponentCycler! = nil
    
    var infoGraphicsImageCycler: HKComponentCycler! = nil
    
    var helpNode: SKMultilineLabel! = nil
    
    var isRestarting = false
    
    var endBackCardChooser: HKCardChooser! = nil
    
    var playAgainCardChooser: HKCardChooser! = nil
    
    var playButton: HKButton! = nil
    
    var infoButton: HKButton! = nil
    
    var settingsButton: HKButton! = nil
    
    var currentGameName = "LIS"
    
    var musicVolumeSlider: HKSlider! = nil
    
    var musicTrackCardChooser: HKCardChooser! = nil
    
    var sfxSlider: HKSlider! = nil
    
    #if os(iOS)
        var viewController: GameViewController! = nil
    #endif
    
    var infoNode: SKNode! = nil
    
    var creditNode: SKNode! = nil
    
    var aboutNode: SKNode! = nil
    
    var settingsNode: SKNode! = nil
    
    var fascinatorNode: SKNode! = nil
    
    var fascinator: Fascinator! = nil
    
    var lastUpdateTime : TimeInterval! = nil
    
    var flyIn: SKAction! = nil
    
    let fadeOut = SKAction.fadeOut(withDuration: 0.5)

    let fadeIn = SKAction.fadeIn(withDuration: 0.5)
    
    let fadePartiallyIn = SKAction.fadeAlpha(to: 0.7, duration: 0.5)
    
    let quickFadeOut = SKAction.fadeOut(withDuration: 0.3)
    
    let quickFadeIn = SKAction.fadeIn(withDuration: 0.3)
    
    let logoYPos = CGFloat(0.88)
    
    let MPCGDLogoYPos = CGFloat(0.9)
    
    var subTitleLabelYPos = CGFloat(0.76)
    
    var mainTextYPos = CGFloat(0.48)
    
    var buttonYPos = CGFloat(0.075)
    
    var topButtonsY = CGFloat(55)
    
    var infoGraphicsY = CGFloat(0.465)
    
    let buttonAction = SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.075), SKAction.scale(to: 1.0,duration: 0.075), SKAction.wait(forDuration: 0.05)])
    
    let buttonAction2 = SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.075), SKAction.scale(to: 1.0,duration: 0.075), SKAction.wait(forDuration: 0.2)])
    
    var tapsPerSession : Int = 0
    
    var downloadButton = HKButton(image: UIImage(named: "DownloadButton")!, dilateTapBy: CGSize(width: 2.5, height: 1.5))
    
    var generateButton = HKButton(image: UIImage(named: "Random")!, dilateTapBy: CGSize(width: 2.5, height: 1.5))
    
    fileprivate let scaleAction = SKAction.sequence([HKEasing.scaleTo(1.15, duration: 0.1, easingFunction: BackEaseOut), HKEasing.scaleTo(1.0, duration: 0.1, easingFunction: BackEaseOut), SKAction.wait(forDuration: 0.1)])

    
    static var instance: MainScene! = nil

    override func didMove(to view: SKView) {
        MainScene.instance = self
        
        super.didMove(to: view)
        HKDisableUserInteractions = false
        _ = shareDialog([])
        
        let baseImage = HKImage(image: UIImage(named: "BlankGraphic")!)
        centralBoxSize = baseImage.size
        gameNameSize = CGSize(width: baseImage.size.width, height: 57)

        // TURN THESE OFF BEFORE RELEASE!!!
        //view.showsPhysics = true
        //view.showsFPS = true
        //view.showsNodeCount = true
        
        dragType = DragType.xAndYStraight
        scaleMode = SKSceneScaleMode.aspectFit
        
        let device = UIDevice.current.model
        if device.contains("iPad"){
            DeviceType.isIPad = true
            DeviceType.isIPhone = false
            DeviceType.simulationIs = .iPad
            size = CGSize(width: 384, height: 512)
        } else {
            DeviceType.isIPad = false
            DeviceType.isIPhone = true
            DeviceType.simulationIs = .iPhone
            size = CGSize(width: 320, height: 568)
        }
        
        if DeviceType.isIPad{
            infoGraphicsY += 0.02
            backgroundSize = size
        }
        else{
            backgroundSize = CGSize(width: size.height * 0.75, height: size.height)
        }

        // Pre-cache all background PDFs
        for choice in 0..<9 {
            for shade in 0..<9 {
                let name = "\(MainScene.backgroundIDs[choice])\(shade)"
                _ = PDFCache.request(name)
            }
        }
        BackgroundTextureCache.initialize(backgroundSize: backgroundSize)
        
        let wG = MPCGDGenome()
        wG.backgroundChoice = 6
        loadBackgroundForSplashScreenFade(wG)
        changeBackgroundParticleEmitter(wG)
        physicsWorld.gravity = CGVector.zero
        setupBackgroundAndMaskNode()

        transGraphic = UIImage(named: "TransparentGraphic")!
        
        addStartupScreen()
        createSettingsScreen()
        createInfoScreen()
        
        CharacterIconHandler.initialise()

        FascinatorLoader.loadBaseCampFascinator("LISiPhone", baseCampType: .Base, scene: (self.scene as! MainScene))
        fascinatorNode.zPosition = 10
        
        addPresetsToDatabase()
        for _ in 0..<allPackIDs.count{
            shareTexts.append([])
        }
        let startTime = CFAbsoluteTimeGetCurrent()
        addLogo()
        print("addLogo took \(CFAbsoluteTimeGetCurrent() - startTime) seconds")

        if DeviceType.isIPad{
            logoImageCycler.pipsNode.position.y += 15
        }
        
        fascinator.playtester = AssistantPlaytester(fascinator: fascinator)
        fascinator.pauseImmediately()
        fascinator.gameOverCode = gameOver
        
        MPCGDSounds.precache(packName: "arcade")
        MPCGDAudio.initialize()
        //MPCGDAudio.playStream(index: 0, path: MPCGDMusic.tracks[0])
        MPCGDAudioPlayer.loadAndPlayAudio(trackName: "Music_1_1.m4a", channelNum: 1, volume: 0.75, rate: 1)

        MPCGDGenomeGenerator.getSextuplets()
        fascinator.calculateImageLayers()
        GeneratorScreen.populateBackgroundIcons()

        LISGenomeString = fascinator.chromosome.getStringRepresentation()
        addTextFieldAndKeyboard()

        flyIn = SKAction.move(by: CGVector(dx: -scene!.size.width, dy: 0), duration: 0.1)
        
        addLetterBoxNodes()
        startOpeningAnimation()
        
        //BaseScene.enableGyro()
        playButton.alpha = 0.2
        playButton.isHidden = true
        fascinator.fascinatorSKNode.isHidden = true
        fascinator.artImageNode.alpha = 0
        
        pauseNode = SKLabelNode(text: "Paused")
        pauseNode.fontName = "Helvetica Neue Thin"
        pauseNode.position = CGPoint(x: scene!.size.width/2, y: DeviceType.isIPad ? 410 : 447)
        pauseNode.fontColor = Colours.getColour(.antiqueWhite)
        pauseNode.fontSize = 20
        pauseNode.zPosition = 1000
        pauseNode.alpha = 0
        addChild(pauseNode)
    }
    
    var menuNode : SKNode?
    
    enum GameState {
        case start
        case menu
        case playing

        case about
        case settings
        case paused
        case tutorial
        case opening
        case credits
    }
    
    var state : GameState = .opening
    
    func addPresetsToDatabase(){
        if !UserHandler.presetsLoaded{
            UserHandler.setPresetsLoaded()
            for gamePackID in allPackIDs{
                addPresets(gamePackID)
            }
        }
    }
    
    func addPresets(_ gamePackID: String){
        let path:String = Bundle.main.path(forResource: gamePackID, ofType: "txt")!
        let text = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let lines = text?.components(separatedBy: "\n")
        let MPCGDGenome = MPCGDGenome()
        for line in lines!{
            if line != ""{
                if MPCGDGenome.decodeFromBase64(line.components(separatedBy: ",")[0]) {
                    let gameName = line.components(separatedBy: ",")[1]
                    let timeString = String(Date().timeIntervalSince1970)
                    let gameID = gameName + "@" + timeString
                    _ = GameHandler.saveGame(MPCGDGenome, gameID: gameID, packID: gamePackID, isLocked: false)
                }
                else{
                    print("BAD: \(line)")
                }
            }
        }
    }
    
    func getGamePackScreen(_ packID: String, onGameTapCode: @escaping (String, GamePackScreen) -> ()) -> GamePackScreen{
        var savedGameIDs = GameHandler.retrieveGamePack(packID)
        var gameComponents: [HKButton] = []
        let sortFunction: (_: String, _: String) ->  Bool = {a,b in
            let d1 = a.components(separatedBy: "@")[1]
            let d2 = b.components(separatedBy: "@")[1]
            return Double(d1) < Double(d2)
        }
        savedGameIDs.sort(by: sortFunction)
        print("Loading pack: \(packID)")
        for gameID in savedGameIDs{
            let (MPCGDGenome, isLocked) = GameHandler.retrieveGame(gameID, packID: packID)
            let encoding = MPCGDGenome?.encodeAsBase64()
            print("\(encoding!),\(gameID.components(separatedBy: "@")[0])")
            loadedMPCGDGenomes[gameID] = MPCGDGenome
            isLockedHash[gameID] = isLocked
            gameComponents.append(getGamePackComponent(gameID, packID: packID))
        }
        print("---")
        let gamesPackScreen = GamePackScreen(size: centralBoxSize, gameButtons: gameComponents, gameIDs: savedGameIDs, packID: packID)
        gamesPackScreen.onGameTapCode = onGameTapCode
        gamesPackScreen.newGameAddedCode = handleNewGameAdded
        gamesPackScreen.inspirationCode = handleInspiringGameAdded
        return gamesPackScreen
    }
    
    let sema = DispatchSemaphore(value: 8)
    
    func getGamePackComponent(_ gameID: String, packID: String, overrideMPCGDGenome: MPCGDGenome! = nil, completion block: ((_ button: HKButton) -> ())? = nil) -> HKButton {
        let gameName = gameID.components(separatedBy: "@")[0]
        var MPCGDGenome = overrideMPCGDGenome
        if overrideMPCGDGenome == nil{
            MPCGDGenome = GameHandler.retrieveGame(gameID, packID: packID).0
        }
        let logoColour = getTextColourForMPCGDGenome(MPCGDGenome!)
        
        let logoComp = getLogoComponent(gameID: gameID, gameName: gameName, colour: logoColour, fontSize: 28)
        logoComp.position.y = 0
        
        let comp = HKButton(image: ImageUtils.getBlankImage(gameNameSize, colour: UIColor.clear))
        
        let choice = MPCGDGenome!.backgroundChoice
        let shade = MPCGDGenome!.dayNightCycle > 0 ? 0 : MPCGDGenome!.backgroundShade

        BackgroundTextureCache.request(choice, shade, completion: { (bgTexture: SKTexture?) in
            guard bgTexture != nil else { return }
            let backgroundImage = UIImage(cgImage: bgTexture!.cgImage())
            
            let h = floor(backgroundImage.size.width * (self.gameNameSize.height / self.gameNameSize.width))
            let randYPos = floor(RandomUtils.randomFloat(1, upperInc: h))
            let rect = CGRect(x: 0, y: randYPos, width: backgroundImage.size.width, height: h)
            let gameImage = ImageUtils.getSubImage(backgroundImage, rect: rect)
        
            DispatchQueue.main.async {
                let backingNode = SKSpriteNode(texture: SKTexture(image: gameImage))
                backingNode.size = CGSize(width: self.gameNameSize.width, height: self.gameNameSize.height)
                comp.addChild(backingNode)
                comp.addChild(logoComp)
                logoComp.zPosition = comp.zPosition + 1
                block?(comp)
            }
        })
        return comp
    }
    
    let infoButtonMinAlpha = CGFloat(0.2)
    
    func fadeInfoButtonOut() {
        guard infoButton.alpha > infoButtonMinAlpha else { return }
        infoButton.removeAllActions()
        infoButton.isHidden = false
        infoButton.isUserInteractionEnabled = false
        infoButton.run(SKAction.fadeAlpha(to: infoButtonMinAlpha, duration: 0.4), completion: { self.infoButton.alpha = self.infoButtonMinAlpha })
    }
    
    func fadeInfoButtonIn() {
        guard infoButton.alpha <= infoButtonMinAlpha + 0.001 else { return }
        infoButton.removeAllActions()
        infoButton.isHidden = false
        infoButton.isUserInteractionEnabled = false
        infoButton.run(SKAction.fadeIn(withDuration: 0.4), completion: { self.infoButton.isUserInteractionEnabled = true })
    }

    func startOpeningAnimation(){
//        self.playButton.run(SKAction.fadeAlpha(to: 0.2, duration: 0.5), completion: {
//            HKDisableUserInteractions = false
//            self.playButton.enabled = true
//            self.playButton.isHidden = false
//        })
//        self.state = .start
//        self.isAnimatingOpening = false
//        self.playButton.isHidden = false
//        return
//
        
        let sfLogo = SKSpriteNode(imageNamed: "Logo-images")
        sfLogo.setScale(0.5 * size.width / sfLogo.width)
        sfLogo.position = CGPoint(x: size.width/2, y: 0.75 * size.height)
        sfLogo.zPosition = 10
        self.addChild(sfLogo)
        
        var action1 = SKAction.sequence([SKAction.wait(forDuration: 0.85), SKAction.scale(to: 1.1, duration: 2.0)])
        if DeviceType.isIPad{
            action1 = SKAction.sequence([SKAction.wait(forDuration: 0.85), SKAction.scale(to: 0.9, duration: 2.0)])
        }
        let action2 = SKAction.sequence([SKAction.wait(forDuration: 0.85), SKAction.fadeOut(withDuration: 2.0)])
        
        sfLogo.run(action1)
        sfLogo.run(action2)
        self.run(SKAction.wait(forDuration: 1), completion: {
            MPCGDAudio.playSound(path: MPCGDSounds.winGame)
        })
        
        let (fluidicLogoNodes, _) = getWordLabels("Fluidic Games", fontSize: 45)
        let logoNode = SKNode()
        for node in fluidicLogoNodes{
            logoNode.addChild(node)
            node.position.y += scene!.size.height * logoYPos
            node.position.x += scene!.size.width * 1.5
            node.zPosition = 10
        }
        addChild(logoNode)
        
        let flyInFromRight = HKEasing.moveXBy(-size.width, duration: TimeInterval(0.4), easingFunction: BackEaseOut)
        let flyInFromRight2 = HKEasing.moveXBy(-size.width, duration: TimeInterval(0.4), easingFunction: BackEaseOut)
        let action3 = SKAction.sequence([SKAction.wait(forDuration: 3.0), flyInFromRight])
        let action4 = SKAction.sequence([SKAction.wait(forDuration: 3.2), flyInFromRight2])

        logoNode.run(action3, completion: {
            self.okButton.run(self.fadeIn)
        })
        
        self.infoGraphicsImageCycler.position.x = (self.infoGraphicsImageCycler?.position.x)! + size.width
        self.logoImageCycler.position.x = self.logoImageCycler.position.x + size.width
        self.playButton.alpha = 0
        self.infoButton.alpha = 0
        self.settingsButton.alpha = 0
        self.settingsButton.isHidden = true
        
        let image = UIImage(named: "OpeningGraphics1")!
        startInfoNode = SKSpriteNode(texture: SKTexture(image: image))
        startInfoNode.position = CGPoint(x: scene!.size.width * 1.5, y: scene!.size.height * infoGraphicsY)
        startInfoNode.zPosition = 10
        addChild(startInfoNode)
        
        okButton = HKButton(image: UIImage(named: "OKButton")!)
        okButton.position = CGPoint(x: scene!.size.width/2, y: scene!.size.height * buttonYPos)
        okButton.zPosition = 10
        okButton.alpha = 0
        addChild(okButton)
        okButton.onTapStartCode = {
            
                    self.isAnimatingOpening = true
                    logoNode.run(self.fadeOut, completion: {
                        logoNode.removeFromParent()
                    })
                    self.okButton.run(self.fadeOut, completion: {
//                        self.okButton.removeFromParent()
                    })
                    self.startInfoNode.run(self.fadeOut, completion: {
                        self.startTheGame()
                        self.state = .start
                        self.startInfoNode.removeFromParent()
                        self.isAnimatingOpening = false
                        self.playButton.isHidden = false
                        self.infoButton.isUserInteractionEnabled = false
                        self.infoButton.run(SKAction.fadeIn(withDuration: 1.0), completion: {
                            self.infoButton.isUserInteractionEnabled = true
                        })
                    })
                    if !self.currentGamePack.gameIDs.isEmpty{
                        let wG = self.currentGamePack.MPCGDGenomeShowingInBackground
                        let colour = self.isBackgroundDark(wG!) ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
                        self.changeBackground(wG!)
                        self.changeInfoColours(wG!)
                        self.changeSettingsColours(wG!)
                        self.changeLogoPipsColour(colour)
                    }
                
            
        }
        startInfoNode.run(action4)
    }
    
    func startTheGame(){
        
        let flyInFromRight = HKEasing.moveXBy(-size.width, duration: TimeInterval(0.4), easingFunction: BackEaseOut)
        let action3 = flyInFromRight
        let action4 = SKAction.sequence([SKAction.wait(forDuration: 0.2), flyInFromRight])
        let action5 = SKAction.fadeIn(withDuration: 0.5)
        
        self.logoImageCycler.run(action3)
        self.infoGraphicsImageCycler.run(action4)
        self.playButton.run(SKAction.fadeAlpha(to: 0.2, duration: 0.5), completion: {
            HKDisableUserInteractions = false
            self.playButton.enabled = false
        })
        self.infoButton.run(action5)
        self.settingsButton.run(action5)
    }
    
    func changeBackgroundParticleEmitter(_ MPCGDGenome: MPCGDGenome, forceIt: Bool = false){
        if backgroundParticleEmitter != nil{
            let hasChangedExistingEmitter = ParticleEmitterHandler.effectChange(forceIt: forceIt, existingBackgroundChoice: currentParticleEmitterBackgroundNum, existingBackgroundShade: currentParticleEmitterBackgroundShade, newMPCGDGenome: MPCGDGenome, emitter: backgroundParticleEmitter, screenSize: size)
            if !hasChangedExistingEmitter{
                backgroundParticleEmitter.run(fadeOut, completion: {
                    self.backgroundParticleEmitter.removeAllActions()
                    self.backgroundParticleEmitter.removeFromParent()
                    self.addNewBackgroundParticleEmitter(MPCGDGenome)
                })
            }
        }
        else{
            addNewBackgroundParticleEmitter(MPCGDGenome)
        }
    }
    
    func addNewBackgroundParticleEmitter(_ MPCGDGenome: MPCGDGenome){
        backgroundParticleEmitter = ParticleEmitterHandler.getBackgroundEmitter(size, MPCGDGenome: MPCGDGenome)
        addChild(self.backgroundParticleEmitter)
        let alpha = self.backgroundParticleEmitter.alpha
        backgroundParticleEmitter.alpha = 0
        backgroundParticleEmitter.run(SKAction.fadeAlpha(to: alpha, duration: 0.3))
        backgroundParticleEmitter.zPosition = 3
        currentParticleEmitterBackgroundNum = MPCGDGenome.backgroundChoice
        currentParticleEmitterBackgroundShade = MPCGDGenome.backgroundShade
        oldDayNightChoice = MPCGDGenome.dayNightCycle
    }
 
    static var pooker = 0
    
    func addStartupScreen(){
        menuNode = SKNode()
        keepGoingButton = HKButton(image: UIImage(named: "KeepGoingButton")!)
        keepGoingButton.onTapStartCode = hideInfoCycler
        keepGoingButton.position = CGPoint(x: size.width * 0.2, y: size.height * buttonYPos)
        keepGoingButton.tapCode = keepGoing
        keepGoingButton.isHidden = true
        menuNode?.addChild(keepGoingButton)

        startOverButton = HKButton(image: UIImage(named: "StartOverButton")!)
        startOverButton.onTapStartCode = hideInfoCycler
        startOverButton.position = CGPoint(x: size.width * 0.5, y: size.height * buttonYPos)
        startOverButton.tapCode = startOver
        startOverButton.isHidden = true
        menuNode?.addChild(startOverButton)

        quitThisButton = HKButton(image: UIImage(named: "QuitThisButton")!)
        quitThisButton.position = CGPoint(x: size.width * 0.8, y: size.height * buttonYPos)
        quitThisButton.tapCode = handleQuitButtonTapped
        quitThisButton.isHidden = true
        menuNode?.addChild(quitThisButton)
        
        playButton = HKButton(image: UIImage(named: "PlayButton")!)
        playButton.tapCode = nil //handlePlayTap
        playButton.position = CGPoint(x: size.width/2, y: size.height * buttonYPos)
        playButton.onTapStartCode = {
            if self.canPressPlay{
                self.hideInfoCyclerAndFadeOutForPlayOnly()
            }
        }
        menuNode?.addChild(playButton)
        
        infoButton = HKButton(image: UIImage(named: "InfoButton")!, dilateTapBy: CGSize(width: 2.5, height: 2.0))
        infoButton.tapCode = handleInfoTap
        infoButton.position = CGPoint(x: size.width * 0.15, y: size.height * buttonYPos)
        infoButton.onTapStartCode = {
            self.createInfoScreen()
            self.hideInfoCycler()
        }
        menuNode?.addChild(infoButton)
        //infoButton.isHidden = true
        
        settingsButton = HKButton(image: UIImage(named: "SettingsButton")!, dilateTapBy: CGSize(width: 2.5, height: 2.0))
        settingsButton.tapCode = handleSettingsTap
        settingsButton.position = CGPoint(x: size.width * 0.85, y: size.height * buttonYPos)
        settingsButton.onTapStartCode = hideInfoCycler
        menuNode?.addChild(settingsButton)
        
        for button in [keepGoingButton, startOverButton, quitThisButton, playButton, infoButton, settingsButton]{
            button?.zPosition = 100
        }
        
        playButton.zPosition = 100
        infoButton.zPosition = 100
        settingsButton.zPosition = 100
        
        addChild(menuNode!)
    }
    
    func hideInfoCyclerAndFadeOutForPlayOnly() {
        HKDisableUserInteractions = true
        menuNode?.run(fadeOut)
        logoImageCycler.run(fadeOut)
        infoGraphicsImageCycler.run(fadeOut)
        infoGraphicsImageCycler.selectedHKComponent?.run(fadeOut)
        handlePlayTap()
    }

    func hideInfoCycler(){
        HKDisableUserInteractions = true
        infoGraphicsImageCycler.run(fadeOut)
        infoGraphicsImageCycler.selectedHKComponent?.run(fadeOut)
    }

    func showInfoCycler(_ cycleToComp: Bool = true){
        infoGraphicsImageCycler.isHidden = false
        infoGraphicsImageCycler.selectedHKComponent?.run(fadeIn)
        infoGraphicsImageCycler.run(fadeIn, completion: { HKDisableUserInteractions = false })
        if cycleToComp{
            
            let genScreen = infoCyclers[currentGameName]?.hkComponents[2] as! GeneratorScreen
            genScreen.alterButtonsForLiveMPCGDGenome()

            _ = infoCyclers[currentGameName]?.cycleToComponentIndex(2)
            infoCyclers[currentGameName]?.handleGeneratorScreenMenuMove()
        }
    }
    
    func createSettingsScreen(){

        settingsNode = SKNode()
        
        let logoNode = SKSpriteNode(imageNamed: "MPCGDLogo")
        logoNode.position = CGPoint(x: size.width/2, y: MPCGDLogoYPos * size.height)
        logoNode.size = logoNode.size * 0.8
        settingsNode.addChild(logoNode)
        
        let sliderSize = CGSize(width: 200, height: 50)
        
        let lowVolume = UIImage(named: "LowVolumeIcon")!
        let highVolume = UIImage(named: "HighVolumeIcon")!

        musicVolumeSlider = HKSlider(size: sliderSize, label: "Music", lhImage: lowVolume, rhImage: highVolume)
        musicVolumeSlider.position = CGPoint(x: size.width/2, y: size.height * 0.675)
        musicVolumeSlider.maximumValue = 1
        musicVolumeSlider.minimumValue = 0
        musicVolumeSlider.value = 1.0
        musicVolumeSlider.touchEndCode = handleMusicVolumeChange
        settingsNode?.addChild(musicVolumeSlider)
        
        sfxSlider = HKSlider(size: sliderSize, label: "Sound effects", lhImage: lowVolume, rhImage: highVolume)
        sfxSlider.position = CGPoint(x: size.width/2, y: size.height * 0.5)
        sfxSlider.maximumValue = 1
        sfxSlider.minimumValue = 0
        sfxSlider.value = 1.0
        sfxSlider.touchEndCode = handleSFXVolumeChange
        settingsNode?.addChild(sfxSlider)
        
        let backButton = HKButton(image: UIImage(named: "BackMenuButton")!)
        backButton.hkImage.size = settingsButton.hkImage.size
        backButton.position = settingsButton.position
        //backButton.userInteractionEnabled = false
        backButton.tapCode = handleBackTap
        settingsNode?.addChild(backButton)
        
        settingsNode?.alpha = 0
        settingsNode.zPosition = 10
        
        let dilate = CGSize(width: 1.5, height: 1.5)
        iPadButton = HKButton(image: UIImage(named: "IPadIconDark")!, dilateTapBy: dilate)
        iPhoneButton = HKButton(image: UIImage(named: "IPhoneIconDark")!, dilateTapBy: dilate)

        // Devices
        
        let deviceLeftX = size.width * 0.25
        let deviceRightX = size.width * 0.75

        deviceTickNode = SKSpriteNode(imageNamed: "BackMenuButton") //DeviceTick")
        deviceTickNode.size = deviceTickNode.size * 0.5
        deviceTickNode.position = DeviceType.isIPhone ? CGPoint(x: deviceLeftX, y: 175) : CGPoint(x: deviceRightX, y: 175)
        settingsNode.addChild(deviceTickNode)
        deviceTickNode.isUserInteractionEnabled = false
        
        iPhoneButton.position = CGPoint(x: deviceLeftX, y: 175)
        iPadButton.position = CGPoint(x: deviceRightX, y: 175)
        settingsNode.addChild(iPadButton)
        settingsNode.addChild(iPhoneButton)
        iPhoneLabel.position = CGPoint(x: deviceLeftX, y: 125)
        iPadLabel.position = CGPoint(x: deviceRightX, y: 125)
        settingsNode.addChild(iPhoneLabel)
        settingsNode.addChild(iPadLabel)
        testGameLabel = SKMultilineLabel(text: "Test\n~game\non", size: CGSize(width: 100, height: 100), pos: CGPoint(x: size.width/2, y: 175), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: 17, fontColor: Colours.getColour(.black), leading: 10, alignment: .center, shouldShowBorder: false, spacing: 1.8)
        settingsNode.addChild(testGameLabel)
        
        iPhoneButton.onTapStartCode = {
            self.deviceTickNode.position.x = deviceLeftX
            DeviceType.simulationIs = .iPhone
            self.updateGeneratorScreenIcons()
        }

        iPadButton.onTapStartCode = {
            self.deviceTickNode.position.x = deviceRightX
            DeviceType.simulationIs = .iPad
            self.updateGeneratorScreenIcons()
        }
    
        self.addChild(settingsNode!)
    }
    
    func updateGeneratorScreenIcons(){
        if currentGamePack.gameIDOnShow != nil{
            let genScreen = infoCyclers[currentGameName]?.hkComponents[2] as! GeneratorScreen
            genScreen.alterForDeviceSimulation()
        }
    }
    
    func getSelectedBackgroundImages(_ unselectedBackgroundImages: [UIImage]) -> [UIImage]{
        var selectedBackgroundImages: [UIImage] = []
        for image in unselectedBackgroundImages{
            selectedBackgroundImages.append(getSelectedBackgroundImage(image))
        }
        return selectedBackgroundImages
    }
    
    func scaleImage(_ image: UIImage) -> UIImage{
        return ImageUtils.getImageScaledToSize(image, size: size * 0.175 * 3)
    }
    
    func getSelectedBackgroundImage(_ image: UIImage) -> UIImage{
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        ImageUtils.drawImageOntoContext(context, image: image)
        context.setStrokeColor(Colours.getColour(ColourNames.steelBlue).cgColor)
        context.stroke(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), width: 16)
        context.setStrokeColor(Colours.getColour(ColourNames.white).cgColor)
        context.stroke(CGRect(x: 4, y: 4, width: image.size.width - 8, height: image.size.height - 8), width: 4)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func getScaledImage(_ image: UIImage, size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0, y: size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    func getVerticalBarImage(_ length: CGFloat) -> UIImage{
        /*
        var length = CGFloat(100)
        if isIPhone{
            length = CGFloat(110)
        }
 */
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 2, height: length), false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.lightGray.cgColor)
        context.fill(CGRect(origin: CGPoint.zero, size: CGSize(width: 2, height: length)))
        let verticalBarImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return verticalBarImage
    }
    
    func getScrollBarImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 25, height: 2), false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.lightGray.cgColor)
        context.fill(CGRect(origin: CGPoint.zero, size: CGSize(width: 25, height: 2)))
        let scrollBarImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scrollBarImage
    }

    func handleAboutButtonTap(){
        (aboutButton.children[1] as! SKLabelNode).fontName = "Dolce Vita Heavy"
        (creditsButton.children[1] as! SKLabelNode).fontName = "Dolce Vita Light"
        aboutNode?.run(fadeIn, completion: {
            self.state = .about
        })
        creditNode?.run(fadeOut)
    }
    
    func handleCreditsTap(){
        (aboutButton.children[1] as! SKLabelNode).fontName = "Dolce Vita Light"
        (creditsButton.children[1] as! SKLabelNode).fontName = "Dolce Vita Heavy"
        creditNode?.run(fadeIn, completion: {
            self.state = .credits
        })
        aboutNode?.run(fadeOut)
    }
    
    func createInfoScreen(){
        aboutNode?.removeFromParent()
        creditNode?.removeFromParent()
        infoNode?.removeFromParent()
        
        var textColour = Colours.getColour(.black)
        if self.currentGamePack != nil{
            if let wG = self.currentGamePack.MPCGDGenomeShowingInBackground{
                textColour = getTextColourForMPCGDGenome(wG)
            }
        }
        
        infoNode = SKNode()

        let logoNode = SKSpriteNode(imageNamed: "MPCGDLogo")
        logoNode.size = logoNode.size * 0.8
        logoNode.position = CGPoint(x: size.width/2, y: MPCGDLogoYPos * size.height)
        infoNode.addChild(logoNode)

        createCreditScreen()
        
        let nilImage = ImageUtils.getBlankImage(CGSize(width: 100, height: 50), colour: UIColor.clear)
        aboutNode = SKNode()
        aboutButton = HKButton(image: nilImage)
        let aboutLabel = SKLabelNode(text: "About")
        aboutLabel.fontName = "Dolce Vita Heavy"
        aboutLabel.fontColor = textColour
        aboutLabel.fontSize = 20
        aboutButton.addChild(aboutLabel)
        
        aboutButton.onTapStartCode = handleAboutButtonTap
        aboutButton.position = CGPoint(x: size.width * 0.25, y: subTitleLabelYPos * size.height)
        infoNode.addChild(aboutButton)
        
        creditsButton = HKButton(image: nilImage)
        let creditsLabel = SKLabelNode(text: "Credits")
        creditsLabel.fontName = "Dolce Vita Light"
        creditsLabel.fontColor = textColour
        creditsLabel.fontSize = 20
        creditsButton.addChild(creditsLabel)
        
        creditsButton.onTapStartCode = handleCreditsTap
        creditsButton.position = CGPoint(x: size.width * 0.75, y: subTitleLabelYPos * size.height)
        infoNode.addChild(creditsButton)
        
        let backButton = HKButton(image: UIImage(named: "BackMenuButton")!)
        backButton.hkImage.size = infoButton.hkImage.size
        backButton.position = infoButton.position
        //backButton.userInteractionEnabled = false
        backButton.tapCode = handleBackTap
        infoNode.addChild(backButton)
        
        aboutNode.alpha = 0
        infoNode.alpha = 0
        creditNode.alpha = 0
        
        infoNode.zPosition = 10
        
        if self.currentGamePack != nil{
            if let wG = self.currentGamePack.MPCGDGenomeShowingInBackground{
                changeInfoColours(wG)
            }
        }
        
        addChild(self.aboutNode)
        addChild(self.creditNode)
        addChild(self.infoNode)
        aboutNode.zPosition = 10
    }
    
    func createCreditScreen(){
        creditNode = SKNode()
        
        var fontSize = CGFloat(15)
        var spacing = CGFloat(1.9)
        var alignment = SKLabelHorizontalAlignmentMode.center
        var xPos = CGFloat(0.67)
        var yPos = CGFloat(0.09)
        if DeviceType.isIPad{
            fontSize = CGFloat(11)
            spacing = CGFloat(1.45)
            alignment = SKLabelHorizontalAlignmentMode.center
            xPos = 0.625
            yPos = 0.176
        }
        
        let audioText = "~Audio\nMusic by Steven Johnson\nThis app uses many sounds from\nfreesound. For the full list see: \nmetamakers.com/MPCGD-credits"
        
        let graphicsText = "~Graphics\nDolce Vita font by Muraknockout\nmuraknockout.com"
        
        var textColour = Colours.getColour(.black)
        if let MPCGDGenome = loadedMPCGDGenomes[currentGameName]{
            textColour = getTextColourForMPCGDGenome(MPCGDGenome)
        }

        let appText = "~Games ~& ~App\nDesigned by @ThoseMetaMakers"
        
        let graphicsDesc = SKMultilineLabel(text: graphicsText, size: CGSize(width: size.width * 0.87, height: size.height), pos: CGPoint(x: size.width/2, y: size.height * 0.69), fontName: "Helvetica Neue Thin" , fontSize: fontSize + 3, fontColor: textColour, alignment: alignment, shouldShowBorder : false, spacing: spacing)
        
        let audioDesc = SKMultilineLabel(text: audioText, size: CGSize(width: size.width * 0.87, height: size.height), pos: CGPoint(x: size.width/2,y: size.height * 0.51), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: fontSize + 3, fontColor: textColour, alignment: alignment, shouldShowBorder : false, spacing: spacing)
        
        let appDesc = SKMultilineLabel(text: appText, size: CGSize(width: size.width * 0.87, height: size.height), pos: CGPoint(x: size.width/2,y: size.height * 0.35), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: fontSize + 3, fontColor: textColour, alignment: alignment, shouldShowBorder : false, spacing: spacing)

        creditNode.addChild(audioDesc)
        creditNode.addChild(graphicsDesc)
        creditNode.addChild(appDesc)

        let image2 = UIImage(named: "EUFlag")
        if image2 != nil {
            let scale = size.width / image2!.size.width
            let logo = SKSpriteNode(texture: SKTexture(image: image2!), size: image2!.size * scale * 0.15)
            creditNode.addChild(logo)
            logo.position = CGPoint(x: size.width * 0.25, y: size.height * 0.23)
        }
        let eraLabel =  SKMultilineLabel(text: "Research funded until 2018 by the\n~ERA ~programme", size: CGSize(width: size.width * 0.8, height: size.height), pos: CGPoint(x: size.width * 0.625, y: size.height * 0.238), fontName: "Helvetica Neue Thin" , fontSize: 14, fontColor: textColour, alignment: .center, shouldShowBorder : false, spacing: 1.6)
        creditNode.addChild(eraLabel)
        
        var mmText = "~MetaMakers: Heidi Ball, Simon Colton,\nMichael Cook, Swen Gaudl, Kamran\nHarandy, Peter Ivey, Tanya Krzywinska,\nMark Nelson, Blanca Pérez Ferrer,\nEdward Powley and Rob Saunders."
        
        if DeviceType.isIPad{
            mmText = "~MetaMakers: Heidi Ball, Simon Colton, Michael Cook,\nSwen Gaudl, Kamran Harandy, Peter Ivey,\nTanya Krzywinska, Mark Nelson, Blanca Pérez Ferrer,\nEdward Powley and Rob Saunders."
            xPos -= 0.05
            yPos -= 0.09
        }
        
        let metamakersLabel = SKMultilineLabel(text: mmText, size: CGSize(width: size.width * 0.7, height: size.height), pos: CGPoint(x: size.width * xPos, y: size.height * yPos), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: 12, fontColor: textColour, alignment: .left, shouldShowBorder: false, spacing: 1.33)
        creditNode.addChild(metamakersLabel)
        creditNode.zPosition = 10
    }
    
    func gameOver() {
        view!.isPaused = false
        playButton.isHidden = false
        menuNode!.isHidden = false
        menuNode!.alpha = 0
        playButton!.alpha = 0
        startOverButton.isHidden = true
        quitThisButton.isHidden = true
        keepGoingButton.isHidden = true
    //    settingsButton.isHidden = false
        settingsButton.run(fadeIn)
        infoButton.isHidden = false
        infoButton.run(SKAction.fadeAlpha(to: infoButtonMinAlpha, duration: 0.4))

        playButton?.run(self.fadeIn)
        logoImageCycler.isHidden = false
        logoImageCycler.pipsNode.isHidden = false
        logoImageCycler.pipsNode.alpha = 0
        logoImageCycler.pipsNode.run(fadeIn)
        logoImageCycler.name = "LogoImageCycler"

        var logoColour = currentGamePack.logoColour
        if loadedMPCGDGenomes[currentGameName]!.dayNightCycle > 0{
            logoColour = cycleBackgroundShade > 4 ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
        }
        
        changeLabelColour(logoImageCycler.selectedHKComponent, textColour: logoColour!)
        logoImageCycler.pipsNode.isHidden = true
        logoImageCycler.run(fadeIn)
        logoImageCycler.enabled = false
 
        okButton.alpha = 0
        okButton.run(fadeIn)
        okButton.onTapStartCode = {
            self.scoreNode.removeAllActions()
            self.scoreNode.run(self.fadeOut)
            self.fadeOutFascinator()
        }
        okButton.zPosition = 10000
        okButton.isUserInteractionEnabled = true
        okButton.enabled = true
        okButton.isHot = true
        
        // Wait for a second to avoid end-game tapping
        self.run(SKAction.wait(forDuration: 1), completion: {
            HKDisableUserInteractions = false
        })
 
        let currentInfoCycler = infoCyclers[currentGameName]

        // Stop the background cycling
        
        hideLetterBox({
            self.run(SKAction.wait(forDuration: 0.1), completion: {
                self.backgroundNode.removeAllActions()
                self.backgroundMaskNode.removeAllActions()
                self.backgroundMaskNode.run(SKAction.fadeOut(withDuration: 0.2))
            })
        })
        
        let gameEndDetails = fascinator.getGameEndDetails()
        
        scoreNode = createScoreScreen(logoColour!, gameEndDetails: gameEndDetails, size: scene!.size * 0.9)
        
        infoGraphicsImageCycler.isHidden = true
        scoreNode.alpha = 0
        scoreNode.run(fadeIn)
        self.addChild(scoreNode)

        saveSession(false, gameEndDetails: gameEndDetails)
        currentInfoCycler?.enabled = true
        
        state = .start
        
        fascinator.scoreDisplay.run(fadeOut)
        fascinator.timeDisplay.run(fadeOut)
        fascinator.livesDisplay.run(fadeOut)
        fascinator.fascinatorSKNode.run(fadeOut, completion: {
            if !self.fascinator.isPaused{
                self.fascinator.pauseImmediately()
            }
            self.fascinator.fascinatorSKNode.alpha = 1
            self.fascinator.fascinatorSKNode.isHidden = true
        })
    }
    
    func fadeOutFascinator(){
        if !fascinator.isPaused{
            fascinator.pauseImmediately()
        }
        fascinator.scoreDisplay.run(fadeOut)
        fascinator.timeDisplay.run(fadeOut)
        fascinator.livesDisplay.run(fadeOut)
        fascinator.fascinatorSKNode.run(fadeOut, completion: {
            self.fascinator.fascinatorSKNode.alpha = 1
            self.fascinator.fascinatorSKNode.isHidden = true
        })
        scoreNode?.run(fadeOut, completion: {
            self.scoreNode.removeFromParent()
            self.scoreNode = nil
        })
        if infoGraphicsImageCycler.isHidden{
            infoGraphicsImageCycler.alpha = 0
            infoGraphicsImageCycler.isHidden = false
            infoGraphicsImageCycler.run(fadeIn)
        }
        let MPCGDGenome = loadedMPCGDGenomes[currentGameName]!
        changeBackground(MPCGDGenome, forceIt: true)
        changeBackgroundParticleEmitter(MPCGDGenome, forceIt: true)
        menuNode?.run(self.fadeIn, completion: {
            self.logoImageCycler.enabled = true
        })
        
        let logoColour = MPCGDGenome.backgroundShade > 4 && MPCGDGenome.dayNightCycle == 0 ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
        changeLabelColour(logoImageCycler.selectedHKComponent, textColour: logoColour)
        
        //changeLogoPipsColour(logoColour)
        logoImageCycler.pipsNode.isHidden = false
        logoImageCycler.pipsNode.alpha = 0
        logoImageCycler.pipsNode.run(fadeIn)
        showInfoCycler()
        okButton.isHot = false
        okButton.run(fadeOut)
    }
    
    func createScoreScreen(_ textColour: UIColor, gameEndDetails: Fascinator.GameEndDetails, size: CGSize) -> HKComponent{
        
        let scoreNode = HKComponent()
        let spacing = CGFloat(3)
        
        let wG = loadedMPCGDGenomes[currentGameName]!
        
        let (topText, changeBestTo) = EndGameTextGenerator.getEndGameText(MPCGDGenome: wG, fascinator: fascinator, gameEndDetails: gameEndDetails)
        
        let finishedNode = SKMultilineLabel(text: topText, size: size, pos: CGPoint(x: 0, y: 0), fontName: "Helvetica Neue Thin", altFontName: "Helvetica Neue Bold", fontSize: 22, fontColor: textColour, alignment: .center, shouldShowBorder : false, spacing: spacing)
        
        if gameEndDetails.gameIsWon!{
            finishedNode.position.y = 40
            let wIconNode = SKSpriteNode(imageNamed: "WIconDark")
            wIconNode.size = CGSize(width: 90, height: 90)
            wIconNode.position.y = 110
            scoreNode.addChild(wIconNode)
            let action = SKAction.rotate(byAngle: -CGFloat.pi * 18, duration: 7)
            wIconNode.run(action)
        }
        scoreNode.addChild(finishedNode)
        scoreNode.position = CGPoint(x: scene!.size.width/2, y: scene!.size.height/2)
        scoreNode.zPosition = 1000
        
        if changeBestTo != ""{
            let emptyImage = ImageUtils.getBlankImage(CGSize(width: 200, height: 50), colour: UIColor.clear)
            let resetButton = HKButton(image: emptyImage)
            let label = SKLabelNode(text: "Set \(changeBestTo) as best")
            label.fontColor = textColour
            label.fontName = "Helvetica Neue Thin"
            label.fontSize = 17
            resetButton.hkImage.imageNode.addChild(label)
            resetButton.isUserInteractionEnabled = true
            resetButton.zPosition = 1100
            resetButton.position = CGPoint(x: 0, y: -165)
            resetButton.onTapStartCode = {
                SessionHandler.clearSessions(gameID: self.currentGameName)
                self.showAlertNode(text: "Best set to: \(changeBestTo)")
                let fade = SKAction.fadeAlpha(to: 0.2, duration: 0.5)
                resetButton.run(fade, completion: {
                    resetButton.enabled = false
                })
                self.saveSession(false, gameEndDetails: gameEndDetails)
            }
            scoreNode.addChild(resetButton)
        }
        
        return scoreNode
    }

    func handleGameRenamed(_ gameID: String, gamePackScreen: GamePackScreen, newName: String) {
        let oldDateString = gameID.components(separatedBy: "@")[1]
        let newGameID = newName + "@" + oldDateString
        let isLocked = isLockedHash[gameID]!
        
        
        let genScreen: GeneratorScreen
        genScreen = infoCyclers[currentGameName]?.hkComponents[2] as! GeneratorScreen
        genScreen.gameID = newGameID
        
        GameHandler.renameGame(gameID, newGameID: newGameID, genome: loadedMPCGDGenomes[currentGameName]!, packID: gamePackScreen.packID, isLocked: isLocked)
        SessionHandler.renameGame(oldGameID: gameID, newGameID: newGameID)
        let statsScreen = infoCyclers[currentGameName]!.hkComponents[0] as! StatsScreen
        statsScreen.reactToGameIDChange(newGameID: newGameID)
        let label = getGamePackComponent(newGameID, packID: gamePackScreen.packID)
        loadedMPCGDGenomes[newGameID] = loadedMPCGDGenomes[currentGameName]!
        loadedMPCGDGenomes.removeValue(forKey: currentGameName)
        gamePackScreen.handleRenamingOfGame(gameID, newID: newGameID, button: label)
        isLockedHash[newGameID] = isLocked
        isLockedHash.removeValue(forKey: currentGameName)
        currentGameName = newGameID
        infoCyclers[newGameID] = infoCyclers[gameID]
        infoCyclers.removeValue(forKey: gameID)
    }
    
    func putGamePackBack(_ gamePackScreen: GamePackScreen, genScreen: GeneratorScreen! = nil){
        
        infoGraphicsImageCycler.selectedHKComponent.run(fadeOut, completion: {
            let ind = self.infoGraphicsImageCycler.ids.index(of: self.infoGraphicsImageCycler.selectedID)!
            _ = self.infoGraphicsImageCycler.removeHKComponentWithID(self.infoGraphicsImageCycler.selectedID)
            self.infoGraphicsImageCycler.addHKComponentAtIndex(gamePackScreen, id: gamePackScreen.packID, index: ind)
            _ = self.infoGraphicsImageCycler.cycleToComponent(gamePackScreen.packID)
            self.infoGraphicsImageCycler.selectedHKComponent.run(SKAction.fadeIn(withDuration: 0.2))
            _ = self.logoImageCycler.cycleToComponent(gamePackScreen.packID)
            gamePackScreen.hideOffscreenGameButtons()
            gamePackScreen.gameIDOnShow = nil
            //self.endGameInBackground()
            self.canPressPlay = false
            self.playButton.enabled = false
            self.playButton.run(SKAction.fadeAlpha(to: 0.2, duration: 0.25))
            //gamePackScreen.fadeIn()
            self.currentGamePack.helpTextNode.text = "Choose a game"
            self.currentGamePack.alpha = 0
            self.currentGamePack.resetTrayState()
            self.currentGamePack.run(self.fadeIn)
            self.fadeInfoButtonIn()
        })
    }

    fileprivate func addLogo(){

        var logoImages: [HKImage] = []
        var infoGraphicCyclers: [HKImage] = []
        
        //FIXME: inserted session data loading, for lots of sessions this might take some time
        SessionHandler.sessions = SessionHandler.retrieveSessions()

        GamePackScreen.mainScene = self
        for pos in 0..<allPackIDs.count{
            let packID = allPackIDs[pos]
            let packAlias = PackAlias.fetch(packID)
            let packLogo = getDilatedLogoComponent(packAlias, colour: blackColour, heavyFirst: true)
            let packImage = HKImage(image: ImageUtils.getBlankImage(CGSize(width: 10, height: 10), colour: UIColor.clear))

            let packButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: 300, height: 45))
            packButton.isUserInteractionEnabled = false
            packButton.setScaleActionInterval(1...1.05)
            packImage.addChild(packButton)
            packButton.addChild(packLogo)

            let gamePack = getGamePackScreen(packID, onGameTapCode: handleGamesPackGameChoice)
            GamePackScreen.allGamePacks.append(gamePack)

            gamePack.MPCGDGenomeShowingInBackground = MPCGDGenome()
            gamePack.backgroundIsDark = false
            gamePack.logoColour = Colours.getColour(.black)
            if !gamePack.gameIDs.isEmpty{
                gamePack.MPCGDGenomeShowingInBackground = loadedMPCGDGenomes[gamePack.gameIDs[0]]!
                gamePack.backgroundIsDark = isBackgroundDark(gamePack.MPCGDGenomeShowingInBackground)
                if gamePack.backgroundIsDark{
                    gamePack.logoColour = Colours.getColour(.antiqueWhite)
                    changeLabelColour(packLogo, textColour: Colours.getColour(.antiqueWhite))
                }
            }
            gamePack.packLogo = packLogo
            gamePack.id = packID
            gamePack.alias = packAlias
            gamePack.packButton = packButton

            logoImages.append(packImage)
            infoGraphicCyclers.append(gamePack)
            if pos == 0{
                currentGamePack = gamePack
            }
            gamePacks.append(gamePack)

            packButton.onTapStartCode = { [unowned self, unowned gamePack] () -> () in
                gamePack.packLogo.run(self.fadeOut)
                self.gameNameTextBox.heavyFirst = true
                self.gameNameTextBox.placeholder = gamePack.alias
                self.gameNameTextBox.alpha = 0
                self.gameNameTextBox.run(self.fadeIn)
                self.gameNameTextBox.reset()
                self.gameNameTextBox.setColour(self.currentGamePack.logoColour)
                self.textField.text = ""
                self.textFieldStartText = gamePack.alias
                self.textFieldCompletionHandler = { [unowned self, unowned gamePack] (newPackAlias: String) -> Void in
                    if newPackAlias != gamePack.alias {
                        gamePack.packLogo.removeFromParent()
                        gamePack.packLogo = self.getDilatedLogoComponent(newPackAlias, colour: gamePack.logoColour, heavyFirst: true)
                        gamePack.packButton.addChild(gamePack.packLogo)
                        gamePack.alias = newPackAlias
                        PackAlias.save(gamePack.id, alias: newPackAlias)
                    } else {
                        gamePack.packLogo.run(self.fadeIn)
                    }
                }
                self.textField.becomeFirstResponder()
            }
        }

        self.savedGamesStartSlot = loadedMPCGDGenomes.count
        
        var widerLogoSize = logoImages[0].size
        widerLogoSize.width = size.width
        widerLogoSize.height *= 16
        logoImageCycler = HKComponentCycler(hkComponents: logoImages, ids: allPackIDs, size: widerLogoSize, tapToCycle: false, waitAtEnd: TimeInterval(0.1))
        logoImageCycler.setZPositionTo(ZPositionConstants.logoNode)
        logoImageCycler.setPositionTo(CGPoint(x: size.width/2, y: size.height * logoYPos))
        logoImageCycler.imageChosenCode = { [unowned self] () -> () in
            self.loadRightGenome()
            self.currentGamePack = self.gamePacks[self.logoImageCycler.imagePosition]
            
            // Game is showing
            
            if self.currentGamePack.gameIDOnShow != nil{
                self.currentGameName = self.currentGamePack.gameIDOnShow
                self.canPressPlay = true
                self.playButton.enabled = true
            }
            else{
                self.canPressPlay = false
                self.playButton.enabled = true
            }
        }
        logoImageCycler.movementStartedCode = { [unowned self] () -> () in
            self.handleSwipeToGame()
        }
        addChild(logoImageCycler)
        logoImageCycler.pipsNode.position.y += 51

        for p in gamePacks {
            logoImageCycler.liveTapComponents.append((p.packButton, p.packButton.parent! as! HKComponent))
        }

        var widerInfoGraphicsSize = infoGraphicCyclers[0].size
        widerInfoGraphicsSize.width = size.width
        infoGraphicsImageCycler = HKComponentCycler(hkComponents: infoGraphicCyclers, ids: allPackIDs, size: widerInfoGraphicsSize, tapToCycle: false, waitAtEnd: TimeInterval(0.1))
        infoGraphicsImageCycler.setZPositionTo(ZPositionConstants.logoNode)
        
        infoGraphicsImageCycler.pipsNode.isHidden = true
        
        logoImageCycler.twinnedCycler = infoGraphicsImageCycler
        
        infoGraphicsImageCycler.position = CGPoint(x: size.width/2, y: size.height * infoGraphicsY)
        menuNode?.addChild(infoGraphicsImageCycler)
        
        logoImageCycler.selectedID = allPackIDs[0]
        infoGraphicsImageCycler.selectedID = allPackIDs[0]
        infoGraphicsImageCycler.enabled = false
        infoGraphicsImageCycler.name = "dead one"
        
        logoImageCycler.onDragCode = { [unowned self] () -> () in
            self.endGameInBackground()
        }
        
        logoImageCycler.zPosition = 100
        infoGraphicsImageCycler.zPosition = 100
    }
    
    func getInfoCycler(_ id: String) -> (HKImage, HKComponentCycler, StatsScreen?){
        let infoGraphic = HKImage(image: UIImage(named: "\(id)InfoGraphic")!)
        infoGraphic.setScale(0.95)
        infoGraphic.position.y += 10
        let cropNode = SKCropNode()
        cropNode.maskNode = SKSpriteNode(imageNamed: "BlankGraphic")
        let ids = ["stats", "helptext", "infographic"]
        
        let helpText = HKImage(image: UIImage(named: "\(id)Strategy")!)
        infoGraphic.name = "infographic"
        helpText.name = "helptext"
        let statsScreen = StatsScreen(gameID: id, wG: loadedMPCGDGenomes[currentGameName]!, size: infoGraphic.size)
        let components: [HKComponent] = [statsScreen, helpText, infoGraphic]
        let cycler = HKComponentCycler(hkComponents: components, ids: ids, size: infoGraphic.size,  tapToCycle: false, cropNode: cropNode, name: "\(id) cycler")
      //  cycler.liveSubComponents.append((statsScreen.barChart, statsScreen))
        cycler.pipsNode.position.y += infoPipsAddOn
        cycler.pipsNode.setScale(0.9)
        
        let base = HKImage(image: UIImage(named: "BlankGraphic")!)
        base.addChild(cycler)
        infoCyclers[id] = cycler
        cycler.name = "infoCycler: \(id)"
        _ = cycler.cycleToComponent("infographic")
        cycler.allow360 = false

        return (base, cycler, statsScreen)
    }
    
    func handleSwipeToGame(){
        let nextGamePack = gamePacks[logoImageCycler.nextSelectedIndex]
        changeBackground(nextGamePack.MPCGDGenomeShowingInBackground)
        if nextGamePack.gameIDOnShow != nil{
            MPCGDAudioPlayer.handleGenomeChange(MPCGDGenome: nextGamePack.MPCGDGenomeShowingInBackground)
        }
        changeLogoPipsColour(nextGamePack.logoColour)
        changeSettingsColours(nextGamePack.MPCGDGenomeShowingInBackground)
        if nextGamePack.gameIDOnShow != nil {
            self.playButton.run(fadeIn)
            fadeInfoButtonOut()
        } else {
            playButton.run(SKAction.fadeAlpha(to: 0.2, duration: 0.2))
            fadeInfoButtonIn()
        }
    }
    
    func handleBackgroundChange(_ genScreen: GeneratorScreen, hasMoved: Bool){
        let mpcgdGenome = genScreen.liveMPCGDGenome
        if mpcgdGenome.dayNightCycle != oldDayNightChoice ||
            oldBackgroundChoice != mpcgdGenome.backgroundChoice || oldBackgroundShade != mpcgdGenome.backgroundShade{
            let wG = MPCGDGenome()
            wG.backgroundChoice = mpcgdGenome.backgroundChoice
            wG.backgroundShade = (mpcgdGenome.dayNightCycle == 0) ? mpcgdGenome.backgroundShade : 0
            changeBackgroundParticleEmitter(wG, forceIt: oldDayNightChoice != mpcgdGenome.dayNightCycle)
            changeBackground(mpcgdGenome)
            currentGamePack.MPCGDGenomeShowingInBackground = mpcgdGenome
            currentGamePack.backgroundIsDark = isBackgroundDark(mpcgdGenome)
            currentGamePack.logoColour = getTextColourForMPCGDGenome(mpcgdGenome)
            changeLogoColour(currentGamePack.logoColour, logo: currentGamePack.gameLogo)
            changeLogoColour(currentGamePack.logoColour, logo: currentGamePack.packLogo)
            changeLogoPipsColour(currentGamePack.logoColour)
            changeSettingsColours(mpcgdGenome)
            changeInfoColours(mpcgdGenome)
            let newButton = getGamePackComponent(currentGameName, packID: currentGamePack.packID, overrideMPCGDGenome: mpcgdGenome)
            currentGamePack.changeShowingGameNameColour(newButton)
        }
    }
    
    func isBackgroundDark(_ MPCGDGenome: MPCGDGenome) -> Bool{
        if MPCGDGenome.dayNightCycle == 0{
            return (MPCGDGenome.backgroundShade > 4)
        }
        else{
            return false
        }
    }
    
    func setupBackgroundAndMaskNode(){
        backgroundNode.zPosition = -10
        backgroundNode.position = size.centrePoint()
        backgroundNode.size = DeviceType.isIPad ? size : CGSize(width: size.height * 3/4, height: size.height)
        backgroundMaskNode.zPosition = 0
        backgroundMaskNode.position = size.centrePoint()
        backgroundMaskNode.size = backgroundNode.size
        addChild(backgroundMaskNode)
        addChild(backgroundNode)
    }
    
    func getTextColourForMPCGDGenome(_ MPCGDGenome: MPCGDGenome) -> UIColor{
        return isBackgroundDark(MPCGDGenome) && MPCGDGenome.dayNightCycle == 0 ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
    }
    
    func changeInfoColours(_ MPCGDGenome: MPCGDGenome){
        let backgroundIsDark = isBackgroundDark(MPCGDGenome)
        if aboutNode.children.count > 0{
            aboutNode.removeAllChildren()
        }
        let aboutImageName = backgroundIsDark ? "AboutLight" : "AboutDark"
        let aboutImage = UIImage(named: aboutImageName)!
        let image = SKSpriteNode(texture: SKTexture(cgImage: aboutImage.cgImage!))
        image.size = self.size
        image.position = CGPoint(x: scene!.size.width/2, y: scene!.size.height * 0.38)
        image.xScale = DeviceType.isIPad ? 3.0 / 4.0 : 1.0
        aboutNode.addChild(image)
        aboutNode.zPosition = 10
        let colour = getTextColourForMPCGDGenome(MPCGDGenome)
        (aboutButton.children[1] as! SKLabelNode).fontColor = colour
        (creditsButton.children[1] as! SKLabelNode).fontColor = colour
        
        for child in creditNode.children{
            changeLabelColour(child, textColour: colour)
        }
    }
    
    func changeSettingsColours(_ MPCGDGenome: MPCGDGenome){
        let colour = getTextColourForMPCGDGenome(MPCGDGenome)
        let backgroundIsDark = isBackgroundDark(MPCGDGenome)
        changeLabelColour(iPadLabel, textColour: colour)
        changeLabelColour(iPhoneLabel, textColour: colour)
        changeLabelColour(testGameLabel, textColour: colour)
        musicVolumeSlider.changeColours(colour)
        sfxSlider.changeColours(colour)
        let lhTextureName = (backgroundIsDark) ? "LowVolumeIconWhite" : "LowVolumeIcon"
        let rhTextureName = (backgroundIsDark) ? "HighVolumeIconWhite" : "HighVolumeIcon"
        musicVolumeSlider.lhImageNode.texture = SKTexture(imageNamed: lhTextureName)
        musicVolumeSlider.rhImageNode.texture = SKTexture(imageNamed: rhTextureName)
        sfxSlider.lhImageNode.texture = SKTexture(imageNamed: lhTextureName)
        sfxSlider.rhImageNode.texture = SKTexture(imageNamed: rhTextureName)
        let iPhoneImageName = (backgroundIsDark) ? "IPhoneIconLight" : "IPhoneIconDark"
        iPhoneButton.hkImage.imageNode.texture = SKTexture(imageNamed: iPhoneImageName)
        let iPadImageName = (backgroundIsDark) ? "IPadIconLight" : "IPadIconDark"
        iPadButton.hkImage.imageNode.texture = SKTexture(imageNamed: iPadImageName)
        let tickImageName = (backgroundIsDark) ? "DeviceTickLight" : "DeviceTickDark"
        deviceTickNode.texture = SKTexture(imageNamed: tickImageName)
    }

    class BackgroundTextureShadeCache {
        static let maxShades = 9
        static var paused = false

        struct Entry {
            let choice: Int
            let texture: SKTexture?
            init(_ choice: Int, _ texture: SKTexture?) {
                self.choice = choice
                self.texture = texture
            }
        }
        
        static var entries: [Entry] = Array<Entry>(repeatElement(Entry(-1, nil), count: maxShades))
        static var pending: [Int] = []
        static var requests: Int = 0

        static func update(MPCGDGenome wg: MPCGDGenome) {
            guard paused == false else { return }
            
            let choice = wg.backgroundChoice
            let cycle = wg.dayNightCycle > 0
            let shade = cycle ? 0 : wg.backgroundShade
            
            pending.removeAll()
            for i in 0..<maxShades {
                if !cycle && i != shade {
                    continue
                }
                if entries[i].choice != choice {
                    pending.insert(i, at: 0)
                }
            }
            
            if pending.count > 0 && requests < 1 {
                //print("Choice #\(choice) needs to fetch background shades: \(pending)")

                let shade = pending.popLast()!
                entries[shade] = Entry(choice, nil)
                requests += 1

                BackgroundTextureCache.request(choice, shade, completion: { (texture: SKTexture?) in
                    DispatchQueue.main.async {
                        //print("Got choice=\(choice), shade=\(shade)")
                        if wg.backgroundChoice == choice {
                            entries[shade] = Entry(choice, texture)
                        }
                        requests -= 1
                    }
                })
            }
        }
    }

    func restartBackgroundCycle(_ gameTimeLeft: CGFloat, nextShadePos: Int, resetBackground: Bool){
        backgroundNode.removeAllActions()
        backgroundMaskNode.removeAllActions()
        let MPCGDGenome = loadedMPCGDGenomes[currentGameName]!

        if resetBackground{
            changeBackground(MPCGDGenome, forceIt: true)
        }
        if MPCGDGenome.dayNightCycle == 0{
            return
        }

        let backgrounds = MPCGDGenome.dayNightCycle == 1 ? [1, 2, 3, 4, 5, 6, 7, 8] : [1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        let numChanges = CGFloat(backgrounds.count - nextShadePos + 1)
        let durationOfEachBackground = gameTimeLeft/numChanges
        let fadeDuration = min(1, durationOfEachBackground/2)
        let preFadeTime = TimeInterval(durationOfEachBackground - fadeDuration)
        
        let imageStem = "\(MainScene.backgroundIDs[MPCGDGenome.backgroundChoice])"
        currentParticleEmitterBackgroundNum = MPCGDGenome.backgroundChoice
        currentParticleEmitterBackgroundShade = nextShadePos - 1
        if nextShadePos < backgrounds.count{
            cycleBackgroundShade = 0
            cycleBackgroundShadePos = 0
            cycleBackground(backgrounds, imageStem: imageStem, nextShadePos: nextShadePos, preFadeTime: preFadeTime, fadeDuration: TimeInterval(fadeDuration))
        }
    }

    func cycleBackground(_ backgrounds: [Int], imageStem: String, nextShadePos: Int, preFadeTime: TimeInterval, fadeDuration: TimeInterval){
        if nextShadePos < backgrounds.count{
            let nextBackgroundIndex = backgrounds[nextShadePos]
            let f = SKAction.fadeOut(withDuration: fadeDuration)
            let wG = MPCGDGenome()
            wG.backgroundShade = backgrounds[nextShadePos]
            wG.backgroundChoice = loadedMPCGDGenomes[currentGameName]!.backgroundChoice
            if fadeDuration > 0.2{
                backgroundNode.run(SKAction.wait(forDuration: preFadeTime), completion: {
                    self.backgroundMaskNode.texture = self.backgroundNode.texture
                    if let t = BackgroundTextureShadeCache.entries[wG.backgroundShade].texture {
                        self.backgroundNode.texture = t
                    }
                    self.backgroundMaskNode.alpha = 1
                    self.backgroundMaskNode.run(f, completion: {
                        self.cycleBackground(backgrounds, imageStem: imageStem, nextShadePos: nextShadePos + 1, preFadeTime: preFadeTime, fadeDuration: fadeDuration)
                        self.cycleBackgroundShade = backgrounds[nextShadePos]
                        self.cycleBackgroundShadePos = nextShadePos
                    })
                    
                    self.fascinator.scoreColour = backgrounds[nextShadePos] > 4 ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
                    
                    self.changeLabelColour(self.fascinator.timeDisplay, textColour: self.fascinator.scoreColour)
                    self.changeLabelColour(self.fascinator.scoreDisplay, textColour: self.fascinator.scoreColour)
                    self.changeLabelColour(self.fascinator.scoreDisplay.children[0] as! SKLabelNode, textColour: self.fascinator.scoreColour)
                    self.changeLabelColour(self.fascinator.livesDisplay, textColour: self.fascinator.scoreColour)
                    self.changeBackgroundParticleEmitter(wG)
                })
            }
            else{
                backgroundNode.run(SKAction.wait(forDuration: preFadeTime + fadeDuration), completion: {
                    if let t = BackgroundTextureShadeCache.entries[nextBackgroundIndex].texture {
                        self.backgroundNode.texture = t
                    }
                    self.cycleBackground(backgrounds, imageStem: imageStem, nextShadePos: nextShadePos + 1, preFadeTime: preFadeTime, fadeDuration: fadeDuration)
                    self.changeBackgroundParticleEmitter(wG)
                })
            }
        }
    }

    func loadBackgroundForSplashScreenFade(_ MPCGDGenome: MPCGDGenome) {
        backgroundNode.removeAllActions()
        backgroundMaskNode.removeAllActions()
        oldBackgroundChoice = MPCGDGenome.backgroundChoice
        oldBackgroundShade = MPCGDGenome.backgroundShade
        backgroundMaskNode.texture = backgroundNode.texture
        backgroundMaskNode.alpha = 1
        let choice = MPCGDGenome.backgroundChoice
        let shade = MPCGDGenome.dayNightCycle > 0 ? 0 : MPCGDGenome.backgroundShade
        
        BackgroundTextureCache.request(choice, shade, completion: { (texture: SKTexture?) in
            self.backgroundNode.texture = texture
        })
        let f = SKAction.fadeOut(withDuration: 0.5)
        self.backgroundMaskNode.run(f)
//        self.changeBackgroundParticleEmitter(MPCGDGenome)
    }
    
    func changeBackground(_ MPCGDGenome: MPCGDGenome, forceIt: Bool = false){
        if forceIt || MPCGDGenome.dayNightCycle != oldDayNightChoice || MPCGDGenome.backgroundChoice != oldBackgroundChoice || MPCGDGenome.backgroundShade != oldBackgroundShade{
            backgroundNode.removeAllActions()
            backgroundMaskNode.removeAllActions()
            oldBackgroundChoice = MPCGDGenome.backgroundChoice
            oldBackgroundShade = MPCGDGenome.backgroundShade
            oldDayNightChoice = MPCGDGenome.dayNightCycle
            backgroundMaskNode.texture = backgroundNode.texture
            backgroundMaskNode.alpha = 1

            let choice = MPCGDGenome.backgroundChoice
            let shade = MPCGDGenome.dayNightCycle > 0 ? 0 : MPCGDGenome.backgroundShade
            BackgroundTextureShadeCache.paused = true

            /*
            var debugBackgroundName: String
            if MPCGDGenome.dayNightCycle > 0{
                debugBackgroundName = "\(MainScene.backgroundIDs[MPCGDGenome.backgroundChoice])0"
            } else {
                debugBackgroundName = "\(MainScene.backgroundIDs[MPCGDGenome.backgroundChoice])\(MPCGDGenome.backgroundShade)"
            }
 */

            BackgroundTextureCache.request(choice, shade, completion: { (texture: SKTexture?) in
                DispatchQueue.main.async {
                    //print(">>> SWITCHED TO BACKGROUND: choice=\(choice), shade=\(shade), \(debugBackgroundName)")
                    self.backgroundNode.texture = texture
                    let f = SKAction.fadeOut(withDuration: 0.5)
                    self.backgroundMaskNode.run(f)
                    self.changeBackgroundParticleEmitter(MPCGDGenome)
                    BackgroundTextureShadeCache.paused = false
                }
            })
        }
    }
    
    func changeLogoColour(_ newColour: UIColor, logo: HKComponent){
        changeLabelColour(logo, textColour: newColour)
    }
    
    func changeLogoPipsColour(_ newColour: UIColor){
        logoImageCycler.animatePipColourChange(newColour.withAlphaComponent(0.8), unselectedColour: newColour.withAlphaComponent(0.2), duration: 0.5)
    }
    
    /*
    func changeGenScreenHelpTextColour(_ newColour: UIColor, genScreen: GeneratorScreen){
        changeLabelColour(genScreen.helpTextNode, textColour: newColour)
    }
 */
    
    func changeInfoGraphicsPipsColour(_ newColour: UIColor, generatorScreenMoved: Bool){
        /*
        let cycler = infoCyclers[currentGameName]!
        cycler.animatePipColourChange(newColour.withAlphaComponent(0.8), unselectedColour: newColour.withAlphaComponent(0.2), duration: 0.5, generatorScreenMoved: generatorScreenMoved)
 */
    }
    
    func changeLabelColour(_ node: SKNode, textColour: UIColor){
        if node is SKLabelNode{
            changeColourForLabelNode(node as! SKLabelNode, toColour: textColour, withDuration: 0.5)
        }
        else{
            for c in node.children{
                changeLabelColour(c, textColour: textColour)
            }
        }
    }
    
    /*
    func changeLabelColourImmediately(node: SKNode, textColour: UIColor){
        if node is SKLabelNode{
            (node as! SKLabelNode).fontColor = textColour
        }
        else{
            for c in node.children{
                changeLabelColourImmediately(c, textColour: textColour)
            }
        }
    }
 */
    
    func changeColourForLabelNode(_ labelNode: SKLabelNode, toColour: UIColor, withDuration: TimeInterval) {
        
        if labelNode.fontColor == toColour{
            return
        }
        
        let (r1, g1, b1, _) = labelNode.fontColor!.getRGBA()
        let (r2, g2, b2, _) = toColour.getRGBA()

        labelNode.run(SKAction.customAction(withDuration: withDuration, actionBlock: {
            node, elapsedTime in
            let frac = CGFloat(elapsedTime / (CGFloat(withDuration)))
            let red = r1 + ((r2 - r1) * frac)
            let green = g1 + ((g2 - g1) * frac)
            let blue = b1 + ((b2 - b1) * frac)
            labelNode.fontColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        }))
    }
    
    override func touchesBegan(_ touchPoint: CGPoint) {
        if fascinator != nil && fascinator.wantsTouchesFromUser() {
            // Pass the touch to the fascinator
            fascinator.touchesBegan(touchPoint)
        }
    }
    
    override func touchesDragged(_ touchPoint: CGPoint, clampedDragVector: CGVector, dragVector: CGVector) {
        if fascinator != nil && fascinator.wantsTouchesFromUser() {
            // Pass the touch to the fascinator
            fascinator.touchesDragged(touchPoint, clampedDragVector: clampedDragVector, dragVector: dragVector)
        }
    }
    
    override func touchesEnded(_ touchPoint: CGPoint) {
        if fascinator != nil && fascinator.wantsTouchesFromUser() {
            fascinator.touchesEnded(touchPoint)
        }
    }
    
    func handleMusicVolumeChange(){
        let v = clamp(value: Float(musicVolumeSlider.value), lower: 0.0, upper: 1.0)
        MPCGDAudio.setMasterStreamVolume(to: v, duration: 0.2)
    }
    
    func handleSFXVolumeChange(){
        MPCGDAudio.masterSoundVolume = clamp(value: sfxSlider.value, lower: 0.0, upper: 1.0)
        MPCGDAudio.playSound(path: MPCGDSounds.bounce)
    }
    
    func handlePlayTap(){
        if canPressPlay{
            restartAfterTutorial(true)
        }
    }
    
    func startOver(){
        saveSession(true, gameEndDetails: fascinator.getGameEndDetails())
        menuNode?.run(self.fadeOut)
        pauseNode.run(fadeOut)
        logoImageCycler.run(self.fadeOut, completion: {
            self.showLetterBox({
                self.startGame(false)
            })
        })
    }
    
    func keepGoing(){
        view!.isPaused = false
        fascinator.artImageNode.run(fadeIn)
        fascinatorNode.run(fadeIn)
        pauseNode.run(fadeOut)
        self.menuNode?.run(self.fadeOut, completion: {
            self.showLetterBox({
                self.fascinator.releaseFromPause()
                self.state = .playing
                self.restartBackgroundCycle(CGFloat(self.fascinator.timeLeft), nextShadePos: self.cycleBackgroundShadePos + 1, resetBackground: false)
            })
            self.menuNode?.isHidden = true
            self.menuNode?.alpha = 1
            self.fascinator.timeDisplay.run(self.fadeIn)
            let wG = self.loadedMPCGDGenomes[self.currentGameName]!
            if self.fascinator.positiveScoresPossible{
                self.fascinator.scoreDisplay.run(self.fadeIn)
            }
            if wG.numLives > 0{
                self.fascinator.livesDisplay.run(self.fadeIn)
            }
        })
        self.logoImageCycler.run(self.fadeOut)
    }

    func saveSession(_ quit: Bool, gameEndDetails: Fascinator.GameEndDetails) {
        let wasWon = (quit == true) ? false : gameEndDetails.gameIsWon
        
        let session = Session(date: Date(), level: currentGameName, user: GameViewController.user.userID, elapsedTime: gameEndDetails.currentTimeElapsed, score: fascinator.score, quit: quit, wasWon: wasWon!)
        
        SessionHandler.saveSession(session)
        SessionHandler.sessions.append(session)
        
        let statsScreen = infoCyclers[currentGameName]?.hkComponents[0] as! StatsScreen
        statsScreen.refresh(gameID: currentGameName, wG: loadedMPCGDGenomes[currentGameName]!)
        
        if !quit{
            currentGamePack.handlePotentialBestChange(gameID: currentGameName)
        }
    }
    
    func handleSettingsTap(){
        self.view!.isPaused = false
        //self.infoGraphicsImageCycler.hidden = true
        settingsNode.run(fadeIn)
        self.infoGraphicsImageCycler.run(fadeOut, completion: {
            HKDisableUserInteractions = false
            self.infoGraphicsImageCycler.isHidden = true
            
        })
        logoImageCycler.enabled = false
        logoImageCycler.run(fadeOut)
        settingsButton.run(fadeOut)
        self.state = .settings
    }
    
    func handleBackTap() {
        self.tapAt(CGPoint.zero)
    }
    
    func handleInfoTap(){
        self.view!.isPaused = false
        infoNode.alpha = 0
        aboutNode!.alpha = 0
        creditNode!.alpha = 0
        (aboutButton.children[1] as! SKLabelNode).fontName = "Dolce Vita Heavy"
        (creditsButton.children[1] as! SKLabelNode).fontName = "Dolce Vita Light"
        aboutNode.run(fadeIn)
        infoNode.run(fadeIn)
        menuNode?.run(fadeOut, completion: {
            self.infoGraphicsImageCycler.isHidden = true
            HKDisableUserInteractions = false
        })
        settingsNode.run(fadeOut)
        logoImageCycler.enabled = false
        logoImageCycler.run(fadeOut)
        self.state = .about
    }
    
    func handleQuitButtonTapped(){
        endGameInBackground()
    }
    
    func endGameInBackground(){
        autoreleasepool{
        if state == .paused{
            self.view!.isPaused = false
            self.settingsButton.alpha = 0
     //       self.settingsButton.isHidden = false
            self.settingsButton.run(fadeIn)
            self.infoButton.alpha = 0
            self.infoButton.isHidden = false
            self.infoButton.run(SKAction.fadeAlpha(to: self.infoButtonMinAlpha, duration: 0.4))
            self.playButton.alpha = 0
            self.playButton.isHidden = false
            self.playButton.run(fadeIn)
            for button in [keepGoingButton, startOverButton, quitThisButton]{
                button?.run(fadeOut, completion: {
                    button?.alpha = 1
                    button?.isHidden = true
                })
            }
            self.logoImageCycler.enabled = true
            self.logoImageCycler.pipsNode.isHidden = false
            self.logoImageCycler.pipsNode.alpha = 0
            self.logoImageCycler.pipsNode.run(self.fadeIn)
            state = .menu
            saveSession(true, gameEndDetails: fascinator.getGameEndDetails())
            infoCyclers[currentGameName]?.enabled = true
            fascinatorNode.run(fadeOut, completion: {
                self.fascinator.onQuitMemoryCleanup()
            })
            pauseNode.run(fadeOut)
            
            backgroundNode.removeAllActions()
            backgroundMaskNode.removeAllActions()
            

            let MPCGDGenome = loadedMPCGDGenomes[currentGameName]!
            changeBackground(MPCGDGenome, forceIt: true)
            changeBackgroundParticleEmitter(MPCGDGenome, forceIt: true)
            currentGamePack.logoColour = getTextColourForMPCGDGenome(MPCGDGenome)
            
            changeLogoColour(currentGamePack.logoColour, logo: currentGamePack.gameLogo)
            changeLogoColour(currentGamePack.logoColour, logo: currentGamePack.packLogo)
            changeLogoPipsColour(currentGamePack.logoColour)
            
     //       changeGenScreenHelpTextColour(currentGamePack.logoColour, genScreen: infoCyclers[currentGameName]?.selectedHKComponent as! GeneratorScreen)
     //       changeInfoGraphicsPipsColour(currentGamePack.logoColour, generatorScreenMoved: false)
        }
        } // autoreleasepool
    }
    
    func loadRightGenome(){
        autoreleasepool {
            let MPCGDGenome = loadedMPCGDGenomes[currentGameName]
            fascinator.chromosome = GameplayChromosome(stringRepresentation: LISGenomeString)
            MPCGDGenome?.applyModifications(fascinator, screenSize: size)
            fascinator.playtester = nil
        }
    }
    
    func showTutorial(_ tutorialNum: Int){
        if tutorialNode != nil{
            isAnimatingTutorial = true
            tutorialNode.run(flyIn, completion: {
                self.tutorialNode.removeFromParent()
                self.addTutorialNode(tutorialNum)
                self.isAnimatingTutorial = false
            })
        }
        else{
            addTutorialNode(tutorialNum)
        }
    }
    
    func addTutorialNode(_ tutorialNum: Int){
        isAnimatingTutorial = true
        fascinator.artImageNode.alpha = 0
        for ball in fascinator.balls{
            ball.node.alpha = 0
            ball.unstickFromPlace()
        }
        fascinator.timeDisplay.alpha = 0
        fascinator.scoreDisplay.alpha = 0
        fascinator.livesDisplay.alpha = 0
        menuNode?.run(fadeOut)
  //      backGround.runAction(fadeOut)
        if tutorialNode != nil{
            tutorialNode.removeFromParent()
        }
        if hideTutorialNode != nil{
            hideTutorialNode.removeFromParent()
        }
        state = .tutorial
        let yPositions = [100, 3, -80]
        showingTutorial = tutorialNum
        let tutorialInfoNode = HKImage(image: UIImage(named: "\(currentGameName)Strategy")!)
        let cropNode = SKCropNode()
        let tutSize = CGSize(width: tutorialInfoNode.imageNode.size.width, height: tutorialInfoNode.imageNode.size.height * 0.3)
        cropNode.maskNode = SKSpriteNode(texture: SKTexture(cgImage: ImageUtils.getBlankImage(tutSize, colour: UIColor.red).cgImage!))
        tutorialInfoNode.position = CGPoint(x: 0, y: CGFloat(yPositions[tutorialNum]))
        cropNode.addChild(tutorialInfoNode)
        tutorialNode = SKNode()
        tutorialNode.addChild(cropNode)
        addChild(tutorialNode)
        tutorialNode.alpha = (tutorialNum == 0 ? 0 : 1)
        tutorialNode.position = CGPoint(x: (tutorialNum == 0 ? scene!.size.width/2 : scene!.size.width * 1.5), y: scene!.size.height/2)
        tutorialNode.run(tutorialNum == 0 ? fadeIn : flyIn, completion:{
                self.isAnimatingTutorial = false
            })
        
        if tutorialNum == 2{
            let font = UIFontCache(name: "HelveticaNeue-Thin", size: 25)
            hideTutorialNode = SKLabelNode(font, Colours.getColour(.black), text: "◎ Hide hints forever")
            addChild(hideTutorialNode)
            hideTutorialNode.position = CGPoint(x: scene!.size.width/2, y: 180)
            hideTutorialNode.alpha = 0
            hideTutorialNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), fadeIn]))
        }
    }

    func restartAfterTutorial(_ newGame: Bool){
        settingsNode.run(fadeOut)
        scoreNode?.run(fadeOut, completion: {
            self.scoreNode.removeFromParent()
            self.scoreNode = nil
        })
        showLetterBox({
            self.startGame(newGame)
        })
    }
    
    func addLetterBoxNodes(){
        if DeviceType.isIPhone{
            let boxHeight = (size.height - (size.width * (4/3)))/2
            topLetterBoxNode = SKSpriteNode(color: Colours.getColour(.black), size: CGSize(width: size.width, height: boxHeight))
            bottomLetterBoxNode = SKSpriteNode(color: Colours.getColour(.black), size: CGSize(width: size.width, height: boxHeight))
            topLetterBoxNode.position = CGPoint(x: size.width/2, y: size.height + boxHeight/2)
            bottomLetterBoxNode.position = CGPoint(x: size.width/2, y: -boxHeight/2)
            topLetterBoxNode.zPosition = 10000
            bottomLetterBoxNode.zPosition = 10000
            addChild(topLetterBoxNode)
            addChild(bottomLetterBoxNode)
        }
        else{
            
        }
    }
    
    func hideLetterBox(_ completion: @escaping (() -> ())){
        if DeviceType.isIPhone && DeviceType.simulationIs == Device.iPad{
            topLetterBoxNode.run(SKAction.move(by: CGVector(dx: 0, dy: topLetterBoxNode.size.height), duration: 0.3))
            bottomLetterBoxNode.run(SKAction.move(by: CGVector(dx: 0, dy: -topLetterBoxNode.size.height), duration: 0.3))
            backgroundNode.run(SKAction.scale(to: 1, duration: 0.3), completion: completion)
            backgroundMaskNode.setScale(1)
            backgroundParticleEmitter.run(SKAction.moveTo(y: backgroundParticleEmitter.position.y - bottomLetterBoxNode.size.height, duration: 0.3))
        }
        else if DeviceType.isIPad && DeviceType.simulationIs == Device.iPhone{
            // TO DO
        }
        else{
            completion()
        }

    }
    
    func showLetterBox(_ completion: @escaping () -> ()){
        if DeviceType.isIPhone && DeviceType.simulationIs == .iPad{
            topLetterBoxNode.run(SKAction.move(by: CGVector(dx: 0, dy: -topLetterBoxNode.size.height), duration: 0.3))
            bottomLetterBoxNode.run(SKAction.move(by: CGVector(dx: 0, dy: topLetterBoxNode.size.height), duration: 0.3))
            let scale = size.width/backgroundNode.width
            backgroundNode.run(SKAction.scale(to: scale, duration: 0.3), completion: completion)
            backgroundMaskNode.setScale(scale)
            backgroundParticleEmitter.run(SKAction.moveTo(y: backgroundParticleEmitter.position.y + bottomLetterBoxNode.size.height, duration: 0.3))
        }
        else if DeviceType.isIPad && DeviceType.simulationIs == Device.iPhone{
            // TO DO
        }
        else{
            completion()
        }
    }
    
    func startGame(_ newGame: Bool){
        if !isRestarting{
            
            isRestarting = true
            loadRightGenome()

            fascinatorNode.alpha = 0
            fascinatorNode.run(fadeIn)
            fascinator.artImageNode.run(fadeIn)
            for ball in fascinator.balls{
                ball.node.alpha = 1
            }
            let wG = loadedMPCGDGenomes[currentGameName]!
            fascinator.timeDisplay.alpha = 1
            if wG.pointsToWin > 0{
                fascinator.scoreDisplay.alpha = 1
            }
            if wG.numLives > 0{
                fascinator.livesDisplay.alpha = 1
            }
            fascinator.fascinatorSKNode.isHidden = false
            
            applyPreDeviceSimulationModifications(fascinator)
            fascinator.restart()
            applyPostDeviceSimulationModifications(fascinator)
            restartBackgroundCycle(fascinator.chromosome.duration.value, nextShadePos: 0, resetBackground: true)
            
            view!.isPaused = false
            logoImageCycler.run(fadeOut)
            
            if wIconNode != nil{
                wIconNode.removeAllActions()
            }

            menuNode?.run(fadeOut, completion: {
                self.menuNode?.isHidden = true
                self.menuNode?.alpha = 1
                self.playButton.isHidden = true
                self.infoButton.isHidden = true
       //         self.settingsButton.isHidden = true
                self.isRestarting = false
                _ = self.infoCyclers[self.currentGameName]?.removeHKComponentWithID("score")
                self.state = .playing
            })
            fascinator.releaseFromPause()
            
            if numTimesTwoFingersShown < 3{
                showAlertNode(imageName: "SwipeDown", waitForDuration: 1)
                numTimesTwoFingersShown += 1
            }
        }
        tapsPerSession = 0
    }
    
    func applyPreDeviceSimulationModifications(_ fascinator: Fascinator){
        if DeviceType.isIPhone && DeviceType.simulationIs == .iPad{
            let boxHeight = (size.height - size.width * (4/3))/2
            fascinator.deviceSimulationYOffset = boxHeight
        }
        else if DeviceType.isIPad && DeviceType.simulationIs == .iPhone{
            let boxWidth = (size.width - size.height * (9/16))/2
            fascinator.deviceSimulationXOffset = boxWidth
        }
        else{
            fascinator.deviceSimulationXOffset = 0
            fascinator.deviceSimulationYOffset = 0
        }
    }
    
    func applyPostDeviceSimulationModifications(_ fascinator: Fascinator){
        if DeviceType.isIPhone && DeviceType.simulationIs == .iPad{
            let boxHeight = (size.height - size.width * (4/3))/2
            fascinator.timeDisplay.position.y = size.height - 75
            fascinator.scoreDisplay.position.y = size.height - 75
            fascinator.livesDisplay.position.y = size.height - 75
            for pos in 0..<fascinator.friendSpawnLocations.count{
                fascinator.friendSpawnLocations[pos].y += boxHeight
            }
            for pos in 0..<fascinator.foeSpawnLocations.count{
                fascinator.foeSpawnLocations[pos].y += boxHeight
            }
        }
        else if DeviceType.isIPad && DeviceType.simulationIs == .iPhone{
            let boxWidth = (size.width - size.height * (9/16))/2
            for pos in 0..<fascinator.friendSpawnLocations.count{
                fascinator.friendSpawnLocations[pos].x += boxWidth
            }
            for pos in 0..<fascinator.foeSpawnLocations.count{
                fascinator.foeSpawnLocations[pos].x += boxWidth
            }
            fascinator.timeDisplay.position.x += boxWidth
            fascinator.scoreDisplay.position.x += boxWidth
            fascinator.livesDisplay.position.x += boxWidth
        }
        else{
            fascinator.deviceSimulationXOffset = 0
            fascinator.deviceSimulationYOffset = 0
            fascinator.timeDisplay.position.y = size.height - 5
            fascinator.scoreDisplay.position.y = size.height - 5
            fascinator.livesDisplay.position.y = size.height - 5
        }
    }
    
    override func tapAt(_ touchPoint: CGPoint) {
        
        if state == .opening{

        }
        else if state == .tutorial && !isAnimatingTutorial{
            if showingTutorial == 2{
                isAnimatingTutorial = true
                if touchPoint.y > 160 && touchPoint.y < 200{
                    hideTutorialNode.text = "◉ Hide hints forever"
                    UserHandler.hideTutorial(currentGameName)
                }
                tutorialNode.run(fadeOut, completion: {
                    self.isAnimatingTutorial = false
                })
                hideTutorialNode.removeAllActions()
                hideTutorialNode.run(fadeOut)
                restartAfterTutorial(false)
                tutorialNode = nil
                hideTutorialNode = nil
            }
            else{
                showTutorial(showingTutorial + 1)
            }
        }
        else if state == .about || state == .credits || state == .settings{
            aboutNode?.run(fadeOut)
            creditNode?.run(fadeOut)
            infoNode.run(fadeOut)
            settingsNode?.run(fadeOut)
            menuNode!.run(fadeIn)
            logoImageCycler.run(fadeIn)
            logoImageCycler.enabled = true
            infoGraphicsImageCycler.isHidden = false
            showInfoCycler(false)
            state = .menu
            settingsButton.run(fadeIn)
        }
        else if state == .playing{
            if fascinator != nil && !fascinator.gameIsOver && fascinator.wantsTouchesFromUser() {
               // fascinator.tapAt(touchPoint)
                tapsPerSession += 1
            }
        }
    }

    var audioDeltaTime: CFTimeInterval = 0
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime

        audioDeltaTime = deltaTime
        
        if BaseScene.gyroEnabled && BaseScene.motionManager != nil {
            let gyroData = BaseScene.motionManager.gyroData
            if gyroData != nil {
                handleGyroMotion(gyroData!)
            }
        }

        if fascinator != nil {
            fascinator.tick(currentTime)
        }
    }
    
    override func didFinishUpdate() {
        MPCGDAudio.tick(audioDeltaTime)
        if self.currentGamePack != nil && self.currentGamePack.gameIDOnShow != nil {
            BackgroundTextureShadeCache.update(MPCGDGenome: self.currentGamePack.MPCGDGenomeShowingInBackground)
        }
    }

    func audioConfigurationChanged() {
        if fascinator != nil {
            fascinator.audioConfigurationChanged()
        }
    }
    
    override func onPauseGesture() {
        // Ignore trying to pause before a game is loaded or not in a valid play state!
        if fascinator == nil || state != .playing {
           return
        }
        if !fascinator.gameIsOver && !fascinator.isPaused && !ignoreUser{
            if !(view?.isPaused)! {
                fascinator.pauseImmediately()
                menuNode?.isHidden = false
                keepGoingButton.isHidden = false
                startOverButton.isHidden = false
                quitThisButton.isHidden = false
                state = .paused
                menuNode?.alpha = 0
                fascinator.scoreDisplay.run(fadeOut)
                fascinator.timeDisplay.run(fadeOut)
                fascinator.livesDisplay.run(fadeOut)
                menuNode?.run(fadeIn)
                
                var logoColour = currentGamePack.logoColour
                if loadedMPCGDGenomes[currentGameName]!.dayNightCycle > 0{
                    logoColour = cycleBackgroundShade > 4 ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
                }
                changeLabelColour(logoImageCycler.selectedHKComponent, textColour: logoColour!)
                
      //          changeLogoPipsColour(logoColour!)
                logoImageCycler.pipsNode.isHidden = true
                
      //          changeInfoGraphicsPipsColour(logoColour!, generatorScreenMoved: false)
                
                logoImageCycler.run(fadeIn)
                pauseNode.alpha = 0
                pauseNode.fontColor = logoColour
                pauseNode.run(fadeIn)
                fascinatorNode.run(SKAction.fadeAlpha(to: 0.2, duration: 0.5))
                fascinator.artImageNode.run(fadeOut)
                logoImageCycler.enabled = true
       //         logoImageCycler.pipsNode.isHidden = false
                showInfoCycler()
       //         changeGenScreenHelpTextColour(logoColour!, genScreen: infoCyclers[currentGameName]?.selectedHKComponent as! GeneratorScreen)
                hideLetterBox({
                    self.run(SKAction.wait(forDuration: 0.1), completion: {
                        self.backgroundNode.removeAllActions()
                        self.backgroundMaskNode.removeAllActions()
                        self.backgroundMaskNode.run(SKAction.fadeOut(withDuration: 0.2))
                    })
                })

            } else {
                fascinator.releaseFromPause()
            }
        }
    }

    func addTextFieldAndKeyboard() {
        // Create our textfield
        textField = UITextField(frame: CGRect(x: 20 + size.width, y: 50, width: 280, height: 40))
        textField.placeholder = "Game Name"
        textField.textColor = UIColor.black
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        //textField.keyboardType = UIKeyboardType.NamePhonePad
        textField.keyboardType = UIKeyboardType.alphabet
        textField.font = dolceVitaFont
        textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textField.textAlignment = .center
        
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextFieldViewMode.never
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        textField.delegate = self
        // To make it invisible, simply set alpha to 0. You should then be able to
        // add the extra UITextFieldDelegate handlers to catch tap events etc, extract
        // and display the string as you see fit.
        textField.alpha = 0.0
        
        // Activate our textField
        self.view!.addSubview(textField)
        // Call 'becomeFirstResponder' to make iOS open keyboard and make textfield active
        
        gameNameTextBox = HKTextBox(size: CGSize(width: 300, height: 50), placeholder: "NAME YOUR GAME", font: dolceVitaLightFont, backgroundColour: Colours.getColour(.steelBlue).withAlphaComponent(0.2))
        gameNameTextBox.position = CGPoint(x: size.width/2, y: size.height * logoYPos)
        gameNameTextBox.alpha = 0
        gameNameTextBox.alternativeLabelGenerator = getLiveNameComponent
        gameNameTextBox.textNode.alpha = 0.3
        gameNameTextBox.zPosition = 100
        addChild(gameNameTextBox)
        
        // HACK: Eat the first-time overhead and cost for spawning the keyboard now while nothings going on
        // Looks to drop showSavingKeyboard's [textFiled becomeFirstResponder] from 140ms to around 68ms
        textField.becomeFirstResponder()
        textField.resignFirstResponder()
    }
    
    // Events we're interested in. See UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
 //       print("TextField did begin editing method called")
        HKDisableUserInteractions = true
        let doAction = {
            if self.textField.text?.count == 0 && self.gameNameTextBox.placeholder == "" && self.gameNameTextBox.textNode.text?.count > 0 {
                self.gameNameTextBox.textNode.text = ""
                self.gameNameTextBox.respondToKeyPress("")
            }
        }
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run(doAction), SKAction.wait(forDuration: 0.1)])), withKey: "textFieldCrapola")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
 //       print("TextField did end editing method called")
        self.removeAction(forKey: "textFieldCrapola")
        HKDisableUserInteractions = false
        textField.alpha = 0
        textField.resignFirstResponder()
        // Trim any trailing white-space
        var gameName = gameNameTextBox.textNode.text!
        if gameName.last == " " {
            gameName = gameName.trimmingCharacters(in: CharacterSet.whitespaces)
            gameNameTextBox.respondToKeyPress("")
        }

        if textFieldCompletionHandler != nil {
            // Ughh....
            if gameName == "" || gameName == textFieldStartText || gameName == "NAME YOUR GAME" {
                textFieldCompletionHandler(textFieldStartText)
            }
            else {
                textFieldCompletionHandler(gameName)
            }
            textFieldCompletionHandler = nil
        }

        logoImageCycler.hkComponents[logoImageCycler.hkComponents.count - 1].run(fadeIn)
        logoImageCycler.pipsNode.run(fadeIn)
        self.gameNameTextBox.stopCursor()
        self.gameNameTextBox.run(self.fadeOut)
        //showInfoCycler()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
  //      print("TextField should end editing method called")
        return true;
    }
    
    var validKeyboardCharacters: CharacterSet! = nil
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
  //      print(self.textField.text)

        if validKeyboardCharacters == nil {
            validKeyboardCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890&! ").inverted
        }
        if string.rangeOfCharacter(from: validKeyboardCharacters) != nil {
            return false
        }
        gameNameTextBox.respondToKeyPress(string)
        return true;
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
  //      print("TextField should clear method called")
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
   //     print("TextField should return method called")
        textField.resignFirstResponder();
        // For this test, we're done with the UITextField so remove/delete from view
        //textField.removeFromSuperview()
        return true;
    }
    
    func handleGamesPackGameChoice(_ gameID: String, gamePackScreen: GamePackScreen){
        autoreleasepool {
            loadUpGame(gameID, gamePackScreen: gamePackScreen, immediate: false)
        }
    }

    func loadUpGame(_ gameID: String, gamePackScreen: GamePackScreen, immediate: Bool){
        fadeInfoButtonOut()
        currentGameName = gameID
        infoGraphicsImageCycler.selectedHKComponent.run(SKAction.fadeOut(withDuration: 0.2))
        let ind = infoGraphicsImageCycler.ids.index(of: self.infoGraphicsImageCycler.selectedID)!
        _ = infoGraphicsImageCycler.removeHKComponentWithID(self.infoGraphicsImageCycler.selectedID)
        
        let gameName = gameID.components(separatedBy: "@")[0]
        let MPCGDGenome = loadedMPCGDGenomes[gameID]!
        let isLocked = isLockedHash[gameID]!
        gamePackScreen.MPCGDGenomeShowingInBackground = MPCGDGenome
        gamePackScreen.backgroundIsDark = isBackgroundDark(MPCGDGenome)
        gamePackScreen.logoColour = gamePackScreen.backgroundIsDark ? whiteColour : blackColour
        let gameLogo = getLogoComponent(gameID: gameID, gameName: gameName, colour: gamePackScreen.logoColour, fontSize: 45)
        gamePackScreen.gameLogo = gameLogo
        //gamePackScreen.helpTextNode.fontColor = gamePackScreen.logoColour
        //gamePackScreen.changeSubcomponentsColour(gamePackScreen.downloadText)
        //gamePackScreen.changeSubcomponentsColour(gamePackScreen.cleanSlateText)
        //gamePackScreen.changeSubcomponentsColour(gamePackScreen.inspirationText)

        let packLogo = gamePackScreen.packLogo!
        changeLabelColour(packLogo, textColour: gamePackScreen.logoColour)
        let genScreen = addGameToUI(gameID, MPCGDGenome: MPCGDGenome, index: ind, isLocked: isLocked)
        genScreen.runLoadingAnimation()
        //genScreen.helpTextNode.fontColor = gamePackScreen.logoColour
        
        genScreen.alpha = 0
        genScreen.run(self.fadeIn, completion: { HKDisableUserInteractions = false })
        
        _ = self.infoGraphicsImageCycler.cycleToComponent(gameID)
        let oldGamePackLogo = gamePackScreen.packButton.parent! as! HKImage
        
        let root = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: 400, height: 140))
        // !!!HACK!!! Parent root to oldGameLogo.
        // We can't make oldGameLogo hidden or alpha to 0 as it would hide our new additions.
        // Solve by translating oldGameLogo off the top of the screen and applying the opposite
        // translation to our root to retain the original position.
        //
        // Tapping pack/game logos work as expected, whilst tap and hold allows user to scroll
        // game packs left/right.
        let fudgeOldGameLogoOffsetY: CGFloat = 100
        oldGamePackLogo.position.y += fudgeOldGameLogoOffsetY
        oldGamePackLogo.alpha = 1.0
        oldGamePackLogo.addChild(root)
        
        root.position.y -= fudgeOldGameLogoOffsetY
        root.zPosition = oldGamePackLogo.zPosition + 1.0
        root.isUserInteractionEnabled = false
        
        let packLogoButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: 150, height: 30))
        let gameLogoButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: 300, height: 45))
        
        root.setScaleActionInterval(1...1)
        packLogoButton.setScaleActionInterval(1...1.075)
        gameLogoButton.setScaleActionInterval(1...1.05)
        
        // Must be released when leaving game design screen
        struct MutableClosureState {
            var gameLogo: HKComponent! = nil
            var gameName: String! = nil
            var tapComponents: [(HKComponent, HKComponent)] = []
        }
        
        var mcs = MutableClosureState()
        mcs.gameLogo = gameLogo
        mcs.gameName = gameName
        mcs.tapComponents = [
            (root as HKComponent, oldGamePackLogo as HKComponent),
            (gameLogoButton as HKComponent, oldGamePackLogo as HKComponent),
            (packLogoButton as HKComponent, oldGamePackLogo as HKComponent)
        ]
        // NOTE: We need to remove these from the cycler when going back or we leak!
        for tc in mcs.tapComponents {
            self.logoImageCycler.liveTapComponents.append(tc)
        }

        packLogoButton.onTapStartCode = {
            self.endGameInBackground()
            //genScreen.run(self.fadeOut)
            oldGamePackLogo.position = packLogoButton.position
            oldGamePackLogo.run(HKEasing.moveBy(x: 0, y: -fudgeOldGameLogoOffsetY + 52, duration: 0.5, easingFunction: BackEaseOut))
            gamePackScreen.packLogo.removeFromParent()
            gamePackScreen.packButton.addChild(gamePackScreen.packLogo)
            gamePackScreen.packLogo.run(SKAction.scale(to: 1.0, duration: 0.5))
            self.putGamePackBack(gamePackScreen, genScreen: nil)
            HKButton.lock = nil

            // TODO: THIS CLEANUP NEEDS TO HAPPEN EVERYWHERE WE CAN EXIT THE DESIGNER SCREEN!!!!
            // Remove tapComponents we added to the logoImageCycler
            for i in (0..<self.logoImageCycler.liveTapComponents.count).reversed() {
                for j in (0..<mcs.tapComponents.count).reversed() {
                    if self.logoImageCycler.liveTapComponents[i] == mcs.tapComponents[j] {
                        self.logoImageCycler.liveTapComponents.remove(at: i)
                        mcs.tapComponents.remove(at: j)
                        break
                    }
                }
            }
            // Ensure we cleanup dangly references
            root.detachAll()
            gamePackScreen.gameLogo = nil
            packLogoButton.onTapStartCode = nil
            gameLogoButton.onTapStartCode = nil
            mcs.gameLogo = nil
            mcs.gameName = nil
            mcs.tapComponents.removeAll()
            self.textFieldCompletionHandler = nil
            self.infoCyclers[gameID] = nil
            // There is no out-of-the-box support for an array of weak/unowned references.
            // Manually remove them ourselves for now. TODO: Revisit.
            genScreen.buttons.removeAll()
            genScreen.detachAll()
        }
    
        gameLogoButton.onTapStartCode = {
            if (self.isLockedHash[self.currentGameName]! == true){
                genScreen.rotateLock()
                return
            }
            self.endGameInBackground()
            mcs.gameLogo.run(self.fadeOut)
            HKDisableUserInteractions = true
            self.gameNameTextBox.heavyFirst = false
            self.gameNameTextBox.placeholder = mcs.gameName
            self.gameNameTextBox.alpha = 0
            self.gameNameTextBox.run(self.fadeIn)
            self.gameNameTextBox.reset()
            self.gameNameTextBox.setColour(self.currentGamePack.logoColour)
            self.textField.text = ""
            self.textFieldStartText = mcs.gameName
            self.textFieldCompletionHandler = { (newGameName: String) -> Void in
                if newGameName != mcs.gameName {
                    self.handleGameRenamed(self.currentGameName, gamePackScreen: gamePackScreen, newName: newGameName)
                    let parent = mcs.gameLogo.parent!
                    mcs.gameLogo.removeFromParent()
                    mcs.gameLogo = self.getLogoComponent(gameID: gameID, gameName: newGameName, colour: self.currentGamePack.logoColour, fontSize: 45)
                    self.currentGamePack.gameLogo = mcs.gameLogo
                    parent.addChild(mcs.gameLogo)
                    mcs.gameName = newGameName
                } else {
                    mcs.gameLogo.run(self.fadeIn)
                }
            }
            self.textField.becomeFirstResponder()
        }
        
        root.addChild(packLogoButton)
        root.addChild(gameLogoButton)
        
        packLogo.removeFromParent()
        packLogoButton.addChild(packLogo)
        gameLogoButton.addChild(gameLogo)
        
        packLogo.run(SKAction.scale(to: 0.5, duration: 0.4))
        packLogoButton.run(HKEasing.moveBy(x: 0, y: 48, duration: 0.4, easingFunction: BackEaseOut))
        
        gameLogo.alpha = 0
        gameLogo.run(SKAction.fadeIn(withDuration: 0.4))

        MPCGDAudioPlayer.handleGenomeChange(MPCGDGenome: MPCGDGenome)
        changeBackground(MPCGDGenome)

        self.playButton.run(SKAction.fadeAlpha(to: 1, duration: 0.2), completion: {
            self.canPressPlay = true
            self.playButton.enabled = true
        })
        
        packLogoButton.isUserInteractionEnabled = false
        packLogoButton.zPosition = root.zPosition + 1.0
        gameLogoButton.isUserInteractionEnabled = false
        gameLogoButton.zPosition = root.zPosition + 1.0
    }
    
    func addGameToUI(_ gameID: String, MPCGDGenome: MPCGDGenome, index: Int, cycle: Bool = false, isLocked: Bool) -> GeneratorScreen{
        let buttonsScreen = HKImage(image: transGraphic)
        
        let labelSize = buttonsScreen.size
        
        let uploadButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: labelSize.width, height: 60))
        
        var shareTextArray: [SKNode] = []
        
        do { // UPLOAD
            uploadButton.isUserInteractionEnabled = false
            uploadButton.setScaleActionInterval(1.0...1.05)
            uploadButton.position.y = 50
            uploadButton.onTapStartCode = { [unowned self] in
                self.handleUpload()
            }
            buttonsScreen.addChild(uploadButton)

            let uploadImage = HKButton(image: UIImage(named: "UploadButton")!)
            uploadImage.position.x = -88
            uploadImage.isUserInteractionEnabled = false
            uploadButton.addChild(uploadImage)

            let uploadText = SKMultilineLabel(
                text: "~Save this game\nto the clipboard",
                size: labelSize,
                pos: CGPoint(x: labelSize.width / 2.0 + 30.0, y: 5.0),
                fontName: "Helvetica Neue Thin",
                altFontName: "Helvetica Neue Bold",
                fontSize: 20.0,
                fontColor: Colours.getColour(.antiqueWhite),
                alignment: .left,
                spacing: 2.5
            )
            shareTextArray.append(uploadText)
            uploadText.isUserInteractionEnabled = false
            uploadImage.addChild(uploadText)
        }

        let shareButton = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: labelSize.width, height: 60))
        do { // SHARE
            shareButton.isUserInteractionEnabled = false
            shareButton.setScaleActionInterval(1.0...1.05)
            shareButton.position.y = -50
            shareButton.onTapStartCode = { [unowned self] in
                self.shareToSocial()
            }
            buttonsScreen.addChild(shareButton)

            let shareImage = HKButton(image: UIImage(named: "ShareButton")!)
            shareImage.position.x = -88
            shareImage.isUserInteractionEnabled = false
            shareButton.addChild(shareImage)

            let shareText = SKMultilineLabel(
                text: "~Share this game\nwith the world",
                size: labelSize,
                pos: CGPoint(x: labelSize.width / 2.0 + 30.0, y: 5.0),
                fontName: "Helvetica Neue Thin",
                altFontName: "Helvetica Neue Bold",
                fontSize: 20.0,
                fontColor: Colours.getColour(.antiqueWhite),
                alignment: .left,
                spacing: 2.5
            )
            shareTextArray.append(shareText)
            shareText.isUserInteractionEnabled = false
            shareImage.addChild(shareText)
        }
        
        let hSize = CGSize(width: labelSize.width, height: 1)
        let gray = Colours.getColour(.antiqueWhite).withAlphaComponent(0.2)
        let topLine = SKSpriteNode(color: gray, size: hSize)
        let bottomLine = SKSpriteNode(color: gray, size: hSize)
        topLine.position = CGPoint(x: 0, y: 127)
        bottomLine.position = CGPoint(x: 0, y: -135)
        buttonsScreen.addChild(topLine)
        buttonsScreen.addChild(bottomLine)
        
        let helpTextNode = SKLabelNode(text: "Share")
        helpTextNode.fontName = "Helvetica Neue Thin"
        helpTextNode.fontColor = Colours.getColour(.antiqueWhite)
        helpTextNode.fontSize = 22
        helpTextNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        helpTextNode.position.y = labelSize.height/2 - 8
        buttonsScreen.addChild(helpTextNode)
        shareTextArray.append(helpTextNode)

        let ind = logoImageCycler.imagePosition
        shareTexts[ind] = shareTextArray

        let cropNode = SKCropNode()
        let base = HKImage(image: UIImage(named: "BlankGraphic")!)
        cropNode.maskNode = SKSpriteNode(imageNamed: "BlankGraphic")
        let statsScreen = StatsScreen(gameID: gameID, wG: MPCGDGenome, size: base.size)
        
        let designScreen = GeneratorScreen(size: base.size, lineColour: Colours.getColour(.antiqueWhite), isLocked: isLocked, gameID: gameID)
        designScreen.liveMPCGDGenome = loadedMPCGDGenomes[gameID]!
        designScreen.alterButtonsForLiveMPCGDGenome()
        
        let pipsColour = MPCGDGenome.backgroundShade > 4 && MPCGDGenome.dayNightCycle == 0 ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
        
        changeLogoPipsColour(pipsColour)
        
        logoImageCycler.movePip(logoImageCycler.hkComponents.index(of: logoImageCycler.selectedHKComponent)!, numComponents: logoImageCycler.hkComponents.count)

        // CHANGE FOR TEST FLIGHT
        
        let components = [statsScreen, buttonsScreen, designScreen]
        let ids = ["\(gameID) stats", "buttons", gameID]

        let cycler = HKComponentCycler(hkComponents: components, ids: ids, size: base.size, tapToCycle: false, cropNode: cropNode, name: "\(gameID) cycler")

        designScreen.cycler = cycler
        designScreen.onGameAlterationCode = handleSavedGameGenomeChange
        designScreen.changeBackgroundCode = { [unowned designScreen] () -> () in
            self.handleBackgroundChange(designScreen, hasMoved: true)
        }
        cycler.generatorScreen = designScreen
        cycler.liveTapComponents.append((uploadButton, buttonsScreen))
        cycler.liveTapComponents.append((shareButton, buttonsScreen))
        cycler.liveSubComponents.append((designScreen.bigButton, designScreen))
        cycler.liveTapComponents.append((statsScreen.clearStatsButton, statsScreen))

        for b in designScreen.buttons{
            cycler.liveTapComponents.append((b, designScreen))
            b.hkImage.isUserInteractionEnabled = false
            b.isUserInteractionEnabled = false
            b.onTouchCode = { [unowned self] () -> () in
                self.endGameInBackground()
            }
        }
        cycler.liveTapComponents.append((designScreen.bigButton, designScreen))
        designScreen.bigButton.hkImage.isUserInteractionEnabled = false
        designScreen.bigButton.isUserInteractionEnabled = false
        
        statsScreen.clearStatsButton.onTapStartCode = { [unowned self, unowned statsScreen, unowned designScreen] () -> () in
            SessionHandler.clearSessions(gameID: self.currentGameName)
            self.showAlertNode(text: "Play data reset")
            designScreen.updateBestLabel()
            statsScreen.refresh(gameID: self.currentGameName, wG: self.loadedMPCGDGenomes[self.currentGameName]!)
        }

        cycler.liveTapComponents.append((designScreen.tallButton, designScreen))
        designScreen.tallButton.hkImage.isUserInteractionEnabled = false
        designScreen.tallButton.isUserInteractionEnabled = false

        cycler.pipsNode.position.y += infoPipsAddOn + 2
        cycler.pipsNode.setScale(0.9)
        cycler.setUpPips(cycler.hkComponents.count)
        cycler.movePip(cycler.hkComponents.index(of: cycler.selectedHKComponent)!, numComponents: cycler.hkComponents.count)

        base.addChild(cycler)
        infoCyclers[gameID] = cycler
        cycler.onDragCode = { [unowned self] () -> () in
            self.endGameInBackground()
        }
        cycler.name = "infoCycler: \(gameID)"
        infoGraphicsImageCycler.addHKComponentAtIndex(base, id: gameID, index: index, cycle: cycle)
        
        logoImageCycler.pipsNode.run(fadeIn)
        
        statsScreen.isUserInteractionEnabled = false
        designScreen.isUserInteractionEnabled = false

        _ = cycler.cycleToComponent(gameID)
        cycler.allow360 = false
        cycler.enabled = true
        cycler.isUserInteractionEnabled = true
        
        designScreen.alpha = 0
        designScreen.run(fadeIn)
        
        return designScreen
    }
    
    func handleSavedGameGenomeChange(_ alteredGenome: MPCGDGenome, isLocked: Bool){
        let encoding = alteredGenome.encodeAsBase64()!
        loadedMPCGDGenomes[currentGameName] = alteredGenome
        isLockedHash[currentGameName] = isLocked
        loadRightGenome()
        let ind = infoGraphicsImageCycler.indexShowing()
        GameHandler.overwriteGenome(currentGameName, alteredGenome: alteredGenome, packID: allPackIDs[ind], isLocked: isLocked)
        currentGamePack.handlePotentialBestChange(gameID: currentGameName)
        let statsScreen = infoCyclers[currentGameName]!.hkComponents[0] as! StatsScreen
        statsScreen.reactToGenomeChange(alteredMPCGDGenome: alteredGenome)
    }
    
    static let useBase64 = true
    
    func encodeShareableGame(_ name: String, genome: MPCGDGenome?) -> String? {
        if MainScene.useBase64 {
            return encodeShareableGame64(name, genome: genome)
        }
        guard let encoding = genome?.encodeAsBase62() else { return nil }
        let title = name.components(separatedBy: "@")[0].replacingOccurrences(of: " ", with: "-")
        guard title != "" else { return nil }
        return "\(encoding),\(title)."
    }
    
    func decodeShareableGame(_ game: String) -> (String?, MPCGDGenome?) {
        if MainScene.useBase64 {
            let (title, genome) = decodeShareableGame64(game)
            if title != nil && genome != nil {
                return (title, genome)
            }
            print("*** base64 decode of \(game) failed. Trying old version")
        }

        let encodingRegex = "[A-Za-z0-9]{1,11}(&[A-Za-z0-9]{1,11}){1,6}"
        let titleRegex = "([A-Z0-9]{1,30}((-[A-Z0-9]{1,30}){1,15})?)"
        let validRegex = "\(encodingRegex),\(titleRegex)."
        
        let validMatch = game.range(of: validRegex, options: .regularExpression)
        guard validMatch != nil else { return (nil, nil) }
        
        let input = game[validMatch!] //.substring(with: validMatch!)
        let encoding = input[input.range(of: encodingRegex, options: .regularExpression)!]
        
        let genome = MPCGDGenome()
        guard genome.decodeFromBase62(String(encoding)) else { return (nil, nil) }
        
        let titleStart = encoding.count + 1
        let titleEnd = min(titleStart + 60, input.count)
        
        let titleString = input[input.index(input.startIndex, offsetBy: titleStart)..<input.index(input.startIndex, offsetBy: titleEnd)]
        let title = titleString[titleString.range(of: titleRegex, options: .regularExpression)!].replacingOccurrences(of: "-", with: " ")
        
        return (title, genome)
    }

    func encodeShareableGame64(_ name: String, genome: MPCGDGenome?) -> String? {
        guard let encoding = genome?.encodeAsBase64() else { return nil }
        let title = name.components(separatedBy: "@")[0].replacingOccurrences(of: " ", with: "-")
        guard title != "" else { return nil }
        return "\(title):\(encoding)"
    }
    
    func decodeShareableGame64(_ game: String) -> (String?, MPCGDGenome?) {
        guard game.count < 512 else { return (nil, nil) }

        let titleRegex = "([A-Z0-9&!]{1,30}((-[A-Z0-9&!]{1,30}){1,15})?)"
        let encodingRegex = "[A-Za-z0-9+/]{1,11}(&?[A-Za-z0-9+/]{1,11}){1,6}"
        let validRegex = "\(titleRegex):\(encodingRegex)"
        
        let validMatch = game.range(of: validRegex, options: .regularExpression)
        guard validMatch != nil else { return (nil, nil) }
        
        let input = game[validMatch!] //substring(with: validMatch!)
        let parts = input.components(separatedBy: ":")
        guard parts.count == 2 else { return (nil, nil) }
        let title = parts[0][parts[0].range(of: titleRegex, options: .regularExpression)!]
        let encoding = parts[1][parts[1].range(of: encodingRegex, options: .regularExpression)!]
        
        let genome = MPCGDGenome()
        guard genome.decodeFromBase64(String(encoding)) else { return (nil, nil) }
        
        return (title.replacingOccurrences(of: "-", with: " "), genome)
    }
    
    func handleUpload(){
        let pasteBoard = UIPasteboard.general
        guard let s = encodeShareableGame(currentGameName, genome: loadedMPCGDGenomes[currentGameName]) else {
            showAlertNode(text: "Clipboard encoding failed")
            return
        }
        pasteBoard.string = s
        showAlertNode(text: "Saved to clipboard")
    }

    func shareDialog(_ activityItems : [AnyObject] ) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        activityViewController.popoverPresentationController?.sourceView = scene!.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(origin: scene!.size.centrePoint(), size: scene!.size)
        activityViewController.excludedActivityTypes = [
            // Restrict sharing to messenger, mail, slack, notes
            UIActivityType.postToFacebook,
            UIActivityType.postToTwitter,
            UIActivityType.postToWeibo,
//            UIActivityType.message,
//            UIActivityType.mail,
            UIActivityType.print,
            UIActivityType.copyToPasteboard,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo,
            UIActivityType.airDrop,
            UIActivityType.openInIBooks,
// (ios11)+ UIActivityType.markupAsPDF
        ];
        let _ = activityViewController.view.self
        
        return activityViewController
    }
    
    
    func shareToSocial() {
        guard let game = encodeShareableGame(currentGameName, genome: loadedMPCGDGenomes[currentGameName]) else {
            showAlertNode(text: "Share failed")
            return
        }
        let infoScreen = getSocialImage()
        
        let message = "Made with #MPCGD from @ThoseMetaMakers: \(game)"
        fascinatorNode.run(SKAction.run({
            let activityViewController = self.shareDialog([message as AnyObject, infoScreen])
            self.presentViewController(activityViewController, animated: true, completion: {})
        }))
    }
    
    func getSocialImage() -> UIImage{
        var backing = UIImage(cgImage: (backgroundNode.texture?.cgImage())!)
        let scale = 1.1 * (size.width/backing.size.width)
        backing = ImageUtils.getScaledImage(backing, scale: scale)
        let node = SKSpriteNode(texture: SKTexture(image: backing))
        let base = HKImage(image: UIImage(named: "BlankGraphic")!)
        let genScreen = GeneratorScreen(size: base.size, lineColour: whiteColour, includeLock: false, isLocked: false, includeHelpButton: false, includeBest: false, gameID: "")
        genScreen.liveMPCGDGenome = loadedMPCGDGenomes[currentGameName]!
        genScreen.alterButtonsForLiveMPCGDGenome()
        genScreen.isHidden = false
        genScreen.children[0].isHidden = true
        let baseColour = UIColor(red: 71/255, green: 130/255, blue: 180/255, alpha: 0.6)
        let tintNode = SKSpriteNode(color: baseColour, size: CGSize(width: base.size.width - 6, height: base.size.width + 10))
        genScreen.position.y = -70
        tintNode.position.y = -75
        node.addChild(tintNode)
        node.addChild(genScreen)
        
        let fontColour = isBackgroundDark(genScreen.liveMPCGDGenome) ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)

        let textNode = SKLabelNode(text: "Made with #MPCGD from @ThoseMetaMakers")
        textNode.fontName = "Helvetica Neue Thin"
        textNode.fontSize = 13
        textNode.position = CGPoint(x: 0, y: -225)
        textNode.fontColor = fontColour
        node.addChild(textNode)
        
        let gameName = currentGameName.components(separatedBy: "@")[0]
        let (logoLabels, _) = getWordLabels(gameName, fontSize: 42)
        for l in logoLabels{
            l.fontColor = fontColour
            node.addChild(l)
            l.position = CGPoint(x: l.position.x, y: 86)
        }

        var socialImage = UIImage(cgImage: (view?.texture(from: node)?.cgImage())!)
        let rect = CGRect(x: 0, y: socialImage.size.height - socialImage.size.width, width: socialImage.size.width, height: socialImage.size.width)
        socialImage = ImageUtils.getSubImage(socialImage, rect: rect)
        return socialImage
    }
    
    func showAlertNode(imageName: String, waitForDuration: CGFloat = 0){
        let infoNode = SKSpriteNode(imageNamed: imageName)
        
        let w = Colours.getColour(.antiqueWhite).withAlphaComponent(0.95)
        let alertNode = SKSpriteNode(color: w, size: CGSize(width: size.width, height: infoNode.height))

        alertNode.addChild(infoNode)
        animateAlert(alertNode: alertNode, waitForDuration: waitForDuration)
    }
    
    func showAlertNode(text: String){
        let h = CGFloat(150)
        let w = Colours.getColour(.antiqueWhite).withAlphaComponent(0.95)
        let alertNode = SKSpriteNode(color: w, size: CGSize(width: size.width, height: h))
        let textNode = SKLabelNode(text: text)
        textNode.fontColor = Colours.getColour(.black)
        textNode.fontName = "Helvetica Neue Bold"
        textNode.fontSize = 27
        textNode.verticalAlignmentMode = .center
        textNode.position.y = -5
        alertNode.addChild(textNode)
        animateAlert(alertNode: alertNode)
    }
    
    private func animateAlert(alertNode: SKSpriteNode, waitForDuration: CGFloat = 0){
        self.addChild(alertNode)
        alertNode.zPosition = ZPositionConstants.fascinatorHeadsUpDisplay + 100
        let h = alertNode.size.height
        alertNode.position = CGPoint(x: size.width/2, y: size.height + h/2)
        if DeviceType.isIPhone && DeviceType.simulationIs == .iPad{
            alertNode.position.y = size.height - topLetterBoxNode.size.height + h/2
        }
//        alertNode.zPosition = topLetterBoxNode.zPosition - 10
        if waitForDuration > 0{
            let sequence = SKAction.sequence([SKAction.wait(forDuration: TimeInterval(waitForDuration)), HKEasing.moveBy(x: 0, y: -h + 10, duration: 0.2, easingFunction: BackEaseOut), SKAction.wait(forDuration: 1.5), SKAction.move(by: CGVector(dx: 0, dy: h), duration: 0.2)])
            alertNode.run(sequence, completion: {
                alertNode.removeFromParent()
            })

        }
        else{
            let sequence = SKAction.sequence([HKEasing.moveBy(x: 0, y: -h + 10, duration: 0.2, easingFunction: BackEaseOut), SKAction.wait(forDuration: 1.5), SKAction.move(by: CGVector(dx: 0, dy: h), duration: 0.2)])
            alertNode.run(sequence, completion: {
                alertNode.removeFromParent()
            })
            
        }
    }
    
    func getLogoComponent(gameID: String, gameName: String, colour: UIColor, fontSize: CGFloat, heavyFirst: Bool = false) -> HKComponent{
        let logo = HKComponent()
        logo.isUserInteractionEnabled = false
        
        let (wordLabels, _) = getWordLabels(gameName, fontSize: fontSize, heavyFirst: heavyFirst)
        for label in wordLabels{
            logo.addChild(label)
            label.fontColor = colour
        }
        return logo
    }

    func getDilatedLogoComponent(_ gameName: String, colour: UIColor, heavyFirst: Bool = false) -> HKComponent{
        let logo = HKButton(image: ImageUtils.getBlankImage(CGSize(width: 1, height: 1), colour: UIColor.clear), dilateTapBy: CGSize(width: 400, height: 140))
        logo.isUserInteractionEnabled = false
        
        let (wordLabels, _) = getWordLabels(gameName, fontSize: 45, heavyFirst: heavyFirst)
        for label in wordLabels{
            logo.addChild(label)
            label.fontColor = colour
        }
        return logo
    }

    func getWordLabels(_ gameName: String, fontSize: CGFloat, heavyFirst: Bool = false) -> ([SKLabelNode], CGFloat){
        
        let words = gameName.components(separatedBy: " ")
        let ceilHalf = Int(ceil(Double(words.count)/2))
        let floorHalf = Int(floor(Double(words.count)/2))
        
        var totalWidth = CGFloat(0)
        var wordLabels: [SKLabelNode] = []
        var wordWidths: [CGFloat] = []
        
        let heavyFont = UIFontCache(name: dolceVitaHeavyFont.familyName, size: fontSize)
        let lightFont = UIFontCache(name: dolceVitaLightFont.familyName, size: fontSize)
        
        for pos in 0..<words.count{
            let word = words[pos]
            var font: UIFont!
            var wordLabel: SKLabelNode!
            
            if heavyFirst{
                font = pos >= floorHalf ? lightFont : heavyFont
            }
            else{
                font = pos >= ceilHalf ? heavyFont : lightFont
            }
            wordLabel = SKLabelNode(font, Colours.getColour(.black))
            wordLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            wordLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
            wordLabel.text = word
            wordLabels.append(wordLabel)
            let wordWidth = FontUtils.textSize(word, font: font).width
            wordWidths.append(wordWidth)
            totalWidth += wordWidth
            if pos < words.count - 1{
                totalWidth += 10
            }
        }
        var xPos = -totalWidth/2
        var pos = 0
        for label in wordLabels{
            label.position.x = xPos
            xPos += wordWidths[pos] + 10
            pos += 1
        }
        return (wordLabels, totalWidth)
    }
    
    func getLiveNameComponent(_ gameName: String, heavyFirst: Bool) -> (HKComponent, CGFloat){
        let comp = HKComponent()
        let (labels, totalWidth) = getWordLabels(gameName, fontSize: 45, heavyFirst: heavyFirst)
        for l in labels{
            comp.addChild(l)
            l.fontColor = currentGamePack.logoColour
        }
        return (comp, totalWidth)
    }

    func changeGenome(_ fascinator: Fascinator, genomeName: String, gameID: String, isIPad: Bool){
        let genomeJsonString = FileUtils.readFile("\(genomeName)_genome", fileType: "json")
        let dict = JsonUtils.jsonStringToObject(genomeJsonString!) as! NSDictionary
        let genome = FascinatorLoader.convertDictToGenome(fascinator, dict: dict)
        fascinator.genome = genome
        
        let gpc = fascinator.genome[.Gameplay] as! GameplayChromosome
        
        gpc.friend.radius.intValue = gpc.friend.radius.mapValueToInt(15)
        gpc.foe.radius.intValue = gpc.foe.radius.mapValueToInt(15)
        gpc.friend.maxBalls.intValue = gpc.friend.maxBalls.mapValueToInt(20)
        gpc.foe.maxBalls.intValue = gpc.foe.maxBalls.mapValueToInt(20)
        
        // ADDED
        
        gpc.friend.spawnMinDistFromFriends.intValue = gpc.friend.spawnMinDistFromFriends.mapValueToInt(30)
        gpc.friend.spawnMinDistFromFoes.intValue = gpc.friend.spawnMinDistFromFriends.mapValueToInt(30)
        gpc.foe.spawnMinDistFromFriends.intValue = gpc.friend.spawnMinDistFromFriends.mapValueToInt(30)
        gpc.foe.spawnMinDistFromFoes.intValue = gpc.friend.spawnMinDistFromFriends.mapValueToInt(30)

        
        let drawing = FascinatorDrawing()
        
        if isIPad{
            let horizontalPath = DrawingPath()
            horizontalPath.pathPoints = [CGPoint(x: 0, y: 850), CGPoint(x: 762, y: 850)]
            let vPath0 = DrawingPath()
            vPath0.pathPoints = [CGPoint(x: 2, y: 210), CGPoint(x: 2, y: 850)]
            let vPath1 = DrawingPath()
            vPath1.pathPoints = [CGPoint(x: 153, y: 210), CGPoint(x: 153, y: 850)]
            let vPath2 = DrawingPath()
            vPath2.pathPoints = [CGPoint(x: 307, y: 210), CGPoint(x: 307, y: 850)]
            let vPath3 = DrawingPath()
            vPath3.pathPoints = [CGPoint(x: 461, y: 210), CGPoint(x: 461, y: 850)]
            let vPath4 = DrawingPath()
            vPath4.pathPoints = [CGPoint(x: 614, y: 210), CGPoint(x: 614, y: 850)]
            let vPath5 = DrawingPath()
            vPath5.pathPoints = [CGPoint(x: 760, y: 210), CGPoint(x: 760, y: 850)]
            drawing.paths = [vPath0, vPath1, vPath2, vPath3, vPath4, vPath5]
            if gameID != "TIB"{
                drawing.paths.append(horizontalPath)
            }
        }
        else{
            let horizontalPath = DrawingPath()
            horizontalPath.pathPoints = [CGPoint(x: 3, y: 903), CGPoint(x: 636, y: 903)]
            let vPath0 = DrawingPath()
            vPath0.pathPoints = [CGPoint(x: 5, y: 210), CGPoint(x: 5, y: 903)]
            let vPath1 = DrawingPath()
            vPath1.pathPoints = [CGPoint(x: 131, y: 210), CGPoint(x: 131, y: 903)]
            let vPath2 = DrawingPath()
            vPath2.pathPoints = [CGPoint(x: 259, y: 210), CGPoint(x: 259, y: 903)]
            let vPath3 = DrawingPath()
            vPath3.pathPoints = [CGPoint(x: 387, y: 210), CGPoint(x: 387, y: 903)]
            let vPath4 = DrawingPath()
            vPath4.pathPoints = [CGPoint(x: 515, y: 210), CGPoint(x: 515, y: 903)]
            let vPath5 = DrawingPath()
            vPath5.pathPoints = [CGPoint(x: 635, y: 210), CGPoint(x: 635, y: 903)]
            drawing.paths = [vPath0, vPath1, vPath2, vPath3, vPath4, vPath5]
            if gameID != "TIB"{
                drawing.paths.append(horizontalPath)
            }
        }
        
        for path in drawing.paths{
            path.strokeWidth = 3
            path.hue = 0
            path.saturation = 0
            path.brightness = 0.3
        }
        
        fascinator.chromosome = gpc
        fascinator.drawingPaths = drawing.paths
        fascinator.calculateImageLayers()
    }
    
    func handleInspiringGameAdded(){
        
        // HACK to keep buttons working when changing screen :(
        HKButton.lock = nil

        let gameName = "NEW GAME"
        let MPCGDGenome = MPCGDGenomeGenerator.getInspiringGenome()
        let timeStamp = String(Date().timeIntervalSince1970)
        let gameID = "\(gameName)@\(timeStamp)"
        _ = GameHandler.saveGame(MPCGDGenome, gameID: gameID, packID: currentGamePack.packID, isLocked: false)
        loadedMPCGDGenomes[gameID] = MPCGDGenome
        isLockedHash[gameID] = false
        loadUpGame(gameID, gamePackScreen: currentGamePack, immediate: false)
        currentGamePack.addGameButton(gameID)
        currentGameName = gameID
        currentGamePack.showTrayNode()
        currentGamePack.gameIDOnShow = gameID
        //genScreen.runLoadingAnimation()
    }
    
    func handleNewGameAdded(_ title: String? = nil, _ genome: MPCGDGenome? = nil) {
        
        // HACK to keep buttons working when changing screen :(
        HKButton.lock = nil
        
        let name = title != nil ? title! : "NEW GAME"
        let MPCGDGenome = genome != nil ? genome! : MPCGDGenome.getCleanSlate()
        
        let timeStamp = String(Date().timeIntervalSince1970)
        let gameID = "\(name)@\(timeStamp)"
        _ = GameHandler.saveGame(MPCGDGenome, gameID: gameID, packID: currentGamePack.packID, isLocked: false)
        loadedMPCGDGenomes[gameID] = MPCGDGenome
        isLockedHash[gameID] = false
        loadUpGame(gameID, gamePackScreen: currentGamePack, immediate: false)
        currentGamePack.addGameButton(gameID)
        currentGamePack.showTrayNode()
        currentGameName = gameID
        currentGamePack.gameIDOnShow = gameID
        //genScreen.runLoadingAnimation()
    }

    #if os(iOS)
        func presentViewController(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
            viewController.present(viewControllerToPresent, animated: animated, completion: completion)
        }
    #elseif os(OSX)
        func presentViewController(viewControllerToPresent: UIAlertController, animated: Bool, completion: (() -> Void)?) {
            viewControllerToPresent.showModal()
            if completion != nil {
                completion!()
            }
        }
    #endif
    
}
