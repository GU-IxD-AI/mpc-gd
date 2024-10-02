//
//  Session.swift
//  MPCGD
//
//  Created by Gaudl, Swen on 16/01/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import CoreData
import SpriteKit

let SESSIONDBTOKEN : String = "Sessioninformation"
let CACHEDBTOKEN : String = "Cache"

class SessionHandler {
    
    static var sessions : [Session] = []
    
    static func clearSessions(gameID: String){
        
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SESSIONDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedGames = try context.fetch(request)
            for game in savedGames{
                let name = (game as AnyObject).value(forKey: "level") as! String
                if name == gameID {
                    context.delete(game as! NSManagedObject)
                    try context.save()
                }
            }
            var newSessions: [Session] = []
            for s in sessions{
                if s.levelName != gameID{
                    newSessions.append(s)
                }
            }
            sessions = newSessions
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble deleting sessions for: \(gameID)")
        }
        
    }
    
    static func renameGame(oldGameID: String, newGameID: String){
        var newSessions: [Session] = []
        for s in sessions{
            if s.levelName == oldGameID{
                newSessions.append(s)
            }
        }
        clearSessions(gameID: oldGameID)
        for s in newSessions{
            var newS = s.getCopy()
            newS.levelName = newGameID
            saveSession(newS)
            sessions.append(newS)
        }
    }
    
    static func getNumWins(_ gameID: String) -> Int{
        var w = 0
        for session in sessions{
            if session.levelName == gameID && session.wasWon{
                w += 1
            }
        }
        return w
    }
    
    static func getSessions(_ gameID: String) -> [Session]{
        var sessionsForName: [Session] = []
        for session in sessions{
            if session.levelName == gameID{
                sessionsForName.append(session)
            }
        }
        return sessionsForName
    }
    
    static func getWinningSessions(_ gameID: String) -> [Session]{
        var sessionsForName: [Session] = []
        for session in sessions{
            if session.levelName == gameID && session.wasWon{
                sessionsForName.append(session)
            }
        }
        return sessionsForName
    }
    
    static func saveSession(_ session: Session){
        let jsonRepresentation = session.getJsonRepresentation()
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let dbEntry = NSEntityDescription.insertNewObject(forEntityName: SESSIONDBTOKEN, into: context) as NSManagedObject
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SESSIONDBTOKEN)
        
        request.returnsObjectsAsFaults = false
        dbEntry.setValue(jsonRepresentation, forKey: "jsonRepresentation")
        dbEntry.setValue(session.date, forKey: "date")
        dbEntry.setValue(session.levelName, forKey: "level")
        do {
            try context.save()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble saving session: '\(session.levelName) - \(session.date)'")
        }
    }
    
    static func getFastestTime(_ gameName : String) -> Int! {
        var fastest: Int! = nil
        for session in sessions {
            if session.levelName == gameName && session.wasWon{
                if fastest == nil || (session.quit == false && session.time < fastest) {
                    fastest = session.time
                }                
            }
        }
        if fastest != nil{
            return fastest
        }
        else{
            return nil
        }
    }
    
    static func getLongestTime(_ gameName : String) -> Int! {
        var longest: Int! = nil
        for session in sessions {
            if session.levelName == gameName && session.wasWon{
                if longest == nil || (session.quit == false && session.time > longest) {
                    longest = session.time
                }
            }
        }
        if longest != nil{
            return longest
        }
        else{
            return nil
        }
    }
    
    static func getHighScore(_ gameName: String) -> Int!{
        var best : Int! = nil
        for session in sessions {
            if session.levelName == gameName && session.wasWon{
                if best == nil || (session.quit == false && session.score > best) {
                    best = session.score
                }
            }
        }
        return best
    }
    
    static func retrieveSessions() -> [Session]!{
        var sessions: [Session] = []
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SESSIONDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedSessions = try context.fetch(request)
            for session in savedSessions{
                let jsonRepresentation = (session as AnyObject).value(forKey: "jsonRepresentation") as! String
                sessions.append(Session(dict: JsonUtils.jsonStringToObject(jsonRepresentation) as! Dictionary<String, AnyObject>))
            }
            if sessions.count > 0 {
                return sessions
            } else {
                return sessions
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble loading saved sessions")
            return nil
        }
    }
    
    static func getTempGame() -> MPCGDGenome {
        let gameString = retrieveCachedData(CacheType.game)
        let gameParameters = JsonUtils.jsonStringToObject(gameString) as! Dictionary<String, AnyObject>

        var game = MPCGDGenome()
        if gameParameters.count > 0 {
            game = GameHandler.getMPCGDGenome(GameParameters(dict: gameParameters))
        }
        
        return game
    }
    
    static func retrieveCachedData(_ dataType : CacheType) -> String{
        var data: String = ""
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: CACHEDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let cachedDataChunks = try context.fetch(request)
            for chunk in cachedDataChunks{
                let type = (chunk as AnyObject).value(forKey: "cacheType") as! Int
                if type == dataType.rawValue {
                    data = (chunk as AnyObject).value(forKey: "cachedData") as! String
                    break
                }
            }
            return data
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble retrieving cache")
            return ""
        }
    }
    
    static func saveCachedData(_ dataType: CacheType, dataString: String) {
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: CACHEDBTOKEN)
        var newValue = true
        request.returnsObjectsAsFaults = false
        do {
            let savedChuncks = try context.fetch(request)
            for chunk in savedChuncks{
                let type = (chunk as AnyObject).value(forKey: "cacheType") as! Int
                if type == dataType.rawValue {
                    (chunk as AnyObject).setValue(dataString, forKey:"cachedData")
                    (chunk as AnyObject).setValue(Date(), forKey: "date")
                    newValue = false
                    break
                }
            }
            if newValue {
                let dbEntry = NSEntityDescription.insertNewObject(forEntityName: CACHEDBTOKEN, into: context) as NSManagedObject
                dbEntry.setValue(dataString, forKey: "cachedData")
                dbEntry.setValue(dataType.rawValue, forKey:"cacheType")
                dbEntry.setValue(Date(), forKey: "date")
            }
            
            try context.save()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble updating cache")
        }
    }
}

enum CacheType : Int {
    case none = 0
    case game = 1
}

struct Session {
    
    let date: Date
    var levelName: String
    
    let time: Int
    let score: Int
    let quit: Bool
    let wasWon: Bool
    let userID: String
    
    init (date: Date, level: String, user : String, elapsedTime: Int, score: Int, quit: Bool, wasWon: Bool) {
        self.date = date
        self.levelName = level
        self.userID = user
        self.time = elapsedTime
        self.score = score
        self.quit = quit
        self.wasWon = wasWon
    }
    
    init(dict: Dictionary<String, AnyObject>){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let sn = dict["date"] as! String
        self.date = formatter.date(from: sn)!
        self.levelName = dict["level"] as! String
        self.userID = dict["user"] as! String
        self.time = dict["time"] as! Int
        self.score = dict["score"] as! Int
        self.quit = dict["quit"] as! Bool
        self.wasWon = dict["won"] as! Bool
    }
    
    func getJsonRepresentation() -> String{
        return JsonUtils.objectToJsonString(getDict(), prettyPrinted: true)
    }
    
    func getDict() -> NSDictionary{
        let dict = NSMutableDictionary()
        let ns = DateFormatter()
        ns.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let fn = ns.string(from: date)
        dict.setValue(fn , forKey: "date")
        dict.setValue(levelName, forKey: "level")
        dict.setValue(userID, forKey: "user")
        dict.setValue(time, forKey: "time")
        dict.setValue(score, forKey: "score")
        dict.setValue(quit, forKey: "quit")
        dict.setValue(wasWon, forKey: "won")
        return dict
    }
    
    func getCopy() -> Session{
        return Session(dict: getDict() as! Dictionary<String, AnyObject>)
    }
}

