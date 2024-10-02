//
//  SubChromosome.swift
//  Engine
//
//  Created by Powley, Edward on 24/03/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation

class SubChromosome {
    init(`$`: String) {
        let mirror = Mirror(reflecting: self)
        for (_, value) in mirror.children {
            if let gene = value as? GeneBase {
                gene.name = gene.name.replacingOccurrences(of: "$", with: `$`)
            }
        }
    }
    
    func setDesignScreenNameForAllGenes(_ designScreenName: DesignScreenName) {
        let mirror = Mirror(reflecting: self)
        for (_, value) in mirror.children {
            if let gene = value as? GeneBase {
                gene.designScreenName = designScreenName
            }
        }
    }
}
