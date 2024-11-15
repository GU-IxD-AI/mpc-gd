//
//  ShapeWranglingImageAndLightingChromosome.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit

class ImageAndLightingChromosome: Chromosome{
    
    let artImageSize = FloatGene(name: "size of art image", min: 0.1, max: 1.0, step: 0.01, def: 0.8, designScreenName: .Appearance)
    let layers = EnumGene<LayersType>(name: "layers", def: .artOnBack, designScreenName: .Appearance)
    
    let initFunctionX = IntGene(name: "InitX", min: 0, max: 200, def: 154, designScreenName: .Image)
    let initFunctionY = IntGene(name: "InitY", min: 0, max: 200, def: 45, designScreenName: .Image)
    let initFunctionR = IntGene(name: "InitR", min: 0, max: 200, def: 71, designScreenName: .Image)
    let initFunctionG = IntGene(name: "InitG", min: 0, max: 200, def: 112, designScreenName: .Image)
    let initFunctionB = IntGene(name: "InitB", min: 0, max: 200, def: 96, designScreenName: .Image)

    let updateFunctionX = IntGene(name: "UpdateX", min: 0, max: 200, def: 122, designScreenName: .Image)
    let updateFunctionY = IntGene(name: "UpdateY", min: 0, max: 200, def: 90, designScreenName: .Image)
    let updateFunctionR = IntGene(name: "UpdateR", min: 0, max: 200, def: 129, designScreenName: .Image)
    let updateFunctionG = IntGene(name: "UpdateG", min: 0, max: 200, def: 23, designScreenName: .Image)
    let updateFunctionB = IntGene(name: "UpdateB", min: 0, max: 200, def: 3, designScreenName: .Image)
    
    let timeSteps = IntGene(name: "number of time steps", min: 20, max: 100, def: 98, designScreenName: .Image)
    let particles = IntGene(name: "number of particles", min: 100, max: 1000, def: 504, designScreenName: .Image)
    
    let blurAmount = IntGene(name: "amount of blur", min: 0, max: 10, def: 7, designScreenName: .Image)
    let blurDistance = IntGene(name: "blur distance", min: 0, max: 10, def: 1, designScreenName: .Image)
    let shapeSize = IntGene(name: "shape size", min: 5, max: 50, def: 14, designScreenName: .Image)
    let shape = EnumGene<ShapeType>(name: "shape", def: .lineStroke, designScreenName: .Image)
    let stroke = IntGene(name: "stroke width", min: 1, max: 10, def: 1, designScreenName: .Image)
    let transform = EnumGene<TransformType>(name: "transform", def: .rectangle, designScreenName: .Image)
    let gridCols = IntGene(name: "grid columns", min: 2, max: 20, def: 5, designScreenName: .Image)
    let gridRows = IntGene(name: "grid rows", min: 2, max: 20, def: 5, designScreenName: .Image)
    let kaleidoscopeSegments = IntGene(name: "kaleidoscope segments", min: 5, max: 50, def: 17, designScreenName: .Image)
    let necklacePearls = IntGene(name: "necklace pearls", min: 6, max: 50, def: 17, designScreenName: .Image)
    
    let backingImageNum = IntGene(name: "backing image", min: -1, max: 13, def: 0, designScreenName: .Appearance)
    let tint = ColourGene(name: "backing tint", def: ColourNames.white, designScreenName: .Appearance)
    let tintPC = FloatGene(name: "tint percent", min: 0, max: 1, step: 0.01, def: 0, designScreenName: .Appearance)
    
    let spotlightOn = BoolGene(name: "use lighting", def: false, designScreenName: .Lighting)
    let lightingType = EnumGene<LightingType>(name: "spotlight position", def: .centre, designScreenName: .Lighting)
    let ambientBrightness = FloatGene(name: "ambient light", min: 0, max:1, step: 0.01, def: 0.7, designScreenName: .Lighting)
    let spotlightFalloff = FloatGene(name: "spotlight falloff", min: 0, max:5, step: 0.1, def: 1, designScreenName: .Lighting)
    let spotlightBrightness = FloatGene(name: "spotlight brightness", min: 0, max: 1, step: 0.01, def: 0.44, designScreenName: .Lighting)
    let invertHeightMap = BoolGene(name: "invert height map", def: true, designScreenName: .Lighting)
    let normalMapSmoothness = FloatGene(name: "normal map smoothness", min: 0, max: 1, step: 0.01, def: 0.5, designScreenName: .Lighting)
    let normalMapContrast = FloatGene(name: "normal map contrast", min: 0, max: 100, step: 0.1, def: 10, designScreenName: .Lighting)
    let applyNormalMapToArtImage = BoolGene(name: "normal map for art", def: true, designScreenName: .Lighting)
    let applyNormalMapToBacking = BoolGene(name: "normal map for backing", def: true, designScreenName: .Lighting)
    
    init(stringRepresentation: String){
        super.init(stringRepresentation: stringRepresentation, name: ChromosomeName.ImageAndLighting)
        initFunctionX.hiddenFromUser = true
        initFunctionY.hiddenFromUser = true
        initFunctionR.hiddenFromUser = true
        initFunctionG.hiddenFromUser = true
        initFunctionB.hiddenFromUser = true
        updateFunctionX.hiddenFromUser = true
        updateFunctionY.hiddenFromUser = true
        updateFunctionR.hiddenFromUser = true
        updateFunctionG.hiddenFromUser = true
        updateFunctionB.hiddenFromUser = true
    }
}
