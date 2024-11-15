//
//  GameplayChromosome.swift
//  Beeee
//
//  Created by Powley, Edward on 26/08/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class AttachmentSubChromosome : SubChromosome {
    enum AttachmentType: Int { case none, fixed, pin, spring, slider }

    let joint = EnumGene<AttachmentType>(name: "$ attachment", def: .pin, designScreenName: .Movement)
    let canRotate = BoolGene(name: "$ can rotate when attached", def: true, designScreenName: .Movement)
    let anchorX = FloatGene(name: "$ attachment x coordinate", min: -1, max: 1, step: 0.1, def: 0,designScreenName: .Movement)
    let anchorY = FloatGene(name: "$ attachment y coordinate", min: -1, max: 1, step: 0.1, def: 0, designScreenName: .Movement)
    let springStiffness = LogarithmicFloatGene(name: "$ attachment spring stiffness", min: 0.01, max: 100, numSteps: 200, alsoAllowZero: true, def: 1, designScreenName: .Movement)
    let springDamping = FloatGene(name: "$ attachment spring damping", min: 0, max: 1, step: 0.01, def: 0.1, designScreenName: .Movement)
    let sliderAxis = FloatGene(name: "$ attachment slider axis", min: 0, max: 179, step: 15, def: 0, designScreenName: .Movement)
    let distanceLimit = FloatGene(name: "$ attachment slider distance limit", min: 0, max: 1, step: 0.01, def: 0, designScreenName: .Movement)
    
    override init(`$`: String) {
        super.init(`$`: `$`)
        
        // Tweak name for image attachment parameter (since image can never be unattached)
        if `$` == "image" {
            canRotate.name = "image can rotate"
        }
    }
}

enum CounterType {
    case score, health, progress
    static let all: [CounterType] = [.score, .health, .progress]
}

class ScoreContributionSubChromosome : SubChromosome {
    enum ObjectType: Int {
        case artImage, friend, foe
        
        var asBallType : Ball.BallType? {
            switch self {
            case .friend: return .friend
            case .foe: return .foe
            default: return nil
            }
        }
    }
    
    enum FilterType: Int {
        case all, stuckTransitively
    }
    
    enum ScoreType: Int {
        case off
        case onScreen, timeOnScreen, stuck, battedAwayInScoreZone, battedAwayInDeadZone, destroyed, tapped
        case biggestCluster, clustersSquared, clustersMatched, inMaxCluster, inMaxMixedCluster
        case constant, score, health, progress, controllerContact
    }
    
    // HACK FOR LET IT SNOW
    //static let amounts = GameplayChromosome.scoreThresholds.filter({i in abs(i) <= 100})
    static let amounts = ScoreContributionSubChromosome.getScoreAmounts()
    
    let type = EnumGene<ScoreType>(name: "$ - score type", def: .onScreen, designScreenName: .Score)
    let who = EnumGene<ObjectType>(name: "$ - which type of ball", def: .friend, designScreenName: .Score)
    let filter = EnumGene<FilterType>(name: "$ - which balls to count", def: .all, designScreenName: .Score)
    let amount = ChoiceGene<Int>(name: "$ - amount", choices: amounts, def: 0, designScreenName: .Score)
    
    init(scoreName: String, contribIndex: Int, designScreenName: DesignScreenName) {
        super.init(`$`: "\(scoreName) \(contribIndex+1)")
        setDesignScreenNameForAllGenes(designScreenName)
    }
    
    static func getScoreAmounts() -> [Int]{
        var amounts: [Int] = []
        for i in -100...100{
            amounts.append(i)
        }
        return amounts
    }
}

enum MaxBallType: Int { case all, notStuckToImage }

class BallSubChromosome : SubChromosome {
    enum SpawnLocation: Int { case edges, imageCentre, /*ImageParticles,*/ finger, onImage, offImage, anywhere, locations }
    enum InitialMovementDirection: Int { case random, towardsCentre, awayFromCentre, towardsImage, awayFromImage, towardsSide, towardsOppositeSide, aimDirection }
    enum DistanceCheckType: Int { case any, all }
    enum CollisionShapeType : Int { case shape, imageLoRes, imageHiRes }
    enum SpawnGridType: Int { case off, all, even, odd}
    enum BallTapAction: Int { case nothing, destroy, stop, stickInPlace, reverse, changeColour, bounce, ping, impulseUp, impulseDown, impulseLeft, impulseRight }
    enum SpawnFailType: Int { case dontSpawn, forceSpawn }
    enum AttractionTarget: Int { case none, centre, image, oppositeSide, finger }

    let radius = FloatGene(name: "$ size", min: 1, max: 20, step: 1, def: 5, designScreenName: .Appearance)
    let radiusRange = FloatGene(name: "$ size range", min: 0, max: 10, step: 1, def: 0, designScreenName: .Appearance)
    let bounciness = FloatGene(name: "$ bounciness", min: 0, max: 1, step: 0.01, def: 0.3, designScreenName: .Movement)
    let friction = FloatGene(name: "$ friction", min: 0, max: 1, step: 0.01, def: 0.3, designScreenName: .Movement)
    let canRotate = BoolGene(name: "$s can rotate", def: true, designScreenName: .Movement)
    let linearDrag = FloatGene(name: "$ linear drag", min: 0, max: 10, step: 0.01, def: 0.1, designScreenName: .Movement)
    let angularDrag = FloatGene(name: "$ angular drag", min: 0, max: 10, step: 0.01, def: 0.1, designScreenName: .Movement)
    let attractTo = EnumGene<AttractionTarget>(name: "$s pulled towards", def: .centre, designScreenName: .Movement)
    let attraction = FloatGene(name: "$ pull strength", min: -1, max: 1, step: 0.01, def: 0.4, designScreenName: .Movement)
    let colour = ColourGene(name: "$ colour", def: .forestGreen, designScreenName: .Appearance)
    let characterCollectionNum = IntGene(name: "$ character collection", min: 0, max: 8, def: 0, designScreenName: .Appearance)
    let characterNum = IntGene(name: "$ character", min: 0, max: 8, def: 0, designScreenName: .Appearance)
    let iconSize = FloatGene(name: "$ icon size", min: 0, max: 2, step: 0.01, def: 1.0, designScreenName: .Appearance)
    let collisionShape = EnumGene<CollisionShapeType>(name: "$ collision shape", def: .shape, designScreenName: .Collisions)
    let criticalClusterSize = IntGene(name: "$ cluster explode size", min: 1, max: 10, def: 3, designScreenName: .Collisions)

    let tapAction = EnumGene<BallTapAction>(name: "$ touch action", def: .nothing, designScreenName: .Interaction)
    let tapAllowsBackgroundTouch = BoolGene(name: "$ pass touches through to background", def: false, designScreenName: .Interaction)
    
    let speedLimit = FloatGene(name: "$ speed limit centre", min: 0, max: 500, step: 1, def: 0, designScreenName: .Movement)
    let speedLimitRange = FloatGene(name: "$ speed limit range", min: 0, max: 500, step: 1, def: 0, designScreenName: .Movement)
    
    let maxBalls = ChoiceGene<Int>(name: "maximum number of $s on screen", choices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000], def: 1000, designScreenName: .Spawning)
    let maxBallsMode = EnumGene<MaxBallType>(name: "$s to count towards maximum on screen", def: .notStuckToImage, designScreenName: .Spawning)
    let numAtStart = IntGene(name: "$s to spawn at start", min: 0, max: 50, def: 0, designScreenName: .Spawning)
    let numPerSecond = ChoiceGene<CGFloat>(name: "$ spawning rate", choices: MPCGDGenome.spawnRates, def: 3.0, designScreenName: .Spawning)
    //let numPerSecond = LogarithmicFloatGene(name: "$ spawning rate", min: 0.125, max: 8, numSteps: 100, alsoAllowZero: true, def: 1, designScreenName: .Spawning)
    let spawnLocation = EnumGene<SpawnLocation>(name: "$ spawning location", def: .edges, designScreenName: .Spawning)

    let spawnMinDistFromFriends = FloatGene(name: "$ spawn min dist from friends", min: 0, max: 200, step: 1, def: 0, designScreenName: .Spawning)
    let spawnMinDistFromFriendsWhich = EnumGene<DistanceCheckType>(name: "$ spawn min dist from which friends", def: .all, designScreenName: .Spawning)
    let spawnMaxDistFromFriends = FloatGene(name: "$ spawn max distance from friends", min: 0, max: 201, step: 1, def: 0, designScreenName: .Spawning)
    let spawnMaxDistFromFriendsWhich = EnumGene<DistanceCheckType>(name: "$ spawn max dist from which friends", def: .any, designScreenName: .Spawning)
    
    let spawnMinDistFromFoes = FloatGene(name: "$ spawn min distance from foes", min: 0, max: 200, step: 1, def: 0, designScreenName: .Spawning)
    let spawnMinDistFromFoesWhich = EnumGene<DistanceCheckType>(name: "$ spawn min dist from which foes", def: .all, designScreenName: .Spawning)
    let spawnMaxDistFromFoes = FloatGene(name: "$ spawn max distance from foes", min: 0, max: 201, step: 1, def: 0, designScreenName: .Spawning)
    let spawnMaxDistFromFoesWhich = EnumGene<DistanceCheckType>(name: "$ spawn max dist from which foes", def: .any, designScreenName: .Spawning)
    
    let spawnMinDistFromImage = FloatGene(name: "$ spawn min distance from image", min: 0, max: 200, step: 1, def: 0, designScreenName: .Spawning)
    let spawnMaxDistFromImage = FloatGene(name: "$ spawn max distance from image", min: 0, max: 201, step: 1, def: 0, designScreenName: .Spawning)
    
    let spawnGridX = EnumGene<SpawnGridType>(name: "$ spawn on grid X", def: .off, designScreenName: .Spawning)
    let spawnGridY = EnumGene<SpawnGridType>(name: "$ spawn on grid Y", def: .off, designScreenName: .Spawning)

    let spawnFail = EnumGene<SpawnFailType>(name: "if $ cannot be spawned", def: .dontSpawn, designScreenName: .Spawning)
    
    let beginStuckInPlace = BoolGene(name: "$s spawn stuck in place", def: false, designScreenName: .Spawning)
    let stickInPlace : AttachmentSubChromosome
    
    let showSpawnArrow = BoolGene(name: "show $ spawn arrow", def: false, designScreenName: .Spawning)

    let initialSpeed = LogarithmicFloatGene(name: "$ initial speed", min: 1, max: 500, numSteps: 100, alsoAllowZero: true, def: 0, designScreenName: .Movement)
    let initialSpeedRange = FloatGene(name: "$ initial speed range", min: 0, max: 100, step: 1, def: 0, designScreenName: .Movement)
    let initialMovementAngle = EnumGene<InitialMovementDirection>(name: "$ initial direction", def: .random, designScreenName: .Movement)
    let spawnAngle = FloatGene(name: "$ spawn angle centre", min: 0, max: 360, step: 15, def: 0, designScreenName: .Spawning)
    let spawnAngleRange = FloatGene(name: "$ spawn angle range", min: 0, max: 180, step: 1, def: 180, designScreenName: .Spawning)
    let spawnAngleRotate = FloatGene(name: "$ spawn angle rotate speed", min: -360, max: 360, step: 1, def: 0, designScreenName: .Spawning)
    let stickTime = FloatGene(name: "time for $s to stick to image", min: -1, max: 10, step: 1, def: 3, designScreenName: .Collisions)
    let noiseStrength = LogarithmicFloatGene(name: "$ movement noise", min: 0.01, max: 1, numSteps: 50, alsoAllowZero: true, def: 0, designScreenName: .Movement)
    let noiseWaves = FloatGene(name: "$ noise waviness", min: 0, max: 2, step: 0.1, def: 0.5, designScreenName: .Movement)
    let wallCollision = IntGene(name: "$s bounce off walls", min: 0, max: 15, def: 0, designScreenName: .Collisions)
    
    let initialAngle = FloatGene(name: "$ initial rotation", min: 0, max: 359, step: 1, def: 0, designScreenName: .Spawning)
    let initialAngleRange = FloatGene(name: "$ initial rotation range", min: 0, max: 180, step: 1, def: 0, designScreenName: .Spawning)
    let constantAngularVelocity = FloatGene(name: "$ initial angular velocity", min: -10, max: 10, step: 0.2, def: 0, designScreenName: .Spawning)
    
    init(ballTypeName: String) {
        stickInPlace = AttachmentSubChromosome(`$`: ballTypeName)
        
        super.init(`$`: ballTypeName)
        
        spawnAngle.genesToUpdateOnChange.append(spawnAngleRange.name)
    }
    
    var sizes: [CGFloat] = []
}

class GameplayChromosome : Chromosome {
    
    //----------------------------------------------------------------------------------------------
    // Enums
    
enum AttractionTarget: Int { case none, centre, image, oppositeSide, finger }
    enum CollisionAction: Int { case bounce, passThrough, stick, destroyFriend, destroyFoe, destroyBoth, change, ping, spring, grow, shrink }
    enum CollisionColourChange: Int { case none, becomeFriend, becomeFoe, swap }
    static let selfCollisionActions: [CollisionAction] = [.bounce, .passThrough, .stick, .destroyBoth]
    
    // HACK FOR LET IT SNOW
//    static let imageCollisionActions: [CollisionAction] = [.Bounce, .PassThrough]
    static let imageCollisionActions: [CollisionAction] = [.bounce, .passThrough, .destroyFriend, .destroyFoe, .stick]
    static let wallCollisionActions: [CollisionAction] = [.bounce, .passThrough]
    enum BallLightingType: Int { case unlit, flat, round }
    enum EndCondition: Int { case none, noFriends, noFoes, noBalls }
    enum ThresholdType: Int { case off, lessThan, lessOrEqual, equal, greaterOrEqual, greater, notEqual }
    enum EndThreshType: Int { case anyTime, atEnd }
    enum ImageControlType: Int { case none, dragMove, dragRotate, moveTowardsFinger, swipeOnGrid, teleport }
    enum BallInteractionType: Int { case tap, drag }
    enum ScreenTapAction: Int { case nothing, spawnFriend, spawnFoe }
    enum GoalChangeType: Int { case none, rotateCW, rotateCCW, rotate180, invert, randomise }
    enum FinalScoreType: Int { case score, timeLeft, timeTaken }
    enum RecordType: Int {case highestScore, lowestScore, none }
    enum ScoreLabelType :Int{case none, score, lives, health, progress, shots, kills, freed, released, saved, bullets, survived}
    
    static let scoreThresholds : [Int] = {
        var positive: [Int] = []
        
        // Ranges -- edit this to add or remove options
        // Entries are in the format (step, end)
        let ranges: [(Int, Int)] = [
            (1, 20),   // 1, 2, 3, ..., 20
            (5, 100),  // 25, 30, 35, ..., 100
            (10, 250), // 110, 120, 130, ..., 250
            (50, 1000) // 300, 350, 400, ..., 1000
        ]
        
        // Start at 1
        var i = 1
        
        // Add the ranges
        for (step, end) in ranges {
            positive.append(contentsOf: stride(from: i, to: end, by: step))
            i = end
        }
        
        // Negative numbers
        var negative: [Int] = []
        for i in (0..<positive.count-1).reversed() {
            negative.append(-positive[i])
        }
        
        return negative + [0] + positive
    }()
    
    //----------------------------------------------------------------------------------------------
    // Genes
    

    let physicsSpeed = ChoiceGene<CGFloat>(name: "physics speed", choices: [0.5, 1.0, 2.0, 4.0, 8.0], def: 1, designScreenName: .Movement)
    
    let imageBounciness = FloatGene(name: "image bounciness", min: 0, max: 1, step: 0.01, def: 0.3, designScreenName: .Movement)
    let wallBounciness = FloatGene(name: "wall bounciness", min: 0, max: 1, step: 0.01, def: 0.3, designScreenName: .Movement)
    let ballLighting = EnumGene<BallLightingType>(name: "ball lighting appearance", def: .round, designScreenName: .Lighting)
    let maxBalls = ChoiceGene<Int>(name: "maximum number of balls on screen", choices: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000], def: 1000, designScreenName: .Spawning)
    let maxBallsMode = EnumGene<MaxBallType>(name: "balls to count towards maximum on screen", def: .notStuckToImage, designScreenName: .Spawning)
    let friendFriendCollision = ChoiceGene<CollisionAction>(name: "friend-friend collision type", choices: selfCollisionActions, def: .bounce, designScreenName: .Collisions)
    let friendFriendCollisionChange = EnumGene<CollisionColourChange>(name: "friend-friend collision type change", def: .none, designScreenName: .Collisions)
    let foeFoeCollision = ChoiceGene<CollisionAction>(name: "foe-foe collision type", choices: selfCollisionActions, def: .bounce, designScreenName: .Collisions)
    let foeFoeCollisionChange = EnumGene<CollisionColourChange>(name: "foe-foe collision type change", def: .none, designScreenName: .Collisions)
    let friendFoeCollision = EnumGene<CollisionAction>(name: "friend-foe collision type", def: .bounce, designScreenName: .Collisions)
    let friendFoeCollisionChange = EnumGene<CollisionColourChange>(name: "friend-foe collision type change", def: .none, designScreenName: .Collisions)
    let friendImageCollision = ChoiceGene<CollisionAction>(name: "friend-image collision type", choices: imageCollisionActions, def: .bounce, designScreenName: .Collisions)
    let foeImageCollision = ChoiceGene<CollisionAction>(name: "foe-image collision type", choices: imageCollisionActions, def: .bounce, designScreenName: .Collisions)
    let imageWallCollision = IntGene(name: "image bounces off walls", min: 0, max: 15, def: 0, designScreenName: .Collisions)
    let gridX = IntGene(name: "grid x divisions", min: 1, max: 50, def: 1, designScreenName: .Appearance)
    let gridY = IntGene(name: "grid y divisions", min: 1, max: 50, def: 1, designScreenName: .Appearance)
    let imageGridSnap = BoolGene(name: "image snap to grid", def: false, designScreenName: .Movement)
    
    let friend = BallSubChromosome(ballTypeName: "friend")
    let foe = BallSubChromosome(ballTypeName: "foe")
    
    func getBallSubChromosome(_ ballType: Ball.BallType) -> BallSubChromosome {
        switch ballType {
        case .friend: return friend
        case .foe: return foe
        }
    }
    
    // HACK FOR LET IT SNOW
    let duration = ChoiceGene<CGFloat>(name: "game duration", choices: [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 1000, 1020, 3600], def: 30, designScreenName: .GameEnd)
    let scoreThresholdType = EnumGene<ThresholdType>(name: "score threshold type", def: .greaterOrEqual, designScreenName: .GameEnd)
    let scoreThreshold = ChoiceGene<Int>(name: "score threshold", choices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 800, 900, 1000], def: 20, designScreenName: .GameEnd)
    let endOnScoreThreshold = BoolGene(name: "end game when score threshold reached?", def: false, designScreenName: .GameEnd)
    let scoreLabel = EnumGene<ScoreLabelType>(name: "score label", def: .score, designScreenName: .GameEnd)
    let scoreStartValue = ChoiceGene<Int>(name: "score start value", choices: scoreThresholds, def: 0, designScreenName: .GameEnd)
    
    let healthThresholdType = EnumGene<ThresholdType>(name: "health threshold type", def: .off, designScreenName: .GameEnd)
    let healthThreshold = ChoiceGene<Int>(name: "health threshold", choices: scoreThresholds, def: 20, designScreenName: .GameEnd)
    let healthLabel = EnumGene<ScoreLabelType>(name: "health label", def: .health, designScreenName: .GameEnd)
    let healthStartValue = ChoiceGene<Int>(name: "health start value", choices: scoreThresholds, def: 0, designScreenName: .GameEnd)
    
    let progressThresholdType = EnumGene<ThresholdType>(name: "progress threshold type", def: .off, designScreenName: .GameEnd)
    let progressThreshold = ChoiceGene<Int>(name: "progress threshold", choices: scoreThresholds, def: 20, designScreenName: .GameEnd)
    let progressLabel = EnumGene<ScoreLabelType>(name: "progress label", def: .progress, designScreenName: .GameEnd)
    let progressStartValue = ChoiceGene<Int>(name: "progress start value", choices: scoreThresholds, def: 0, designScreenName: .GameEnd)
    
    let recordType = EnumGene<RecordType>(name: "record", def: RecordType.none, designScreenName: .GameEnd)
    let showTimer = BoolGene(name: "show timer", falseText: "No", trueText: "Yes", def: true, designScreenName: .GameEnd)
    
    let mixedCriticalClusterSize = IntGene(name: "mixed cluster explode size", min: 1, max: 10, def: 3, designScreenName: .Collisions)
    let batAwayGoals = IntGene(name: "bat-away goal sides", min: 1, max: 0xF, def: 0x5, designScreenName: .Collisions)
    let goalChangeWhen = ChoiceGene<CGFloat>(name: "when bat-away goals change", choices: [-1, 0, 0.25, 0.5, 0.75, 1, 1.5, 2, 5, 10], def: -1, designScreenName: .Collisions)
    let goalChangeType = EnumGene<GoalChangeType>(name: "how bat-away goals change", def: .none, designScreenName: .Collisions)
    let goalColour = ColourGene(name: "goal colour", def: .darkGray, designScreenName: .Appearance)
    let attachment = AttachmentSubChromosome(`$`: "image")
    let controlType = EnumGene<ImageControlType>(name: "image control", def: .dragRotate, designScreenName: .Interaction)
    let forwardDirection = FloatGene(name: "image 'forward' direction", min: 0, max: 359, step: 15, def: 180, designScreenName: .Interaction)
    let ballInteraction = EnumGene<BallInteractionType>(name: "ball touch type", def: .tap, designScreenName: .Interaction)
    let showTouch = BoolGene(name: "show touch position", falseText: "hide", trueText: "show", def: false, designScreenName: .Interaction)
    let tapRadius = FloatGene(name: "tap area-of-effect radius", min: 1, max: 100, step: 1, def: 30, designScreenName: .Interaction)
    let dragRadius = FloatGene(name: "drag area-of-effect radius", min: 1, max: 100, step: 1, def: 15, designScreenName: .Interaction)
    let dragThreshold = FloatGene(name: "drag distance threshold", min: 1, max: 20, step: 1, def: 1, designScreenName: .Interaction)
    let imageTapAction = EnumGene<ScreenTapAction>(name: "image touch action", def: .nothing, designScreenName: .Interaction)
    let backgroundTapAction = EnumGene<ScreenTapAction>(name: "background touch action", def: .nothing, designScreenName: .Interaction)
    let showScore = BoolGene(name: "show score", falseText: "hide", trueText: "show", def: true, designScreenName: .Score)
    let showHealth = BoolGene(name: "show health", falseText: "hide", trueText: "show", def: false, designScreenName: .Health)
    let showProgress = BoolGene(name: "show progress", falseText: "hide", trueText: "show", def: false, designScreenName: .Progress)
    let textColour = ColourGene(name: "score text colour", def: .darkGray, designScreenName: .Appearance)
    let finalScore = EnumGene<FinalScoreType>(name: "final score type", def: .score, designScreenName: .GameEnd)
    
    var score: [ScoreContributionSubChromosome] = []
    var health: [ScoreContributionSubChromosome] = []
    var progress: [ScoreContributionSubChromosome] = []
    
    //----------------------------------------------------------------------------------------------
    // Initialisation
    
    func getCounterContributions(_ counterType: CounterType) -> [ScoreContributionSubChromosome] {
        switch counterType {
        case .score: return score
        case .health: return health
        case .progress: return progress
        }
    }
    
    // HACK FOR LET IT SNOW
    //static let numScores = 6
    static let numScores = 9
    
    static func initCounterContributions(_ counterName: String, designScreenName: DesignScreenName) -> [ScoreContributionSubChromosome] {
        var result : [ScoreContributionSubChromosome] = []
        for i in 0 ..< numScores {
            let newScore = ScoreContributionSubChromosome(scoreName: counterName, contribIndex: i, designScreenName: designScreenName)
            result.append(newScore)
        }
        return result
    }
    
    init(stringRepresentation: String){
        score = GameplayChromosome.initCounterContributions("score", designScreenName: .Score)
        health = GameplayChromosome.initCounterContributions("health", designScreenName: .Health)
        progress = GameplayChromosome.initCounterContributions("progress", designScreenName: .Progress)
        super.init(stringRepresentation: stringRepresentation, name: .Gameplay)
    }
    
    deinit {
        //print("!!! [DEINIT] GameplayChromosome")
    }
}
