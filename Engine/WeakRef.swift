//
//  WeakRef.swift
//  Engine
//
//  Created by Powley, Edward on 06/11/2015.
//  Copyright © 2015 Simon Colton. All rights reserved.
//

import Foundation

/// Weak wrapper for a reference.
/// This is a workaround to allow arrays of weak references.
/// See http://stackoverflow.com/questions/24127587/how-do-i-declare-an-array-of-weak-references-in-swift
class Weak<T: AnyObject> {
    weak var value : T!
    init (value: T) {
        self.value = value
    }
}
