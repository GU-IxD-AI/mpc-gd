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
        let data = jsonString.data(using: String.Encoding.utf8)!
        return try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject
    }
    
    static func objectToJsonString(_ object : AnyObject, prettyPrinted : Bool) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        let data = try! JSONSerialization.data(withJSONObject: object, options: options)
        let jsonString = String(data: data, encoding: String.Encoding.utf8)!
        return jsonString
    }
    
}
