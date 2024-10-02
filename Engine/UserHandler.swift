//
//  User.swift
//  MPCGD
//
//  Created by Gaudl, Swen on 16/01/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import SpriteKit
import CoreData

let USERDBTOKEN : String = "Userinformation"

class UserHandler {
    
    fileprivate static var tutorialStatus : [String : [String:Bool]] = [:]
    open static var presetsLoaded = false
    
    static func setPresetsLoaded(){
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: USERDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedUsers = try context.fetch(request)
            for userRow in savedUsers{
                let jsonRepresentation = (userRow as AnyObject).value(forKey: "jsonRepresentation") as! String
                let user = User(dict: JsonUtils.jsonStringToObject(jsonRepresentation) as! Dictionary<String, AnyObject>)
                if user.userID == GameViewController.user.userID {
                    //var preset = false
                    if (userRow as AnyObject).value(forKey: "presetsLoaded") != nil {
                        presetsLoaded = (userRow as AnyObject).value(forKey: "presetsLoaded") as! Bool
                    }
                    
                    (userRow as AnyObject).setValue(true, forKey: "presetsLoaded")
                    
                    try context.save()
                    presetsLoaded = true
                    break
                }
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble updating tutorial information")
        }
    }
    
    static func saveUser(_ user: User){
        
        let jsonRepresentation = user.getJsonRepresentation()
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let dbEntry = NSEntityDescription.insertNewObject(forEntityName: USERDBTOKEN, into: context) as NSManagedObject
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: USERDBTOKEN)
        
        request.returnsObjectsAsFaults = false
        dbEntry.setValue(jsonRepresentation, forKey: "jsonRepresentation")
        do {
            try context.save()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble saving user: '\(user.userName)'")
        }
    }
    
    static func retrieveUser() -> User!{
        var users: [User] = []
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: USERDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedUsers = try context.fetch(request)
            for user in savedUsers{
                let jsonRepresentation = (user as AnyObject).value(forKey: "jsonRepresentation") as! String
                users.append(User(dict: JsonUtils.jsonStringToObject(jsonRepresentation) as! Dictionary<String, AnyObject>))
            }
            if users.count > 0 {
                return users.last
            } else {
                return nil
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble loading saved users")
            return nil
        }
    }
    
    static func hideTutorial(_ userID: String, gameName:String, hide : Bool = true) {
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: USERDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedUsers = try context.fetch(request)
            for userRow in savedUsers{
                let jsonRepresentation = (userRow as AnyObject).value(forKey: "jsonRepresentation") as! String
                let user = User(dict: JsonUtils.jsonStringToObject(jsonRepresentation) as! Dictionary<String, AnyObject>)
                if user.userID == userID {
                    var tutorialStatus : [String:Bool] = [:]
                    var tutorialString = ""
                    if (userRow as AnyObject).value(forKey: "tutorials") != nil {
                        tutorialString = (userRow as AnyObject).value(forKey: "tutorials") as! String
                        if !tutorialString.isEmpty {
                            tutorialStatus =  JsonUtils.jsonStringToObject(tutorialString) as! Dictionary<String,Bool>
                        }
                    }
                    
                    tutorialStatus[gameName] = hide
                    UserHandler.tutorialStatus[userID] = tutorialStatus // updating local copy
                    tutorialString =  JsonUtils.objectToJsonString(tutorialStatus as AnyObject, prettyPrinted: true)
                    
                    (userRow as AnyObject).setValue(tutorialString, forKey: "tutorials")
                    
                    try context.save()
                    break
                }
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble updating tutorial information")
        }
    }
    
    static func isTutorialHidden(_ gameName: String) -> Bool{
        let status : [String: Bool] = UserHandler.getTutorialStatus(GameViewController.user.userID)
        if status.keys.contains(gameName) {
            return status[gameName]!
        }
        return false
    }
    
    static func hideTutorial(_ gameName: String, onOff: Bool = true) {
        UserHandler.hideTutorial(GameViewController.user.userID, gameName: gameName, hide: onOff)
    }
    
    static func getTutorialStatus(_ userID : String) -> [String:Bool] {
        var result : [String:Bool] = [:]
        if UserHandler.tutorialStatus.keys.contains(userID) {
            result = UserHandler.tutorialStatus[userID]!
        }
        
        return result
    }
    static func retrievePresetStatus(_ userID: String) {
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        var loaded : Bool = false
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: USERDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedUsers = try context.fetch(request)
            for userRow in savedUsers{
                let jsonRepresentation = (userRow as AnyObject).value(forKey: "jsonRepresentation") as! String
                let user = User(dict: JsonUtils.jsonStringToObject(jsonRepresentation) as! Dictionary<String, AnyObject>)
                if user.userID == userID {
                    if (userRow as AnyObject).value(forKey: "presetsLoaded") != nil {
                        let presetStatus = (userRow as AnyObject).value(forKey: "presetsLoaded") as! Bool
                        loaded = presetStatus
                    }
                    break
                }
                
            }
            
            presetsLoaded = loaded
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble loading saved users")
            UserHandler.tutorialStatus[userID] = [:]
        }
    }

    
    static func retrieveTutorialStatus(_ userID: String) {
        let appDel = (UIApplication.shared.delegate as! AppDelegate)
        var tutorialStatus : [String:Bool] = [:]
        let context = appDel.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: USERDBTOKEN)
        request.returnsObjectsAsFaults = false
        do {
            let savedUsers = try context.fetch(request)
            for userRow in savedUsers{
                let jsonRepresentation = (userRow as AnyObject).value(forKey: "jsonRepresentation") as! String
                let user = User(dict: JsonUtils.jsonStringToObject(jsonRepresentation) as! Dictionary<String, AnyObject>)
                if user.userID == userID {
                    if (userRow as AnyObject).value(forKey: "tutorials") != nil {
                        let tutorialString = (userRow as AnyObject).value(forKey: "tutorials") as! String
                        if !tutorialString.isEmpty {
                            tutorialStatus =  JsonUtils.jsonStringToObject(tutorialString) as! Dictionary<String,Bool>
                        }
                    }
                    break
                }
            
            }
        
            UserHandler.tutorialStatus[userID] = tutorialStatus
        }
        catch let error as NSError {
            print(error.localizedDescription)
            print("Trouble loading saved users")
            UserHandler.tutorialStatus[userID] = [:]
        }
    }
}


struct User {
    
    let userID: String
    
    let userName: String
    
    init (userID: String, userName: String) {
        self.userID = userID
        self.userName = userName
    }
    
    init(dict: Dictionary<String, AnyObject>){
        userID = dict["userID"] as! String
        userName = dict["userName"] as! String
    }
    
    func getJsonRepresentation() -> String{
        return JsonUtils.objectToJsonString(getDict(), prettyPrinted: true)
    }
    
    func getDict() -> NSDictionary{
        let dict = NSMutableDictionary()
        dict.setValue(userID, forKey: "userID")
        dict.setValue(userName, forKey: "userName")
        return dict
    }
    
    func getCopy() -> User{
        return User(dict: getDict() as! Dictionary<String, AnyObject>)
    }
}

