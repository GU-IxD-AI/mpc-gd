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
    
    init(endpoint: String) {
        self.endpoint = endpoint

    }
    
    func request(api: String) -> URLRequest{
        var request = URLRequest(url: URL(string:endpoint+authAPI)! )
        print ("string: \(endpoint)\(authAPI)")
        print(request.url)
        request.httpMethod = "POST"
        
        return request
    }
  
    func auth(user: String, pwd: String){
        var request = request(api: authAPI)
        // Serialize HTTP Body data as JSON
        
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
            if let data = data, let dataString = String(data: data, encoding: .utf8){
                print("Response: \n \(dataString)")
                do {
                    let answer = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    print (answer?["token"] as! String)
                } catch let error as NSError {
                    print("could not deserialize network data")
                    return
                }
            }
            
        }
        task.resume()
    }
    
}
