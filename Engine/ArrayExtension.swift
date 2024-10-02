//
//  ArrayExtension.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation

/* Unused - use array.contains(object) instead
extension Array{
    func containsObject(object: Any) -> Bool
    {
        if let anObject: AnyObject = object as? AnyObject
        {
            for obj in self
            {
                if let anObj: AnyObject = obj as? AnyObject
                {
                    if anObj === anObject { return true }
                }
            }
        }
        return false
    }   
}
*/

extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        if let index = self.index(of: element) {
            self.remove(at: index)
        }
        else {
            assertionFailure("Element not found in array")
        }
    }
}

extension Array where Element: AnyObject {
    func containsIdentity(_ element: Element) -> Bool {
        return self.contains(where: {x in x === element})
    }
    
    mutating func removeByIdentity(_ element: Element) {
        if removeWhere({x in x === element}) == 0 {
            assertionFailure("Element not found in array")
        }
    }
}

extension Array {
    func getOrNil(_ index: Int) -> Element? {
        if index >= 0 && index < count {
            return self[index]
        }
        else {
            return nil
        }
    }
    
    mutating func removeWhere(_ predicate: ((Element) -> Bool)) -> Int {
        var count: Int = 0
        for i in (0..<self.count).reversed() {
            if predicate(self[i]) {
                self.remove(at: i)
                count += 1
            }
        }
        return count
    }
}
