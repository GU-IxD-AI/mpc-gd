//
//  DBConnection.swift
//  MPCGD
//
//  Created by Swen on 2025-08-08.
//  Copyright © 2025 ThoseMetaMakers. All rights reserved.
//

class DBConnection {
    var endpoint : String = ""
    //FIXME: Needs to be secured
    let authAPI : String = HiddenParameters.authAPI
    let createAPI : String = HiddenParameters.createAPI
    var uuid : String = ""
    var user : String = ""
    var authToken : String = ""
    
    init(endpoint: String, uuid : String) {
        self.endpoint = endpoint
        self.uuid = uuid
    }
    
    func request(api: String) -> URLRequest{
        var request = URLRequest(url: URL(string:endpoint+api)! )
        print ("string: \(endpoint)\(api)")
        request.httpMethod = "POST"
        
        return request
    }
  
    func sendDesignPath(dataDict : Dictionary<String,Any>){
        
        if self.user.isEmpty{
            print("not sending anything! (no user)")
            return
        }
        var request = request(api: createAPI)
        // Serialize HTTP Body data as JSON

        let body = [HiddenParameters.db_query[0]: self.user,HiddenParameters.db_query[1]:self.uuid,HiddenParameters.db_query[2]: dataDict] as [String : Any]
        
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error=error
            {
                print("Error: \(error)")
                return
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8){
                print("Response: \n \(dataString)")
                do {
                    let answer = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    //TODO: DO something with the answer to check or potentially resend or turn off sending
                    print("successful")
                } catch let error as NSError {
                    print("could not deserialize network data: \(error)")
                    
                    return
                }
            }
            
        }
        task.resume()
    }
    
    func auth(user: String, pwd: String){
        var request = request(api: authAPI)
        // Serialize HTTP Body data as JSON
        let body = ["identity": user,"password":pwd]
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error=error
            {
                print("Error: \(error)")
                return
            }
            if let data = data{
                do {
                    let answer = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    self.authToken = answer?["token"] as! String
                    self.user = user
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
