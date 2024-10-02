//
//  FileUtilities.swift
//  Fask
//
//  Created by Simon Colton on 12/09/2015.
//  Copyright (c) 2015 Simon Colton. All rights reserved.
//

import Foundation

class FileUtils{
    
    static func readFileLines(_ fileName: String, fileType: String) -> [String]?{
        let path = Bundle.main.path(forResource: fileName, ofType: fileType)
        if (path != nil){
            let fileContent = try? NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            if (fileContent != nil){
                let s = String(fileContent!)
                return s.components(separatedBy: "\n")
            }
        }
        return nil
    }
    
    static func readFile(_ fileName: String, fileType: String) -> String! {
        let path = Bundle.main.path(forResource: fileName, ofType: fileType)
        if (path != nil){
            let fileContent = try? NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            if (fileContent != nil){
                return String(fileContent!)
            }
        }
        return nil
    }
    
}
