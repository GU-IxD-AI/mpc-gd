//
//  StopClusterFormingWhenOthersMoving.swift
//  MPCGD
//
//  Created by Simon Colton on 26/12/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class RainRainTactic : MacroTactic{
    
    override init(settings: StrategySettings) {
        super.init(settings: settings)
    }
    
    // Find the ball directly below this one, or nil if there isn't one
    func findNextBallDown(_ ball: Ball) -> Ball? {
        var highestBall : Ball! = nil
        
        for side : CGFloat in [-1, 1] {
            let rayStart = CGPoint(x: ball.node.position.x + side * ball.radius, y: ball.node.position.y + 1)
            let rayEnd = CGPoint(x: rayStart.x, y: 0)
            
            let physicsWorld = ball.fascinator.scene.physicsWorld
            physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd, using: { body, point, normal, stop in
                if let otherBall = body.node?.userData?.value(forKey: "ball") as? Ball {
                    if otherBall !== ball
                        && otherBall.node.position.y < ball.node.position.y - ball.radius
                        && (highestBall == nil || otherBall.node.position.y > highestBall.node.position.y) {
                        highestBall = otherBall
                    }
                }
            })
        }
        
        return highestBall
    }
    
    // Return whether this cluster is directly above one or more white balls
    func isBlueClusterAboveWhites(_ cluster: [Ball]) -> Bool {
        for ball in cluster {
            if let nextBall = findNextBallDown(ball) {
                if nextBall.type == .foe {
                    return true
                }
            }
        }
        
        return false
    }
    
    // Do a raycast, and return the first ball encountered (or nil if no balls are hit)
    func getFirstBallAlongRay(_ physicsWorld: SKPhysicsWorld,
                              rayStart: CGPoint, rayDirection: CGVector, excludeBall: Ball?) -> Ball? {
        var firstBall : Ball? = nil
        var firstDistance = CGFloat.infinity
        let rayEnd = rayStart + rayDirection
        
        physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd, using: {body, point, normal, stop in
            if let ball = body.node?.userData?.value(forKey: "ball") as? Ball {
                let distance = (point - rayStart).sqrMagnitude()
                if ball !== excludeBall && distance < firstDistance {
                    firstBall = ball
                    firstDistance = distance
                }
            }
        })
        
        return firstBall
    }
    
    // Is the ball falling?
    func isFalling(_ ball: Ball) -> Bool {
        return ball.node.physicsBody!.velocity.dy < -10
    }
    
    // Heuristic for when a white cluster is considered to be "exposed"
    func isWhiteClusterExposed(_ cluster: [Ball]) -> Bool {
        // Don't consider falling cluster to be exposed
        
        var allFalling = true
        for ball in cluster {
            if !isFalling(ball) {
                allFalling = false
                break
            }
        }
        
        if allFalling {
            return false
        }
        
        let fascinator = cluster[0].fascinator
        let physicsWorld = fascinator?.scene.physicsWorld
        for ball in cluster {
            if let ballAbove = getFirstBallAlongRay(physicsWorld!, rayStart: ball.node.position,
                                                    rayDirection: CGVector(dx: 0, dy: 10000), excludeBall: ball) {
                if ballAbove.type == .foe && isFalling(ballAbove) && !cluster.containsIdentity(ballAbove) {
                    // Ball above is a falling white ball not in the same cluster, so this cluster is exposed
                    return true
                }
            }
            else {
                // No ball above, so it's exposed
                return true
            }
        }
        
        return false
    }
    
    // Heuristic for when it is considered to be "snowing"
    func isSnowing(_ fascinator: Fascinator) -> Bool {
        let whites = fascinator.balls.filter({b in b.type == .foe})
        
        if whites.count < fascinator.chromosome.foe.maxBalls.value {
            return true
        }
        else {
            for white in whites {
                if white.node.physicsBody!.velocity.dy < -100 && findNextBallDown(white)?.type == .foe {
                    return true
                }
            }
        }
        
        return false
    }
    
    // Get all clusters of the specified type. Returns an array of arrays, each inner array being a list of balls in a cluster.
    func getClusters(_ fascinator: Fascinator, type: Ball.BallType) -> [[Ball]] {
        var result : [[Ball]] = []
        var balls = fascinator.balls.filter({ b in b.type == type })
        
        while let ball = balls.popLast() {
            let cluster = fascinator.getCluster(ball, clusterType: .same)
            result.append(cluster)
            _ = balls.removeWhere(cluster.containsIdentity) // Remove cluster from balls
        }
        
        return result
    }
    
    // Heuristic for when a blue cluster should be protected by tapping incoming blues
    func shouldProtectCluster(_ cluster: [Ball]) -> Bool {
        let fascinator = cluster[0].fascinator!
        
        if !isBlueClusterAboveWhites(cluster) {
            // If there are no whites below this cluster, don't protect it
            return false
        }
        
        // Find all the white balls touching this blue cluster
        var touchingWhites : [Ball] = []
        for ball in cluster {
            for body in ball.node.physicsBody!.allContactedBodies() {
                if let touchingBall = body.node?.userData?.value(forKey: "ball") as? Ball {
                    if touchingBall.type == .foe && !touchingWhites.containsIdentity(touchingBall) {
                        touchingWhites.append(touchingBall)
                    }
                }
            }
        }
        
        // Expand out to find the clusters touching this one
        for touchingBall in touchingWhites {
            let touchingCluster = fascinator.getCluster(touchingBall, clusterType: .same)
            for clusterBall in touchingCluster {
                if !touchingWhites.containsIdentity(clusterBall) {
                    touchingWhites.append(clusterBall)
                }
            }
        }
        
        if touchingWhites.count == 0 {
            // Not touching any whites, so no need to protect
            return false
        }
        else if touchingWhites.count >= 4 {
            // If there are enough whites touching this cluster to form a 4-cluster of their own, then need to protect
            return true
        }
        else {
            var fallingWhites = 0
            for ball in fascinator.balls {
                if ball.type == .foe && isFalling(ball) {
                    fallingWhites += 1
                }
            }
            
            let whites = fascinator.balls.filter({b in b.type == .foe})
            let whitesLeftToSpawn = max(0, fascinator.chromosome.foe.maxBalls.value - whites.count)
            
            if touchingWhites.count + fallingWhites + whitesLeftToSpawn >= 4 {
                // If there are enough falling or unspawned whites to form a 4-cluster with the touching whites, then protect
                return true
            }
            
            // If all of the falling whites pop exposed clusters in the worst-case way, how many whites might potentially be spawned?
            var potentialFallingWhites = 0
            var exposedClusters = getClusters(fascinator, type: .foe).filter(isWhiteClusterExposed)
            exposedClusters.sort(by: { a,b in a.count < b.count }) // Smallest to largest
            
            while let biggestCluster = exposedClusters.popLast() {
                let neededToPop = 4 - biggestCluster.count
                if fallingWhites >= neededToPop {
                    fallingWhites -= neededToPop
                    potentialFallingWhites += biggestCluster.count
                }
                else {
                    break
                }
            }
            
            potentialFallingWhites += fallingWhites
            
            if touchingWhites.count + potentialFallingWhites + whitesLeftToSpawn >= 4 {
                // If there would be enough falling whites to form a 4-cluster with the touching whites, then protect
                return true
            }
            
            // Otherwise, no need to protect this cluster because there is no way that the whites freed by letting it pop could form a cluster of their own
            // ... right?  ¯\_(ツ)_/¯
            return false
        }
    }
    
    // The main AI function
    override func findMacroActions(_ fascinator: Fascinator) -> [MacroAction] {
        
        var result : [MacroAction] = []
        
        if isSnowing(fascinator) {
            // Find all blues which are about to form clusters of 4 or more
            let blues = fascinator.balls.filter({ b in b.type == settings.ballType })
            for i in 0 ..< blues.count {
                let ballA = blues[i]
                for j in 0 ..< i {
                    let ballB = blues[j]
                    let dist = nearestDistance(ballA, ballB)
                    if dist < (ballA.radius + ballB.radius) * settings.distanceThreshold {
                        let clusterA = fascinator.getCluster(ballA, clusterType: .same)
                        if !clusterA.containsIdentity(ballB) {
                            let clusterB = fascinator.getCluster(ballB, clusterType: .same)
                            if clusterA.count + clusterB.count >= fascinator.chromosome.getBallSubChromosome(settings.ballType).criticalClusterSize.value {
                                // If the cluster should be protected, pop the incoming ball
                                if shouldProtectCluster(clusterA) {
                                    result.append(BallTapMacroAction(ball: ballB))
                                }
                                if shouldProtectCluster(clusterB) {
                                    result.append(BallTapMacroAction(ball: ballA))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return result
    }
    
}
