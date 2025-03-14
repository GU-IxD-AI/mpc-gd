//
//  FriendsAndFoesScene.swift
//  Fask
//
//  Created by Simon Colton on 12/09/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class SoundLimiter {
    static let gainlose = MPCGDSoundLimiter("gainlose", limit: 2, rate: 0.25...0.5)
    static let bounce = MPCGDSoundLimiter("bounce", limit: 2, rate: 0.1...0.2)
    static let clusterExplode = MPCGDSoundLimiter("clusterExplode", limit: 2, rate: (1.0/60.0)...(2.0/60.0))
    
    static func tick(wallclock wc: Date) {
        gainlose.tick(wallclock: wc)
        bounce.tick(wallclock: wc)
        clusterExplode.tick(wallclock: wc)
    }
}

class Fascinator: NSObject, SKPhysicsContactDelegate{
    
    var sfxPackName = "8bit"
    
    var lifeLostAnimationIsHappening = false
    
    var artImageColour: UIColor! = nil
    
    var gameOverCode: (() -> ())! = nil
    
    var gameOverReason: GameOverReason! = nil
    
    var sfxVolume = CGFloat(0.5)
    
    var positiveScoresPossible = false
    
    var score: Int = 0
    
    var drawingPaths: [DrawingPath] = []
    
    struct ScoringColours {

        static var friend = UIColor.black
        static var foe = UIColor.white
        static var mixed = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        static func mixFriendAndFoe(_ t: CGFloat) -> UIColor {
            let a = Fascinator.ScoringColours.friend.getRGBA()
            let b = Fascinator.ScoringColours.foe.getRGBA()
            return UIColor(
                red: (b.0 - a.0) * t + a.0,
                green: (b.1 - a.1) * t + a.1,
                blue: (b.2 - a.2) * t + a.2,
                alpha: 1.0
                )
        }
    }
    
    struct Scoring {
        // Defaults for LIS
        var snowControllerCollision: Int! = 0
        var rainControllerCollision: Int! = 0
        var rainTapped: Int! = -1
        var snowTapped: Int! = 0
        var rainClusterExplodeScore = -1
        var snowClusterExplodeScore = 1
        var mixedClusterExplodeScore = 0
        // Zones
        var snowScoreZone = 0
        var rainScoreZone = 0
    }
    
    struct ParticleEffect {
        static var friend = "BeeExplode"
        static var foe = "BeeExplode"
    }
    
    var livesLeft = 3
    
    var noLivesLeft = false
    
    var restartTimeElapsed: TimeInterval = 0
    
    var restartScore = 0
    
    var controllerHasJustTeleported = false
    
    var teleportControllerTo: CGPoint! = nil
    
    let pointsNode = SKLabelNode(text: "pts")
    
    var ballHasBeenTapped = false
    
    var controllerAttachmentPoint: CGPoint! = nil
    
    var controllerStartPosition: CGPoint! = nil
    
    var activeSpawnedScores: [SKLabelNode] = []
    
    var controllerOverlayImage: UIImage! = nil
    
    var controllerCollectionNum: Int! = nil
    
    var controllerSize: CGFloat = 1
    
    var controllerColour: UIColor! = nil
    
    var controllerReflectionID: Int! = nil
    
    var controllerCharacterNum: Int! = nil
    
    var useBoundingBoxFix = true
    
    var detachJointOnDrag = false
    
    var deviceSimulationYOffset = CGFloat(0)
    
    var deviceSimulationXOffset = CGFloat(0)
    
    var emptyArtImage = false
    
    var whiteSizes: [CGFloat] = [15]
    
    var blueSizes: [CGFloat] = [15]
    
    var friendSpawnLocations: [CGPoint] = []
    
    var foeSpawnLocations: [CGPoint] = []
    
    var scoring = Scoring()
    
    var pauseInfoGraphic: SKSpriteNode! = nil
    
    var scoreColour = UIColor.black
    
    var noBackingPause = true
    
    var lastQuiescentTime: Date! = nil
    
    var playtester: MacroTacticPlaytester! = nil
    
    var playtesterStrategyGlobalProbability = CGFloat(0)
    
    var genome: Dictionary<ChromosomeName, Chromosome>! = nil
    
    weak var scene: SKScene! = nil
    
    var sceneSize: CGSize! = nil

    var imageSize: CGSize! = nil
    
    var sceneCentre: CGPoint! = nil
    
    var fascinatorSKNode: SKNode! = nil
    
    var backingNode: SKSpriteNode! = nil
    
    var artImageNode: SKSpriteNode! = nil
    
    var artImageBoundingBox: CGRect! = nil
    
    var fascinatorContent: FascinatorContent! = nil
    
    var artImage: UIImage! = nil
    
    var backing: UIImage! = nil
    
    var imageAndLightingChromosome: ImageAndLightingChromosome! = nil
    
    var chromosome : GameplayChromosome! = nil
    
    var shouldInitialiseSoundOnRestart = false
    
    var spotLight: SKLightNode! = nil
    
    static let maskBg     : UInt32 = 1 << 0
    static let maskFriend : UInt32 = 1 << 1
    static let maskFoe    : UInt32 = 1 << 2
    static let maskOffsetWall : UInt32  = 3
    
    var imageCentreOfMass = CGPoint.zero
    
    var balls : [Ball] = []
    var friendSpawnAngle: CGFloat = 0
    var foeSpawnAngle: CGFloat = 0
    var nextFriendSpawnTime: TimeInterval = 0
    var nextFoeSpawnTime: TimeInterval = 0
    var rarestBallType : Ball.BallType? = nil
    
    struct ReservedSpawnSpot {
        let ballType : Ball.BallType
        let position : CGPoint
        let radius : CGFloat
        let debugNode : SKShapeNode?
    }
    
    var reservedSpawnSpots : [ReservedSpawnSpot] = []
    
    var ballsSpawned    : [Ball.BallType : Int] = [.friend: 0, .foe: 0]
    var clustersMatched : [Ball.BallType : Int] = [.friend: 0, .foe: 0]
    
    struct BallRecord {
        let type : Ball.BallType
        let filtersMatched : [ScoreContributionSubChromosome.FilterType]
        
        init(ball: Ball) {
            self.type = ball.type
            var filters : [ScoreContributionSubChromosome.FilterType] = []
            var i = 0
            while let filter = ScoreContributionSubChromosome.FilterType(rawValue: i) {
                if ball.matchesFilter(filter) {
                    filters.append(filter)
                }
                i+=1
            }
            self.filtersMatched = filters
        }
    }
    
    var scoreDisplay: SKLabelNode! = nil
    var timeDisplay: SKLabelNode! = nil
    var livesDisplay: SKLabelNode! = nil

    var lastFingerPos: CGPoint = CGPoint.zero
    var isDragging : Bool = false
    
    var attractFields: [SKFieldNode] = []
    var fingerAttractFields: [SKFieldNode] = []
    var fields: [SKFieldNode] = []
    var walls: SKNode! = nil
    
    var deadZone: Int = 0
    var scoreZone: Int = 0
    var goalZoneNode: SKNode! = nil
    
    var startTime: Date! = nil
    var timeElapsed: TimeInterval = 0
    var timeLeft: TimeInterval = 0
    var timeSpentPaused: TimeInterval = 0
    var whenPaused: Date! = nil
    var gameIsOver: Bool = false
    var gameOverField: SKFieldNode! = nil
    var firstTickAfterRestart: Bool = true
    
    var axle: SKNode! = nil
    var attachmentJoint: SKPhysicsJoint! = nil
    var attachmentPoint = CGPoint.zero
    
    var customHelpText: String = ""
    
    var artImageData : ImageData! = nil
    var artImageController : ArtImageController! = nil
    
    var imageGridPointOverride : CGPoint? = nil
    
    // gameSpeed is a double so that it can be multiplied with NSTimeInterval without casting
    var gameSpeed : Double = 1
    var lastCounterUpdateTime : CFTimeInterval = 0
    var gameLog : [[String : AnyObject]] = []
    
    //pausing
    var isPaused = false
    var needsUnpausingAfterFocusLost = false
    
    func pauseImmediately() {
        isPaused = true
        gameSpeed = 0
        lastTickTime = nil
        if self.scene != nil {
            scene.physicsWorld.speed = 0
        }
        //TODO: handle audio pausing here
    }
    
    func releaseFromPause(){
        isPaused = false
        gameSpeed = Double(self.chromosome.physicsSpeed.value)
        
        scene.physicsWorld.speed = CGFloat(gameSpeed)
        //TODO: handle audio pausing here
        //(scene as! MainScene).restoreTheFrameRate()
        if artImageController is TowardsFingerController{
            artImageController.touchEnded(CGPoint(x: 0, y: 0))
        }
    }
    
    // Initialising
    
    func extractChromosomes(_ genome: Dictionary<ChromosomeName, Chromosome>){
        imageAndLightingChromosome = ImageAndLightingChromosome(stringRepresentation: genome[ChromosomeName.ImageAndLighting]!.getStringRepresentation())
        chromosome = GameplayChromosome(stringRepresentation: genome[ChromosomeName.Gameplay]!.getStringRepresentation())
    }
    
    func constructFascinatorSKNode(_ genome: Dictionary<ChromosomeName, Chromosome>, view: SKView, sceneSize: CGSize, controllerImage: UIImage!) {
        
        self.genome = genome
        self.sceneSize = sceneSize
        imageSize = sceneSize.doubled()
        sceneCentre = sceneSize.centrePoint()
        extractChromosomes(genome)
        fascinatorSKNode = SKNode()
        _ = addImageAndBackingNodes(genome, view: view, controllerImage: controllerImage)
        calculateImageLayers()
        
        scoreDisplay = SKLabelNode(text: "0")
        scoreDisplay.horizontalAlignmentMode = .right
        scoreDisplay.verticalAlignmentMode = .top
        scoreDisplay.position = CGPoint(x: sceneSize.width - 48, y: sceneSize.height - 10)
        scoreDisplay.zPosition = ZPositionConstants.fascinatorHeadsUpDisplay
        scoreDisplay.fontColor = scoreColour
        scoreDisplay.fontName = "Helvetica Neue Thin"
        scoreDisplay.fontSize = 24
        fascinatorSKNode.addChild(scoreDisplay)
        
        pointsNode.fontColor = scoreColour
        pointsNode.fontName = "Helvetica Neue Thin"
        pointsNode.fontSize = 24
        pointsNode.position = CGPoint(x: 7, y: 0)
        pointsNode.horizontalAlignmentMode = .left
        pointsNode.verticalAlignmentMode = .top
        scoreDisplay.addChild(pointsNode)
        
        timeDisplay = SKLabelNode(text: "0")
        timeDisplay.horizontalAlignmentMode = .left
        timeDisplay.verticalAlignmentMode = .top
        timeDisplay.position = CGPoint(x: 10, y: sceneSize.height - 10)
        timeDisplay.zPosition = ZPositionConstants.fascinatorHeadsUpDisplay
        timeDisplay.fontColor = scoreColour
        timeDisplay.fontName = "Helvetica Neue Thin"
        timeDisplay.fontSize = 24
        fascinatorSKNode.addChild(timeDisplay)
        
        livesDisplay = SKLabelNode(text: "0")
        livesDisplay.horizontalAlignmentMode = .center
        livesDisplay.verticalAlignmentMode = .top
        livesDisplay.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height - 4)
        livesDisplay.zPosition = ZPositionConstants.fascinatorHeadsUpDisplay
        livesDisplay.fontColor = scoreColour
        livesDisplay.fontName = "Helvetica Neue Thin"
        livesDisplay.fontSize = 24
        fascinatorSKNode.addChild(livesDisplay)

        restart()
    }
    
    func addImageAndBackingNodes(_ genome: Dictionary<ChromosomeName, Chromosome>, view: SKView?, controllerImage: UIImage!) -> FascinatorContent{
        fascinatorContent = FascinatorContent()
        fascinatorContent.imageOnWhite = controllerImage
         
        // HACK FOR LET IT SNOW
        backing = UIImage(named: "City2")
        
        backingNode = SKSpriteNode(texture: SKTexture(image: backing))
        backingNode.size = sceneSize
        
        artImage = fascinatorContent.imageOnWhite
        artImageNode = SKSpriteNode(texture: SKTexture(image: artImage))
        artImageNode.size = sceneSize
        
        backingNode.setPositionTo(sceneCentre)
        artImageNode.setPositionTo(sceneCentre)
        
        calculateImageLayers()
        
       // fascinatorSKNode.addChild(backingNode)
        fascinatorSKNode.addChild(artImageNode)
                
        return fascinatorContent
    }
    
    func addToScore(_ scoreAddon: Int){
        if scoreAddon != -90{
            score += scoreAddon
        }
        if score < 0{
            score = 0
        }
        scoreDisplay.text = "\(score)"
        if score == 1{
            pointsNode.text = "pt"
        }
        else{
            pointsNode.text = "pts"
        }
        
        if scoreAddon == -90 && livesLeft > 0{

            MPCGDAudio.playSound(path: MPCGDSounds.loseLife, volume: Float(sfxVolume), priority: 9.0)
            
            livesLeft -= 1
            if livesLeft > 0{
                restartTimeElapsed = timeElapsed
                restartScore = score
                restartAfterLifeLost()
            }
            else{
                noLivesLeft = true
            }
            livesDisplay.text = "Lives: \(livesLeft)"
        }
    }
    
    func getFascinatorSKNode() -> SKNode{
        return fascinatorSKNode
    }
    
    func gameHasBallsOfType(_ ballType: Ball.BallType) -> Bool {
        let ballChromosome = chromosome.getBallSubChromosome(ballType)
        
        if ballChromosome.numAtStart.value > 0 || ballChromosome.numPerSecond.value > 0 {
            return true
        }
        
        for tapAction in [chromosome.imageTapAction.value, chromosome.backgroundTapAction.value] {
            if (tapAction == .spawnFriend && ballType == .friend) || (tapAction == .spawnFoe && ballType == .foe) {
                return true
            }
        }
        
        return false
    }
    
    var lastScale: CGFloat! = nil
    
    func rescaleArtImage(force: Bool) {
        let scale = imageAndLightingChromosome.artImageSize.value
        if force || scale != lastScale {
            
            //           calculateImageLayers()
            artImage = ImageUtils.getScaledImageOnCanvasWithSize(artImage, scale: scale, canvasSize: sceneSize * 2)
            
            artImageNode.texture = SKTexture(image: artImage)
            artImageNode.size = sceneSize
            
            imageCentreOfMass = CGPoint.zero
        }
        lastScale = scale
    }
    
    func getImageScale() -> CGFloat {
        return imageAndLightingChromosome.artImageSize.value
    }
    
    func addWalls() {
        if walls != nil {
            walls.removeFromParent()
            walls = nil
        }
        
        walls = SKNode()
        let thickness: CGFloat = 1000
        
        let offScreenNess = LAF.wallOffScreenNess
        
        for edge in Edge.allEdges {
            let size: CGSize
            var offset: CGVector
            
            switch edge {
            case .top, .bottom:
                size = CGSize(width: sceneSize.width + thickness, height: thickness)
                offset = CGVector(dx: 0, dy: (0.5 * sceneSize.height) + (0.5 * thickness) + offScreenNess.1)
            case .left, .right:
                size = CGSize(width: thickness, height: sceneSize.height + thickness)
                offset = CGVector(dx: (0.5 * sceneSize.width) + (0.5 * thickness) + offScreenNess.0, dy: 0)
            }
            
            if edge == .bottom || edge == .left {
                offset = -1 * offset
            }
            
            let wall = SKNode()
            wall.physicsBody = SKPhysicsBody(rectangleOf: size, center: sceneCentre + offset)
            wall.physicsBody!.isDynamic = false
            wall.physicsBody!.restitution = chromosome.wallBounciness.value
            wall.physicsBody!.categoryBitMask = edge.mask << Fascinator.maskOffsetWall
            
            wall.physicsBody!.collisionBitMask = 0
            if (UInt32(chromosome.friend.wallCollision.value) & edge.mask) != 0 {
                wall.physicsBody!.collisionBitMask |= Fascinator.maskFriend
            }
            if (UInt32(chromosome.foe.wallCollision.value) & edge.mask) != 0 {
                wall.physicsBody!.collisionBitMask |= Fascinator.maskFoe
            }
            if (UInt32(chromosome.imageWallCollision.value) & edge.mask) != 0 {
                wall.physicsBody!.collisionBitMask |= Fascinator.maskBg
            }
            
            walls.addChild(wall)
        }
        
        fascinatorSKNode.addChild(walls)
    }
    
    func createAttachmentToScene(_ body: SKPhysicsBody, attachmentChromosome: AttachmentSubChromosome, attachmentPointArea: CGSize) -> (SKPhysicsJoint?, CGPoint) {
        body.allowsRotation = attachmentChromosome.canRotate.value
        
        let localAnchor = CGPoint(
            x: attachmentPointArea.width  * 0.5 * attachmentChromosome.anchorX.value,
            y: attachmentPointArea.height * 0.5 * attachmentChromosome.anchorY.value)
        var worldAnchor = body.node!.convert(localAnchor, to: scene)
        
        if body === artImageNode.physicsBody && controllerAttachmentPoint != nil{
            worldAnchor = controllerAttachmentPoint
        }
        
        switch attachmentChromosome.joint.value {
        case .fixed:
            let joint = SKPhysicsJointFixed.joint(withBodyA: body, bodyB: fascinatorSKNode.physicsBody!, anchor: worldAnchor)
            scene.physicsWorld.add(joint)
            return (joint, worldAnchor)
            
        case .pin:
            let joint = SKPhysicsJointPin.joint(withBodyA: body, bodyB: fascinatorSKNode.physicsBody!, anchor: worldAnchor)
            joint.frictionTorque = 0.7
            scene.physicsWorld.add(joint)
            return (joint, worldAnchor)
            
        case .spring:
            var secondAnchor = worldAnchor
            if body === artImageNode.physicsBody{
                secondAnchor = artImageNode.position
            }
            let joint = SKPhysicsJointSpring.joint(withBodyA: body, bodyB: fascinatorSKNode.physicsBody!, anchorA: worldAnchor, anchorB: secondAnchor)
            joint.frequency = attachmentChromosome.springStiffness.value
            joint.damping = attachmentChromosome.springDamping.value
            scene.physicsWorld.add(joint)
//            print("anchorA: \(worldAnchor)  anchorB: \(secondAnchor)")
            return (joint, worldAnchor)
            
        case .slider:
            let angle = MathsUtils.degreesToRadians(attachmentChromosome.sliderAxis.value)
            let axis = CGVector(dx: cos(angle), dy: -sin(angle))
            let limit = attachmentChromosome.distanceLimit.value * sceneSize.height * 0.5
            
            let sliderBody: SKPhysicsBody
            
            if body.allowsRotation {
                axle = SKNode()
                axle.position = body.node!.position
                axle.physicsBody = SKPhysicsBody()
                axle.physicsBody!.mass = 1
                fascinatorSKNode.addChild(axle)
                
                let axleJoint = SKPhysicsJointPin.joint(withBodyA: body, bodyB: axle.physicsBody!, anchor: worldAnchor)
                axleJoint.frictionTorque = 0.7
                scene.physicsWorld.add(axleJoint)
                
                sliderBody = axle.physicsBody!
            }
            else {
                sliderBody = body
            }
            
            let sliderJoint = SKPhysicsJointSliding.joint(withBodyA: sliderBody, bodyB: fascinatorSKNode.physicsBody!, anchor: worldAnchor, axis: axis)
            sliderJoint.shouldEnableLimits = (limit > 0)
            sliderJoint.lowerDistanceLimit = -limit
            sliderJoint.upperDistanceLimit = +limit
            scene.physicsWorld.add(sliderJoint)

            return (sliderJoint, worldAnchor)

        case .none:
            return (nil, worldAnchor)
        }
    }
    
    func removePhysicsFromScene() {
        if axle != nil {
            axle.removeFromParent()
            axle = nil
        }
        
        attachmentJoint = nil
        
        for field in attractFields {
            field.removeFromParent()
        }
        attractFields.removeAll()
        fingerAttractFields.removeAll()
        
        for field in fields {
            field.removeFromParent()
        }
        fields.removeAll()
        
        fascinatorSKNode.physicsBody = nil
        artImageNode.physicsBody = nil
    }
    
    func addPhysicsToScene(_ scene: SKScene) {
        removePhysicsFromScene()
        
        self.scene = scene
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        fascinatorSKNode.physicsBody = SKPhysicsBody()
        fascinatorSKNode.physicsBody!.restitution = chromosome.imageBounciness.value
        fascinatorSKNode.physicsBody!.isDynamic = false
        
        emptyArtImage = false
        if controllerOverlayImage != nil{
            let radius = sceneSize.width * controllerSize * 0.5
            var needsFlipBack = false
            if artImageNode.xScale == -1{
                needsFlipBack = true
                artImageNode.xScale = 1
            }
            artImageNode.physicsBody = CharacterIconHandler.getPhysicsBody(radius: radius, collectionNum: controllerCollectionNum, characterNum: controllerCharacterNum, isController: true)
            if needsFlipBack{
                artImageNode.xScale = -1
            }
            let offset = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
            artImageBoundingBox = CharacterIconHandler.getCharacterBoundingBox(radius: radius, collectionNum: controllerCollectionNum, characterNum: controllerCharacterNum, centreOffset: offset)
            
            CharacterIconHandler.alterNodeOrientation(isGrid: false, collectionNum: controllerCollectionNum, characterNum: controllerCharacterNum, reflectionID: controllerReflectionID, node: artImageNode)
            
            if controllerColour != nil{
                artImageNode.colorBlendFactor = 0.5
                artImageNode.color = controllerColour
            }
            else{
                artImageNode.colorBlendFactor = 0
            }

        }
        else if !drawingPaths.isEmpty{
            let scale = 0.5 * imageAndLightingChromosome.artImageSize.value
            artImageNode.physicsBody = DrawingHandler.getPhysicsBody(scale, paths: drawingPaths, sceneSize: sceneSize)
            artImageBoundingBox = DrawingHandler.getBoundingBox(scale, paths:drawingPaths, sceneSize: sceneSize)
            if controllerReflectionID != nil{
                CharacterIconHandler.alterNodeOrientation(isGrid: true, collectionNum: 0, characterNum: 0, reflectionID: controllerReflectionID, node: artImageNode)
            }
        }
        else{
            artImageNode.physicsBody = nil
            artImageBoundingBox = CGRect(x: -0.5, y: -0.5, width: 1, height: 1)
            emptyArtImage = true
        }
        if artImageNode.physicsBody != nil{
            artImageNode.physicsBody!.isDynamic = true
            artImageNode.physicsBody!.mass = 10
            //artImageNode.physicsBody!.usesPreciseCollisionDetection = true
            artImageNode.physicsBody!.restitution = chromosome.imageBounciness.value
            artImageNode.physicsBody!.linearDamping = 1
            artImageNode.physicsBody!.allowsRotation = chromosome.attachment.canRotate.value
            artImageNode.physicsBody!.categoryBitMask = Fascinator.maskBg
            artImageNode.physicsBody!.collisionBitMask = 0
            if chromosome.friendImageCollision.value != .passThrough {
                artImageNode.physicsBody!.collisionBitMask |= Fascinator.maskFriend
            }
            if chromosome.foeImageCollision.value != .passThrough {
                artImageNode.physicsBody!.collisionBitMask |= Fascinator.maskFoe
            }
            artImageNode.physicsBody!.collisionBitMask |= UInt32(chromosome.imageWallCollision.value) << Fascinator.maskOffsetWall
            artImageNode.physicsBody!.contactTestBitMask = Fascinator.maskFriend | Fascinator.maskFoe
            artImageNode.physicsBody!.fieldBitMask = 0
            
            let (joint, point) = createAttachmentToScene(artImageNode.physicsBody!, attachmentChromosome: chromosome.attachment, attachmentPointArea: sceneSize)
            attachmentJoint = joint
            attachmentPoint = point
        }
        
        for who in [Ball.BallType.friend, Ball.BallType.foe] {
            setupAttractField(who)
            
            let noiseStrength = chromosome.getBallSubChromosome(who).noiseStrength.value
            
            if noiseStrength > 0 {
                let noiseField = SKFieldNode.noiseField(withSmoothness: chromosome.getBallSubChromosome(who).noiseWaves.value, animationSpeed: 1)
                noiseField.strength = Float(noiseStrength)
                noiseField.categoryBitMask = (who == .friend) ? 0x0F : 0xF0
                fascinatorSKNode.addChild(noiseField)
                fields.append(noiseField)
            }
        }
        
        for ballType: Ball.BallType in [.friend, .foe] {
            for _ in 0 ..< chromosome.getBallSubChromosome(ballType).numAtStart.value {
                _ = tryToSpawnBall(ballType)
            }
        }
        
        // HACK FOR LET IT SNOW - ONLY THE CONTROLLER HITS THE WALLS
        if chromosome.imageWallCollision.value > 0{
            addWalls()
        }
        else if walls != nil {
            walls.removeFromParent()
            walls = nil
        }

        scene.physicsWorld.contactDelegate = self
    }
    
    func setupAttractField(_ who : Ball.BallType) {
        
        let ballChromosome = chromosome.getBallSubChromosome(who)
        
        switch ballChromosome.attractTo.value {
        case .none, .centre, .finger, .image:
            let field = SKFieldNode.radialGravityField()
            field.strength = Float(ballChromosome.attraction.value)
            switch who {
            case .friend:
                field.categoryBitMask = 0x0F
            case .foe:
                field.categoryBitMask = 0xF0
            }
            field.falloff = 0
            field.minimumRadius = 1
            
            switch ballChromosome.attractTo.value {
            case .none, .finger:
                field.isEnabled = false
                fallthrough
            case .centre:
                field.position = sceneCentre
                fascinatorSKNode.addChild(field)
            case .image:
                field.position = CGPoint.zero
                artImageNode.addChild(field)
            case .oppositeSide:
                break
            }
            
            attractFields.append(field)
            if ballChromosome.attractTo.value == .finger {
                fingerAttractFields.append(field)
            }
            
        case .oppositeSide:
            for edge in Edge.allEdges {
                let strength = Float(ballChromosome.attraction.value)
                
                let gravityVector: vector_float3
                switch edge.opposite {
                case .left:
                    gravityVector = vector_float3(-strength, 0, 0)
                case .right:
                    gravityVector = vector_float3(+strength, 0, 0)
                case .bottom:
                    gravityVector = vector_float3(0, -strength, 0)
                case .top:
                    gravityVector = vector_float3(0, +strength, 0)
                }
                
                let field = SKFieldNode.linearGravityField(withVector: gravityVector)
                
                switch who {
                case .friend:
                    field.categoryBitMask = UInt32(1 << edge.rawValue)
                case .foe:
                    field.categoryBitMask = UInt32(1 << (edge.rawValue + 4))
                }
                
                fascinatorSKNode.addChild(field)
                attractFields.append(field)
            }
            break
        }
        
    }
    
    func precacheIconImages() {
        
        func ballImageName(type: Ball.BallType) -> String {
            return type == .foe ? CharacterIconHandler.getCharacterName(collectionNum: chromosome.foe.characterCollectionNum.value, characterNum: chromosome.foe.characterNum.value) : CharacterIconHandler.getCharacterName(collectionNum: chromosome.friend.characterCollectionNum.value, characterNum: chromosome.friend.characterNum.value)

            
            //            let icon = chromosome.getBallSubChromosome(type).icon.value
//            return "\(icon)"
        }

//        let startTime = CFAbsoluteTimeGetCurrent()
        var ballsizes: [CGSize] = []

        for s in MPCGDGenome.sizeNums {
            let size = CGFloat(s) * 2.0
            ballsizes.append(CGSize(width: size, height: size))
        }

        let foeImageName = ballImageName(type: .foe)
        let friendImageName = ballImageName(type: .friend)

        let foeImages = PDFImages(named: foeImageName, sizes: ballsizes)
        let friendImages = PDFImages(named: friendImageName, sizes: ballsizes)

//        print("Fascinator.precacheIconPDFImages took \(1000.0 * (CFAbsoluteTimeGetCurrent() - startTime))ms")

        if foeImages != nil {
            BallTextureCache.foe.populate(images: foeImages!)
        }
        if friendImages != nil {
            BallTextureCache.friend.populate(images: friendImages!)
        }
    }
    
    func restartAfterLifeLost(){
        lifeLostAnimationIsHappening = true
        for b in balls{
            b.node.run(SKAction.fadeOut(withDuration: 0.3))
        }
        artImageNode.physicsBody = nil

        if artImageNode != nil && artImageColour != nil{
            makeExplosionAt(self.artImageNode.position, velocity: CGVector.zero, colour: artImageColour!, scale: 0.1, numParticles: 17, effectName: ParticleEffect.foe)
            artImageNode.run(SKAction.scale(by: 0.1, duration: 0.3), completion: {
                self.artImageNode.setScale(1)
                self.restart()
            })
            artImageNode.run(SKAction.fadeOut(withDuration: 0.3), completion: {
                self.artImageNode.alpha = 1
            })
        }
        else{
            self.fascinatorSKNode.run(SKAction.wait(forDuration: 0.3), completion: {
                self.restart()
            })
        }
    }

    func onQuitMemoryCleanup() {
        removeAllBalls()
        removePhysicsFromScene()
        BallTextureCache.friend.wipe()
        BallTextureCache.foe.wipe()
        self.chromosome = nil
        gameLog.removeAll()
        self.backingNode.texture = nil
        self.artImageNode.texture = nil
    }
    
    func restart() {
        
        lifeLostAnimationIsHappening = false
        score = restartScore
        noLivesLeft = false
        
        if !positiveScoresPossible{
            livesDisplay.x = sceneSize.width - 10
            livesDisplay.horizontalAlignmentMode = .right
        }
        else{
            livesDisplay.x = sceneSize.width/2
            livesDisplay.horizontalAlignmentMode = .center
        }
        
        livesDisplay.alpha = (livesLeft == 0) ? 0 : 1
        scoreDisplay.alpha = positiveScoresPossible ? 1 : 0
        
        gameSpeed = Double(chromosome.physicsSpeed.value)
        
        if scene != nil{
            scene.physicsWorld.speed = CGFloat(gameSpeed)
        }
        
        precacheIconImages()
        
        removeAllBalls()
        
        artImageNode.position = sceneCentre
        
        // HACK FOR LET IT SNOW
        if controllerStartPosition != nil{
            artImageNode.position = controllerStartPosition
        }
        
        artImageNode.zRotation = 0
        calculateImageLayers()
        
        //rescaleArtImage(force: false)
        
        artImageData = ImageData(image: artImage)
        
        // HACK FOR LET IT SNOW
        if self.scene != nil{
            //        if artImageNode.physicsBody != nil {
            addPhysicsToScene(self.scene)
            //        }
        }
        
        switch chromosome.controlType.value {
        case .none:
            artImageController = ImpotentController(fascinator: self)
        case .dragRotate:
            artImageController = DragRotateController(fascinator: self)
        case .dragMove:
            artImageController = DragMoveController(fascinator: self)
            // HACK FOR LET IT SNOW
            (artImageController as! DragMoveController).useBoundingBoxFix = useBoundingBoxFix
            (artImageController as! DragMoveController).detachJointOnDrag = detachJointOnDrag
        case .moveTowardsFinger:
            artImageController = TowardsFingerController(fascinator: self)
        case .swipeOnGrid:
            artImageController = GridSwipeController(fascinator: self)
        case .teleport:
            artImageController = TeleportController(fascinator: self)
        }
        
        imageGridPointOverride = nil
        
        scoreDisplay.text = "\(score)"
        timeDisplay.text = "\(Int(floor(restartTimeElapsed)))s"
        livesDisplay.text = "Lives: \(livesLeft)"
        scoreDisplay.fontColor = scoreColour
        (scoreDisplay.children[0] as! SKLabelNode).fontColor = scoreColour
        timeDisplay.fontColor = scoreColour
        livesDisplay.fontColor = scoreColour
        
        // If the spawning rate is zero, these evaluate to +inf, which results in no spawning
        nextFriendSpawnTime = restartTimeElapsed + TimeInterval(1.0 / chromosome.friend.numPerSecond.value)
        nextFoeSpawnTime = restartTimeElapsed + TimeInterval(1.0 / chromosome.foe.numPerSecond.value)
        
        // Determine rarest ball type
        if chromosome.friend.maxBalls.value < chromosome.foe.maxBalls.value {
            rarestBallType = .friend
        }
        else if chromosome.foe.maxBalls.value < chromosome.friend.maxBalls.value {
            rarestBallType = .foe
        }
        else if chromosome.friend.numPerSecond.value < chromosome.foe.numPerSecond.value {
            rarestBallType = .friend
        }
        else if chromosome.foe.numPerSecond.value < chromosome.friend.numPerSecond.value {
            rarestBallType = .foe
        }
        else {
            rarestBallType = nil
        }
        
        if rarestBallType != nil {
            let ch = chromosome.getBallSubChromosome(rarestBallType!)
            print("Rarest ball type = \(CharacterIconHandler.getCharacterName(collectionNum: ch.characterCollectionNum.value, characterNum: ch.characterNum.value))")
        } else {
            print("Rarest ball type = nil")
        }
        
        friendSpawnAngle = chromosome.friend.spawnAngle.value
        foeSpawnAngle = chromosome.foe.spawnAngle.value
        ballsSpawned    = [.friend: 0, .foe: 0]
        clustersMatched = [.friend: 0, .foe: 0]
        startTime = Date()
        //       timeSpentPaused = 0
        
        // HACK FOR LET IT SNOW (
        // timeElapsed = 0
        timeElapsed = restartTimeElapsed
//        timeElapsed = -0.5
        lastCounterUpdateTime = 0
        if chromosome.duration.value > 0 {
            timeLeft = TimeInterval(chromosome.duration.value) - restartTimeElapsed
        }
        else {
            timeLeft = TimeInterval.infinity
        }
        
        // Preserve "paused-ness", but act as if the game was just paused now
        whenPaused = (whenPaused != nil) ? Date() : nil
        
        gameIsOver = false
//        counters = [.score: chromosome.scoreStartValue.value, .health: chromosome.healthStartValue.value, .progress: chromosome.progressStartValue.value]
        lastFingerPos = sceneCentre
        isDragging = false
        
        if gameOverField != nil {
            gameOverField.removeFromParent()
            gameOverField = nil
        }
        
        // HACK FOR LET IT SNOW
        //goalSides = chromosome.batAwayGoals.value
        
        gameLog.removeAll()
        lastSnapshotTime = 0

        if shouldInitialiseSoundOnRestart {
            //TODO(audio): Stop music
            //SoundEngine.singleton.stopMusic()
        }

        firstTickAfterRestart = true
    }
    
    func calculateImageLayers(){
        
        let layerType = imageAndLightingChromosome.layers.value
        
        // Backing
        if layerType == .back || layerType == .artOnBack || layerType == .drawArtOnBack || layerType == .drawOnBack{
            backingNode.texture = SKTexture(image: backing)
        }
        else if layerType == .drawOnBackArt{
            let composite = ImageUtils.blendImages(backing, topImage: fascinatorContent.imageOnWhite, blendMode: "CIMultiplyBlendMode")
            backingNode.texture = SKTexture(image: composite)
        }
        
        // Art image
        
        if layerType == .back{
            artImage = ImageUtils.getBlankImage(CGSize(width: 100, height: 100), colour: UIColor.clear)
        }
        else if layerType == .artOnBack {
            artImage = fascinatorContent.imageOnWhite
        }
        else if layerType == .drawOnBack || layerType == .drawOnBackArt{
            if controllerOverlayImage != nil{
                artImage = controllerOverlayImage
            }
            else if !drawingPaths.isEmpty{
                artImage = DrawingHandler.getDrawingImage(paths: drawingPaths, sceneSize: sceneSize)
            }
            else{
                artImage = ImageUtils.getBlankImage(CGSize(width: 10, height: 10), colour: UIColor.clear)
            }
        }
        else if layerType == .drawArtOnBack{
            if !drawingPaths.isEmpty{
                artImage = ImageUtils.blendImages(fascinatorContent.imageOnWhite, topImage: DrawingHandler.getDrawingImage(paths: drawingPaths, sceneSize: sceneSize), blendMode: "CIMultiplyBlendMode")
            }
            else{
                artImage = fascinatorContent.imageOnWhite
            }
        }
        rescaleArtImage(force: true)
        //            artImageNode.texture = SKTexture(image: artImage)
        
        if pauseInfoGraphic != nil{
            pauseInfoGraphic!.removeFromParent()
        }
        
        if scene != nil{
            let fascinatorName = (scene as! MainScene).currentGameName
            
            if fascinatorName == "LIS" || fascinatorName == "RR" || fascinatorName == "SS" || fascinatorName == "JF"{
                pauseInfoGraphic = SKSpriteNode(texture: SKTexture(image: UIImage(named: "PauseSmallNoBacking")!))
                let device = UIDevice.current.model
                
                if device.contains("iPad") {
                    pauseInfoGraphic.position = CGPoint(x: 0, y: -artImageNode.size.height/2 + pauseInfoGraphic.size.height/2)
                } else {
                    pauseInfoGraphic.position = CGPoint(x: 0, y: -artImageNode.size.height/2 + pauseInfoGraphic.size.height - 10)
                }
                pauseInfoGraphic.position.x -= 60
                let aiNode = HKImage(image: UIImage(named: "AIHand")!)
                aiNode.size = aiNode.size * 0.35
                aiNode.position.x += 130
                aiNode.position.y -= 10
//                aiNode.alpha = 0.7
                aiNode.zRotation = -1.1
                pauseInfoGraphic.addChild(aiNode)
                
                let prop = Int(round(playtesterStrategyGlobalProbability * 100))
                var aiText = "\(prop)%"
                aiText = (prop == 0) ? "off" : aiText
                aiText = (prop == 100) ? "max" : aiText
                
                let textNode = SKMultilineLabel(text: "AI\nassist\n\(aiText)", size: CGSize(width: 100, height: 60), pos: CGPoint(x: 0, y: 0), fontName: "Helvetica Neue Thin", fontSize: 20, fontColor: Colours.getColour(.black), alignment: .center, shouldShowBorder: false, spacing: 2.3)

                textNode.position.x += 180
                textNode.position.y += 4
                textNode.labels[2].fontName = "Helvetica Neue Bold"
                pauseInfoGraphic.addChild(textNode)
                
                artImageNode.addChild(pauseInfoGraphic)
            }
        }
    }
    
    func countBalls(_ predicate: (Ball) -> Bool) -> Int {
        var result: Int = 0
        for ball in balls {
            if predicate(ball) {
                result += 1
            }
        }
        
        return result
    }
    
    func getPointOnEdgeOfScreen(_ angle: CGFloat) -> (Edge, CGPoint) {
        var theta = angle
        while theta >  MathsUtils.π { theta -= 2 * MathsUtils.π }
        while theta < -MathsUtils.π { theta += 2 * MathsUtils.π }
        
        // http://stackoverflow.com/questions/4061576/finding-points-on-a-rectangle-at-a-given-angle
        let rectAtan = atan2(sceneSize.height, sceneSize.width)
        let tanTheta = tan(theta)
        let region: Edge
        
        if theta > -rectAtan && theta <= rectAtan {
            region = .right
        }
        else if theta > rectAtan && theta <= MathsUtils.π - rectAtan {
            region = .bottom
        }
        else if theta > MathsUtils.π - rectAtan || theta <= -(MathsUtils.π - rectAtan) {
            region = .left
        }
        else {
            region = .top
        }
        
        var edgePoint = sceneSize.centrePoint()
        var xFactor: CGFloat = 1
        var yFactor: CGFloat = 1
        
        if region == .right || region == .bottom {
            yFactor = -1
        }
        else {
            xFactor = -1
        }
        
        if region == .right || region == .left {
            edgePoint.x += xFactor * sceneSize.width * 0.5
            edgePoint.y += yFactor * sceneSize.width * 0.5 * tanTheta
        }
        else {
            edgePoint.x += xFactor * sceneSize.height * 0.5 / tanTheta
            edgePoint.y += yFactor * sceneSize.height * 0.5
        }
        
        return (region, edgePoint)
    }
    
    func getClosestEdge(_ position: CGPoint) -> Edge {
        var closestEdge : Edge? = nil
        var closestDist : CGFloat = CGFloat.infinity
        
        for edge in Edge.allEdges {
            let dist : CGFloat
            switch edge
            {
            case .bottom:
                dist = position.y - deviceSimulationYOffset
            case .top:
                dist = sceneSize.height - deviceSimulationYOffset - position.y
            case .left:
                dist = position.x - deviceSimulationXOffset
            case .right:
                dist = sceneSize.width - deviceSimulationXOffset - position.x
            }
            
            if closestEdge == nil || dist < closestDist {
                closestEdge = edge
                closestDist = dist
            }
        }
        
        return closestEdge!
    }
    
    func isBallSpawnPositionOK(_ position: CGPoint, radius: CGFloat, ballType : Ball.BallType, checkReservedSpots : Bool) -> Bool {
        let ballChromosome = chromosome.getBallSubChromosome(ballType)
        
        // Check distance from art image
        let distFromImage = (artImageNode.position - position).magnitude()
        if distFromImage < ballChromosome.spawnMinDistFromImage.value {
            return false
        }
        
        if ballChromosome.spawnMaxDistFromImage.value != 0 && distFromImage > ballChromosome.spawnMaxDistFromImage.value {
            return false
        }
        
        if checkReservedSpots {
            for reserved in reservedSpawnSpots {
                let distSq = (reserved.position - position).sqrMagnitude()
                let d = reserved.radius + radius
                if distSq < d*d {
                    return false
                }
            }
        }
        
        for ball in balls {
            //var minDist: CGFloat
            var maxDist : CGFloat
            switch ball.type {
            case .friend:
                //minDist = ballChromosome.spawnMinDistFromFriends.value
                maxDist = ballChromosome.spawnMaxDistFromFriends.value
            case .foe:
                //minDist = ballChromosome.spawnMinDistFromFoes.value
                maxDist = ballChromosome.spawnMaxDistFromFoes.value
            }
            
            if maxDist == 0 {
                maxDist = CGFloat.infinity
            }
            
            let distSq = (ball.node.position - position).sqrMagnitude()
            
            // HACK FOR LET IT SNOW - IGNORE THE MIN DISTANCE
            let d1 = ball.radius * 2
            let d2 = radius * 2
            if distSq < (d1 * d1) || distSq < (d2 * d2){
                return false
            }
            
            // USED TO BE:
//            if distSq < minDist * minDist || distSq > maxDist * maxDist {
//                return false
//            }
        }
        
        return true
    }
    
    func chooseBallSpawnLocation(_ location : BallSubChromosome.SpawnLocation, ballType : Ball.BallType, radius: CGFloat, forceSuccess: Bool) -> CGPoint? {
        let maxAttempts : Int
        switch location {
        case .imageCentre, .finger:
            // Deterministic -- no point trying more than once
            maxAttempts = 1
        default:
            // Random
            maxAttempts = 100
        }
        
        for attempt in 1 ... maxAttempts
        {
            var position : CGPoint! = nil
            
            switch location {
            case .locations:
                if ballType == .friend && !friendSpawnLocations.isEmpty{
                    position = RandomUtils.randomChoice(friendSpawnLocations)
                }
                else if ballType == .foe && !foeSpawnLocations.isEmpty{
                    position = RandomUtils.randomChoice(foeSpawnLocations)
                }
                
                // HACK FOR LET IT SNOW - MOVE BALL IN A BIT
                if position != nil{
                    position.x = min(position.x, deviceSimulationXOffset + sceneSize.width + radius - 7)
                    position.x = max(position.x, deviceSimulationXOffset + -radius + 7)
                    position.y = min(position.y, deviceSimulationYOffset + sceneSize.height + radius - 7)
                    position.y = max(position.y, deviceSimulationYOffset + -radius + 7)
                }

            case .edges:
                let angleCentre: CGFloat
                let angleRange = chromosome.getBallSubChromosome(ballType).spawnAngleRange.value
                switch ballType {
                case .friend:
                    angleCentre = friendSpawnAngle
                case .foe:
                    angleCentre = foeSpawnAngle
                }
                
                let angle = MathsUtils.degreesToRadians(CGFloat(RandomUtils.randomFloat(angleCentre - angleRange, upperInc: angleCentre + angleRange)))
                position = getPointOnEdgeOfScreen(angle).1
                
            case .imageCentre:
                position = artImageNode.position
                
            case .onImage, .offImage, .anywhere:
                let x = RandomUtils.randomFloat(0, upperInc: sceneSize.width)
                let y = RandomUtils.randomFloat(0, upperInc: sceneSize.height)
                position = CGPoint(x: x, y: y)
                
            case .finger:
                position = lastFingerPos
            }
            
            if position != nil{
                
                if forceSuccess {
                    return position
                }
                else if attempt == maxAttempts && chromosome.getBallSubChromosome(ballType).spawnFail.value == .forceSpawn {
                    // Force the final attempt to succeed
                    return position
                }
                else {
                    var ok : Bool
                    switch location {
                    case .onImage:
                        ok = isArtImageAtPoint(position)
                    case .offImage:
                        ok = !isArtImageAtPoint(position)
                    default:
                        ok = true
                    }
                    
                    ok = ok && isBallSpawnPositionOK(position, radius: radius, ballType: ballType, checkReservedSpots: true)
                    
                    if ok {
                        return position
                    }
                }
            }
        }
        return nil
    }
    
    func canSpawnBallWithinNumberLimits(_ ballType: Ball.BallType, extraBalls: Int = 0) -> Bool {
        let numBalls: Int
        switch chromosome.maxBallsMode.value {
        case .all:
            numBalls = countBalls({ball in !ball.removeOnNextFrame})
        case .notStuckToImage:
            numBalls = countBalls({ball in !ball.removeOnNextFrame && !ball.isStuck})
        }
        
        let numBallsOfType: Int
        switch chromosome.getBallSubChromosome(ballType).maxBallsMode.value {
        case .all:
            numBallsOfType = countBalls({ball in ball.type == ballType && !ball.removeOnNextFrame})
        case .notStuckToImage:
            numBallsOfType = countBalls({ball in ball.type == ballType && !ball.removeOnNextFrame && !ball.isStuck})
        }
        
        // Prevent tap-on-change from spawning too many balls
        let maxActiveBalls =
            chromosome.getBallSubChromosome(.foe).maxBalls.value +
                chromosome.getBallSubChromosome(.friend).maxBalls.value
        
        return numBalls + extraBalls < chromosome.maxBalls.value
            && numBallsOfType + extraBalls < chromosome.getBallSubChromosome(ballType).maxBalls.value
            && numBalls + extraBalls < maxActiveBalls
    }
    
    // Formerly known as createBall
    func tryToSpawnBall(_ ballType: Ball.BallType) -> Ball? {

        if canSpawnBallWithinNumberLimits(ballType) {
            let ballChromosome = chromosome.getBallSubChromosome(ballType)
            
            let radius = Ball.chooseRadius(ballChromosome)
            let pos = chooseBallSpawnLocation(ballChromosome.spawnLocation.value, ballType: ballType, radius: radius, forceSuccess: false)
            
            if pos != nil {
                return spawnBall(ballType: ballType, pos: pos!, radius: radius)
            }
            else if ballType == rarestBallType {
                let numReserved = reservedSpawnSpots.filter({ r in r.ballType == ballType }).count
                if canSpawnBallWithinNumberLimits(ballType, extraBalls: numReserved) {
                    if let reservePos = chooseBallSpawnLocation(ballChromosome.spawnLocation.value, ballType: ballType, radius: radius, forceSuccess: true) {
                        reserveSpawnSpot(ballType: ballType, pos: reservePos, radius: radius)
                    }
                }
                return nil
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    func spawnBall(ballType: Ball.BallType, pos: CGPoint, radius: CGFloat) -> Ball {
        let ballChromosome = chromosome.getBallSubChromosome(ballType)
        let ball = Ball(fascinator: self, position: pos, type: ballType, radius: radius)
        
        let collectionNum = ballChromosome.characterCollectionNum.value
        let characterNum = ballChromosome.characterNum.value
        
        if pos.x > sceneSize.width/2 && CharacterIconHandler.requiresHorizontalFlipIfSpawnedOnRight(collectionNum: collectionNum, characterNum: characterNum){
            ball.node.xScale *= -1
        }
        else if pos.x <= sceneSize.width/2 && CharacterIconHandler.requiresHorizontalFlipIfSpawnedOnLeft(collectionNum: collectionNum, characterNum: characterNum){
            ball.node.xScale *= -1
        }
        else if CharacterIconHandler.requiresRotationIfSpawnedAtTopOrSides(collectionNum: collectionNum, characterNum: characterNum){
            if ball.spawnedFrom == .left{
                ball.node.zRotation = -CGFloat.pi / 2
            }
            else if ball.spawnedFrom == .right{
                ball.node.zRotation = CGFloat.pi / 2
            }
            else if ball.spawnedFrom == .top{
                ball.node.zRotation = CGFloat.pi
            }
        }
        
        let speedBase = ballChromosome.initialSpeed.value
        let speedRange = ballChromosome.initialSpeedRange.value
        
        let speed = RandomUtils.randomFloat(speedBase - speedRange, upperInc: speedBase + speedRange)
        let direction: CGVector
        
        switch ballChromosome.initialMovementAngle.value {
        case .random:
            let angle = RandomUtils.randomFloat(0, upperInc: 2 * MathsUtils.π)
            direction = CGVector(dx: cos(angle), dy: sin(angle))
            
        case .towardsCentre:
            direction = (sceneCentre - pos).normalised()
            
        case .awayFromCentre:
            direction = (pos - sceneCentre).normalised()
            
        case .towardsImage:
            direction = (artImageNode.position - pos).normalised()
            
        case .awayFromImage:
            direction = (pos - artImageNode.position).normalised()
            
        case .towardsSide:
            direction = ball.spawnedFrom.directionVector
            
        case .towardsOppositeSide:
            direction = ball.spawnedFrom.opposite.directionVector
            
        case .aimDirection:
            let angle = artImageNode.zRotation + MathsUtils.degreesToRadians(chromosome.forwardDirection.value)
            direction = CGVector(dx: -sin(angle), dy: cos(angle))
        }
        
        ball.node.physicsBody!.velocity = direction * speed
        
        if ballChromosome.beginStuckInPlace.value {
            ball.stickInPlace()
        }
        
        ballsSpawned[ball.type]! += 1
        
        balls.append(ball)
        //                ball.node.physicsBody?.angularVelocity = 7
        return ball
    }
    
    func reserveSpawnSpot(ballType: Ball.BallType, pos: CGPoint, radius: CGFloat) {
        /*let debugNode = SKShapeNode(circleOfRadius: radius)
        debugNode.position = pos
        debugNode.fillColor = UIColor.orange.withAlphaComponent(0.5)
        debugNode.strokeColor = UIColor.orange
        debugNode.lineWidth = 2
        fascinatorSKNode.addChild(debugNode)*/
        
        reservedSpawnSpots.append(ReservedSpawnSpot(ballType: ballType, position: pos, radius: radius, debugNode: nil))
    }
    
    func makeExplosionAt(_ position: CGPoint, velocity: CGVector, colour: UIColor, scale: CGFloat, numParticles: Int, effectName: String) {
        let particleEmitter = SKEmitterNode(fileNamed: effectName)!
        particleEmitter.setPositionTo(position)
        particleEmitter.particleColorSequence = nil
        particleEmitter.particleColor = colour
        particleEmitter.particleScale = scale
        particleEmitter.numParticlesToEmit = numParticles
//        particleEmitter.particleAlpha = 0.05
//        particleEmitter.particleAlpha =
        fascinatorSKNode.addChild(particleEmitter)
        
        let maxParticleLifetime = TimeInterval(particleEmitter.particleLifetime + particleEmitter.particleLifetimeRange)
        let timeToEmitAllParticles = TimeInterval(particleEmitter.numParticlesToEmit) / TimeInterval(particleEmitter.particleBirthRate)
        let totalDuration = maxParticleLifetime + timeToEmitAllParticles
        particleEmitter.performAction(SKAction.sequence([
            SKAction.move(by: velocity * CGFloat(totalDuration), duration: totalDuration),
            SKAction.removeFromParent()
            ]))
    }
    
    func removeBallWithParticleEffect(_ ball: Ball, effectName: String) {
        if ball.removeOnNextFrame == false {
            let explosionColour : UIColor
            let scale = max(0.1, ball.iconNode!.size.width/150)
            let numParticles = max(5, Int(ball.iconNode!.size.width)/3 - 5)
            if ball.type == .friend {
                explosionColour = CharacterIconHandler.getCharacterColour(collectionNum: chromosome.friend.characterCollectionNum.value, characterNum: chromosome.friend.characterNum.value)
            } else {
                explosionColour = CharacterIconHandler.getCharacterColour(collectionNum: chromosome.foe.characterCollectionNum.value, characterNum: chromosome.foe.characterNum.value)
            }
            makeExplosionAt(ball.node.position, velocity: ball.node.physicsBody!.velocity, colour: explosionColour, scale: scale, numParticles: numParticles, effectName: effectName)
            
            ball.removeOnNextFrame = true
        }
    }
    
    func explodeBall(_ ball: Ball, playSound: Bool) {
        if ball.type == .foe{
            removeBallWithParticleEffect(ball, effectName: ParticleEffect.foe)
        }
        else{
            removeBallWithParticleEffect(ball, effectName: ParticleEffect.friend)
        }
        if playSound{
            MPCGDAudio.playSound(path: MPCGDSounds.explode, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 1)
        }
    }
    
    func removeAllBalls() {
        for ball in balls {
            ball.removeFromScene()
        }
        balls.removeAll()
    }
    
    // PETE
    func spawnInGameScoreLabelEffect(_ at: CGPoint, score: Int, positiveColor: UIColor, negativeColor: UIColor) {
        if !gameIsOver{
            if score == 0 || !positiveScoresPossible || score == -90{
                return
            }
            // Added by Simon to stop spawning on top of an existing score
            for exN in activeSpawnedScores{
                if exN.position.isInRadiusOf(at, radius: 20){
                    return
                }
            }
            let moveDuration = 0.75
            let fadeDuration = moveDuration / 2.0

            let n = SKLabelNode()
            if score < 0 {
                n.text = "\(score)"
                n.fontColor = negativeColor
            } else {
                n.text = "+\(score)"
                n.fontColor = positiveColor
            }
            n.position = CGPoint(x: floor(at.x), y: floor(at.y))
            n.zPosition += 100
            if UIDevice.current.model.contains("iPad") {
                n.fontSize = CGFloat(24)
                n.fontName = "Helvetica Neue Thin"
                n.run(SKAction.move(by: CGVector(dx: 0.0, dy: 20.0), duration: moveDuration))
                n.run(SKAction.wait(forDuration: moveDuration - fadeDuration), completion: {
                    n.run(SKAction.fadeOut(withDuration: fadeDuration), completion: {
                        n.removeFromParent()
                        self.activeSpawnedScores.remove(n)
                    })
                })
            } else {
                n.fontSize = CGFloat(28)
                n.fontName = "Helvetica Neue Thin"
                n.run(SKAction.move(by: CGVector(dx: 0.0, dy: 30.0), duration: moveDuration))
                n.run(SKAction.wait(forDuration: moveDuration - fadeDuration), completion: {
                    n.run(SKAction.fadeOut(withDuration: fadeDuration), completion: {
                        n.removeFromParent()
                        self.activeSpawnedScores.remove(n)
                    })
                })
            }
            scene.addChild(n)
            activeSpawnedScores.append(n)
        }
    }
    
    func checkClusterCriticalSize(_ ball: Ball, sameType: Bool) -> Bool {
        let maxCluster : Int
        if sameType {
            maxCluster = ball.chromosome.criticalClusterSize.value
        }
        else {
            maxCluster = chromosome.mixedCriticalClusterSize.value
        }
            
        if maxCluster >= 2 && !ball.isExplodingInMaxCluster{
            let cluster = getCluster(ball, clusterType: sameType ? .same : .mixed)
            if cluster.count >= maxCluster {
                var clusterScoreColour = scoreColour
                var clusterScore = 0
                if sameType{
                    if ball.type == .foe{
                        clusterScore = scoring.snowClusterExplodeScore
                        clusterScoreColour = ScoringColours.foe
                    }
                    else if ball.type == .friend{
                        clusterScore = scoring.rainClusterExplodeScore
                        clusterScoreColour = ScoringColours.friend
                    }
                }
                else{
                    clusterScore = scoring.mixedClusterExplodeScore
                    clusterScoreColour = ScoringColours.mixed
                }
                clustersMatched[ball.type]! += (cluster.count - maxCluster + 1)
                var clusterCenter = CGPoint.zero
                for ball in cluster {
                    let ballPos = ball.node.position
                    clusterCenter.x += ballPos.x
                    clusterCenter.y += ballPos.y
                    explodeBall(ball, playSound: false)
                    ball.isExplodingInMaxCluster = true
                }
                clusterCenter.x /= CGFloat(cluster.count)
                clusterCenter.y /= CGFloat(cluster.count)
                spawnInGameScoreLabelEffect(clusterCenter, score: clusterScore, positiveColor: clusterScoreColour, negativeColor: clusterScoreColour)
                addToScore(clusterScore)
                
                if !gameIsOver {
                    if SoundLimiter.clusterExplode.canPlay(){
                        MPCGDAudio.playSound(path: MPCGDSounds.explode, volume: Float(sfxVolume), priority: 1, tracker: SoundLimiter.clusterExplode)
                    }
                    if SoundLimiter.gainlose.canPlay(){
                        if clusterScore > 0{
                            MPCGDAudio.playSound(path: MPCGDSounds.gainPoints, volume: Float(sfxVolume), priority: 1, tracker: SoundLimiter.clusterExplode)
                        }
                        else if clusterScore < 0 && clusterScore != -90{
                            MPCGDAudio.playSound(path: MPCGDSounds.losePoints, volume: Float(sfxVolume), priority: 1, tracker: SoundLimiter.clusterExplode)
                        }
                    }
                }
                
                
                var logEvent : [String : AnyObject?] = ["type" : "\(ball.type)" as Optional<AnyObject>, "size" : cluster.count as Optional<AnyObject>]
                var balls : [[AnyObject]] = []
                for ball in cluster {
                    balls.append([ball.node.position.x as AnyObject, ball.node.position.y as AnyObject])
                }
                logEvent["balls"] = balls as AnyObject??
                return true
            }
        }
        
        return false
    }
    
    func handleBallCollision(_ ballA : Ball, _ ballB : Ball) {
        let action: GameplayChromosome.CollisionAction
        let change: GameplayChromosome.CollisionColourChange
        
        switch (ballA.type, ballB.type) {
        case (.friend, .friend):
            action = chromosome.friendFriendCollision.value
            change = chromosome.friendFriendCollisionChange.value
            
        case (.foe, .foe):
            action = chromosome.foeFoeCollision.value
            change = chromosome.foeFoeCollisionChange.value
            
        case (.friend, .foe), (.foe, .friend):
            action = chromosome.friendFoeCollision.value
            change = chromosome.friendFoeCollisionChange.value
        }
        
        // Changing type
        switch change {
        case .none:
            break
        case .becomeFriend:
            ballA.type = .friend
            ballB.type = .friend
        case .becomeFoe:
            ballA.type = .foe
            ballB.type = .foe
        case .swap:
            ballA.type = ballA.type.otherType
            ballB.type = ballB.type.otherType
        }
        
        // Sticking or destroying
        switch action {
        case .bounce, .passThrough:
            break
            
        case .stick:
            ballA.stickTo(ballB)
            let foundCluster = checkClusterCriticalSize(ballA, sameType: true)
            if !foundCluster {
                _ = checkClusterCriticalSize(ballA, sameType: false)
            }
            break
            
        case .destroyBoth:
            explodeBall(ballA, playSound: true)
            explodeBall(ballB, playSound: true)
            
        case .destroyFriend:
            if ballA.type == .friend {
                explodeBall(ballA, playSound: true)
            }
            if ballB.type == .friend {
                explodeBall(ballB, playSound: true)
            }
            
        case .destroyFoe:
            if ballA.type == .foe {
                explodeBall(ballA, playSound: true)
            }
            if ballB.type == .foe {
                explodeBall(ballB, playSound: true)
            }
        
        default:
            print("Nothing")
        }
        
    }

    func killJustSpawnedBall(_ ball: Ball) {
        ball.removeOnNextFrame = true
        
        // Force a replacement ball of this type to be spawned on the next tick
        switch ball.type {
        case .friend:
            nextFriendSpawnTime = timeElapsed
        case .foe:
            nextFoeSpawnTime = timeElapsed
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let ballA : Ball? = contact.bodyA.node?.userData?.value(forKey: "ball") as? Ball
        let ballB : Ball? = contact.bodyB.node?.userData?.value(forKey: "ball") as? Ball
        
        // If a ball collides with something immediately after spawning, quietly remove it
        if ballA != nil && ballA!.numFramesSinceSpawn <= 1 {
            killJustSpawnedBall(ballA!)
        }
        
        if ballB != nil && ballB!.numFramesSinceSpawn <= 1 {
            killJustSpawnedBall(ballB!)
        }
        
        if ballA != nil && ballA!.hasJustLanded {
            bounceBall(ballA!)
            return
        }
        
        if ballB != nil && ballB!.hasJustLanded {
            bounceBall(ballB!)
            return
        }

        if ballA != nil && ballB != nil {
            handleBallCollision(ballA!, ballB!)
        }
        else if ballA != nil && contact.bodyB == artImageNode.physicsBody {
            if !ballA!.removeOnNextFrame{
                handleBallControllerCollision(ball: ballA!)
            }
        }
        else if ballB != nil && contact.bodyA == artImageNode.physicsBody {
            if !ballB!.removeOnNextFrame{
                handleBallControllerCollision(ball: ballB!)
            }
        }
    }
    
    func handleBallControllerCollision(ball: Ball){
        
        var playSound = false
        if controllerHasJustTeleported{
            explodeBall(ball, playSound: true)
        }
        else if ball.type == .foe && chromosome.foeImageCollision.value == .destroyFoe{
            explodeBall(ball, playSound: true)
        }
        else if ball.type == .friend && chromosome.friendImageCollision.value == .destroyFriend{
            explodeBall(ball, playSound: true)
        }
        else{
            ball.beginContactWithBg()
            playSound = true
        }
        
        let canScore = ball.previousControllerBounceTime == nil || Date().timeIntervalSince(ball.previousControllerBounceTime) > 0.2
        
        if canScore{
            if ball.type == .foe{
                spawnInGameScoreLabelEffect((ball.node.position), score: scoring.snowControllerCollision, positiveColor: ScoringColours.foe, negativeColor: ScoringColours.foe)
                addToScore(scoring.snowControllerCollision)

                if SoundLimiter.gainlose.canPlay() {
                    if scoring.snowControllerCollision > 0{
                        MPCGDAudio.playSound(path: MPCGDSounds.gainPoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2, tracker: SoundLimiter.gainlose)
                    }
                    else if scoring.snowControllerCollision < 0{
                        MPCGDAudio.playSound(path: MPCGDSounds.losePoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2, tracker: SoundLimiter.gainlose)
                    }
                }
            }
            else if ball.type == .friend{
                spawnInGameScoreLabelEffect((ball.node.position), score: scoring.rainControllerCollision, positiveColor: ScoringColours.friend, negativeColor: ScoringColours.friend)
                addToScore(scoring.rainControllerCollision)
                if SoundLimiter.gainlose.canPlay() {
                    if scoring.rainControllerCollision > 0{
                        MPCGDAudio.playSound(path: MPCGDSounds.gainPoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2, tracker: SoundLimiter.gainlose)
                    }
                    else if scoring.rainControllerCollision < 0{
                        MPCGDAudio.playSound(path: MPCGDSounds.losePoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2, tracker: SoundLimiter.gainlose)
                    }
                }
            }
            if playSound && SoundLimiter.bounce.canPlay() {
                MPCGDAudio.playSound(path: MPCGDSounds.bounce, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2, tracker: SoundLimiter.bounce)
            }
        }
        
        ball.previousControllerBounceTime = Date()
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
    func isArtImageAtPoint(_ point: CGPoint) -> Bool {
        let localPoint = artImageNode.convert(point, from: scene)
        let propX = 0.5 + (localPoint.x / artImageNode.size.width)
        let propY = 0.5 - (localPoint.y / artImageNode.size.height)
        let pixelX = Int(propX * artImageData.bounds.width)
        let pixelY = Int(propY * artImageData.bounds.height)
        
        if artImageData.bounds.contains(CGPoint(x: pixelX, y: pixelY)) {
            let (r,g,b,a) = artImageData.rgbaTupleAt(pixelX, y: pixelY)
            return ImageUtils.isNotWhite(r, g: g, b: b, a: a)
        }
        else {
            return false
        }
    }
    
    func getBallsNearPoint(_ point: CGPoint, radius: CGFloat) -> [(CGFloat, Ball)] {
        
        if chromosome.showTouch.value {
            let visual = SKShapeNode(circleOfRadius: radius)
            visual.position = point
            visual.fillColor = UIColor.yellow.withAlphaComponent(0.25)
            visual.strokeColor = UIColor.yellow.withAlphaComponent(0.5)
            fascinatorSKNode.addChild(visual)
            visual.run(SKAction.fadeOut(withDuration: 1), completion: {
                visual.removeFromParent()
            })
        }
        
        var result: [(CGFloat, Ball)] = []
        let sqrRadius = radius * radius
        
        for ball in balls {
            let sqrDistance = (ball.node.position - point).sqrMagnitude()
            if sqrDistance < sqrRadius {
                result.append((sqrt(sqrDistance), ball))
            }
        }
        
        // Sort in ascending order of distance from the point
        result.sort(by: {a, b in a.0 < b.0})
        
        return result
    }
    
    func bounceBall(_ ball: Ball){
        let p = ball.node.physicsBody!
        let v = ball.node.physicsBody?.velocity
        let f = ball.node.physicsBody?.fieldBitMask
        ball.node.physicsBody = SKPhysicsBody()
        ball.node.physicsBody?.velocity = v!
        ball.node.physicsBody?.fieldBitMask = f!
        let z = ball.node.zPosition
        ball.node.zPosition = 1000
        ball.isFlying = true
        var sequence = SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.3),
                                          SKAction.wait(forDuration: 0.4), SKAction.scale(to: 1.0, duration: 0.3)])
        if ball.node.xScale == -1{
            let sequence1 = SKAction.sequence([SKAction.scaleX(to: -1.2, duration: 0.3),
                                               SKAction.wait(forDuration: 0.4), SKAction.scaleX(to: -1.0, duration: 0.3)])
            let sequence2 = SKAction.sequence([SKAction.scaleY(to: 1.2, duration: 0.3),
                                               SKAction.wait(forDuration: 0.4), SKAction.scaleY(to: 1.0, duration: 0.3)])
            sequence = SKAction.group([sequence1, sequence2])
        }
        ball.node.run(sequence, completion: {
            let v2 = ball.node.physicsBody?.velocity
            ball.node.physicsBody = p
            ball.node.physicsBody?.velocity = v2!
            ball.node.zPosition = z
            ball.hasJustLanded = true
            ball.isFlying = false
        })
    }
    
    func getSFXRate(ball: Ball) -> Float{
        return ball.type == .friend ? 1.0 : 1.2
    }
    
    func ballTouched(_ ball: Ball) {
        let action = chromosome.getBallSubChromosome(ball.type).tapAction.value
        
        if ball.type == .friend && scoring.rainTapped != nil{
            spawnInGameScoreLabelEffect(ball.node.position, score: scoring.rainTapped, positiveColor: ScoringColours.friend, negativeColor: ScoringColours.friend)
            addToScore(scoring.rainTapped)
            if scoring.rainTapped > 0{
                if SoundLimiter.gainlose.canPlay(){
                    MPCGDAudio.playSound(path: MPCGDSounds.gainPoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
                }
                
            }
            else if scoring.rainTapped < 0 && scoring.rainTapped != -90{
                if SoundLimiter.gainlose.canPlay(){
                    MPCGDAudio.playSound(path: MPCGDSounds.losePoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
                }
            }
        }
        if ball.type == .foe && scoring.snowTapped != nil{
            spawnInGameScoreLabelEffect(ball.node.position, score: scoring.snowTapped, positiveColor: ScoringColours.foe, negativeColor: ScoringColours.foe)
            addToScore(scoring.snowTapped)
            if scoring.snowTapped > 0{
                if SoundLimiter.gainlose.canPlay(){
                    MPCGDAudio.playSound(path: MPCGDSounds.gainPoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
                }
            }
            else if scoring.snowTapped < 0 && scoring.snowTapped != -90{
                if SoundLimiter.gainlose.canPlay(){
                    MPCGDAudio.playSound(path: MPCGDSounds.losePoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
                }
            }
        }

        switch action {
        case .nothing:
            break
            
        case .stop:
            ball.node.physicsBody!.velocity = CGVector.zero
         
        case .bounce:
            if !ball.isFlying{
                bounceBall(ball)
            }
            MPCGDAudio.playSound(path: MPCGDSounds.tap, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
            
        case .reverse:
            ball.spawnedFrom = ball.spawnedFrom.opposite
            switch ball.type {
            case .friend:
                ball.node.physicsBody!.fieldBitMask = UInt32(1 << ball.spawnedFrom.rawValue)
            case .foe:
                ball.node.physicsBody!.fieldBitMask = UInt32(1 << (ball.spawnedFrom.rawValue + 4))
            }
            ball.node.physicsBody?.velocity = CGVector.zero
            CharacterIconHandler.alterBallOnReverse(ball: ball)
            MPCGDAudio.playSound(path: MPCGDSounds.tap, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
            
        case .ping:
            let v = ball.node.physicsBody?.velocity
            let dx = (v?.dx)!
            let dy = (v?.dy)!
            let speed = CGFloat(250)
            if dx == 0{
                addImpulse(ball, impulse: CGVector(dx: 0, dy: dy > 0 ? speed : -speed))
            }
            else if dy == 0{
                addImpulse(ball, impulse: CGVector(dx: dx > 0 ? speed : -speed, dy: 0))
            }
            else{
                if abs(dx) > abs(dy){
                    let prop = abs(dy)/abs(dx)
                    let dyy = dy > 0 ? speed * prop : -speed * prop
                    addImpulse(ball, impulse: CGVector(dx: dx > 0 ? speed : -speed, dy: dyy))
                }
                else{
                    let prop = abs(dx)/abs(dy)
                    let dxx = dx > 0 ? speed * prop : -speed * prop
                    addImpulse(ball, impulse: CGVector(dx: dxx, dy: dy > 0 ? speed : -speed))
                }
            }
            MPCGDAudio.playSound(path: MPCGDSounds.tap, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)

        case .stickInPlace:
            ball.toggleStuckInPlace()
            MPCGDAudio.playSound(path: MPCGDSounds.tap, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
            
        case .destroy:
            MPCGDAudio.playSound(path: MPCGDSounds.tap, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
            MPCGDAudio.playSound(path: MPCGDSounds.explode, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)
            explodeBall(ball, playSound: false)

        case .changeColour:
            if ball.type == .friend {
                ball.type = .foe
            }
            else {
                ball.type = .friend
            }
            MPCGDAudio.playSound(path: MPCGDSounds.tap, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 3)

        case .impulseUp:
            addImpulse(ball, impulse: CGVector(dx: 0, dy: 50))
            
        case .impulseDown:
            addImpulse(ball, impulse: CGVector(dx: 0, dy: -50))
            
        case .impulseLeft:
            addImpulse(ball, impulse: CGVector(dx: -30, dy: 0))
            
        case .impulseRight:
            addImpulse(ball, impulse: CGVector(dx: 30, dy: 0))
        }

    }
    
    func addImpulse(_ ball: Ball, impulse: CGVector){
        ball.node.physicsBody!.applyImpulse(impulse)
    }
    
    func touchesBeganOrDragged(_ touchPoint: CGPoint) {
        if spotLight != nil && imageAndLightingChromosome.lightingType.value == .finger {
            spotLight.position = touchPoint
        }
        
        for field in fingerAttractFields {
            field.isEnabled = true
            field.position = touchPoint
        }
    }
    
    func wantsTouchesFromUser() -> Bool {
        return true
    }
    
    func touchesBegan(_ touchPoint: CGPoint) {
        if !lifeLostAnimationIsHappening && !gameIsOver && (scene as! MainScene).state == .playing {
            ballHasBeenTapped = false
            lastFingerPos = touchPoint
            isDragging = false
            
            var logEvent : [String : AnyObject?] = ["position" : (touchPoint as AnyObject??)!]
            var ballForLog : Ball! = nil
            
            if artImageController != nil {
                artImageController.touchBegan(touchPoint)
            }
            
            let ballsNearPoint = getBallsNearPoint(touchPoint, radius: chromosome.tapRadius.value)
            
            var allowThroughToBackground = true
            
            if ballsNearPoint.count > 0 {
                switch chromosome.ballInteraction.value {
                case .tap:
                    let (_, ball) = ballsNearPoint.first!
                    ballTouched(ball)
                    allowThroughToBackground = allowThroughToBackground && ball.chromosome.tapAllowsBackgroundTouch.value
                    ballHasBeenTapped = true
                    
                    if ball.type == .friend {
                        ballForLog = ball
                        logEvent["hit"] = true as AnyObject??
                    }
                    
                case .drag:
                    for (_, ball) in ballsNearPoint {
                        ballTouched(ball)
                        allowThroughToBackground = allowThroughToBackground && ball.chromosome.tapAllowsBackgroundTouch.value
                    }
                }
            }
            
            if ballForLog == nil {
                logEvent["hit"] = false as AnyObject??
                var closestDist = CGFloat.infinity
                for ball in balls {
                    let dist = (touchPoint - ball.node.position).sqrMagnitude()
                    if ballForLog == nil || closestDist > dist {
                        ballForLog = ball
                        closestDist = dist
                    }
                }
            }
            
            if ballForLog != nil {
                logEvent["ballPosition"] = ballForLog.node.position as AnyObject??
                logEvent["velocity"] = ballForLog.node.physicsBody!.velocity as AnyObject??
                logEvent["clusterSize"] = getCluster(ballForLog, clusterType: .same).count as AnyObject??
                logEvent["touchingFoes"] = ballForLog.node.physicsBody!.allContactedBodies()
                    .filter({ b in (b.node?.userData?["ball"] as? Ball)?.type == .foe })
                    .count as AnyObject??
            }
            
            if allowThroughToBackground && !ballHasBeenTapped {
                let isArtImage = isArtImageAtPoint(touchPoint)
                let action = isArtImage ? chromosome.imageTapAction.value : chromosome.backgroundTapAction.value
                
                switch action {
                case .nothing:
                    break // do nothing
                    
                case .spawnFriend:
                    _ = tryToSpawnBall(.friend)
                    
                case .spawnFoe:
                    _ = tryToSpawnBall(.foe)
                }
            }
            touchesBeganOrDragged(touchPoint)
        }
    }
    
    func touchesDragged(_ touchPoint: CGPoint, clampedDragVector: CGVector, dragVector: CGVector){
        if !lifeLostAnimationIsHappening && !gameIsOver {
            
            let distance = (touchPoint - lastFingerPos).magnitude()
            isDragging = isDragging || distance >= chromosome.dragThreshold.value
            
            if isDragging {
                lastFingerPos = touchPoint
                
                if artImageController != nil && !emptyArtImage{
                    artImageController.touchDragged(touchPoint)
                }
                
                if chromosome.ballInteraction.value == .drag {
                    let ballsNearPoint = getBallsNearPoint(touchPoint, radius: chromosome.dragRadius.value)
                    for (_, ball) in ballsNearPoint {
                        ballTouched(ball)
                    }
                }
                touchesBeganOrDragged(touchPoint)
            }
        }
    }
    
    func touchesEnded(_ touchPoint: CGPoint){
        if gameIsOver || lifeLostAnimationIsHappening{
            return
        }
        
        isDragging = false
        
        if artImageController != nil{
            artImageController.touchEnded(touchPoint)
        }
        
        if chromosome.attachment.joint.value == .spring {
            if artImageNode != nil && artImageNode.physicsBody != nil{
                artImageNode.physicsBody!.allowsRotation = chromosome.attachment.canRotate.value
            }
        }
        
        for field in fingerAttractFields {
            field.isEnabled = false
        }
    }
    
    func getGridTickSize(_ dimension: CGFloat, ticks: Int) -> CGFloat {
        if ticks <= 1 {
            return 0
        }
        else {
            return dimension / CGFloat(ticks)
        }
    }
    
    var gridSquareSize : CGSize {
        return CGSize(width: getGridTickSize(sceneSize.width, ticks: chromosome.gridX.value),
            height: getGridTickSize(sceneSize.height, ticks: chromosome.gridY.value))
    }
    
    func getNearestGridTick(_ coordinate: CGFloat, dimension: CGFloat, ticks: Int) -> CGFloat {
        if ticks <= 1 {
            return coordinate
        }
        else {
            let tickSize = dimension / CGFloat(ticks)
            return round(coordinate / tickSize) * tickSize
        }
    }
    
    func getNearestGridPoint(_ point: CGPoint) -> CGPoint {
        var x = getNearestGridTick(point.x, dimension: sceneSize.width, ticks: chromosome.gridX.value)
        var y = getNearestGridTick(point.y, dimension: sceneSize.height, ticks: chromosome.gridY.value)
        if x < 0 || x > sceneSize.width{
            x = point.x
        }
        if y < 0 || y > sceneSize.height{
            y = point.y
        }
        return CGPoint(x: x, y: y)
    }
    
    var imageTargetGridPoint : CGPoint {
        return imageGridPointOverride ?? getNearestGridPoint(artImageNode.position)
    }
    
    func moveArtImageTowardsGrid() {
        if artImageNode != nil && artImageNode.physicsBody != nil{
            let diff = imageTargetGridPoint - artImageNode.position
            let targetVel = diff * 30
            let velDiff = (targetVel - artImageNode.physicsBody!.velocity).clampMagnitude(min: 0, max: 500)
            let force = velDiff * 300
            artImageNode.physicsBody!.applyForce(force)
        }
    }
    
    struct GameEndDetails{
        var currentScore: Int! = nil
        var highScore: Int! = nil
        var currentTimeElapsed: Int! = nil
        var fastestTime: Int!
        var longestTime: Int!
        var gameIsWon: Bool! = nil
        var gameOverReason: GameOverReason! = nil
    }
    
    func getGameEndDetails() -> GameEndDetails{
        gameIsOver = true
        let currentGame = (scene as! MainScene).currentGameName
        var gED = GameEndDetails()
        gED.currentScore = score
        if let hS = SessionHandler.getHighScore(currentGame){
            gED.highScore = hS
        }
        
        gED.currentTimeElapsed = Int(floor(timeElapsed))
        if let fT = SessionHandler.getFastestTime(currentGame){
            gED.fastestTime = fT
        }
        if let lT = SessionHandler.getLongestTime(currentGame){
            gED.longestTime = lT
        }
        
        if gameOverReason == nil{
            gED.gameIsWon = false
        }
        else{
            gED.gameIsWon = (gameOverReason == .ranOutOfTime || gameOverReason == .lostAllLivesBeforeEnd) ? false : true
            gED.gameOverReason = gameOverReason
        }
        return gED
    }
    
    // Same: same colour
    // Mixed: "means mixed" (i.e. needs at least one of each colour
    // DontCare: includes both same colour and mixed colour
    enum ClusterType { case dontCare, same, mixed }
    
    func getCluster(_ ball: Ball, clusterType : ClusterType) -> [Ball] {
        var result : [Ball] = []
        let queue = Queue<Ball>()
        queue.enqueue(ball)
        
        var includesFriends = (ball.type == .friend)
        var includesFoes = (ball.type == .foe)
        
        while let next = queue.dequeue() {
            if !result.containsIdentity(next) {
                result.append(next)
                
                includesFriends = includesFriends || (next.type == .friend)
                includesFoes = includesFoes || (next.type == .foe)
                
                for neighbourRef in next.stuckBalls {
                    let neighbour = neighbourRef.value
                    
                    let takeNeighbour : Bool
                    switch clusterType {
                    case .same:
                        takeNeighbour = (neighbour?.type == ball.type)
                    case .dontCare, .mixed:
                        takeNeighbour = true
                    }
                    
                    if takeNeighbour && !result.containsIdentity(neighbour!) {
                        queue.enqueue(neighbour!)
                    }
                }
            }
        }
        
        if clusterType == .mixed && !(includesFriends && includesFoes) {
            // Mixed means mixed! If it doesn't include both types, discount it
            result = [ball]
        }
        
        return result
    }
    
    func countClusters() -> [(Ball.BallType?, Int)] {
        
        // If all balls in the cluster have the same type, the first element of each pair is that type.
        // Otherwise (i.e. if the cluster contains both types of ball) it is nil.
        
        var result : [(Ball.BallType?, Int)] = []
        
        var ballsToCount = balls
        
        while let ball = ballsToCount.last {
            let cluster = getCluster(ball, clusterType: .dontCare)
            if cluster.count > 1 {
                var clusterType : Ball.BallType? = ball.type
                for clusterBall in cluster {
                    if clusterBall.type != clusterType {
                        clusterType = nil
                        break
                    }
                }
                
                result.append((clusterType, cluster.count))
            }
            for b in cluster {
                ballsToCount.removeByIdentity(b)
            }
        }
        
        return result
    }
    
    func getBiggestClusterSize(_ type: Ball.BallType?) -> Int {
        var biggestOverall = 0
        
        for (clusterType, count) in countClusters() {
            if type == nil || clusterType == type {
                if count > biggestOverall {
                    biggestOverall = count
                }
            }
        }
        
        return biggestOverall
    }
    
    func audioConfigurationChanged() {
        //TODO(audio): Handle audioConfigurationChanged
        //SoundEngine.singleton.playMusic(position: timeElapsed)
    }
    
    func isPointOffZoneSide(_ point: CGPoint, zoneMask: Int) -> Bool {
        if (zoneMask & 1) != 0 && point.y > (sceneSize.height + deviceSimulationYOffset) {
            return true
        }
        else if (zoneMask & 2) != 0 && point.x > (sceneSize.width + deviceSimulationXOffset) {
            return true
        }
        else if (zoneMask & 4) != 0 && point.y < (0 + deviceSimulationYOffset) {
            return true
        }
        else if (zoneMask & 8) != 0 && point.x < (0 + deviceSimulationXOffset) {
            return true
        }
        else if (zoneMask & 16) != 0 {
            let cornerProportion: CGFloat = 0.2
            let left = (sceneSize.width * cornerProportion) + deviceSimulationXOffset
            let right = (sceneSize.width * (1-cornerProportion)) + deviceSimulationXOffset
            let bottom = (sceneSize.height * cornerProportion) + deviceSimulationYOffset
            let top = (sceneSize.height * (1-cornerProportion)) + deviceSimulationYOffset
            
            if (point.x < left || point.x > right) && (point.y < bottom || point.y > top) {
                return true
            }
        }

        return false
    }
    
    // PETE

    func spawnInGameZoneEffect(_ point: CGPoint, zoneMask: Int, score: Int, color: UIColor) {
        if zoneMask == 0 || score == 0 || !positiveScoresPossible || score == -90{
            return
        }
        let hw: CGFloat = 4
        let hh: CGFloat = 4

        func spawn(_ at: CGPoint, _ vAlign: SKLabelVerticalAlignmentMode, _ hAlign: SKLabelHorizontalAlignmentMode) {
            
            // Added by Simon to stop spawning on top of an existing score
            for exN in activeSpawnedScores{
                if exN.position.isInRadiusOf(at, radius: 20){
                    return
                }
            }
            
            let n = SKLabelNode()
            let fadeDuration = 1.0
            if score < 0 {
                n.text = "\(score)"
            } else {
                n.text = "+\(score)"
            }
            n.fontColor = color
            n.position = CGPoint(x: floor(at.x), y: floor(at.y))
            n.zPosition += 100
            n.verticalAlignmentMode = vAlign
            n.horizontalAlignmentMode = hAlign
            if UIDevice.current.model.contains("iPad") {
                n.fontSize = CGFloat(24)
                n.fontName = "Helvetica Neue Thin"
                n.run(SKAction.fadeOut(withDuration: fadeDuration), completion: {
                    self.activeSpawnedScores.remove(n)
                    n.removeFromParent()
                })
            } else {
                n.fontSize = CGFloat(28)
                n.fontName = "Helvetica Neue Thin"
                n.run(SKAction.fadeOut(withDuration: fadeDuration), completion: {
                    n.removeFromParent()
                    self.activeSpawnedScores.remove(n)
                })
            }
            activeSpawnedScores.append(n)
            scene.addChild(n)
        }
        
        var p = point
        var vAlign = SKLabelVerticalAlignmentMode.center
        var hAlign = SKLabelHorizontalAlignmentMode.center
        
        if (zoneMask & 1) != 0 && point.y > (sceneSize.height + deviceSimulationYOffset) {
            p.x = point.x + deviceSimulationXOffset
            p.y = sceneSize.height - hh + deviceSimulationYOffset
            vAlign = SKLabelVerticalAlignmentMode.top
        }
        else if (zoneMask & 2) != 0 && point.x > (sceneSize.width + deviceSimulationXOffset){
            p.x = sceneSize.width - hw + deviceSimulationXOffset
            p.y = point.y + deviceSimulationYOffset
            hAlign = SKLabelHorizontalAlignmentMode.right
        }
        else if (zoneMask & 4) != 0 && point.y < (0 + deviceSimulationYOffset) {
            p.x = point.x + deviceSimulationXOffset
            p.y = hh + deviceSimulationYOffset
            vAlign = SKLabelVerticalAlignmentMode.bottom
        }
        else if (zoneMask & 8) != 0 && point.x < (0 + deviceSimulationXOffset) {
            p.x = hw + deviceSimulationXOffset
            p.y = point.y + deviceSimulationYOffset
            hAlign = SKLabelHorizontalAlignmentMode.left
        }
        else if (zoneMask & 16) != 0 {
            let cornerProportion: CGFloat = 0.2
            let left = (sceneSize.width * cornerProportion) + deviceSimulationXOffset
            let right = (sceneSize.width * (1-cornerProportion)) + deviceSimulationXOffset
            let bottom = (sceneSize.height * cornerProportion) + deviceSimulationYOffset
            let top = (sceneSize.height * (1-cornerProportion)) + deviceSimulationYOffset
         
            if (point.x < left && point.y > top) {
                // Top-Left
                p.x = hw + deviceSimulationXOffset
                p.y = sceneSize.height - hh + deviceSimulationYOffset
                vAlign = SKLabelVerticalAlignmentMode.top
                hAlign = SKLabelHorizontalAlignmentMode.left
            }
            else if (point.x > right && point.y > top) {
                // Top-Right
                p.x = sceneSize.width - hw + deviceSimulationXOffset
                p.y = sceneSize.height - hh + deviceSimulationYOffset
                vAlign = SKLabelVerticalAlignmentMode.top
                hAlign = SKLabelHorizontalAlignmentMode.right
            }
            else if (point.x < left && point.y < bottom) {
                // Bottom-Left
                p.x = hw + deviceSimulationXOffset
                p.y = hh + deviceSimulationYOffset
                vAlign = SKLabelVerticalAlignmentMode.bottom
                hAlign = SKLabelHorizontalAlignmentMode.left
            }
            else if (point.x > right && point.y < bottom) {
                // Bottom-Right
                p.x = sceneSize.width - hw + deviceSimulationXOffset
                p.y = hh + deviceSimulationYOffset
                vAlign = SKLabelVerticalAlignmentMode.bottom
                hAlign = SKLabelHorizontalAlignmentMode.right
            }
        }
        else {
            return
        }
        p.x = clamp(value: p.x, lower: hw, upper: sceneSize.width - hw + deviceSimulationXOffset)
        p.y = clamp(value: p.y, lower: hh, upper: sceneSize.height - hh + deviceSimulationYOffset)
        spawn(p, vAlign, hAlign)
    }

    
    func isPointOffScoreZoneSide(_ point: CGPoint) -> Bool {
        return isPointOffZoneSide(point, zoneMask: scoreZone)
    }
    
    func isPointOffDeadZoneSide(_ point: CGPoint) -> Bool {
        return isPointOffZoneSide(point, zoneMask: deadZone)
    }
    
    var lastTickTime: CFTimeInterval! = nil
    var lastSnapshotTime : CFTimeInterval = 0
    
    func tick(_ currentTime: CFTimeInterval) {
        
        // deltaWallTime is "wall-clock" delta time, not scaled by gameSpeed
        let deltaWallTime = currentTime - (lastTickTime ?? currentTime)
        
        // deltaTime is scaled by gameSpeed
        let deltaTime = gameSpeed * deltaWallTime
        
        lastTickTime = currentTime

        SoundLimiter.tick(wallclock: Date());

        if gameSpeed < 0.05 { //arbitrary low threshold for what the game uses as a tick
            return
        }
        
        for ball in balls {
            ball.updateVisuals()
            ball.hasJustLanded = false
        }
        
        if !isPaused{
            
            if !gameIsOver && playtester != nil {
                playtester!.tick()
            }
            
            timeElapsed += deltaTime
                
            if timeLeft != TimeInterval.infinity {
                timeLeft -= deltaTime
            }
            
            if firstTickAfterRestart && shouldInitialiseSoundOnRestart {
                firstTickAfterRestart = false
                // TODO(audio): Restart music
                // SoundEngine.singleton.playMusic(position: 0)
            }

            if chromosome.imageGridSnap.value {
                moveArtImageTowardsGrid()
            }
            
            // Try to spawn reserved balls
            for i in (0 ..< reservedSpawnSpots.count).reversed() {
                let reserved = reservedSpawnSpots[i]
                
                if !canSpawnBallWithinNumberLimits(reserved.ballType) {
                    // If maximum number of balls is already on screen, un-reserve this spot
                    if reserved.debugNode != nil { reserved.debugNode!.removeFromParent() }
                    reservedSpawnSpots.remove(at: i)
                }
                else if isBallSpawnPositionOK(reserved.position, radius: reserved.radius, ballType: reserved.ballType, checkReservedSpots: false) {
                    // Spawn it
                    _ = spawnBall(ballType: reserved.ballType, pos: reserved.position, radius: reserved.radius)
                    if reserved.debugNode != nil { reserved.debugNode!.removeFromParent() }
                    reservedSpawnSpots.remove(at: i)
                }
            }
            
            friendSpawnAngle += CGFloat(deltaTime) * chromosome.friend.spawnAngleRotate.value
            foeSpawnAngle += CGFloat(deltaTime) * chromosome.foe.spawnAngleRotate.value

            let tryFriendSpawn = (chromosome.friend.maxBalls.intValue > 0 && timeElapsed >= nextFriendSpawnTime)
            let tryFoeSpawn = (chromosome.foe.maxBalls.intValue > 0 && timeElapsed >= nextFoeSpawnTime)
            
            if tryFriendSpawn && !tryFoeSpawn{
                if let _ = tryToSpawnBall(.friend){
                    nextFriendSpawnTime = timeElapsed + TimeInterval(1.0 / chromosome.friend.numPerSecond.value)
                }
            }
            else if tryFoeSpawn && !tryFriendSpawn{
                if let _ = tryToSpawnBall(.foe){
                    nextFoeSpawnTime = timeElapsed +  TimeInterval(1.0 / chromosome.foe.numPerSecond.value)
                }
            }
            else if tryFriendSpawn && tryFoeSpawn{
                if RandomUtils.randomBool(){
                    if let _ = tryToSpawnBall(.friend){
                        nextFriendSpawnTime = timeElapsed +  TimeInterval(1.0 / chromosome.friend.numPerSecond.value)
                    }
                    if let _ = tryToSpawnBall(.foe){
                        nextFoeSpawnTime = timeElapsed +  TimeInterval(1.0 / chromosome.foe.numPerSecond.value)
                    }
                }
                else{
                    if let _ = tryToSpawnBall(.foe){
                        nextFoeSpawnTime = timeElapsed +  TimeInterval(1.0 / chromosome.foe.numPerSecond.value)
                    }
                    if let _ = tryToSpawnBall(.friend){
                        nextFriendSpawnTime = timeElapsed +  TimeInterval(1.0 / chromosome.friend.numPerSecond.value)
                    }
                }
            }
            
            for ball in balls {
                ball.isInContactWithBg = false
            }
            
            if !lifeLostAnimationIsHappening && teleportControllerTo != nil{
                artImageNode.position = teleportControllerTo!
                teleportControllerTo = nil
                controllerHasJustTeleported = true
                MPCGDAudio.playSound(path: MPCGDSounds.tap, volume: Float(sfxVolume), priority: 3)
            }
            else{
                controllerHasJustTeleported = false
            }
            
            if artImageNode.physicsBody != nil{
                for body in artImageNode.physicsBody!.allContactedBodies() {
                    if let ball = body.node?.userData?.value(forKey: "ball") as? Ball {
                        ball.isInContactWithBg = true
                    }
                }                
            }
            
            for i in (0..<balls.count).reversed() {
                let ball = balls[i]
                
                if ball.removeOnNextFrame {
                    ball.removeFromScene()
                    balls.remove(at: i)
                    continue
                }
                
                ball.update(deltaTime)
                
                // Delete ball if it has been batted off screen
                if !ball.isOnScreen && ball.hasBeenOnScreen {
                    if isPointOffScoreZoneSide(ball.node.position) {
                        if ball.type == .foe && !gameIsOver{
                            spawnInGameZoneEffect(ball.node.position, zoneMask: scoreZone, score: scoring.snowScoreZone, color: ScoringColours.foe)
                            addToScore(scoring.snowScoreZone)
                            if scoring.snowScoreZone > 0{
                                MPCGDAudio.playSound(path: MPCGDSounds.gainPoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2)
                            }
                            else if scoring.snowScoreZone < 0{
                                MPCGDAudio.playSound(path: MPCGDSounds.losePoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2)
                            }

                        }
                    }
                    
                    if isPointOffDeadZoneSide(ball.node.position) {
                        if ball.type == .friend && !gameIsOver {
                            spawnInGameZoneEffect(ball.node.position, zoneMask: deadZone, score: scoring.rainScoreZone, color: ScoringColours.friend)
                            addToScore(scoring.rainScoreZone)
                            if scoring.rainScoreZone > 0{
                                MPCGDAudio.playSound(path: MPCGDSounds.gainPoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2)
                            }
                            else if scoring.rainScoreZone < 0{
                                MPCGDAudio.playSound(path: MPCGDSounds.losePoints, volume: Float(sfxVolume), rate: getSFXRate(ball: ball), priority: 2)
                            }
                        }
                    }
                    ball.removeFromScene()
                    balls.remove(at: i)
                    continue
                }
            }
            
            if chromosome.showTimer.value == true{
                if !gameIsOver{
                    timeDisplay.text = "\(Int(floor(timeElapsed)))s"
                    if chromosome.finalScore.value == .timeLeft && timeLeft.isFinite {
                        timeDisplay.text = "\(Int(round(timeLeft)))s"
                    }
                }
            }
            else {
                timeDisplay.text = nil
            }
            
            if artImageController != nil {
                artImageController.tick(currentTime)
            }
            
            if timeElapsed - lastSnapshotTime > 0.5 {
                lastSnapshotTime = timeElapsed
                var maxBallSpeed : CGFloat = 0
                for ball in balls {
                    let speed = ball.node.physicsBody!.velocity.sqrMagnitude()
                    if speed > maxBallSpeed {
                        maxBallSpeed = speed
                    }
                }
                maxBallSpeed = sqrt(maxBallSpeed)
            }
            
            if !gameIsOver{
                var gameOverSoundEffect = ""
                if noLivesLeft{
                    gameIsOver = true
                    if chromosome.duration.value > 0{
                        gameOverReason = .lostAllLivesBeforeEnd
                        gameOverSoundEffect = MPCGDSounds.loseGame
                    }
                    else{
                        gameOverReason = .lostAllLivesNoEnd
                        gameOverSoundEffect = MPCGDSounds.winGame
                    }
                }
                else if chromosome.scoreThreshold.value > 0 && score >= chromosome.scoreThreshold.value{
                    gameIsOver = true
                    gameOverReason = .achievedPoints
                    gameOverSoundEffect = MPCGDSounds.winGame
                }
                else if timeLeft < 0{
                    gameIsOver = true
                    if chromosome.scoreThreshold.value == 0{
                        gameOverReason = .survivedForDuration
                        gameOverSoundEffect = MPCGDSounds.winGame
                    }
                    else{
                        gameOverReason = .ranOutOfTime
                        gameOverSoundEffect = MPCGDSounds.loseGame
                    }
                }
                if gameIsOver{
                    MPCGDAudio.playSound(path: gameOverSoundEffect, volume: Float(sfxVolume), priority: 10.0)
                    gameOverCode?()
                }
            }
        }
    }
    
}
