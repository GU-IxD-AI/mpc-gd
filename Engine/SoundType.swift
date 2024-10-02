//
//  SoundType.swift
//  Engine
//
//  Created by Powley, Edward on 01/06/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//
#if false
import Foundation

enum SoundType : Int {
    case whiteCluster, blueCluster, blueTap, gameWin, gameLose
    
    static var all : [SoundType] = {
        var result : [SoundType] = []
        var i = 0
        while let v = SoundType(rawValue: i) {
            result.append(v)
            i += 1
        }
        return result
    }()
}

#endif
