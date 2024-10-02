//
//  EndGameTextGenerator.swift
//  MPCGD
//
//  Created by Simon Colton on 23/05/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit

class EndGameTextGenerator{
    
    static func getEndGameText(MPCGDGenome: MPCGDGenome, fascinator: Fascinator, gameEndDetails: Fascinator.GameEndDetails) -> (String, String){
        
        switch gameEndDetails.gameOverReason!{
        case .ranOutOfTime:
            return outOfTimeText(fascinator: fascinator, pointsScored: gameEndDetails.currentScore)
        case .survivedForDuration:
            if fascinator.positiveScoresPossible && MPCGDGenome.pointsToWin == 0{
                let isNewHighScore = gameEndDetails.highScore != nil && (gameEndDetails.highScore < gameEndDetails.currentScore)
                return pointsInTimeAvailableText(pointsScored: gameEndDetails.currentScore, isNewHighScore: isNewHighScore, oldHighScore: gameEndDetails.highScore)
            }
            else{
                return survivedText(MPCGDGenome: MPCGDGenome, fascinator: fascinator, timeElapsed: gameEndDetails.currentTimeElapsed)
            }
        case .achievedPoints:
            let isNewFastest = gameEndDetails.fastestTime != nil ? (gameEndDetails.currentTimeElapsed < gameEndDetails.fastestTime) : true
            return achievedRequiredPointsText(MPCGDGenome: MPCGDGenome, fascinator: fascinator, pointsScored: gameEndDetails.currentScore, isNewFastest: isNewFastest, fastestTime: gameEndDetails.fastestTime, timeElapsed: gameEndDetails.currentTimeElapsed)
        case .lostAllLivesBeforeEnd:
            if MPCGDGenome.pointsToWin == 0{
                return lostLivesBeforeEndText(MPCGDGenome: MPCGDGenome, timeElapsed: gameEndDetails.currentTimeElapsed)
            }
            else{
                return notAchievedPointsBeforeEndText(MPCGDGenome: MPCGDGenome, pointsScored: gameEndDetails.currentScore)
            }
        case .lostAllLivesNoEnd:
            if fascinator.positiveScoresPossible{
                let isNewHighScore = gameEndDetails.highScore != nil && (gameEndDetails.highScore < gameEndDetails.currentScore)
                return lostAllLivesCountPointsText(pointsScored: gameEndDetails.currentScore, isNewHighScore: isNewHighScore, oldHighScore: gameEndDetails.highScore)

            }
            else{
                let isNewLongest = gameEndDetails.longestTime != nil ? (gameEndDetails.currentTimeElapsed > gameEndDetails.longestTime) : true
                return lostAllLivesNoEndNoScoreText(MPCGDGenome: MPCGDGenome, fascinator: fascinator, timeElapsed: gameEndDetails.currentTimeElapsed, isNewLongest: isNewLongest, oldLongest: gameEndDetails.longestTime)
            }
        }
    }

    static func outOfTimeText(fascinator: Fascinator, pointsScored: Int) -> (String, String){
        let ps = (fascinator.chromosome.scoreThreshold.value == 1) ? "point" : "points"
        let endGameText = "GAME ~OVER\n\nYou scored:\n~\(pointsScored) out of ~\(fascinator.chromosome.scoreThreshold.value) \(ps)\n\nBetter luck next time!"
        
        return (endGameText, "")
    }
    
    static func survivedText(MPCGDGenome: MPCGDGenome, fascinator: Fascinator, timeElapsed: Int) -> (String, String){
        var endGameText = "~Congratulations!"
        endGameText += "\nYou survived for ~\(MPCGDGenome.gameDuration)s"
        if MPCGDGenome.numLives > 0{
            if fascinator.livesLeft < MPCGDGenome.numLives{
                if fascinator.livesLeft < MPCGDGenome.numLives - 1{
                    endGameText += "\n\nBut you ~lost ~lives"
                }
                else{
                    endGameText += "\n\nBut you ~lost ~a ~life"
                }
                endGameText += "\nCan you ~do ~better?"
            }
            else{
                endGameText += "\n\nAnd you ~lost ~no ~lives!"
            }
        }
        return (endGameText, "")
    }
    
    static func lostAllLivesNoEndNoScoreText(MPCGDGenome: MPCGDGenome, fascinator: Fascinator, timeElapsed: Int, isNewLongest: Bool, oldLongest: Int!) -> (String, String){
        var endGameText = "~Congratulations!"
        endGameText += "\nYou survived for ~\(timeElapsed)s"
        var changeBestTo = ""
        if isNewLongest && oldLongest != nil{
            endGameText += "\n~A ~new ~longest ~time!\nPrevious longest time: \(oldLongest!)s"
            endGameText += "\n\nCan you ~beat ~that?"
        }
        else if oldLongest != nil && timeElapsed == oldLongest{
            endGameText += "\n~Equal ~longest ~time!"
            endGameText += "\n\nCan you ~beat ~that?"
        }
        else if oldLongest != nil{
            endGameText += "\n\nCan you beat the\n~best ~of ~\(oldLongest!)s?"
            changeBestTo = "\(timeElapsed)s"
        }
        else{
            endGameText += "\n\nCan you ~beat ~that?"
        }
        
        return (endGameText, changeBestTo)
    }
    
    static func pointsInTimeAvailableText(pointsScored: Int, isNewHighScore: Bool, oldHighScore: Int!) -> (String, String){
        var endGameText = "~Time's ~up!"
        if pointsScored == 0{
            endGameText += "\nYou scored ~no ~points!"
        }
        else{
            endGameText += "\nYou scored ~\(pointsScored) points!"
        }
        var changeBestTo = ""
        if isNewHighScore{
            endGameText += "\n~A ~new ~high ~score!\nOld high score: \(oldHighScore!) points"
            endGameText += "\nCan you ~get ~more?"
        }
        else if oldHighScore != nil && pointsScored == oldHighScore{
            endGameText += "\n~You ~equalled ~the ~high ~score!"
            endGameText += "\n\nCan you ~get ~more?"
        }
        else if oldHighScore != nil{
            endGameText += "\n\nCan you beat the\n~high ~score ~of ~\(oldHighScore!) ~points?"
            changeBestTo = "\(pointsScored) points"
        }
        else{
            endGameText += "\n\nCan you ~get ~more?"
        }
        
        return (endGameText, changeBestTo)
    }
    
    static func achievedRequiredPointsText(MPCGDGenome: MPCGDGenome, fascinator: Fascinator, pointsScored: Int, isNewFastest: Bool, fastestTime: Int!, timeElapsed: Int) -> (String, String){
        var endGameText = "~Congratulations!"
        endGameText += "\nYou scored ~\(pointsScored) points in ~\(timeElapsed)s"
        var changeBestTo = ""
        if isNewFastest{
            if fastestTime != nil{
                if fastestTime != timeElapsed{
                    endGameText += "\n\n~A ~new ~fastest ~time!"
                    endGameText += "\nPrevious fastest: \(fastestTime!)s"
                }
                else {
                    endGameText += "\n\n~Equal ~fastest ~time!"
                    endGameText += "\nCan you do better?"
                }
            }
        }
        else if fastestTime != nil && timeElapsed == fastestTime{
            endGameText += "\n\n~Equal ~fastest ~time!"
            endGameText += "\nCan you do better?"
        }
        else if fastestTime != nil && !isNewFastest && fastestTime != timeElapsed{
            endGameText += "\n\nGreat work, but can you"
            if fastestTime == 0{
                endGameText += "\n~equal ~your ~best ~of ~\(fastestTime!)s?"
            }
            else{
                endGameText += "\n~beat ~your ~best ~of ~\(fastestTime!)s?"
            }
            changeBestTo = "\(timeElapsed)s"
        }
        else{
            endGameText += "\n\nGreat work, but"
            endGameText += "\ncan you ~do ~better?"
        }
        
        return (endGameText, changeBestTo)
    }
    
    static func lostLivesBeforeEndText(MPCGDGenome: MPCGDGenome, timeElapsed: Int) -> (String, String){
        var endGameText = "GAME ~OVER"
        endGameText += "\nYou survived:\n~\(timeElapsed)s out of ~\(MPCGDGenome.gameDuration)s\n\nBetter luck next time!"

        return (endGameText, "")
    }
    
    static func notAchievedPointsBeforeEndText(MPCGDGenome: MPCGDGenome, pointsScored: Int) -> (String, String){
        var endGameText = "GAME ~OVER"
        endGameText += "\nYou scored:\n~\(pointsScored) out of ~\(MPCGDGenome.pointsToWin) points\n\nBetter luck next time!"

        return (endGameText, "")
    }
    
    static func lostAllLivesCountPointsText(pointsScored: Int, isNewHighScore: Bool, oldHighScore: Int!) -> (String, String){
        var endGameText = "~Congratulations!"
        if pointsScored == 0{
            endGameText = "~Bad ~luck"
            endGameText += "\nYou scored ~no ~points"
        }
        else{
            endGameText += "\nYou scored ~\(pointsScored) points"
        }
        
        var changeBestTo = ""
        if isNewHighScore{
            endGameText += "\n~A ~new ~high ~score!\nOld high score: \(oldHighScore!) points"
            endGameText += "\nCan you ~get ~more?"
        }
        else if oldHighScore != nil && pointsScored == oldHighScore{
            endGameText += "\n~You ~equalled ~the ~high ~score!"
            endGameText += "\n\nCan you ~get ~more?"
        }
        else if oldHighScore != nil{
            endGameText += "\n\nCan you beat the\n~high ~score ~of ~\(oldHighScore!) ~points?"
            changeBestTo = "\(pointsScored) points"
        }
        else{
            endGameText += "\n\nCan you ~get ~more?"
        }
        return (endGameText, changeBestTo)
    }
    
}
