//
//  SoundQueue.swift
//  Engine
//
//  Created by Powley, Edward on 09/06/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//
#if false
import Foundation
import SpriteKit
import AVFoundation

class SoundQueue {
    
    // SoundQueue contains a number of "channels" (player nodes) which it cycles through to allow for multiple sounds playing at once.
    
    fileprivate(set) weak var engine : SoundEngine!
    fileprivate var channels : [SoundChannel]
    fileprivate var buffers : [AVAudioPCMBuffer]
    var volumeMultiplier : Float = 1.0
    var panMultiplier : Float = 0.5
    
    init(engine : SoundEngine, numChannels : Int, volume : Float) {
        self.engine = engine
        volumeMultiplier = volume
        
        self.buffers = []
        
        channels = []
        for _ in 0 ..< numChannels {
            let channel = SoundChannel(queue: self)
            channels.append(channel)
        }
    }
    
    deinit {
        print("A queue is destroyed")
    }
    
    func setSoundNames(_ soundNames: [String]) {
        buffers = []
        for soundName in soundNames {
            if let b = engine.loadAudioBuffer(soundName) {
                buffers.append(b)
            }
            else {
                print("WARNING: failed to load sound '\(soundName)'")
            }
        }
    }
    
    func play(volume : Float, pan : Float, force : Bool) {
        guard buffers.count > 0 else { return }
        
        // Play on the first available channel
        var played : Bool = false
        for channel in channels {
            if !channel.isPlaying {
                let buffer = RandomUtils.randomChoice(buffers)
                channel.play(buffer!, volume: volume, pan: pan)
                played = true
                break
            }
        }
        
        if force && !played {
            // Play on a random channel
            let channel = RandomUtils.randomChoice(channels)
            let buffer = RandomUtils.randomChoice(buffers)
            channel?.play(buffer!, volume: volume, pan: pan)
        }
    }
}
#endif
