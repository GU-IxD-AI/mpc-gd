//
//  JsonUtils.swift
//  Engine
//
//  Created by Powley, Edward on 06/05/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//

import Foundation

class JsonUtils {
    
    static func jsonStringToObject(_ jsonString: String) -> AnyObject {
        guard let data = jsonString.data(using: String.Encoding.utf8) else {
            print("Could not encode JSON string")
            return NSDictionary()
        }
        do {
            return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject
        } catch {
            print("Could not parse JSON string: \(error)")
            return NSDictionary()
        }
    }
    
    static func objectToJsonString(_ object : AnyObject, prettyPrinted : Bool) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: options)
            return String(data: data, encoding: String.Encoding.utf8) ?? "{}"
        } catch {
            print("Could not serialize JSON object: \(error)")
            return "{}"
        }
    }
    
}
