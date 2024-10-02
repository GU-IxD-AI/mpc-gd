//
//  SoundChannel.swift
//  Engine
//
//  Created by Powley, Edward on 09/06/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//
#if false
import Foundation
import SpriteKit
import AVFoundation

class SoundChannel {
    
    fileprivate weak var queue : SoundQueue!
    fileprivate var player : AVAudioPlayerNode
    fileprivate(set) var isPlaying = false
    
    init(queue : SoundQueue) {
        self.queue = queue
        
        let avAudioEngine = queue.engine.avAudioEngine
        player = AVAudioPlayerNode()
        player.volume = 0
        //print("[\(unsafeAddressOf(queue.engine)) \(unsafeAddressOf(self))] SoundChannel attaching node")
        avAudioEngine.attach(player)
        avAudioEngine.connect(player, to: avAudioEngine.mainMixerNode, format: nil)
    }
    
    deinit {
        if let av = player.engine {
            print("[\(Unmanaged.passUnretained(self).toOpaque())] SoundChannel detaching node")
            player.stop()
            av.disconnectNodeOutput(player)
            av.detach(player)
        }
    }
    
    func play(_ buffer : AVAudioPCMBuffer, volume : Float, pan : Float) {
        player.stop()
        player.volume = max(0.0, volume) * queue.volumeMultiplier
        player.pan = MathsUtils.clamp(pan, min: -1, max: 1) * queue.panMultiplier
        self.isPlaying = true
        //print("[\(unsafeAddressOf(queue.engine)) \(unsafeAddressOf(self))] SoundChannel playing buffer")
        player.scheduleBuffer(buffer, completionHandler: { [weak self] in
            if self != nil {
                self!.isPlaying = false
            }
        })
        player.play()
    }
}
#endif
