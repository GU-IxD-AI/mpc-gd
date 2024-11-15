//
//  Chromosome.swift
//  Beeee
//
//  Created by Simon Colton on 11/07/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class Chromosome{
    
    let name: ChromosomeName
    
    var genes: [Int] = []
    
    fileprivate(set) var geneSpecs : [GeneBase] = []
    
    init(stringRepresentation: String, name: ChromosomeName){
        self.name = name
        self.geneSpecs = Chromosome.getGenesByReflection(self)
        for i in 0 ..< self.geneSpecs.count {
            self.geneSpecs[i].chromosome = self
            self.geneSpecs[i].geneIndex = i
        }
        initFromStringRepresentation(stringRepresentation)
    }
    
    
    deinit {
        //print("!!! [DEINIT] Chromosone")
    }

    static func getGenesByReflection(_ ob: Any) -> [GeneBase] {
        var result : [GeneBase] = []
        let mirror = Mirror(reflecting: ob)
        for (_, value) in mirror.children {
            if let gene = value as? GeneBase {
                result.append(gene)
            }
            else {
                result.append(contentsOf: getGenesByReflection(value))
            }
        }
        return result
    }
    
    func initFromStringRepresentation(_ stringRepresentation: String) {
        if stringRepresentation != ""{
            let geneStrings = stringRepresentation.components(separatedBy: ",")
            genes = [Int](repeating: 0, count: geneStrings.count)
            for pos in 0..<genes.count{
                genes[pos] = Int(geneStrings[pos])!
            }
        }
        else{
            genes = []
        }
        
        if genes.count < geneSpecs.count {
            for i in genes.count ..< geneSpecs.count {
                genes.append(geneSpecs[i].intDef)
            }
        }
        
        clampValuesToValidRange()
    }
    
    func clampValuesToValidRange() {
        for gene in geneSpecs {
            let value = genes[gene.geneIndex]
            if value < gene.intMin || value > gene.intMax {
                //print("Value \(value) is out of range \(gene.intMin)-\(gene.intMax) for gene '\(gene.name)'")
                genes[gene.geneIndex] = MathsUtils.clamp(value, min: gene.intMin, max: gene.intMax)
            }
        }
    }
    
    func getStringRepresentation() -> String{
        var stringRepresentation = ""
        var pos = 0
        for gene in genes{
            if pos > 0{
                stringRepresentation += ","
            }
            stringRepresentation += "\(gene)"
            pos += 1
        }
        return stringRepresentation
    }
    
    func initFromJsonObject(_ dict: [String : AnyObject]) {
        initFromStringRepresentation("")
        
        for (key, value) in dict {
            
            if let geneIndex = geneSpecs.index(where: {g in g.name == key}) {
                let gene = geneSpecs[geneIndex]
                if let intValue = gene.parseJsonObjectToIntValue(value) {
                    genes[geneIndex] = intValue
                }
                else {
                    print("WARNING: failed to parse value '\(value)' for gene '\(key)' in '\(type(of: self))'")
                }
            }
            else {
                print("WARNING: no gene named '\(key)' in '\(type(of: self))'")
            }
        }
        
        clampValuesToValidRange()
    }
    
    func getGeneNamed(_ name: String) -> GeneBase! {
        for gene in geneSpecs {
            if gene.name == name {
                return gene
            }
        }
        
        return nil
    }
    
    func getGeneSpec(_ genePosition: Int) -> GeneBase! {
        if genePosition >= 0 && genePosition < geneSpecs.count {
            return geneSpecs[genePosition]
        }
        else {
            return nil
        }
    }
    
    func getGeneName(_ genePosition: Int) -> String{
        return getGeneSpec(genePosition)?.name ?? "gene"
    }
    
    func getGeneValueString(_ genePosition: Int, geneValue: Int) -> String {
        return getGeneSpec(genePosition)?.displayIntValue(geneValue) ?? String(geneValue)
    }
}
