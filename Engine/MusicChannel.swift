//
//  MusicChannel.swift
//  Engine
//
//  Created by Powley, Edward on 09/06/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//
#if false
import Foundation
import SpriteKit
import AVFoundation

class MusicChannel {
    
    fileprivate weak var engine : SoundEngine!
    fileprivate var player : AVAudioPlayerNode
    fileprivate var file : AVAudioFile! = nil
    
    fileprivate var isPlaying : Bool = false

    fileprivate var fadeTarget : Float! = nil
    fileprivate var fadeDelta : Float! = nil
    fileprivate var fadeTime : CFTimeInterval! = nil
    
    init(engine : SoundEngine) {
        self.engine = engine
        
        player = AVAudioPlayerNode()
        player.volume = 0.0
        //print("[\(unsafeAddressOf(engine)) \(unsafeAddressOf(self))] MusicChannel attaching node")
        engine.avAudioEngine.attach(player)
        engine.avAudioEngine.connect(player, to: engine.avAudioEngine.mainMixerNode, format: nil)
    }
    
    deinit {
        if let av = engine?.avAudioEngine {
            //print("[\(unsafeAddressOf(engine)) \(unsafeAddressOf(self))] MusicChannel detaching node")
            player.stop()
            av.disconnectNodeOutput(player)
            av.detach(player)
        }
    }
    
    func load(_ musicName : String) {
        file = loadAudioFile(musicName)
    }
    
    func play(initialVolume : Float, position: TimeInterval) {
        var loopMusic : AVAudioNodeCompletionHandler!
        loopMusic = {
            if self.isPlaying {
                self.player.scheduleFile(self.file, at: nil, completionHandler: loopMusic)
            }
        }

        player.stop()
        fadeTarget = nil; fadeDelta = nil; fadeTime = nil
        player.volume = initialVolume
        isPlaying = true
        if file != nil {
            //print("[\(unsafeAddressOf(engine)) \(unsafeAddressOf(self))] MusicChannel playing")
            let fileLength = file.length
            let startingFrame = AVAudioFramePosition(position * file.processingFormat.sampleRate) % fileLength
            let frameCount = AVAudioFrameCount(fileLength - startingFrame)
            player.scheduleSegment(file, startingFrame: startingFrame, frameCount: frameCount, at: nil, completionHandler: loopMusic)
            if player.engine!.isRunning {
                player.play()
            }
            else {
                //print("Engine is not running")
            }
        }
    }
    
    func stop() {
        isPlaying = false
        player.stop()
    }
    
    func beginFade(_ volume : Float, duration : CFTimeInterval) {
        // Only fade if the current volume is different from the target volume, or if there is already a fade in progress
        if abs(player.volume - volume) > 1.0e-5 || fadeTarget != nil {
            fadeTarget = volume
            fadeTime = duration
            fadeDelta = (volume - player.volume) / Float(duration)
        }
    }
    
    func tick(_ deltaTime : CFTimeInterval) {
        if fadeTarget != nil && fadeDelta != nil && fadeTime != nil {
            fadeTime! -= deltaTime
            if fadeTime <= 0 {
                player.volume = fadeTarget
                fadeTarget = nil; fadeDelta = nil; fadeTime = nil
            }
            else {
                player.volume += fadeDelta * Float(deltaTime)
            }
        }
    }
}
#endif
