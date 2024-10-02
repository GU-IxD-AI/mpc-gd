//
//  Ball.swift
//  Fask
//
//  Created by Powley, Edward on 18/09/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class BallTextureCache {
    
    struct Entry {
        var texture: SKTexture! = nil
    }

    var name: String! = nil
    var entries: [Int : Entry] = [:]

    init(_ n: String!) {
        name = n
    }

    func populate(images: [UIImage]) {
        wipe()

        for i in images {
            var e = Entry()
            e.texture = SKTexture(image: i)
            entries[Int(i.size.width)] = e
        }
    }

    func wipe() {
        entries.removeAll()
    }

    func texture(size: Int) -> SKTexture? {
        guard let e = entries[size] else {
            return nil
        }
        return e.texture
    }

    static var foe = BallTextureCache("foe")
    static var friend = BallTextureCache("friend")
}

class Ball{
    
    var previousControllerBounceTime: Date! = nil

    var requiresScaleInverseWhileChanging = false
    
    static let showDebugVis = false

    fileprivate static var nextId = 0
    let id : Int
    
    weak var fascinator : Fascinator!
    let node : SKNode
    //let sprite : SKSpriteNode
    var iconNode : SKSpriteNode! = nil
    var arrowShape : SKShapeNode! = nil
    var springNode : SKSpriteNode! = nil
    var attachmentJoint : SKPhysicsJoint! = nil
    var attachmentPoint : CGPoint! = nil
    var bounceID: Int = RandomUtils.randomInt(0, upperInc: 1000000)
    
    var isExplodingInMaxCluster = false
    var hasJustLanded = false
    var isFlying = false
    
    var radius : CGFloat
    var spawnedFrom : Edge
    var collisionShapeType : BallSubChromosome.CollisionShapeType! = nil
    
    var isChangingType = false
    var targetRadius : CGFloat = 0
    var radiusChangeSpeed : CGFloat = 0
    var timeChangingAndTrapped : CFTimeInterval = 0
    var oldIcon : SKSpriteNode! = nil
    
    enum BallType: Int {
    case friend, foe
        var otherType: BallType {
            switch self {
            case .friend: return .foe
            case .foe: return .friend
            }
        }
    }
    
    var type : BallType {
        didSet {
            if type != oldValue {
                onBallTypeChanged()
            }
        }
    }
    
    var chromosome : BallSubChromosome
    
    var colour : UIColor { return UIColor.white }
    
    var explosionColour : UIColor {
        // TODO: Fix
        return colour
//        if iconNode != nil {
//            return ScaledImageCache.getDominantColour(chromosome.icon.value, size: iconNode.size * 2, maintainAspectRatio: true)
//        }
//        else {
//            return sprite.color
//        }
    }
    
    var collectionNum = 0
    var characterNum = 0
    
    var isOnScreen : Bool = false
    var hasBeenOnScreen : Bool = false
    var removeOnNextFrame : Bool = false
    var timeOnScreen: CGFloat = 0
    var numFramesSinceSpawn : Int = 0
    
    var ringShape : SKShapeNode! = nil
    var timeContactingBg: CGFloat = 0
    var isInContactWithBg = false
    var isStuck = false
    var stuckBalls: [Weak<Ball>] = []
    
//    static var spriteTextures: [Int: SKTexture] = [:]
//
//    static func getTextureForBallOfRadius(_ radius: CGFloat) -> SKTexture {
//        let intRadius = Int(ceil(radius))
//
//        if let texture = spriteTextures[intRadius] {
//            return texture
//        }
//
//        let desiredWH = ceil(radius * 2 * 2)
//        let circle = DrawingShapes.getCircleImage(desiredWH, colour: UIColor.white)
//        let texture = SKTexture(image: circle)
//        spriteTextures[intRadius] = texture
//
//        return texture
//    }
//
//    static var normalTexture = SKTexture(imageNamed: "ball_normalmap")

    init(fascinator: Fascinator, position: CGPoint, type: BallType, radius: CGFloat){
        
        self.id = Ball.nextId
        Ball.nextId += 1
        
        self.collectionNum = type == .foe ? fascinator.chromosome.foe.characterCollectionNum.intValue : fascinator.chromosome.friend.characterCollectionNum.intValue
        self.characterNum = type == .foe ? fascinator.chromosome.foe.characterNum.intValue : fascinator.chromosome.friend.characterNum.intValue
        
        self.fascinator = fascinator
        self.chromosome = fascinator.chromosome.getBallSubChromosome(type)
        
        //self.radius = Ball.chooseRadius(chromosome)
        self.radius = radius
        
        self.type = type
//        self.sprite = SKSpriteNode(texture: Ball.getTextureForBallOfRadius(radius), size: CGSize(width: radius*2, height: radius*2))
//        sprite.colorBlendFactor = 1.0
        self.node = SKNode()
        
        let angleBase = chromosome.initialAngle.value
        let angleRange = chromosome.initialAngleRange.value
        let rotation = RandomUtils.randomFloat(angleBase - angleRange, upperInc: angleBase + angleRange)
        
        self.spawnedFrom = fascinator.getClosestEdge(position)
        node.setPositionTo(position)
        node.setAngleTo(degrees: -rotation)
        node.zPosition = ZPositionConstants.ballNode
        
        addIconNode()
        iconNode.alpha = 0
        iconNode.run(SKAction.fadeIn(withDuration: 0.5))

        updatePhysicsBodyOnChange()
        
        node.userData = NSMutableDictionary()
        node.userData?.setValue(self, forKey: "ball")
        
        //let velocity = CGFloat(RandomUtils.randomInt(10, upperInc: 100))
        //shape.physicsBody!.velocity = CGVector(dx: -cos(angle) * velocity, dy: -sin(angle) * velocity)
        
        fascinator.fascinatorSKNode.addChild(node)
        
        if Ball.showDebugVis || chromosome.showSpawnArrow.value{
            let arrowPath = CGMutablePath()
            arrowPath.move(to: CGPoint(x: radius, y: 0))
            arrowPath.addLine(to: CGPoint(x: -radius, y: -radius))
            arrowPath.addLine(to: CGPoint(x: -radius, y: radius))
            arrowPath.addLine(to: CGPoint(x: radius, y: 0))
            arrowShape = SKShapeNode(path: arrowPath)
            arrowShape.strokeColor = (type == .friend) ? UIColor.blue : UIColor.white
            arrowShape.fillColor = colour
            let labelNode = SKLabelNode(text: "\(id)")
            arrowShape.addChild(labelNode)
            fascinator.fascinatorSKNode.addChild(arrowShape)
        }
    }
    
    static func chooseRadius(_ chromosome : BallSubChromosome) -> CGFloat {
        guard chromosome.sizes.isEmpty == false else { return 64 }
        return RandomUtils.randomChoice(chromosome.sizes)
    }
    
    func createBallPhysicsBody(_ collisionShapeType : BallSubChromosome.CollisionShapeType) -> SKPhysicsBody {
        self.collisionShapeType = collisionShapeType
        return CharacterIconHandler.getPhysicsBody(radius: radius, collectionNum: collectionNum, characterNum: characterNum, isController: false)
    }
    
    func onBallTypeChanged() {
        chromosome = fascinator.chromosome.getBallSubChromosome(type)
        
        unstickBall()
        let newRadius = Ball.chooseRadius(chromosome)
        let newColour = chromosome.colour.value
        collectionNum = type == .friend ? fascinator.chromosome.friend.characterCollectionNum.value : fascinator.chromosome.foe.characterCollectionNum.value
        characterNum = type == .friend ? fascinator.chromosome.friend.characterNum.value : fascinator.chromosome.foe.characterNum.value
        
        runSizeChangeAnimation(newRadius, newColour: newColour)
    }
    
    func unstickBall(){
        if isStuck {
            isStuck = false
            timeContactingBg = 0
        }
    }
    
    func removeFromScene() {
        for ballRef in stuckBalls {
            _ = ballRef.value.stuckBalls.removeWhere({w in w.value === self})
        }
        
        node.removeFromParent()
        if arrowShape != nil {
            arrowShape.removeFromParent()
        }
        if springNode != nil {
            springNode.removeFromParent()
        }
        node.userData = nil
        node.physicsBody = nil
    }
    
    func createIcon(_ radius : CGFloat) -> SKSpriteNode! {
        let diameter = Int(radius) * 2
        let cache = type == .friend ? BallTextureCache.friend : BallTextureCache.foe
        guard let texture = cache.texture(size: diameter) else { return nil }
        iconNode = SKSpriteNode(texture: texture, size: CGSize(width: diameter, height: diameter))
        return iconNode
    }
    
    func addIconNode(){
        if iconNode != nil {
            iconNode.removeFromParent()
            iconNode = nil
        }
        
        iconNode = createIcon(self.radius)
        if iconNode != nil {
            node.addChild(iconNode)
        }
    }
    
    // NEED TO GET IT TO INHERIT THE ANGULAR ROTATION
    
    func runSizeChangeAnimation(_ newRadius: CGFloat, newColour: UIColor){
        isChangingType = true
        let oldRadius = radius

        oldIcon = iconNode
        iconNode = createIcon(newRadius)
        
      //  iconNode.zRotation = oldIcon.zRotation
        
        let cc = chromosome.characterCollectionNum.value
        let c = chromosome.characterNum.value
        
        requiresScaleInverseWhileChanging = false
        if spawnedFrom == .right && CharacterIconHandler.requiresHorizontalFlipIfSpawnedOnRight(collectionNum: cc, characterNum: c){
            requiresScaleInverseWhileChanging = true
        }
        if spawnedFrom == .left && CharacterIconHandler.requiresHorizontalFlipIfSpawnedOnLeft(collectionNum: cc, characterNum: c){
            requiresScaleInverseWhileChanging = true
        }
        
        if requiresScaleInverseWhileChanging{
            node.xScale = -1
        }
        else{
            node.xScale = 1
        }

        iconNode.alpha = 0
        iconNode.size = oldIcon.size
        node.addChild(iconNode)
        
        // Change the physics size and radius property
        targetRadius = newRadius
        radiusChangeSpeed = (newRadius - oldRadius) / CGFloat(LAF.ballScaleDuration)
        
        // Fade the old icon out and the new icon in
        oldIcon.run(SKAction.fadeOut(withDuration: LAF.ballScaleDuration), completion: {
            self.oldIcon.removeFromParent()
            self.oldIcon = nil
        })
        iconNode.run(SKAction.fadeIn(withDuration: LAF.ballScaleDuration))
    }
    
    func enableAttractionFields() {
        switch type {
        case .friend:
            node.physicsBody!.fieldBitMask = UInt32(1 << spawnedFrom.rawValue)
        case .foe:
            node.physicsBody!.fieldBitMask = UInt32(1 << (spawnedFrom.rawValue + 4))
        }
    }
    
    func disableAttractionFields() {
        node.physicsBody!.fieldBitMask = 0
    }

    func updatePhysicsBodyOnChange(){
        // Unstick all balls from this one
        for ballRef in stuckBalls {
            _ = ballRef.value.stuckBalls.removeWhere({w in w.value === self})
        }
        stuckBalls = []
        
        var oVelocity = CGVector.zero
        if node.physicsBody != nil {
            oVelocity = node.physicsBody!.velocity
        }
        let angularVelocity = node.physicsBody?.angularVelocity
        node.physicsBody = createBallPhysicsBody(chromosome.collisionShape.value)
        if angularVelocity != nil{
            node.physicsBody!.angularVelocity = angularVelocity!
        }
        node.physicsBody!.mass = 0.5
        node.physicsBody!.charge = 100
        node.physicsBody!.restitution = chromosome.bounciness.value
        node.physicsBody!.friction = chromosome.friction.value
        node.physicsBody!.allowsRotation = chromosome.canRotate.value
        
        node.physicsBody!.linearDamping = chromosome.linearDrag.value
        node.physicsBody!.angularDamping = chromosome.angularDrag.value
        node.physicsBody!.velocity = oVelocity
        let wallMask = UInt32(chromosome.wallCollision.value) << Fascinator.maskOffsetWall
        node.physicsBody!.collisionBitMask = wallMask
        node.physicsBody!.contactTestBitMask = Fascinator.maskBg | Fascinator.maskFriend | Fascinator.maskFoe | wallMask
        
        enableAttractionFields()
        
        switch type {
        case .friend:
            node.physicsBody!.categoryBitMask = Fascinator.maskFriend
            if fascinator.chromosome.friendFriendCollision.value != .passThrough {
                node.physicsBody!.collisionBitMask |= Fascinator.maskFriend
            }
            if fascinator.chromosome.friendFoeCollision.value != .passThrough {
                node.physicsBody!.collisionBitMask |= Fascinator.maskFoe
            }
            if fascinator.chromosome.friendImageCollision.value != .passThrough {
                node.physicsBody!.collisionBitMask |= Fascinator.maskBg
            }
            
        case .foe:
            node.physicsBody!.categoryBitMask = Fascinator.maskFoe
            if fascinator.chromosome.friendFoeCollision.value != .passThrough {
                node.physicsBody!.collisionBitMask |= Fascinator.maskFriend
            }
            if fascinator.chromosome.foeFoeCollision.value != .passThrough {
                node.physicsBody!.collisionBitMask |= Fascinator.maskFoe
            }
            if fascinator.chromosome.foeImageCollision.value != .passThrough {
                node.physicsBody!.collisionBitMask |= Fascinator.maskBg
            }
        }
        
    }

    static func getScoreValue(ballType: BallType) -> Int {
        switch ballType {
        case .friend:
            return +1
        case .foe:
            return -1
        }
    }
    
    func getScoreValue() -> Int {
        return Ball.getScoreValue(ballType: self.type)
    }
    
    func beginContactWithBg() {
        if stickTime == 0 {
            stickToArtImage()
        }
    }
    
    func stickTo(_ otherBall: Ball) {
        if self.node.scene == nil || otherBall.node.scene == nil {
            print("Warning: attempted to stick balls which are no longer in the scene")
            return
        }
        
        if self.stuckBalls.contains(where: {w in w.value === otherBall}) || otherBall.stuckBalls.contains(where: {w in w.value === self}) {
            print("Warning: attempted to stick balls which are already stuck")
            return
        }
        
        // Move the balls so that they are the correct distance apart
        // HACK FOR LET IT SNOW - TURN THIS OFF
        /*
        if self.collisionShapeType == .shape && otherBall.collisionShapeType == .shape {
            let jointCentre = MathsUtils.lerp(self.radius / (self.radius + otherBall.radius), p0: node.position, p1: otherBall.node.position)
            let jointDirection = (otherBall.node.position - node.position).normalised()
            node.position = jointCentre - jointDirection * self.radius
            otherBall.node.position = jointCentre + jointDirection * otherBall.radius
        }
 */
        
        // Create the joint
        
        
        /*
        let joint = SKPhysicsJointPin.joint(withBodyA: node.physicsBody!, bodyB: otherBall.node.physicsBody!, anchor: node.position)
        joint.rotationSpeed = 0
        joint.frictionTorque = 1000
         
         let joint = SKPhysicsJointLimit.joint(withBodyA: node.physicsBody!, bodyB: otherBall.node.physicsBody!, anchorA: node.position, anchorB: otherBall.node.position)
         joint.maxLength = sqrt((node.position - otherBall.node.position).sqrMagnitude())
*/
        let joint = SKPhysicsJointSpring.joint(withBodyA: node.physicsBody!, bodyB: otherBall.node.physicsBody!, anchorA: node.position, anchorB: otherBall.node.position)
        joint.frequency = 1
        joint.damping = 1
        
        node.physicsBody?.allowsRotation = false
        otherBall.node.physicsBody?.allowsRotation = false
 
        fascinator.scene.physicsWorld.add(joint)
        
        self.stuckBalls.append(Weak(value: otherBall))
        otherBall.stuckBalls.append(Weak(value: self))
    }
    
    func stickToArtImage() {
        if isStuck {
            print("Warning: attempted to stick a ball which is already stuck")
            return
        }
        
        isStuck = true
        
        let joint = SKPhysicsJointPin.joint(withBodyA: node.physicsBody!, bodyB: fascinator.artImageNode.physicsBody!, anchor: node.position)
        joint.rotationSpeed = 0
        joint.frictionTorque = 1000
        fascinator.scene.physicsWorld.add(joint)
        
        ringShape = SKShapeNode(circleOfRadius: 1.25*radius)
        ringShape.strokeColor = colour
        ringShape.alpha = 0.5
        ringShape.lineWidth = radius
        node.addChild(ringShape)
        ringShape.zRotation = CGFloat(0.5 * .pi) - node.zRotation
        
        let duration = 0.5
        let action = SKAction.group([
            SKAction.scale(to: 4, duration: duration),
            SKAction.fadeOut(withDuration: duration),
            SKAction.customAction(withDuration: duration, actionBlock: {(node: SKNode, elapsed: CGFloat) -> Void in
                if let shapeNode = node as? SKShapeNode {
                    shapeNode.lineWidth = self.radius * CGFloat(1 - elapsed / CGFloat(duration))
                }
            })
            ])
        ringShape.run(action, completion: {
            self.ringShape.removeFromParent()
            self.ringShape = nil
        })
    }
    
    func stickInPlace() {
        if !isChangingType {
            if attachmentJoint != nil {
                print("WARNING: sticking a ball which is already stuck")
            }
            
            let (aJoint, _) = fascinator.createAttachmentToScene(
                node.physicsBody!,
                attachmentChromosome: chromosome.stickInPlace,
                attachmentPointArea: CGSize(width: self.radius * 2, height: self.radius * 2))
            
            attachmentJoint = aJoint
            
            if chromosome.stickInPlace.joint.value == .spring {
                if springNode != nil {
                    springNode.removeFromParent()
                    springNode = nil
                }
                
                // FIX THIS - GET THE SPRING BACK
                
                /*
                
                springNode = SKSpriteNode(imageNamed: (type == .friend) ? "BlueSpring" : "WhiteSpring")
           //     springNode.position = attachmentPoint
                springNode.position = node.position//CGPoint(x: 0, y: 0)
                springNode.zPosition = ZPositionConstants.springNode
                springNode.alpha = 0
                springNode.run(SKAction.fadeIn(withDuration: LAF.ballFadeInDuration))
                fascinator.fascinatorSKNode.addChild(springNode)
 */
            }
        }
    }
    
    func unstickFromPlace() {
        if attachmentJoint == nil {
            print ("WARNING: attempting to unstick a non-stuck ball")
            return
        }
        
        fascinator.scene.physicsWorld.remove(attachmentJoint)
        attachmentJoint = nil
        attachmentPoint = nil
        
        if springNode != nil {
            springNode.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: LAF.ballFadeOutDuration),
                SKAction.removeFromParent()
            ]))
            springNode = nil
        }
    }
    
    func toggleStuckInPlace() {
        if attachmentJoint == nil {
            stickInPlace()
        }
        else {
            unstickFromPlace()
        }
    }
    
    var stickTime: CGFloat {
        return chromosome.stickTime.value
    }
    
    func matchesFilter(_ filter: ScoreContributionSubChromosome.FilterType) -> Bool {
        switch filter {
        case .all:
            return true
        case .stuckTransitively:
            return isStuckTransitively()
        }
    }
    
    func isStuckTransitively() -> Bool {
        if isStuck {
            return true
        }
        else {
            var visited = [self]
            var stack = [self]
            while let current = stack.popLast() {
                for neighbour in current.stuckBalls {
                    if neighbour.value.isStuck {
                        return true
                    }
                    if !visited.containsIdentity(neighbour.value) {
                        visited.append(neighbour.value)
                        stack.append(neighbour.value)
                    }
                }
            }
            return false
        }
    }
    
    func updateVisuals() {
        
        // Un-rotate the sprite -- this fixes a bug with normal mapping
        //sprite.zRotation = -node.zRotation
        
        // Update the spring
        if springNode != nil && attachmentPoint != nil {
            springNode.position = (attachmentPoint + node.position) * CGFloat(0.5)
            let delta = node.position - attachmentPoint
            let length = delta.magnitude()
            let thickness: CGFloat
            if length == 0 {
                thickness = LAF.springMaxThickness
            }
            else {
                thickness = MathsUtils.clamp(LAF.springThicknessMult / length, min: LAF.springMinThickness, max: LAF.springMaxThickness)
            }
            springNode.size = CGSize(width: length, height: thickness)
            springNode.zRotation = atan2(delta.dy, delta.dx)
        }
        
        for stuckBallRef in stuckBalls {
            if stuckBallRef.value.id < id{
                let path = CGMutablePath()
                let p1 = node.position
                let p2 = stuckBallRef.value.node.position
                let d = (p2 - p1).normalised() * 3
                path.move(to: CGPoint(x: node.position.x + d.dy, y: node.position.y - d.dx))
                path.addLine(to: CGPoint(x: stuckBallRef.value.node.position.x + d.dy, y: stuckBallRef.value.node.position.y - d.dx))
                let lineNode = SKShapeNode(path: path)
                lineNode.strokeColor = CharacterIconHandler.getCharacterColour(collectionNum: collectionNum, characterNum: characterNum)
                lineNode.lineWidth = 2
                lineNode.alpha = 0.6
                lineNode.zPosition = node.zPosition - 1
                fascinator.fascinatorSKNode.addChild(lineNode)
                lineNode.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.01),
                    SKAction.removeFromParent()
                    ]))
            }
        }
    }
    
    func canEverBeOnScreen() -> Bool {
        let pos = node.position
        let vel = node.physicsBody!.velocity
        let acc : CGVector
        
        switch chromosome.attractTo.value {
        case .centre, .finger, .image:
            // We only really care about the signs of x and y, not the magnitudes, so this is good enough
            acc = node.position - fascinator.sceneCentre
            
        case .oppositeSide:
            acc = spawnedFrom.opposite.directionVector
            
        case .none:
            acc = CGVector.zero
        }
        
        // In all cases: if the ball is off the side, and velocity is not moving it back, and acceleration is not pulling it back, then it's outta here
        
        // Left
        if pos.x <= 0 && vel.dx <= 0 && acc.dx <= 0 {
            return false
        }
        // Right
        if pos.x >= fascinator.sceneSize.width && vel.dx >= 0 && acc.dx >= 0 {
            return false
        }
        // Bottom
        if pos.y <= 0 && vel.dy <= 0 && acc.dy <= 0 {
            return false
        }
        // Top
        if pos.y >= fascinator.sceneSize.height && vel.dy >= 0 && acc.dy >= 0 {
            return false
        }
        
        return true
    }
    
    func update(_ deltaTime: CFTimeInterval){
        let w = fascinator.sceneSize.width + fascinator.deviceSimulationXOffset
        let h = fascinator.sceneSize.height + fascinator.deviceSimulationYOffset
        
        if node.position.x > -radius && node.position.y > -radius && node.position.x < w+radius && node.position.y < h+radius {
            isOnScreen = true
        }
        else {
            isOnScreen = false
        }
        
        if isOnScreen {
            hasBeenOnScreen = true
        }
        
        if isOnScreen {
            timeOnScreen += CGFloat(deltaTime)
        }
        
        if isOnScreen && chromosome.constantAngularVelocity.value != 0 {
            node.physicsBody?.angularVelocity = chromosome.constantAngularVelocity.value
        }
        
        if !isOnScreen && !hasBeenOnScreen && !canEverBeOnScreen() {
            removeOnNextFrame = true
        }
        
        if arrowShape != nil {
            if isOnScreen {
                arrowShape.removeFromParent()
                arrowShape = nil
            }
            else {
                let dx = node.position.x - w*0.5
                let dy = node.position.y - h*0.5
                let angle = atan2(dy, dx)
                let r = w*0.5 - 10
                
                // TODO: the arrows might look better at the edge of the screen
                arrowShape.setPositionTo(CGPoint(x: w*0.5 + cos(angle)*r, y: h*0.5 + sin(angle)*r))
                arrowShape.setAngleTo(radians: angle)
            }
        }
        
        if chromosome.speedLimit.value > 0 {
            let centre = chromosome.speedLimit.value
            let range = chromosome.speedLimitRange.value
            node.physicsBody!.velocity = node.physicsBody!.velocity.clampMagnitude(min: centre - range, max: centre + range)
        }
        
        if isChangingType {
            var isTrapped = false
            
            if radiusChangeSpeed > 0 {
                let numRaycasts = Int(4 * radius)
                
                // Do raycasts to find nearby objects. Apply a force to the ball, and an equal and opposite force to the object.
                // A sensible physics engine would let us just query current contacts for the physics body, but this is SpriteKit so it's time for an inefficient workaround.
                for i in 0 ..< numRaycasts {
                    let angle = CGFloat(i) / CGFloat(numRaycasts) * 2 * MathsUtils.π
                    let vector = CGVector(dx: cos(angle), dy: sin(angle))
                    let rayEnd = node.position + vector * (radius + 1)
                    fascinator.scene.physicsWorld.enumerateBodies(alongRayStart: node.position, end: rayEnd, using: { body, point, normal, stop in
                        if body !== self.node.physicsBody {
                            let f = normal
                            body.applyForce(-1 * f, at: point)
                            self.node.physicsBody!.applyForce(f, at: point)
                            isTrapped = true
                        }
                    })
                    
                    if Ball.showDebugVis {
                        let path = CGMutablePath()
                        let p1 = node.position
                        let p2 = rayEnd
                        path.move(to: p1)
                        path.addLine(to: p2)
                        let lineNode = SKShapeNode(path: path)
                        lineNode.strokeColor = UIColor.orange
                        lineNode.lineWidth = 1
                        lineNode.zPosition = node.zPosition - 1
                        fascinator.fascinatorSKNode.addChild(lineNode)
                        lineNode.run(SKAction.sequence([
                            SKAction.wait(forDuration: 0.01),
                            SKAction.removeFromParent()
                            ]))
                    }
                }
            }
            
            if isTrapped {
                timeChangingAndTrapped += deltaTime
                if timeChangingAndTrapped > 0.5 {
                    isChangingType = false
                }
            }
            else {
                timeChangingAndTrapped = 0
            
                self.radius += radiusChangeSpeed * CGFloat(deltaTime)
                if (radiusChangeSpeed > 0 && self.radius > targetRadius) || (radiusChangeSpeed < 0 && self.radius < targetRadius) || (radiusChangeSpeed.approxEquals(0)) {
                    self.radius = targetRadius
                    self.isChangingType = false
                }
                
                if requiresScaleInverseWhileChanging{
                    node.xScale = 1
                }
                self.updatePhysicsBodyOnChange()
                if requiresScaleInverseWhileChanging{
                    node.xScale = -1
                }

                let size = CGSize(width: radius*2, height: radius*2)
                iconNode.size = size
                if oldIcon != nil {
                    oldIcon.size = size
                }
            }
        }
        
        if !isStuck && stickTime >= 0 {
            if isInContactWithBg {
                timeContactingBg += CGFloat(deltaTime)
                
                if timeContactingBg >= stickTime {
                    stickToArtImage()
                }
            }
            else {
                timeContactingBg -= 10 * CGFloat(deltaTime)
                if timeContactingBg < 0 {
                    timeContactingBg = 0
                }
            }
            
            if !isStuck {
            	if timeContactingBg > 0 {
                	let path = CGMutablePath()
                	var endAngle = CGFloat.pi * 2 * (1 - timeContactingBg / stickTime)
                	endAngle = max(endAngle, 0)
                	endAngle = min(endAngle, 2 * CGFloat.pi - 0.00001)
                    path.addArc(center: CGPoint.zero, radius: 1.25*radius, startAngle: 0, endAngle: endAngle, clockwise: true)

                	if ringShape == nil {
                		ringShape = SKShapeNode(path: path)
                		ringShape.strokeColor = colour
                		ringShape.alpha = 0.5
                		ringShape.lineWidth = 0.5 * radius
                		node.addChild(ringShape)
                		ringShape.zRotation = CGFloat(0.5 * .pi) - node.zRotation           
                    }
                } else  if timeContactingBg == 0 && ringShape != nil {
                	ringShape.lineWidth = 0.5 * radius //FIXME: ringShape needs to converted to clocknode
                }
            }
        }
        
        numFramesSinceSpawn += 1
    }
}
