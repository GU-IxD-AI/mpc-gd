//
//  StringExtension.swift
//  MPCGD
//
//  Created by Simon Colton on 07/02/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation

extension String {
    
    func subString(_ startIndex: Int, length: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: startIndex + length)
        return String(self[start ..< end])
    }
}
