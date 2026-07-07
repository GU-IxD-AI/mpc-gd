//
//  DBConnection.swift
//  MPCGD
//
//  Created by Swen on 2025-08-08.
//  Copyright © 2025 ThoseMetaMakers. All rights reserved.
//

import CoreData
import Foundation
import UIKit

let OUTGOINGBACKLOGDBTOKEN : String = "OutgoingBacklog"

class DBConnection {
    var endpoint : String = ""
    //FIXME: Needs to be secured
    let authAPI : String = HiddenParameters.authAPI
    let createAPI : String = HiddenParameters.createAPI
    var uuid : String = ""
    var user : String = ""
    var authToken : String = ""
    var isStudyMode : Bool = false
    private let maxBacklogItems = 200
    private let maxBacklogBytes = 1024 * 1024
    private var isFlushingBacklog = false
    
    init(endpoint: String, uuid : String, isStudyMode: Bool = false) {
        self.endpoint = endpoint
        self.uuid = uuid
        self.isStudyMode = isStudyMode
    }
    
    func request(api: String) -> URLRequest?{
        guard let url = URL(string:endpoint+api) else {
            print("Invalid DB URL: \(endpoint)\(api)")
            return nil
        }
        var request = URLRequest(url: url )
        print ("string: \(endpoint)\(api)")
        request.httpMethod = "POST"
        
        return request
    }
  
    func sendDesignPath(dataDict : Dictionary<String,Any>){
        guard isStudyMode else {
            print("not sending anything! (not in study mode)")
            return
        }
        guard enqueue(dataDict: dataDict) else { return }
        flushBacklog()
    }

    func flushPendingBacklog() {
        flushBacklog()
    }

    private func sendBacklogItem(dataDict : Dictionary<String,Any>, completion: @escaping (Bool) -> ()){
        guard isStudyMode else {
            print("not sending anything! (not in study mode)")
            completion(false)
            return
        }
        if self.user.isEmpty || self.authToken.isEmpty{
            print("not sending anything! (no confirmed server connection)")
            completion(false)
            return
        }
        guard var request = request(api: createAPI) else {
            completion(false)
            return
        }
        // Serialize HTTP Body data as JSON
        guard HiddenParameters.db_query.count >= 3 else {
            print("DB query configuration is incomplete")
            completion(false)
            return
        }
        let body = [HiddenParameters.db_query[0]: self.user,HiddenParameters.db_query[1]:self.uuid,HiddenParameters.db_query[2]: dataDict] as [String : Any]
        
        guard let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        ) else {
            print("Could not serialize DB request body")
            completion(false)
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error=error
            {
                print("Error: \(error)")
                completion(false)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                print("DB write did not return a success status")
                completion(false)
                return
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8){
                print("Response: \n \(dataString)")
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    print("successful")
                } catch let error as NSError {
                    print("could not deserialize network data: \(error)")
                }
            }
            completion(true)
        }
        task.resume()
    }

    private func enqueue(dataDict: Dictionary<String,Any>) -> Bool {
        guard JSONSerialization.isValidJSONObject(dataDict),
              let data = try? JSONSerialization.data(withJSONObject: dataDict, options: []) else {
            print("Could not cache outgoing DB data")
            return false
        }

        var didEnqueue = false
        performOnMainSync {
            guard let context = getManagedObjectContext(),
                  let entity = NSEntityDescription.entity(forEntityName: OUTGOINGBACKLOGDBTOKEN, in: context) else {
                print("Could not access outgoing backlog storage")
                return
            }
            let entry = NSManagedObject(entity: entity, insertInto: context)
            entry.setValue(Date(), forKey: "date")
            entry.setValue(data, forKey: "payload")
            if saveContext(context) {
                trimBacklog()
                didEnqueue = true
            }
        }
        return didEnqueue
    }

    private func flushBacklog() {
        guard isStudyMode, !user.isEmpty, !authToken.isEmpty else { return }
        performOnMainAsync {
            if self.isFlushingBacklog { return }
            self.isFlushingBacklog = true
            self.flushNextBacklogItem()
        }
    }

    private func flushNextBacklogItem() {
        guard Thread.isMainThread else {
            performOnMainAsync { self.flushNextBacklogItem() }
            return
        }
        guard let firstEntry = fetchBacklog(limit: 1).first else {
            isFlushingBacklog = false
            return
        }
        guard let first = firstEntry.value(forKey: "payload") as? Data,
              let dataDict = (try? JSONSerialization.jsonObject(with: first, options: [])) as? Dictionary<String, Any> else {
            deleteBacklogEntry(firstEntry)
            flushNextBacklogItem()
            return
        }

        sendBacklogItem(dataDict: dataDict) { success in
            self.performOnMainAsync {
                if success {
                    self.deleteBacklogEntry(firstEntry)
                    self.flushNextBacklogItem()
                } else {
                    self.isFlushingBacklog = false
                }
            }
        }
    }

    private func fetchBacklog(limit: Int? = nil) -> [NSManagedObject] {
        guard let context = getManagedObjectContext() else { return [] }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: OUTGOINGBACKLOGDBTOKEN)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        if let limit = limit {
            request.fetchLimit = limit
        }
        do {
            return try context.fetch(request) as? [NSManagedObject] ?? []
        } catch {
            print("Could not fetch outgoing backlog: \(error)")
            return []
        }
    }

    private func deleteBacklogEntry(_ entry: NSManagedObject) {
        guard let context = getManagedObjectContext() else { return }
        context.delete(entry)
        _ = saveContext(context)
    }

    private func trimBacklog() {
        let backlog = fetchBacklog()
        var totalBytes = backlog.reduce(0) { total, entry in
            total + ((entry.value(forKey: "payload") as? Data)?.count ?? 0)
        }
        var deleteCount = max(0, backlog.count - maxBacklogItems)
        for entry in backlog {
            if deleteCount <= 0 && totalBytes <= maxBacklogBytes { break }
            totalBytes -= (entry.value(forKey: "payload") as? Data)?.count ?? 0
            deleteBacklogEntry(entry)
            deleteCount -= 1
        }
    }

    private func getManagedObjectContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.managedObjectContext
    }

    private func saveContext(_ context: NSManagedObjectContext) -> Bool {
        do {
            if context.hasChanges {
                try context.save()
            }
            return true
        } catch {
            print("Could not save outgoing backlog: \(error)")
            context.rollback()
            return false
        }
    }

    private func performOnMainSync(_ work: () -> ()) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }

    private func performOnMainAsync(_ work: @escaping () -> ()) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    func auth(user: String, pwd: String){
        guard var request = request(api: authAPI) else { return }
        // Serialize HTTP Body data as JSON
        let body = ["identity": user,"password":pwd]
        guard let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        ) else {
            print("Could not serialize auth request body")
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error=error
            {
                print("Error: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                print("Auth did not return a success status")
                self.authToken = ""
                return
            }
            if let data = data{
                do {
                    guard let answer = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
                          let token = answer["token"] as? String else {
                        print("Auth response did not contain a token")
                        self.authToken = ""
                        return
                    }
                    self.authToken = token
                    self.user = user
                    self.flushBacklog()
                } catch let error as NSError {
                    print("could not deserialize network data: \(error)")
                    self.authToken = ""
                    return
                }
            }
            
        }
        task.resume()
    }
    
}
