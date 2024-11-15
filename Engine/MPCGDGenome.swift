//
//  MPCGDGenome.swift
//  MPCGD
//
//  Created by Simon Colton on 23/01/2017.
//  Copyright © 2017 ThoseMetamakers. All rights reserved.
//

import Foundation
import SpriteKit
import CoreGraphics

enum GenomeError : Error {
    case invalidVersion
    case outOfBounds
    case indexNotFound
    case bufferOverrun
}

protocol GenomeEncoder {
    func encode(_ x: Int, _ interval: ClosedRange<Int>) throws
    func encode<T: Comparable>(_ v: T, asIndexOf m: [T]) throws
}

protocol GenomeDecoder {
    func decode(_ interval: ClosedRange<Int>) throws -> Int
    func decode<T: Comparable>(_ values: [T]) throws -> T
}

class Base2Encoder : GenomeEncoder {
    var a: [UInt64]
    var place: Int

    var numAttribs: Int
    var totalPlaces: Int
    
    init() {
        a = [0]
        place = 0
        numAttribs = 0
        totalPlaces = 0
    }
    
    func encode(_ x: Int, _ interval: ClosedRange<Int>) throws {
        guard interval.contains(x) else { throw GenomeError.outOfBounds }
        let maxValue = interval.upperBound - interval.lowerBound
        let places = max(1, Int(ceil(log2(Double(maxValue+1)))))
        if place + places > 64 {
            place = 0
            a.append(0)
        }
        a[a.count - 1] += UInt64(x - interval.lowerBound) * (UInt64(1) << UInt64(place))
        place += places
        totalPlaces += places
        numAttribs += 1
    }
    
    func encode<T: Comparable>(_ v: T, asIndexOf m: [T]) throws {
        let i = m.index(of: v)
        guard i != nil else { throw GenomeError.indexNotFound }
        try encode(i!, 0...m.count-1)
    }
    
    func asBase64String() -> String {
        var s = ""
        for i in 0..<a.count {
            var x = Base64.encodeUInt64(a[i])
            if i < a.count - 1 {
                if x.count < Base64.MAX_UINT64_ENCODED_STRING_LENGTH {
                    x.append("&")
                }
            }
            s = "\(s)\(x)"
        }
        return s
    }
    
    var values: [UInt64] {
        get { return a }
    }
}

class Base2Decoder : GenomeDecoder {
    fileprivate var a: [UInt64]
    fileprivate var sp: Int
    fileprivate var place: Int
    
    init(values: [UInt64]) {
        a = values
        sp = 0
        place = 0
    }

    func decode(_ interval: ClosedRange<Int>) throws -> Int {
        let maxValue = interval.upperBound - interval.lowerBound
        let places = max(1, Int(ceil(log2(Double(maxValue+1)))))
        if place + places > 64 {
            place = 0
            sp += 1
            guard sp < a.count else {
                throw GenomeError.bufferOverrun
            }
        }
        let divisor = UInt64(pow(2, Double(place)))
        let remainder = UInt64(pow(2, Double(places)))
        place += places
        let x = Int((a[sp] / divisor) % remainder) + interval.lowerBound
        guard interval.contains(x) else { throw GenomeError.outOfBounds }
        return x
    }
    
    func decode<T: Comparable>(_ values: [T]) throws -> T {
        let i = try decode(0...(values.count - 1))
        guard i >= 0 else { throw GenomeError.outOfBounds }
        return values[i]
    }
}


class Base10Encoder : GenomeEncoder {
    var a: [UInt64]
    var place: Int
    var numAttribs: Int
    var totalPlaces: Int

    init() {
        a = [0]
        place = 0
        numAttribs = 0
        totalPlaces = 0
    }

    func encode(_ x: Int, _ interval: ClosedRange<Int>) throws {
        guard interval.contains(x) else { throw GenomeError.outOfBounds }
        let maxValue = interval.upperBound - interval.lowerBound
        let places = maxValue <= 9 ? 1 : Int(ceil(log10(Double(maxValue+1))))
        if place + places > 19 {
            place = 0
            a.append(0)
        }
        a[a.count - 1] += UInt64(x - interval.lowerBound) * UInt64(pow(10, Double(place)))
        place += places
        totalPlaces += places
        numAttribs += 1
    }
    
    func encode<T: Comparable>(_ v: T, asIndexOf m: [T]) throws {
        let i = m.index(of: v)
        guard i != nil else { throw GenomeError.indexNotFound }
        try encode(i!, 0...m.count-1)
    }

    func asBase62String() -> String {
        var s = Base62.encodeUInt64(a[0])
        for i in 1..<a.count {
            s = "\(s)&\(Base62.encodeUInt64(a[i]))"
        }
        return s
    }
    
    var values: [UInt64] {
        get { return a }
    }
}

class Base10Decoder : GenomeDecoder {
    fileprivate var a: [UInt64]
    fileprivate var sp: Int
    fileprivate var place: Int
    
    init(values: [UInt64]) {
        a = values
        sp = 0
        place = 0
    }

    func decode(_ interval: ClosedRange<Int>) throws -> Int {
        let maxValue = interval.upperBound - interval.lowerBound
        let places = maxValue <= 9 ? 1 : Int(ceil(log10(Double(maxValue+1))))
        if place + places > 19 {
            place = 0
            sp += 1
            guard sp < a.count else {
                throw GenomeError.bufferOverrun
            }
        }
        let divisor = UInt64(pow(10, Double(place)))
        let remainder = UInt64(pow(10, Double(places)))
        place += places
        let x = Int((a[sp] / divisor) % remainder) + interval.lowerBound
        guard interval.contains(x) else { throw GenomeError.outOfBounds }
        return x
    }
    
    func decode<T: Comparable>(_ values: [T]) throws -> T {
        let i = try decode(0...(values.count - 1))
        guard i >= 0 else { throw GenomeError.outOfBounds }
        return values[i]
    }
}

class ParameterArrayEncoder : GenomeEncoder {
    fileprivate var a: [Int]
    
    init() {
        a = []
    }

    func encode(_ x: Int, _ interval: ClosedRange<Int>) throws {
        guard interval.contains(x) else { throw GenomeError.outOfBounds }
        a.append(x)
    }

    func encode<T: Comparable>(_ v: T, asIndexOf m: [T]) throws {
        let i = m.index(of: v)
        guard i != nil else { throw GenomeError.indexNotFound }
        try encode(i!, 0...m.count-1)
    }
    
    var values: [Int] {
        get { return a }
    }
}

class ParameterArrayDecoder : GenomeDecoder {
    fileprivate var a: [Int]
    fileprivate var sp: Int
    
    init(values: [Int]) {
        a = values
        sp = 0
    }
    
    func decode(_ interval: ClosedRange<Int>) throws -> Int {
        guard sp < a.count else { throw GenomeError.bufferOverrun }
        let x = a[sp]
        sp += 1
        guard interval.contains(x) else { throw GenomeError.outOfBounds }
        return x
    }
    
    func decode<T: Comparable>(_ values: [T]) throws -> T {
        let i = try decode(0...(values.count - 1))
        guard i >= 0 else { throw GenomeError.outOfBounds }
        return values[i]
    }
}

class MPCGDGenome{
    // White
    var whiteCriticalClusterSize = 0
    var whiteExplodeScore = 0
    var whiteTapAction = 0
    var whiteTapScore = 0
    var whiteSizes = 8
    var whiteBallIconPack = 0
    var whiteBallCollection = 0
    var whiteBallChoice = 0
    var whiteEdgeSpawnPositions = 4
    var whiteMidSpawnPositions = 0
    var whiteCentralSpawnPositions = 0
    var whiteSpawnRate = 17
    var whiteScoreZones = 0
    var whiteZoneScore = 0
    var whiteMaxOnScreen = 20
    var whiteControllerCollisionScore = 0
    var whiteBounce = 0
    var whiteNoise = 0
    var whiteSpeed = 2
    var whiteRotation = 0
    // Blue
    var blueCriticalClusterSize = 0
    var blueExplodeScore = 0
    var blueTapAction = 0
    var blueTapScore = 0
    var blueSizes = 8
    var blueBallIconPack = 0
    var blueBallCollection = 0
    var blueBallChoice = 1
    var blueEdgeSpawnPositions = 4
    var blueMidSpawnPositions = 0
    var blueCentralSpawnPositions = 0
    var blueSpawnRate = 17
    var blueScoreZones = 0
    var blueZoneScore = 0
    var blueMaxOnScreen = 20
    var blueControllerCollisionScore = 0
    var blueBounce = 0
    var blueNoise = 0
    var blueSpeed = 2
    var blueRotation = 0
    // Mixed
    var mixedCriticalClusterSize = 0
    var mixedExplodeScore = 0
    // Grid
    var controllerPack = 0
    var gridShape = 5
    var gridOrientation = 1
    var gridGrain = 7
    var gridSize = 6
    var gridColour = 0
    var gridShade = 0
    var gridControl = 0
    var gridStartX = 30
    var gridStartY = 30
    var gridReflection = 0
    // Audio
    var soundtrackPack = 0
    var musicChoice = 0
    var ambiance1 = 0
    var ambiance2 = 0
    var ambiance3 = 0
    var ambiance4 = 0
    var ambiance5 = 0
    var channelVolume1 = 15
    var channelVolume2 = 15
    var channelVolume3 = 15
    var channelVolume4 = 15
    var channelVolume5 = 15
    var channelTempo1 = 15
    var channelTempo2 = 15
    var channelTempo3 = 15
    var channelTempo4 = 15
    var channelTempo5 = 15
    var sfxPack = 0
    var sfxBooleans = 63
    var soundtrackMasterVolume = 15
    var sfxVolume = 15
    // Misc
    var backgroundPack = 0
    var backgroundChoice = 1
    var backgroundShade = 0
    var ballControllerExplosions = 0
    // Game endings
    var pointsToWin = 100
    var gameDuration = 300
    var dayNightCycle = 0
    var numLives = 9

    static let font = UIFontCache(name: "HelveticaNeue-Thin", size: 50)!
    
    static let deathSymbol = "☠️"
    
    static let explodeNums = [0, 2, 3, 4, 5, 6, 7, 8, 9]

    static let sizeNums = [3, 7, 11, 15, 19, 23, 27, 31]
    
    static let spawnRates: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2, 2.4, 2.6, 2.8, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0]
    
    static let winningScores = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 900]
    
    static let gameDurations = [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 1000, 1020, 3600]
    
    static func getScores() -> [Int]{
        var scores = [-90, -80, -70, -60, -50, -45, -40, -35, -30, -25, -20]
        for s in -19...21{
            scores.append(s)
        }
        scores.append(contentsOf: [25, 30, 35, 40, 45, 50, 60, 70, 80, 90])
        return scores
    }

    static let zoneScores = MPCGDGenome.getScores()
    
    static let collisionScores = MPCGDGenome.getScores()
    
    static let clusterExplodeScores = MPCGDGenome.getScores()
    
    static let tapScores = MPCGDGenome.getScores()

    static let tapActions = ["Off", "Explode", "Reverse", "Spring", "Change", "Bounce", "Ping", "Down", "Left", "Right"]
    
    static let gridColours = [Colours.getColour(.black), Colours.getColour(.antiqueWhite), Colours.getColour(.red), Colours.getColour(.orange), Colours.getColour(.yellow), Colours.getColour(.green), Colours.getColour(.blue), Colours.getColour(.indigo), Colours.getColour(.gray)]
    
    static let shadeColours = [Colours.getColour(.black), Colours.getColour(.black), Colours.getColour(.black), Colours.getColour(.black), Colours.getColour(.black), Colours.getColour(.black), Colours.getColour(.black), Colours.getColour(.black), Colours.getColour(.black)]
    
    func encode(_ g: GenomeEncoder) -> Bool {
        do {
            try g.encode(CONSUMER_GENOME_VERSION, 1...9)
            // White
            try g.encode(whiteCriticalClusterSize, asIndexOf: MPCGDGenome.explodeNums)
            try g.encode(whiteExplodeScore, asIndexOf: MPCGDGenome.clusterExplodeScores)
            try g.encode(whiteTapAction, 0...8)
            try g.encode(whiteTapScore, asIndexOf: MPCGDGenome.tapScores)
            try g.encode(whiteSizes, 0...(1 << MPCGDGenome.sizeNums.count) - 1)
            try g.encode(whiteBallIconPack, 0...8)
            try g.encode(whiteBallCollection, 0...8)
            try g.encode(whiteBallChoice, 0...8)
            try g.encode(whiteEdgeSpawnPositions, 0...15)
            try g.encode(whiteMidSpawnPositions, 0...15)
            try g.encode(whiteCentralSpawnPositions, 0...15)
            try g.encode(whiteSpawnRate, 0...31)
            try g.encode(whiteScoreZones, 0...((1<<5)-1))
            try g.encode(whiteZoneScore, asIndexOf: MPCGDGenome.zoneScores)
            try g.encode(whiteMaxOnScreen, 0...30)
            try g.encode(whiteControllerCollisionScore, asIndexOf: MPCGDGenome.collisionScores)
            try g.encode(whiteBounce, 0...8)
            try g.encode(whiteNoise, 0...8)
            try g.encode(whiteSpeed, 1...9)
            try g.encode(whiteRotation, 0...2)
            // Blue
            try g.encode(blueCriticalClusterSize, asIndexOf: MPCGDGenome.explodeNums)
            try g.encode(blueExplodeScore, asIndexOf: MPCGDGenome.clusterExplodeScores)
            try g.encode(blueTapAction, 0...8)
            try g.encode(blueTapScore, asIndexOf: MPCGDGenome.tapScores)
            try g.encode(blueSizes, 0...(1 << MPCGDGenome.sizeNums.count) - 1)
            try g.encode(blueBallIconPack, 0...8)
            try g.encode(blueBallCollection, 0...8)
            try g.encode(blueBallChoice, 0...8)
            try g.encode(blueEdgeSpawnPositions, 0...15)
            try g.encode(blueMidSpawnPositions, 0...15)
            try g.encode(blueCentralSpawnPositions, 0...15)
            try g.encode(blueSpawnRate, 0...31)
            try g.encode(blueScoreZones, 0...((1<<5)-1))
            try g.encode(blueZoneScore, asIndexOf: MPCGDGenome.zoneScores)
            try g.encode(blueMaxOnScreen, 0...30)
            try g.encode(blueControllerCollisionScore, asIndexOf: MPCGDGenome.collisionScores)
            try g.encode(blueBounce, 0...8)
            try g.encode(blueNoise, 0...8)
            try g.encode(blueSpeed, 1...9)
            try g.encode(blueRotation, 0...2)
            // Mixed
            try g.encode(mixedCriticalClusterSize, asIndexOf: MPCGDGenome.explodeNums)
            try g.encode(mixedExplodeScore, asIndexOf: MPCGDGenome.clusterExplodeScores)
            // Grid
            try g.encode(controllerPack, 0...8)
            try g.encode(gridShape, 0...8)
            try g.encode(gridOrientation, 0...8)
            try g.encode(gridGrain, 0...8)
            try g.encode(gridSize, 1...62)
            try g.encode(gridColour, 0...8)
            try g.encode(gridShade, 0...8)
            try g.encode(gridControl, 0...8)
            try g.encode(gridStartX, 0...60)
            try g.encode(gridStartY, 0...60)
            try g.encode(gridReflection, 0...3)
            // Audio
            try g.encode(soundtrackPack, 0...8)
            try g.encode(musicChoice, 0...5)
            try g.encode(ambiance1, 0...30)
            try g.encode(ambiance2, 0...30)
            try g.encode(ambiance3, 0...30)
            try g.encode(ambiance4, 0...30)
            try g.encode(ambiance5, 0...30)
            try g.encode(channelVolume1, 0...30)
            try g.encode(channelVolume2, 0...30)
            try g.encode(channelVolume3, 0...30)
            try g.encode(channelVolume4, 0...30)
            try g.encode(channelVolume5, 0...30)
            try g.encode(channelTempo1, 0...30)
            try g.encode(channelTempo2, 0...30)
            try g.encode(channelTempo3, 0...30)
            try g.encode(channelTempo4, 0...30)
            try g.encode(channelTempo5, 0...30)
            try g.encode(sfxPack, 0...8)
            try g.encode(sfxBooleans, 0...255)
            try g.encode(soundtrackMasterVolume, 0...30)
            try g.encode(sfxVolume, 0...30)
            // Misc
            try g.encode(backgroundPack, 0...17)
            try g.encode(backgroundChoice, 0...8)
            try g.encode(backgroundShade, 0...8)
            try g.encode(ballControllerExplosions, 0...3)
            // Game endings
            try g.encode(pointsToWin, asIndexOf: MPCGDGenome.winningScores)
            try g.encode(gameDuration, asIndexOf: MPCGDGenome.gameDurations)
            try g.encode(numLives, 0...9)
            try g.encode(dayNightCycle, 0...2)
        }
        catch {
            print("Encode failed: \(error)")
            return false
        }
        return true
    }
    
    func decode(_ g: GenomeDecoder) -> Bool {
        do {
            let version = try g.decode(1...9)
            guard version == CONSUMER_GENOME_VERSION else { throw GenomeError.invalidVersion }
            // White
            whiteCriticalClusterSize = try g.decode(MPCGDGenome.explodeNums)
            whiteExplodeScore = try g.decode(MPCGDGenome.clusterExplodeScores)
            whiteTapAction = try g.decode(0...8)
            whiteTapScore = try g.decode(MPCGDGenome.tapScores)
            whiteSizes = try g.decode(0...(1 << MPCGDGenome.sizeNums.count) - 1)
            whiteBallIconPack = try g.decode(0...8)
            whiteBallCollection = try g.decode(0...8)
            whiteBallChoice = try g.decode(0...8)
            whiteEdgeSpawnPositions = try g.decode(0...15)
            whiteMidSpawnPositions = try g.decode(0...15)
            whiteCentralSpawnPositions = try g.decode(0...15)
            whiteSpawnRate = try g.decode(0...31)
            whiteScoreZones = try g.decode(0...((1<<5)-1))
            whiteZoneScore = try g.decode(MPCGDGenome.zoneScores)
            whiteMaxOnScreen = try g.decode(0...30)
            whiteControllerCollisionScore = try g.decode(MPCGDGenome.collisionScores)
            whiteBounce = try g.decode(0...8)
            whiteNoise = try g.decode(0...8)
            whiteSpeed = try g.decode(1...9)
            whiteRotation = try g.decode(0...2)
            // Blue
            blueCriticalClusterSize = try g.decode(MPCGDGenome.explodeNums)
            blueExplodeScore = try g.decode(MPCGDGenome.clusterExplodeScores)
            blueTapAction = try g.decode(0...8)
            blueTapScore = try g.decode(MPCGDGenome.tapScores)
            blueSizes = try g.decode(0...(1 << MPCGDGenome.sizeNums.count) - 1)
            blueBallIconPack = try g.decode(0...8)
            blueBallCollection = try g.decode(0...8)
            blueBallChoice = try g.decode(0...8)
            blueEdgeSpawnPositions = try g.decode(0...15)
            blueMidSpawnPositions = try g.decode(0...15)
            blueCentralSpawnPositions = try g.decode(0...15)
            blueSpawnRate = try g.decode(0...31)
            blueScoreZones = try g.decode(0...((1<<5)-1))
            blueZoneScore = try g.decode(MPCGDGenome.zoneScores)
            blueMaxOnScreen = try g.decode(0...30)
            blueControllerCollisionScore = try g.decode(MPCGDGenome.collisionScores)
            blueBounce = try g.decode(0...8)
            blueNoise = try g.decode(0...8)
            blueSpeed = try g.decode(1...9)
            blueRotation = try g.decode(0...2)
            // Mixed
            mixedCriticalClusterSize = try g.decode(MPCGDGenome.explodeNums)
            mixedExplodeScore = try g.decode(MPCGDGenome.clusterExplodeScores)
            // Grid
            controllerPack = try g.decode(0...8)
            gridShape = try g.decode(0...8)
            gridOrientation = try g.decode(0...8)
            gridGrain = try g.decode(0...8)
            gridSize = try g.decode(1...62)
            gridColour = try g.decode(0...8)
            gridShade = try g.decode(0...8)
            gridControl = try g.decode(0...8)
            gridStartX = try g.decode(0...60)
            gridStartY = try g.decode(0...60)
            gridReflection = try g.decode(0...3)
            // Audio
            soundtrackPack = try g.decode(0...8)
            musicChoice = try g.decode(0...5)
            ambiance1 = try g.decode(0...30)
            ambiance2 = try g.decode(0...30)
            ambiance3 = try g.decode(0...30)
            ambiance4 = try g.decode(0...30)
            ambiance5 = try g.decode(0...30)
            channelVolume1 = try g.decode(0...30)
            channelVolume2 = try g.decode(0...30)
            channelVolume3 = try g.decode(0...30)
            channelVolume4 = try g.decode(0...30)
            channelVolume5 = try g.decode(0...30)
            channelTempo1 = try g.decode(0...30)
            channelTempo2 = try g.decode(0...30)
            channelTempo3 = try g.decode(0...30)
            channelTempo4 = try g.decode(0...30)
            channelTempo5 = try g.decode(0...30)
            sfxPack = try g.decode(0...8)
            sfxBooleans = try g.decode(0...255)
            soundtrackMasterVolume = try g.decode(0...30)
            sfxVolume = try g.decode(0...30)
            // Misc
            backgroundPack = try g.decode(0...17)
            backgroundChoice = try g.decode(0...8)
            backgroundShade = try g.decode(0...8)
            ballControllerExplosions = try g.decode(0...3)
            // Game endings
            pointsToWin = try g.decode(MPCGDGenome.winningScores)
            gameDuration = try g.decode(MPCGDGenome.gameDurations)
            numLives = try g.decode(0...9)
            dayNightCycle = try g.decode(0...2)
        }
        catch {
            print("Decode failed: \(error)")
            return false
        }
        return true
    }

    func encodeAsBase62() -> String? {
        let encoder = Base10Encoder()
        guard encode(encoder) else { return nil }
        let base62 = encoder.asBase62String()
        //print("base62=\"\(base62)\" length=\(base62.count)")
        return base62
    }
    
    func decodeFromBase62(_ encoding: String) -> Bool {
        guard encoding.count > 8 && encoding.count < 256 else {
            print("INVALID ENCODING STRING: LENGTH")
            return false
        }
        let encodingParts = encoding.components(separatedBy: "&")
        guard encodingParts.count > 0 && encodingParts.count < 8 else {
            print("INVALID ENCODING STRING: TOO MANY PARTS")
            return false
        }
        var encodedValues: [UInt64] = []
        for s in encodingParts {
            if Base62.validUInt64Encoding(s) == false {
                print("INVALID UINT64 ENCODING")
                return false
            }
            encodedValues.append(Base62.decodeUInt64(s))
        }
        
        return decode(Base10Decoder(values: encodedValues))
    }
    
    func encodeAsBase64() -> String? {
        let encoder = Base2Encoder()
        guard encode (encoder) else { return nil }
        let base64 = encoder.asBase64String()
        //print("base64=\"\(base64)\" length=\(base64.count)")
        return base64
    }

    func decodeFromBase64(_ encoding: String) -> Bool {
        guard encoding.count > 8 && encoding.count < 256 else {
            print("INVALID ENCODING STRING: LENGTH")
            return false
        }
        
        let chunks = encoding.components(separatedBy: "&")
        guard chunks.count < 8 else { return false }
        var encodingParts: [String] = []
        for c in chunks {
            var tmp = c
            while tmp.count > 0 {
                let n = min(Base64.MAX_UINT64_ENCODED_STRING_LENGTH, tmp.count)
                let splitIndex = tmp.index(tmp.startIndex, offsetBy: n)
                let s = tmp[..<splitIndex]
                tmp = String(tmp[splitIndex...])
                encodingParts.append(String(s))
            }
        }
        guard encodingParts.count > 0 && encodingParts.count < 8 else {
            print("INVALID ENCODING STRING: TOO MANY PARTS")
            return false
        }
        var encodedValues: [UInt64] = []
        for s in encodingParts {
            if Base64.validUInt64Encoding(s) == false {
                print("INVALID UINT64 ENCODING")
                return false
            }
            encodedValues.append(Base64.decodeUInt64(s))
        }
        return decode(Base2Decoder(values: encodedValues))
    }
    
    func encodeAsParameterArray() -> [Int]? {
        let encoder = ParameterArrayEncoder()
        return encode(encoder) ? encoder.values : nil
    }
    
    func decodeFromParameterArray(_ encoding: [Int]) -> Bool {
        let decoder = ParameterArrayDecoder(values: encoding)
        return decode(decoder)
    }
    
    func getCopy() -> MPCGDGenome{
        let copy = MPCGDGenome()
        // Hammer... Nail...
        let params = self.encodeAsParameterArray()
        if params != nil {
            _ = copy.decodeFromParameterArray(params!)
        }
        return copy
    }
    
    func getBestText(gameID: String) -> (String?, String){
        
        var positiveScoresPossible = false
        if (whiteScoreZones != 0 && whiteZoneScore > 0) || (blueScoreZones != 0 && blueZoneScore > 0){
            positiveScoresPossible = true
        }
        if (whiteTapScore > 0 || blueTapScore > 0){
            positiveScoresPossible = true
        }
        if (whiteCriticalClusterSize != 0 && whiteExplodeScore > 0) || (blueCriticalClusterSize != 0 && blueExplodeScore > 0) || (mixedCriticalClusterSize != 0 && mixedExplodeScore > 0){
            positiveScoresPossible = true
        }
        if (whiteControllerCollisionScore > 0 || blueControllerCollisionScore > 0){
            positiveScoresPossible = true
        }
        
        if pointsToWin > 0{
            if let fT = SessionHandler.getFastestTime(gameID){
                return ("\(fT)s", "Fastest")
            }
            else{
                return (nil, "Fastest")
            }
        }
        if gameDuration > 0{
            if positiveScoresPossible{
                if let hS = SessionHandler.getHighScore(gameID){
                    return ("\(hS) pts", "High score")
                }
                else{
                    return (nil, "High score")
                }
            }
            else if numLives > 0{
                let nW = SessionHandler.getNumWins(gameID)
                return ("\(nW)", "Completes")
            }
            else{
                return (nil, "Completes")
            }
        }
        if numLives > 0{
            if positiveScoresPossible{
                if let hS = SessionHandler.getHighScore(gameID){
                    return ("\(hS) pts", "High score")
                }
                else{
                    return (nil, "High score")
                }
            }
            else{
                if let lT = SessionHandler.getLongestTime(gameID){
                    return ("\(lT)s", "Longest")
                }
                else{
                    return (nil, "Longest")
                }
            }
        }
        return (nil, "")
    }

    
    func getBinaryBreakdown(_ num: Int) -> [Bool]{
        var onOffs: [Bool] = []
        let binString = String(num, radix: 2)
        let len = binString.count - 1
        for pos in 0...len{
            let strPos = len - pos
            let oo = binString[binString.index(binString.startIndex, offsetBy: strPos)...binString.index(binString.startIndex, offsetBy: strPos)]
            onOffs.append(oo == "1")
        }
        while onOffs.count < 8{
            onOffs.append(false)
        }
        return onOffs
    }
    
    func getCornerSpawnImage(_ size: CGSize) -> UIImage{
        let buttonSize = size * 2
        
        UIGraphicsBeginImageContextWithOptions(buttonSize, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        let w = DeviceType.simulationIs == .iPad ? buttonSize.width * 0.45 : buttonSize.width * 0.4
        let h = DeviceType.simulationIs == .iPad ? w * (4/3) : w * (16/9)
        let xPos = (buttonSize.width - w)/2
        let yPos = (buttonSize.height - h)/2
        let screenRect = CGRect(x: xPos, y: yPos, width: w, height: h)
        
        let bw = screenRect.width/5
        let bh = screenRect.height/5
        context.setFillColor(Colours.getColour(.antiqueWhite).cgColor)
        let cornerRects = [
            CGRect(x: screenRect.origin.x, y: screenRect.origin.y, width: bw, height: bh),
            CGRect(x: screenRect.origin.x + screenRect.width - bw, y: screenRect.origin.y, width: bw, height: bh),
            CGRect(x: screenRect.origin.x, y: screenRect.origin.y + screenRect.height - bh, width: bw, height: bh),
            CGRect(x: screenRect.origin.x + screenRect.width - bw, y: screenRect.origin.y + screenRect.height - bh, width: bw, height: bh)
        ]
        for rect in cornerRects{
            context.fill(rect)
        }
        
        context.setStrokeColor(Colours.getColour(.antiqueWhite).cgColor)
        context.setLineWidth(2)
        context.stroke(screenRect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func getSpawnImage(_ size: CGSize, whiteSpawnNum: Int, blueSpawnNum: Int!, isOff: Bool = false, showZoneScores: Bool = false) -> UIImage{
        let buttonSize = size * 2
        let w = DeviceType.simulationIs == .iPad ? buttonSize.width * 0.45 : buttonSize.width * 0.4
        let h = DeviceType.simulationIs == .iPad ? w * (4/3) : w * (16/9)
        let xPos = (buttonSize.width - w)/2
        let yPos = (buttonSize.height - h)/2
        let screenRect = CGRect(x: xPos, y: yPos, width: w, height: h)
        
        UIGraphicsBeginImageContextWithOptions(buttonSize, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        
        if whiteSpawnNum == 256 || (blueSpawnNum != nil && blueSpawnNum == 256){
            let t = isOff ? "Off" : "OK"
            let f = UIFontCache(name: "HelveticaNeue-Thin", size: 50)!
            let textSize = FontUtils.textSize(t, font: f)
            let pos = CGPoint(x: xPos + w/2 - textSize.width/2, y: yPos + h/2 - textSize.height/2)
            _ = DrawingText.addTextToContext(context, font: f, text: t, colour: Colours.getColour(.antiqueWhite), position: pos)
        }
        else{
            let whiteBinBreakDown = getBinaryBreakdown(whiteSpawnNum)
            if blueSpawnNum != nil{
                let blueBinBreakDown = getBinaryBreakdown(blueSpawnNum)
                let blueSpawnRects = getBlueSpawnRects(screenRect, onOffs: blueBinBreakDown, whiteOnOffs: whiteBinBreakDown)
                context.setFillColor(Colours.getColour(.antiqueWhite).cgColor)
                for rect in blueSpawnRects{
                    context.fill(rect)
                }
            }
            
            let whiteSpawnRects = getWhiteSpawnRects(screenRect, onOffs: whiteBinBreakDown)
            context.setFillColor(Colours.getColour(.antiqueWhite).cgColor)
            for rect in whiteSpawnRects{
                context.fill(rect)
            }
            
            context.setStrokeColor(Colours.getColour(.antiqueWhite).cgColor)
            context.setLineWidth(2)
            context.stroke(screenRect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
    
    func getWhiteSpawnRects(_ screenRect: CGRect, onOffs: [Bool]) -> [CGRect]{
        var rects: [CGRect] = []
        let x = screenRect.origin.x
        let y = screenRect.origin.y
        let w = screenRect.width
        let h = screenRect.height
        if onOffs[0]{
            rects.append(CGRect(x: x, y: y, width: w, height: 10))
        }
        if onOffs[1]{
            rects.append(CGRect(x: x + w - 10, y: y, width: 10, height: h))
        }
        if onOffs[2]{
            rects.append(CGRect(x: x, y: y + h - 10, width: w, height: 10))
        }
        if onOffs[3]{
            rects.append(CGRect(x: x, y: y, width: 10, height: h))
        }
        if onOffs[4]{
            rects.append(CGRect(x: x + w/3, y: y, width: w/3, height: 10))
        }
        if onOffs[5]{
            rects.append(CGRect(x: x + w - 10, y: y + h/3, width: 10, height: h/3))
        }
        if onOffs[6]{
            rects.append(CGRect(x: x + w/3, y: y + h - 10, width: w/3, height: 10))
        }
        if onOffs[7]{
            rects.append(CGRect(x: x, y: y + h/3, width: 10, height: h/3))
        }
        return rects
    }
    
    func getBlueSpawnRects(_ screenRect: CGRect, onOffs: [Bool], whiteOnOffs: [Bool]) -> [CGRect]{
        var rects: [CGRect] = []
        let x = screenRect.origin.x
        let y = screenRect.origin.y
        let w = screenRect.width
        let h = screenRect.height
        var addOn = CGFloat(0)
        if onOffs[0]{
            addOn = whiteOnOffs[0] || whiteOnOffs[4] ? 10 : 0
            rects.append(CGRect(x: x, y: y + addOn, width: w, height: 10))
        }
        if onOffs[1]{
            addOn = whiteOnOffs[1] || whiteOnOffs[5] ? 10 : 0
            rects.append(CGRect(x: x + w - 10 - addOn, y: y, width: 10, height: h))
        }
        if onOffs[2]{
            addOn = whiteOnOffs[2] || whiteOnOffs[6] ? 10 : 0
            rects.append(CGRect(x: x, y: y + h - 10 - addOn, width: w, height: 10))
        }
        if onOffs[3]{
            addOn = whiteOnOffs[3] || whiteOnOffs[7] ? 10 : 0
            rects.append(CGRect(x: x + addOn, y: y, width: 10, height: h))
        }
        if onOffs[4]{
            addOn = whiteOnOffs[0] || whiteOnOffs[4] ? 10 : 0
            rects.append(CGRect(x: x + w/3, y: y + addOn, width: w/3, height: 10))
        }
        if onOffs[5]{
            addOn = whiteOnOffs[1] || whiteOnOffs[5] ? 10 : 0
            rects.append(CGRect(x: x + w - 10 - addOn, y: y + h/3, width: 10, height: h/3))
        }
        if onOffs[6]{
            addOn = whiteOnOffs[2] || whiteOnOffs[6] ? 10 : 0
            rects.append(CGRect(x: x + w/3, y: y + h - 10 - addOn, width: w/3, height: 10))
        }
        if onOffs[7]{
            addOn = whiteOnOffs[3] || whiteOnOffs[7] ? 10 : 0
            rects.append(CGRect(x: x + addOn, y: y + h/3, width: 10, height: h/3))
        }
        return rects
    }
    
    func getWhiteBallImage(_ size: Int) -> UIImage{
        let bbi = UIImage(named: "Snowflake")!
        let size = CGSize(width: CGFloat(size * 4), height: CGFloat(size * 4))
        return ImageUtils.getScaledImage(bbi, size: size)
    }
    
    func getBlueBallImage(_ size: Int) -> UIImage{
        let bbi = UIImage(named: "Droplet")!
        let size = CGSize(width: CGFloat(size * 4), height: CGFloat(size * 4))
        return ImageUtils.getScaledImage(bbi, size: size)
    }
    
    func applyModifications(_ fascinator: Fascinator, screenSize: CGSize){
        
        fascinator.sceneSize = screenSize
        if DeviceType.isIPhone && DeviceType.simulationIs == .iPad{
            fascinator.sceneSize = CGSize(width: screenSize.width, height: screenSize.width * (4/3))
        }
        else if DeviceType.isIPad && DeviceType.simulationIs == .iPhone{
            fascinator.sceneSize = CGSize(width: screenSize.height * (9/16), height: screenSize.height)
        }
        
        let gpc = fascinator.genome[.Gameplay] as! GameplayChromosome
        fascinator.whiteSizes.removeAll()
        fascinator.blueSizes.removeAll()
        
        var maxWhiteSize = 0
        var maxBlueSize = 0
        for pos in 0...7{
            if whiteSizes & Int(exp2(Double(pos))) != 0{
                fascinator.whiteSizes.append(CGFloat(MPCGDGenome.sizeNums[pos]))
                maxWhiteSize = max(maxWhiteSize, MPCGDGenome.sizeNums[pos])
            }
            if blueSizes & Int(exp2(Double(pos))) != 0{
                fascinator.blueSizes.append(CGFloat(MPCGDGenome.sizeNums[pos]))
                maxBlueSize = max(maxBlueSize, MPCGDGenome.sizeNums[pos])
            }
        }
        gpc.friend.sizes = fascinator.blueSizes
        gpc.foe.sizes = fascinator.whiteSizes
 
        gpc.friend.spawnMinDistFromFriends.intValue = gpc.friend.spawnMinDistFromFriends.mapValueToInt(CGFloat(maxBlueSize * 2))
        gpc.friend.spawnMinDistFromFoes.intValue = gpc.friend.spawnMinDistFromFriends.mapValueToInt(CGFloat(maxBlueSize * 2))
        gpc.foe.spawnMinDistFromFriends.intValue = gpc.foe.spawnMinDistFromFriends.mapValueToInt(CGFloat(maxWhiteSize * 2))
        gpc.foe.spawnMinDistFromFoes.intValue = gpc.foe.spawnMinDistFromFriends.mapValueToInt(CGFloat(maxWhiteSize * 2))
        
        // Max on screen
        gpc.foe.maxBalls.intValue = gpc.foe.maxBalls.mapValueToInt(whiteMaxOnScreen)
        gpc.friend.maxBalls.intValue = gpc.friend.maxBalls.mapValueToInt(blueMaxOnScreen)

        // Icons
        gpc.friend.characterCollectionNum.intValue = blueBallCollection
        gpc.friend.characterNum.intValue = blueBallChoice
        gpc.foe.characterCollectionNum.intValue = whiteBallCollection
        gpc.foe.characterNum.intValue = whiteBallChoice
        
        // Score colour
        fascinator.scoring = Fascinator.Scoring()
        fascinator.scoreColour = (dayNightCycle == 0 && backgroundShade > 4) ? Colours.getColour(.antiqueWhite) : Colours.getColour(.black)
        Fascinator.ScoringColours.friend = CharacterIconHandler.getCharacterColour(collectionNum: blueBallCollection, characterNum: blueBallChoice)
        Fascinator.ScoringColours.foe = CharacterIconHandler.getCharacterColour(collectionNum: whiteBallCollection, characterNum: whiteBallChoice)
        Fascinator.ScoringColours.mixed = Fascinator.ScoringColours.mixFriendAndFoe(0.5)

        // Particle effects for characters
        Fascinator.ParticleEffect.friend = CharacterIconHandler.getParticleEffectNameForCharacter(collectionNum: blueBallCollection, characterNum: blueBallChoice)
        Fascinator.ParticleEffect.foe = CharacterIconHandler.getParticleEffectNameForCharacter(collectionNum: whiteBallCollection, characterNum: whiteBallChoice)
        
        // Critical cluster sizes
        gpc.friend.criticalClusterSize.intValue = blueCriticalClusterSize
        gpc.foe.criticalClusterSize.intValue = whiteCriticalClusterSize
        gpc.mixedCriticalClusterSize.intValue = mixedCriticalClusterSize
        
        if blueCriticalClusterSize == 0{
            gpc.friendFriendCollision.intValue = gpc.friendFriendCollision.mapValueToInt(.bounce)
        }
        else{
            gpc.friendFriendCollision.intValue = gpc.friendFriendCollision.mapValueToInt(.stick)
        }
        
        if whiteCriticalClusterSize == 0{
            gpc.foeFoeCollision.intValue = gpc.foeFoeCollision.mapValueToInt(.bounce)
        }
        else{
            gpc.foeFoeCollision.intValue = gpc.foeFoeCollision.mapValueToInt(.stick)
        }
        
        if mixedCriticalClusterSize == 0{
            gpc.friendFoeCollision.intValue = gpc.friendFoeCollision.mapValueToInt(.bounce)
        }
        else{
            gpc.friendFoeCollision.intValue = gpc.friendFoeCollision.mapValueToInt(.stick)
        }
        
        // Cluster explode scores
        fascinator.scoring.snowTapped = whiteTapAction > 0 ? whiteTapScore : 0
        fascinator.scoring.rainTapped = blueTapAction > 0 ? blueTapScore : 0
        fascinator.scoring.rainClusterExplodeScore = blueExplodeScore
        fascinator.scoring.snowClusterExplodeScore = whiteExplodeScore
        fascinator.scoring.mixedClusterExplodeScore = mixedExplodeScore
        fascinator.scoring.snowControllerCollision = whiteControllerCollisionScore
        fascinator.scoring.rainControllerCollision = blueControllerCollisionScore
        
        let tapActions: [BallSubChromosome.BallTapAction] = [.nothing, .destroy, .reverse, .stickInPlace, .changeColour, .bounce, .ping, .impulseUp, .impulseDown, .impulseLeft, .impulseRight]

        gpc.foe.tapAction.intValue = gpc.foe.tapAction.mapValueToInt(tapActions[whiteTapAction])
        gpc.score[0].amount.intValue = gpc.score[0].amount.mapValueToInt(whiteTapScore)
        gpc.score[0].who.intValue = gpc.score[0].who.mapValueToInt(.foe)
        gpc.score[0].type.intValue = gpc.score[0].type.mapValueToInt(.tapped)
        
        gpc.friend.tapAction.intValue = gpc.friend.tapAction.mapValueToInt(tapActions[blueTapAction])
        gpc.score[1].amount.intValue = gpc.score[1].amount.mapValueToInt(blueTapScore)
        gpc.score[1].who.intValue = gpc.score[1].who.mapValueToInt(.friend)
        gpc.score[1].type.intValue = gpc.score[1].type.mapValueToInt(.tapped)

        gpc.score[2].amount.intValue = gpc.score[2].amount.mapValueToInt(blueExplodeScore)
        gpc.score[2].who.intValue = gpc.score[2].who.mapValueToInt(.friend)
        gpc.score[2].type.intValue = gpc.score[2].type.mapValueToInt(.inMaxCluster)
        
        gpc.score[3].amount.intValue = gpc.score[3].amount.mapValueToInt(whiteExplodeScore)
        gpc.score[3].who.intValue = gpc.score[3].who.mapValueToInt(.foe)
        gpc.score[3].type.intValue = gpc.score[3].type.mapValueToInt(.inMaxCluster)
        
        gpc.score[4].amount.intValue = gpc.score[4].amount.mapValueToInt(mixedExplodeScore)
        gpc.score[4].who.intValue = gpc.score[4].who.mapValueToInt(.friend)
        gpc.score[4].type.intValue = gpc.score[4].type.mapValueToInt(.inMaxMixedCluster)

        gpc.score[5].amount.intValue = gpc.score[5].amount.mapValueToInt(blueControllerCollisionScore)
        gpc.score[5].who.intValue = gpc.score[5].who.mapValueToInt(.friend)
        gpc.score[5].type.intValue = gpc.score[5].type.mapValueToInt(.controllerContact)
        
        gpc.score[6].amount.intValue = gpc.score[6].amount.mapValueToInt(whiteControllerCollisionScore)
        gpc.score[6].who.intValue = gpc.score[6].who.mapValueToInt(.foe)
        gpc.score[6].type.intValue = gpc.score[6].type.mapValueToInt(.controllerContact)
        
        fascinator.scoreZone = whiteScoreZones
        fascinator.deadZone = blueScoreZones
        fascinator.scoring.snowScoreZone = self.whiteZoneScore
        fascinator.scoring.rainScoreZone = self.blueZoneScore
        
        if whiteScoreZones != 0{
            // White = foe
            gpc.score[7].amount.intValue = gpc.score[7].amount.mapValueToInt(whiteZoneScore)
            gpc.score[7].who.intValue = gpc.score[7].who.mapValueToInt(.foe)
            gpc.score[7].type.intValue = gpc.score[7].type.mapValueToInt(.battedAwayInScoreZone)
        }
        
        if blueScoreZones != 0{
            // Blue = friend
            gpc.score[8].amount.intValue = gpc.score[8].amount.mapValueToInt(blueZoneScore)
            gpc.score[8].who.intValue = gpc.score[8].who.mapValueToInt(.friend)
            gpc.score[8].type.intValue = gpc.score[8].type.mapValueToInt(.battedAwayInDeadZone)
        }
        
        // Behaviours
        
        if whiteRotation == 0{
            gpc.foe.constantAngularVelocity.intValue = gpc.foe.constantAngularVelocity.mapValueToInt(0)
            gpc.foe.canRotate.intValue = gpc.foe.canRotate.mapValueToInt(true)
        }
        else if whiteRotation == 1{
            gpc.foe.constantAngularVelocity.intValue = gpc.foe.constantAngularVelocity.mapValueToInt(7)
            gpc.foe.canRotate.intValue = gpc.foe.canRotate.mapValueToInt(true)
        }
        else if whiteRotation == 2{
            gpc.foe.constantAngularVelocity.intValue = gpc.foe.constantAngularVelocity.mapValueToInt(0)
            gpc.foe.canRotate.intValue = gpc.foe.canRotate.mapValueToInt(false)
        }

        if blueRotation == 0{
            gpc.friend.constantAngularVelocity.intValue = gpc.friend.constantAngularVelocity.mapValueToInt(0)
            gpc.friend.canRotate.intValue = gpc.friend.canRotate.mapValueToInt(true)
        }
        else if blueRotation == 1{
            gpc.friend.constantAngularVelocity.intValue = gpc.friend.constantAngularVelocity.mapValueToInt(7)
            gpc.friend.canRotate.intValue = gpc.friend.canRotate.mapValueToInt(true)
        }
        else if blueRotation == 2{
            gpc.friend.constantAngularVelocity.intValue = gpc.friend.constantAngularVelocity.mapValueToInt(0)
            gpc.friend.canRotate.intValue = gpc.friend.canRotate.mapValueToInt(false)
        }

        let whiteB = CGFloat(whiteBounce)/10
        gpc.foe.bounciness.intValue = gpc.foe.bounciness.mapValueToInt(whiteB)
        
        let blueB = CGFloat(blueBounce)/10
        gpc.friend.bounciness.intValue = gpc.friend.bounciness.mapValueToInt(blueB)
        
        gpc.wallBounciness.intValue = gpc.wallBounciness.mapValueToInt(0.5)
        gpc.imageBounciness.intValue = gpc.imageBounciness.mapValueToInt(0)
        
        let whiteN = CGFloat(whiteNoise)/10
        gpc.foe.noiseStrength.intValue = gpc.foe.noiseStrength.mapValueToInt(whiteN)
        
        let blueN = CGFloat(blueNoise)/10
        gpc.friend.noiseStrength.intValue = gpc.friend.noiseStrength.mapValueToInt(blueN)
        
        gpc.friend.noiseWaves.intValue = gpc.friend.noiseWaves.mapValueToInt(0.1)
        gpc.foe.noiseWaves.intValue = gpc.foe.noiseWaves.mapValueToInt(0.1)
        
        if whiteNoise > 7{
            gpc.foe.noiseWaves.intValue = gpc.foe.noiseWaves.mapValueToInt(0.5)
        }
        if blueNoise > 7{
            gpc.friend.noiseWaves.intValue = gpc.friend.noiseWaves.mapValueToInt(0.5)
        }

        var whiteVal = -1.9 + (2.9 * (CGFloat(whiteSpeed - 1)/9))
        if whiteVal < 0{
            whiteVal = whiteVal/2
        }
        gpc.foe.attraction.intValue = 100 + Int(round(whiteVal * 100))
        
        var blueVal = -1.9 + (2.9 * (CGFloat(blueSpeed - 1)/9))
        if blueVal < 0{
            blueVal = blueVal/2
        }
        gpc.friend.attraction.intValue = 100 + Int(round(blueVal * 100))
        
        // Spawn locations
        
        gpc.friend.spawnLocation.intValue = gpc.friend.spawnLocation.mapValueToInt(.locations)
        gpc.foe.spawnLocation.intValue = gpc.foe.spawnLocation.mapValueToInt(.locations)
        addSpawnLocations(fascinator)
        
        gpc.friend.numPerSecond.intValue = gpc.friend.numPerSecond.mapValueToInt(MPCGDGenome.spawnRates[blueSpawnRate])
        gpc.foe.numPerSecond.intValue = gpc.foe.numPerSecond.mapValueToInt(MPCGDGenome.spawnRates[whiteSpawnRate])
        
        // Control
        gpc.controlType.intValue = gpc.controlType.mapValueToInt(.dragMove)
        gpc.imageGridSnap.intValue = gpc.imageGridSnap.mapValueToInt(false)
        gpc.attachment.canRotate.intValue = gpc.attachment.canRotate.mapValueToInt(false)
        gpc.attachment.joint.intValue = gpc.attachment.joint.mapValueToInt(.none)
        gpc.imageGridSnap.intValue = gpc.imageGridSnap.mapValueToInt(false)
        gpc.imageWallCollision.intValue = gpc.imageWallCollision.mapValueToInt(15)
        fascinator.useBoundingBoxFix = true
        fascinator.detachJointOnDrag = false
        
        if gridControl == 0{ // None
            gpc.attachment.joint.intValue = gpc.attachment.joint.mapValueToInt(.pin)
            gpc.controlType.intValue = gpc.controlType.mapValueToInt(.none)
        }
        // 1 = Move - nothing to do
        else if gridControl == 2{ // Float
            gpc.attachment.canRotate.intValue = gpc.attachment.canRotate.mapValueToInt(true)
        }
        else if gridControl == 3{ // Teleport
            gpc.controlType.intValue = gpc.controlType.mapValueToInt(.teleport)
        }
        else if gridControl == 4{ // Rotate
            gpc.controlType.intValue = gpc.controlType.mapValueToInt(.dragRotate)
            gpc.imageWallCollision.intValue = gpc.imageWallCollision.mapValueToInt(0)
            gpc.attachment.anchorX.intValue = gpc.attachment.anchorX.mapValueToInt(0)
            gpc.attachment.anchorY.intValue = gpc.attachment.anchorY.mapValueToInt(0)
            gpc.attachment.joint.intValue = gpc.attachment.joint.mapValueToInt(.pin)
        }
        else if gridControl == 5{ // UpDown
            gpc.attachment.joint.intValue = gpc.attachment.joint.mapValueToInt(.slider)
            gpc.attachment.sliderAxis.intValue = gpc.attachment.sliderAxis.mapValueToInt(90)
        }
        else if gridControl == 6{ // LeftRight
            gpc.attachment.joint.intValue = gpc.attachment.joint.mapValueToInt(.slider)
            gpc.attachment.sliderAxis.intValue = gpc.attachment.sliderAxis.mapValueToInt(0)
        }
        else if gridControl == 7{ // Chase
            gpc.imageWallCollision.intValue = gpc.imageWallCollision.mapValueToInt(0)
            gpc.controlType.intValue = gpc.controlType.mapValueToInt(.moveTowardsFinger)
        }
        else if gridControl == 8{ // Grid
            gpc.controlType.intValue = gpc.controlType.mapValueToInt(.swipeOnGrid)
            gpc.gridX.intValue = 10
            gpc.gridY.intValue = 10
            gpc.imageGridSnap.intValue = gpc.imageGridSnap.mapValueToInt(true)
        }

        // Collisions with controller
        
        let foeICollision = (ballControllerExplosions == 1 || ballControllerExplosions == 3) ? GameplayChromosome.CollisionAction.destroyFoe : GameplayChromosome.CollisionAction.bounce
        let frICollision = (ballControllerExplosions == 2 || ballControllerExplosions == 3) ? GameplayChromosome.CollisionAction.destroyFriend : GameplayChromosome.CollisionAction.bounce
        gpc.foeImageCollision.intValue = gpc.foeImageCollision.mapValueToInt(foeICollision)
        gpc.friendImageCollision.intValue = gpc.friendImageCollision.mapValueToInt(frICollision)
        
        // Audio

        MPCGDSounds.precache(packName: MPCGDSounds.sfxPackNames[sfxPack])
        fascinator.sfxVolume = CGFloat(sfxVolume)/63
        
        MPCGDSounds.soundsAllowed.removeAll()
        let bBins = getBinaryBreakdown(sfxBooleans)
        for pos in 0...7{
            if bBins[pos] == true{
                MPCGDSounds.soundsAllowed.append(MPCGDSounds.sounds[pos])
            }
        }
        
        // Game endings

        gpc.scoreThreshold.intValue = gpc.scoreThreshold.mapValueToInt(pointsToWin)
        gpc.duration.intValue = gpc.duration.mapValueToInt(CGFloat(gameDuration))
        fascinator.livesLeft = numLives
        fascinator.restartScore = 0
        fascinator.restartTimeElapsed = 0
        fascinator.positiveScoresPossible = false
        if (whiteScoreZones != 0 && whiteZoneScore > 0) || (blueScoreZones != 0 && blueZoneScore > 0){
            fascinator.positiveScoresPossible = true
        }
        if (whiteTapScore > 0 || blueTapScore > 0){
            fascinator.positiveScoresPossible = true
        }
        if (whiteCriticalClusterSize != 0 && whiteExplodeScore > 0) || (blueCriticalClusterSize != 0 && blueExplodeScore > 0) || (mixedCriticalClusterSize != 0 && mixedExplodeScore > 0){
            fascinator.positiveScoresPossible = true
        }
        if (whiteControllerCollisionScore > 0 || blueControllerCollisionScore > 0){
            fascinator.positiveScoresPossible = true
        }
        
        if controllerPack == 2{
            fascinator.artImageColour = CharacterIconHandler.getCharacterColour(collectionNum: gridShape, characterNum: gridOrientation)
        }
        else if controllerPack == 1{
            fascinator.artImageColour = MPCGDGenome.getGridShades(gridColour)[gridShade]
        }
        
        fascinator.chromosome = gpc
        
        var xOffset = ((CGFloat(gridStartX)/60) * screenSize.width)
        var yOffset = ((CGFloat(gridStartY)/60) * screenSize.height)

        var bb = CGRect()
        
        if controllerPack == 0{
            fascinator.controllerOverlayImage = nil
            fascinator.controllerCollectionNum = nil
            fascinator.controllerCharacterNum = nil
            fascinator.drawingPaths = []
            LAF.wallOffScreenNess = (3, 3)
        }
        else if controllerPack == 1{
            let iPhoneGameDimensions = CGSize(width: 320 * 2 - 4, height: 568 * 2 - 4)
            let iPadGameDimensions = CGSize(width: (384 * 2) - 4, height: (512 * 2) - 4)
            let gameDimensions = DeviceType.isIPhone ? iPhoneGameDimensions : iPadGameDimensions
            
            let drawing = getGridDrawing(gameDimensions)
            for path in drawing.paths{                
                path.strokeWidth = 3
                let (h, s, b, _) = MPCGDGenome.getGridShades(gridColour)[gridShade].getHSBA()
                path.hue = h
                path.saturation = s
                path.brightness = b
                if path.filled {
                    path.alpha = LAF.controllerFillAlpha
                }
                else {
                    path.alpha = 1.0
                }
            }
            fascinator.drawingPaths = drawing.paths
            fascinator.controllerOverlayImage = nil
            fascinator.controllerCollectionNum = nil
            fascinator.controllerCharacterNum = nil
            let gg = GridGenerator()
            bb = gg.getBoundingBox(fascinator.sceneSize * 0.5, controllerPack: controllerPack, shape: gridShape, orientation: gridOrientation, grain: gridGrain, size: gridSize, reflectionID: gridReflection, useIconSize: true)
            LAF.wallOffScreenNess = (bb.width * 2, bb.height * 2)
            if gridControl == 5 || gridControl == 6{
                LAF.wallOffScreenNess = (5, 5)
            }
        }
        else if controllerPack == 2{
            let width = 2 * fascinator.sceneSize.width * CGFloat(gridSize)/62
            fascinator.drawingPaths = []
            fascinator.controllerOverlayImage = CharacterIconHandler.getCharacterImage(collectionNum: gridShape, characterNum: gridOrientation, size: CGSize(width: width, height: width))
            fascinator.controllerSize = CGFloat(gridSize)/62
            fascinator.controllerCollectionNum = gridShape
            fascinator.controllerCharacterNum = gridOrientation
            if gridColour < 8{
                let shades = MPCGDGenome.getGridShades(gridColour)
                fascinator.controllerColour = shades[gridShade]
            }
            else{
                fascinator.controllerColour = nil
            }
            let radius = fascinator.sceneSize.width * fascinator.controllerSize * 0.5
            bb = CharacterIconHandler.getCharacterBoundingBox(radius: radius, collectionNum: gridShape, characterNum: gridOrientation, centreOffset: CGPoint(x: 0, y: 0))
            LAF.wallOffScreenNess = (bb.width * 2, bb.height * 2)
            if gridControl == 5 || gridControl == 6{
                LAF.wallOffScreenNess = (bb.width, bb.height)
            }
        }
        
        fascinator.controllerReflectionID = gridReflection
        
        // Positioning of the controller and its attachment point

        if controllerPack != 0{

            xOffset = max(bb.width, xOffset)
            yOffset = max(bb.height, yOffset)
            xOffset = min(fascinator.sceneSize.width - bb.width, xOffset)
            yOffset = min(fascinator.sceneSize.height - bb.height, yOffset)
            
            fascinator.controllerStartPosition = CGPoint(x: xOffset, y: yOffset)
            
            if gridControl == 3{// Rotation
                fascinator.controllerAttachmentPoint = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
            }
            else{
                fascinator.controllerAttachmentPoint = CGPoint(x: xOffset, y: yOffset)
            }
        }
    }
    
    func getSpawnAts(_ n1: Int, _ n2: Int, _ n3: Int) -> [Bool]{
        var spawnAts: [Bool] = []
        for n in [n1, n2, n3]{
            let firstFour = getBinaryBreakdown(n)[0...3]
            spawnAts.append(contentsOf: firstFour)
        }
        return spawnAts
    }

    func addSpawnLocations(_ fascinator: Fascinator){
        let w = Int(fascinator.sceneSize.width)
        let h = Int(fascinator.sceneSize.height)
        
        let leftMidX = Int(fascinator.sceneSize.width * 0.33)
        let rightMidX = Int(fascinator.sceneSize.width * 0.66)
        let topMidY = Int(fascinator.sceneSize.height * 0.66)
        let bottomMidY = Int(fascinator.sceneSize.height * 0.33)

        let leftCentralX = Int(fascinator.sceneSize.width * 0.45)
        let rightCentralX = Int(fascinator.sceneSize.width * 0.55)
        let topCentralY = Int(fascinator.sceneSize.height * 0.55)
        let bottomCentralY = Int(fascinator.sceneSize.height * 0.45)

        fascinator.foeSpawnLocations.removeAll()
        let foeOnOffs = getSpawnAts(whiteEdgeSpawnPositions, whiteMidSpawnPositions, whiteCentralSpawnPositions)
        
        let locations = [
            ("h", h + 30, 2, w - 2),
            ("h", -30, 2, w - 2),
            ("v", -30, 2, h - 2),
            ("v", w + 30, 2, h - 2),
            ("h", h + 30, leftMidX, rightMidX),
            ("h", -30, leftMidX, rightMidX),
            ("v", -30, bottomMidY, topMidY),
            ("v", w + 30, bottomMidY, topMidY),
            ("h", h + 30, leftCentralX, rightCentralX),
            ("h", -30, leftCentralX, rightCentralX),
            ("v", -30, bottomCentralY, topCentralY),
            ("v", w + 30, bottomCentralY, topCentralY)
        ]
        
        var pos = 0
        for l in locations{
            if foeOnOffs[pos]{
                if l.0 == "h"{
                    fascinator.foeSpawnLocations.append(contentsOf: getHorizontalSpawnLocations(l.1, x1: l.2, x2: l.3))
                }
                else if l.0 == "v"{
                    fascinator.foeSpawnLocations.append(contentsOf: getVerticalSpawnLocations(l.1, y1: l.2, y2: l.3))
                }
            }
            pos += 1
        }

        fascinator.friendSpawnLocations.removeAll()
        let friendOnOffs = getSpawnAts(blueEdgeSpawnPositions, blueMidSpawnPositions, blueCentralSpawnPositions)
        
        pos = 0
        for l in locations{
            if friendOnOffs[pos]{
                if l.0 == "h"{
                    fascinator.friendSpawnLocations.append(contentsOf: getHorizontalSpawnLocations(l.1, x1: l.2, x2: l.3))
                }
                else if l.0 == "v"{
                    fascinator.friendSpawnLocations.append(contentsOf: getVerticalSpawnLocations(l.1, y1: l.2, y2: l.3))
                }
            }
            pos += 1
        }
    }
    
    func getHorizontalSpawnLocations(_ y: Int, x1: Int, x2: Int) -> [CGPoint]{
        var locations: [CGPoint] = []
        for x in x1...x2{
            locations.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }
        return locations
    }
    
    func getVerticalSpawnLocations(_ x: Int, y1: Int, y2: Int) -> [CGPoint]{
        var locations: [CGPoint] = []
        for y in y1...y2{
            locations.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }
        return locations
    }
    
    func getGridDrawing(_ screenSize: CGSize) -> FascinatorDrawing{
        
        let gg = GridGenerator()
        var isBad = true
        var gS = gridSize
        var lines: [(CGPoint, CGPoint)] = []
        var polys: [[CGPoint]] = []
        while isBad{
            isBad = false
            lines = gg.getLines(controllerPack: controllerPack, shape: gridShape, orientation: gridOrientation, grain: gridGrain, size: gS)
            for (p1, p2) in lines{
                let x1 = (p1.x * screenSize.width) + 2
                let y1 = (p1.y * screenSize.height)
                let x2 = (p2.x * screenSize.width) + 2
                let y2 = (p2.y * screenSize.height)
                let dist = sqrt(pow((x1 - x2), 2) + pow((y1 - y2), 2))
                if dist < 3{
                    isBad = true
                    break
                }
            }
            if isBad{
                gS += 1
            }
        }
        polys = gg.getPolys(controllerPack: controllerPack, shape: gridShape, orientation: gridOrientation, grain: gridGrain, size: gS)
        
        let drawing = FascinatorDrawing()
        
        for poly in polys {
            let path = DrawingPath()
            for p in poly {
                let x = (p.x * screenSize.width)
                var y = (p.y * screenSize.height)
                if DeviceType.isIPhone && DeviceType.simulationIs == .iPad{
                    y = y * CGFloat(3)/CGFloat(4)
                }
                path.pathPoints.append(CGPoint(x: x, y: y))
            }
            path.closed = true
            path.filled = true
            drawing.paths.append(path)
        }

        for (p1, p2) in lines{
            let path = DrawingPath()
            let x1 = (p1.x * screenSize.width) + 2
            var y1 = (p1.y * screenSize.height)
            let x2 = (p2.x * screenSize.width) + 2
            var y2 = (p2.y * screenSize.height)
            
            if DeviceType.isIPhone && DeviceType.simulationIs == .iPad{
                y1 = y1 * CGFloat(3)/CGFloat(4)
                y2 = y2 * CGFloat(3)/CGFloat(4)
            }

            path.pathPoints = [CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2)]
            drawing.paths.append(path)
        }
        return drawing
    }

    static func getGridShades(_ gridColour: Int) -> [UIColor]{
        var shades: [ColourNames] = []
        switch gridColour{
        case 0:
            shades = [.black, .darkViolet, .darkBlue, .darkSlateGray, .darkRed, .darkGreen, .darkSlateBlue, .darkOrchid, .darkMagenta]
        case 1:
            shades = [.antiqueWhite, .lightGray, .lightBlue, .lightYellow, .lightPink, .lightGreen, .lightSalmon, .lightCyan, .lightSkyBlue]
        case 2:
            shades = [.red, .crimson, .magenta, .indianRed, .mediumVioletRed, .maroon, .paleVioletRed, .salmon, .tomato]
        case 3:
            shades = [.orange, .darkOrange, .fireBrick, .brown, .chocolate, .burlyWood, .orangeRed, .rosyBrown, .sandyBrown]
        case 4:
            shades = [.yellow, .yellowGreen, .lightGoldenrodYellow, .goldenrod, .greenYellow, .lemonChiffon, .cornsilk, .gold, .papayaWhip]
        case 5:
            shades = [.green, .springGreen, .forestGreen, .cyan, .lawnGreen, .olive, .oliveDrab, .lime, .lightSeaGreen]
        case 6:
            shades = [.blue, .blueViolet, .dodgerBlue, .skyBlue, .powderBlue, .navy, .aquamarine, .royalBlue, .cornflowerBlue]
        case 7:
            shades = [.indigo, .hotPink, .lavender, .plum, .orchid, .deepPink, .purple, .thistle, .blueViolet]
            
        default:
            shades = []
        }
        
        var colours: [UIColor] = []
        for shade in shades{
            colours.append(Colours.getColour(shade))
        }
        if gridColour == 8{
            for g in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]{
                let s = CGFloat(g)
                let c = UIColor(red: s, green: s, blue: s, alpha: 1)
                colours.append(c)
            }
        }
        return colours
    }
    
    func positiveScoresPossible() -> Bool{
        if hasWhiteCharacters() && whiteTapAction > 0 && whiteTapScore > 0{
            return true
        }
        if hasBlueCharacters() && blueTapAction > 0 && blueTapScore > 0{
            return true
        }
        if hasWhiteCharacters() && whiteScoreZones > 0 && whiteZoneScore > 0{
            return true
        }
        if hasBlueCharacters() && blueScoreZones > 0 && blueZoneScore > 0{
            return true
        }
        if controllerPack > 0{
            if hasWhiteCharacters() && whiteControllerCollisionScore > 0{
                return true
            }
            if hasBlueCharacters() && blueControllerCollisionScore > 0{
                return true
            }
        }
        if hasWhiteCharacters() && whiteCriticalClusterSize > 0 && whiteExplodeScore > 0{
            return true
        }
        if hasBlueCharacters() && blueCriticalClusterSize > 0 && blueExplodeScore > 0{
            return true
        }
        if hasWhiteCharacters() && hasBlueCharacters() && mixedCriticalClusterSize > 0 && mixedExplodeScore > 0{
            return true
        }
        
        return false
    }
    
    func livesCanBeLost() -> Bool{
        if hasWhiteCharacters() && whiteTapAction > 0 && whiteTapScore == -90{
            return true
        }
        if hasBlueCharacters() && blueTapAction > 0 && blueTapScore == -90{
            return true
        }
        if hasWhiteCharacters() && whiteScoreZones > 0 && whiteZoneScore == -90{
            return true
        }
        if hasBlueCharacters() && blueScoreZones > 0 && blueZoneScore == -90{
            return true
        }
        if controllerPack > 0{
            if hasWhiteCharacters() && whiteControllerCollisionScore == -90{
                return true
            }
            if hasBlueCharacters() && blueControllerCollisionScore == -90{
                return true
            }
        }
        if hasWhiteCharacters() && whiteCriticalClusterSize > 0 && whiteExplodeScore == -90{
            return true
        }
        if hasBlueCharacters() && blueCriticalClusterSize > 0 && blueExplodeScore == -90{
            return true
        }
        if hasWhiteCharacters() && hasBlueCharacters() && mixedCriticalClusterSize > 0 && mixedExplodeScore == -90{
            return true
        }
        
        return false
    }
    
    func isWinnable() -> Bool{
        if numLives == 0 && pointsToWin == 0 && gameDuration == 0{
            return false
        }
        if pointsToWin > 0 && !positiveScoresPossible(){
            return false
        }
        if pointsToWin == 0 && numLives == 0 && gameDuration > 0 && !positiveScoresPossible(){
            return false
        }
        return true
    }
        
    func hasCharacters() -> Bool{
        return (hasWhiteCharacters() || hasBlueCharacters())
    }
    
    func hasWhiteCharacters() -> Bool{
        if whiteEdgeSpawnPositions == 0 && whiteMidSpawnPositions == 0 && whiteCentralSpawnPositions == 0{
            return false
        }
        if whiteMaxOnScreen == 0{
            return false
        }
        return true
    }
    
    func hasBlueCharacters() -> Bool{
        if blueEdgeSpawnPositions == 0 && blueMidSpawnPositions == 0 && blueCentralSpawnPositions == 0{
            return false
        }
        if blueMaxOnScreen == 0{
            return false
        }
        return true
    }
    
    func hasInteraction() -> Bool{
        if whiteTapAction == 0 && blueTapAction == 0 && (gridControl == 0 || controllerPack == 0){
            return false
        }
        return true
    }

    static func getCleanSlate() -> MPCGDGenome{
        let wG = MPCGDGenome()
        wG.backgroundChoice = RandomUtils.randomInt(0, upperInc: 8)
        wG.backgroundShade = RandomUtils.randomInt(0, upperInc: 8)
        wG.whiteBallCollection = RandomUtils.randomInt(0, upperInc: 8)
        wG.blueBallCollection = RandomUtils.randomInt(0, upperInc: 8)
        wG.whiteBallChoice = RandomUtils.randomInt(0, upperInc: 8)
        wG.blueBallChoice = RandomUtils.randomInt(0, upperInc: 8)
        wG.whiteSpeed = 1
        wG.blueSpeed = 1
        wG.gameDuration = 0
        wG.pointsToWin = 0
        wG.numLives = 0
        wG.whiteMidSpawnPositions = 0
        wG.whiteEdgeSpawnPositions = 0
        wG.whiteCentralSpawnPositions = 0
        wG.blueMidSpawnPositions = 0
        wG.blueEdgeSpawnPositions = 0
        wG.blueCentralSpawnPositions = 0
        wG.sfxBooleans = 0
        return wG
    }
    
}
