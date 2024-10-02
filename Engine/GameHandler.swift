//
//  GameHandler.swift
//  MPCGD
//
//  Created by Swen Gaudl on 23/01/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//


import Foundation
import SpriteKit
import CoreData

let GAMEDBTOKEN : String = "GeneratedGames"
let CONSUMER_GENOME_VERSION : Int = 1

class PackAlias {
    fileprivate static func fetchEntry(_ pack: String) -> NSManagedObject? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let context = appDelegate.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PackAlias")

        do {
            let entries = try context.fetch(request)
            //print(">>> FETCHED \(entries.count) aliases")
            for e in entries {
                //print("pack=\(e.valueForKey("pack") as! String), alias=\(e.valueForKey("alias") as! String)")
                if (e as AnyObject).value(forKey: "pack") as! String == pack {
                    return e as? NSManagedObject
                }
            }
        } catch {
            print("PackAlias.fetchEntry(FAILED): \(error)")
        }
        return nil
    }
    
    static func save(_ pack: String, alias: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.managedObjectContext

        if let e = fetchEntry(pack) {
            do {
                e.setValue(alias, forKey: "alias")
                try context.save()
            } catch {
                print("PackAlias.save(FAILED): \(error)")
            }
            return
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "PackAlias", in: context)
        let e = NSManagedObject(entity: entity!, insertInto: context)
        e.setValue(pack, forKey: "pack")
        e.setValue(alias, forKey: "alias")

        do {
            try context.save()
        } catch {
            print("PackAlias.save(FAILED): \(error)")
        }
    }

    static func fetch(_ pack: String) -> String {
        guard let e = fetchEntry(pack) else { return pack }
        return e.value(forKey: "alias") as! String
    }
}

class GameHandler {
    
    /* THIS IS WHAT WE NEED
    
    static func getGameNamesForPack(gamePackID: String) -> [String]{
        let gameNames: [String] = []
        
        return gameNames
    }
 
    static func getMPCGDGenomeForGame(gameID: String) -> MPCGDGenome{
        let MPCGDGenome = MPCGDGenome()
        
        return MPCGDGenome
    }
    
    static func moveGame(gameID: String, oldPackID: String, newPackID: String){
        
    }
    
    static func saveNewGame(gameID: String, packID: String, MPCGDGenome: MPCGDGenome){
        
    }
    
    static func overwriteGame(gameID: String, newMPCGDGenome: MPCGDGenome){
        
    }
    
    static func deleteGame(gameID: String){
        
    }
    
    static func renameGame(oldGameID: String, newGameID: String){
        
    }
    
    */
    
    static func getPackNames() -> [String] {
        return ["Simple Games", "Fast Games", "Skilful Games", "Tricky Games"]
    }
    
    static func getMPCGDGenome(_ game: GameParameters) -> MPCGDGenome {
 //       assert(game.gameParameters[0] == CONSUMER_GENOME_VERSION, "Only consumer genome version \(CONSUMER_GENOME_VERSION) currently supported!")
        if game.gameParameters.isEmpty || game.gameParameters[0] != CONSUMER_GENOME_VERSION {
            return MPCGDGenome()
        }
        return convertParametersToGenome(game)
    }
    
    static func saveGame(_ game: MPCGDGenome, gameID: String, packID: String, isLocked: Bool) -> String {
        let gameParameters = convertGenomeToParameters(game, gameID: gameID)
        return GameHandler.saveGame(gameParameters, packID: packID, isLocked: isLocked)
    }
    
    static func convertGenomeToParameters(_ game : MPCGDGenome, gameID: String) -> GameParameters {
        let encoding = game.encodeAsParameterArray()
        let parameters: [Int] = encoding != nil ? encoding! : []
        let userID = GameViewController.user.userID
        let gP = GameParameters(userID: userID, gameID: gameID, gameParameters: parameters)
        return gP
    }
    
    static func convertParametersToGenome(_ game: GameParameters) -> MPCGDGenome {
        let snow = MPCGDGenome()
        _ = snow.decodeFromParameterArray(game.gameParameters)
        return snow
    }
    
    static func saveGame(_ game: GameParameters, packID: String, isLocked: Bool) -> String {
        
        let jsonRepresentation = game.getJsonRepresentation()
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let dbEntry = NSEntityDescription.insertNewObject(forEntityName: GAMEDBTOKEN, into: context) as NSManagedObject
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: GAMEDBTOKEN)
        
        request.returnsObjectsAsFaults = false
        dbEntry.setValue(jsonRepresentation, forKey: "gameParameters")
        let dbKey = game.gameID
        dbEntry.setValue(dbKey, forKey: "gameID")
        dbEntry.setValue(packID, forKey: "gamePackID")
        dbEntry.setValue(isLocked, forKey: "isLocked")
        do {
            try context.save()
            return dbKey
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble saving game: '\(game.gameID)'")
            return ""
        }
    }
    
    static func renameGame(_ originalGameID: String, newGameID: String, genome: MPCGDGenome, packID: String, isLocked: Bool){
        deleteGame(originalGameID)
        _ = saveGame(genome, gameID: newGameID, packID: packID, isLocked: isLocked)
    }
    
    static func overwriteGenome(_ gameID: String, alteredGenome: MPCGDGenome, packID: String, isLocked: Bool){
        deleteGame(gameID)
        _ = saveGame(alteredGenome, gameID: gameID, packID: packID, isLocked: isLocked)
    }
    
    static func setLock(_ gameID: String, gamePackID: String, isLocked: Bool){
        
    }
    
    static func deleteGame(_ gameName: String){
        
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: GAMEDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedGames = try context.fetch(request)
            for game in savedGames{
                let name = (game as AnyObject).value(forKey: "gameID") as! String
                if name == gameName {
                    context.delete(game as! NSManagedObject)
                    try context.save()
                }
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble deleting game: \(gameName)")
        }
    }
    
    static func clearAllGames(){
        
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: GAMEDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedGames = try context.fetch(request)
            for game in savedGames{
                context.delete(game as! NSManagedObject)
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble clearing all saved games")
        }
    }
    
    /**
     Retrieves games from the database.
     Retrieves all games in the db if an empty string is given.
     Retrieves the last saved game if a game name is given.
     */
    
    static func retrieveGame(_ gameID: String, packID: String) -> (MPCGDGenome?, Bool){
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: GAMEDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedGames = try context.fetch(request)
            for game in savedGames{
                let id = (game as AnyObject).value(forKey: "gameID") as! String
                let pack = (game as AnyObject).value(forKey: "gamePackID") as! String
                let isLocked = (game as AnyObject).value(forKey: "isLocked") as! Bool
                if (id == gameID && packID == pack) {
                    let jsonRepresentation = (game as AnyObject).value(forKey: "gameParameters") as! String
                    let game = GameParameters(dict: JsonUtils.jsonStringToObject(jsonRepresentation) as! Dictionary<String, AnyObject>)
                    return (getMPCGDGenome(game), isLocked)
                }
            }
            return (nil, false)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble loading saved game")
            return (nil, false)
        }
    }
    
    static func retrieveGameNames() -> [(String, String)] {
        var games: [(String,String)] = []
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: GAMEDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedGames = try context.fetch(request)
            for game in savedGames{
                let name = (game as AnyObject).value(forKey: "gameID") as! String
                let pack = (game as AnyObject).value(forKey: "gamePackID") as! String
                games.append((name,pack))
            }
            return games
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble loading saved game")
            return []
        }
    }
    static func retrieveGamePack(_ gamePackID: String) -> [String] {
        var games: [(String)] = []
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: GAMEDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedGames = try context.fetch(request)
            for game in savedGames{
                let name = (game as AnyObject).value(forKey: "gameID") as! String
                let pack = (game as AnyObject).value(forKey: "gamePackID") as! String
                if pack == gamePackID {
                    games.append(name)
                }
            }
            return games
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble loading saved game")
            return []
        }
    }
}


struct GameParameters {
    
    let userID: String
    
    let gameID: String
    
    let gameParameters : [Int]
    
    
    init (userID: String, gameID: String, gameParameters: [Int]) {
        self.userID = userID
        self.gameID = gameID
        self.gameParameters = gameParameters
    }
    
    init(dict: Dictionary<String, AnyObject>){
        self.userID = dict["userID"] as! String
        self.gameID = dict["gameID"] as! String
        self.gameParameters = dict["gameParameters"] as! [Int]
    }
    
    func getJsonRepresentation() -> String{
        return JsonUtils.objectToJsonString(getDict(), prettyPrinted: true)
    }
    
    func getDict() -> NSDictionary{
        let dict = NSMutableDictionary()
        dict.setValue(userID, forKey: "userID")
        dict.setValue(gameID, forKey: "gameID")
        dict.setValue(gameParameters, forKey: "gameParameters")
        return dict
    }
    
    func getCopy() -> User{
        return User(dict: getDict() as! Dictionary<String, AnyObject>)
    }
}
