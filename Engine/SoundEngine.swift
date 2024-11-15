//
//  SoundEngine.swift
//  Engine
//
//  Created by Powley, Edward on 01/06/2016.
//  Copyright © 2016 ThoseMetamakers. All rights reserved.
//
#if false
import Foundation
import SpriteKit

class SoundEngine {
    
    static fileprivate(set) var singleton : SoundEngine = SoundEngine()
    
    let avAudioEngine : AVAudioEngine

    static let numChannelsPerSoundEffect : Int = 4
    
    var currentTheme : SoundTheme! = nil
    
    fileprivate var queues : [SoundType : SoundQueue] = [:]
    
    var musicChannels : [MusicChannel] = []
    
    fileprivate var currentStage : Int = 0

    /* HACK by pete to fix audio startup glitch: private */ var musicVolume : Float = 0.0
    
    var musicEnabled : Bool = true
    var soundEnabled : Bool = true
    
    fileprivate init() {
        avAudioEngine = AVAudioEngine()
        
        // Accessing mainMixerNode causes AVAudioEngine to create its mixer node.
        // This is required, even though we don't actually need the mixer node yet.
        // Hence this strange line of code that appears to do nothing.
        _ = avAudioEngine.mainMixerNode
        
        for _ in 1 ... 8 { // Dirty hack: 8 audio tracks hard-coded
            musicChannels.append(MusicChannel(engine: self))
        }
        
        for key in SoundType.all {
            let numChannels : Int
            if key == .gameWin || key == .gameLose {
                numChannels = 1
            }
            else {
                numChannels = SoundEngine.numChannelsPerSoundEffect
            }
            
            queues[key] = SoundQueue(engine: self,
                                     numChannels: numChannels,
                                     volume: getDefaultVolume(key))
        }
        
        //using the Bridging Header and the ExceptionCatcher to catch proper exceptions instead of just ignoring them
        // based on http://stackoverflow.com/questions/34956002/how-to-properly-handle-nsfilehandle-exceptions-in-swift-2-0/35003095#35003095
        if let _ = self.start(20) {
            
        }
    }
    
    deinit {
        print("[\(Unmanaged.passUnretained(self).toOpaque())] SoundEngine destroyed")
    }
    
    func start(_ retries : Int) -> NSException? {
        let error = tryBlock{
            do {
                //print("[\(unsafeAddressOf(self))] SoundEngine starting")
                
                try self.avAudioEngine.start()
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.audioConfigurationChanged), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: self.avAudioEngine)
            }
            catch {
                print("Debug: [\(Unmanaged.passUnretained(self).toOpaque())] Failed to start audio engine")
            }
        }
        
        if error != nil && retries > 0 {
            print("audio queue broken")
            sleep(1)
            _ = start(retries-1)
            return nil
        } else {
            return error
        }
    }
    
    fileprivate func getDefaultVolume(_ soundType : SoundType) -> Float {
/*        switch soundType {
        case .BallExplode:
            return 0.2
        default:
            return 1.0
        }
 */
        return 0.5
    }
    
    func loadTheme(_ theme : SoundTheme) {
        //print("[\(unsafeAddressOf(self))] Loading sound theme")
        
        currentTheme = theme
        
        for (key, queue) in queues {
            queue.setSoundNames(theme.soundFiles[key] ?? [])
        }
        
        for i in 0 ..< theme.musicFiles.count {
            musicChannels[i].load(theme.musicFiles[i])
        }
    }
    
    
    
    // Called when audio configuration changes, e.g. when plugging or unplugging headphones.
    // Destroy and recreate the sound engine
    @objc func audioConfigurationChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            SoundEngine.singleton = SoundEngine()
            
            if let theme = self.currentTheme {
                SoundEngine.singleton.loadTheme(theme)
            }
            
            if let scene = (UIApplication.shared.delegate as! AppDelegate).getMainScene() {
                scene.audioConfigurationChanged()
            }
        }
    }
    
    func loadAudioFile(_ soundName: String) -> AVAudioFile? {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: nil) else {
            print("Failed to find url for \(soundName)")
            return nil
        }
        
        do {
            let file = try AVAudioFile(forReading: url)
            return file
        }
        catch {
            print("Failed to load audio file \(url)")
            return nil
        }
    }
    
    fileprivate var audioBufferCache : [String : AVAudioPCMBuffer] = [:]
    
    func loadAudioBuffer(_ soundName: String) -> AVAudioPCMBuffer? {
        if let cached = audioBufferCache[soundName] {
            return cached
        }
        
        guard let file = loadAudioFile(soundName) else { return nil }
        let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        
        do {
            try file.read(into: buffer)
            audioBufferCache[soundName] = buffer
            return buffer
        }
        catch {
            print("Failed to read sound \(soundName) into buffer")
            return nil
        }
    }

    func setAllSoundVolumes(_ volume : CGFloat) {
        for sound in queues.keys {
            switch sound {
            case .gameWin, .gameLose:
                setSoundVolume(sound, volume: max(volume, CGFloat(musicVolume)))
            default:
                setSoundVolume(sound, volume: volume)
            }
        }
        // treat zero (or very near) volumes as disabled, to avoid glitches
        if volume < 0.01 {
            soundEnabled = false
        }
        else {
            soundEnabled = true
        }
    }
    
    func setSoundVolume(_ sound : SoundType, volume : CGFloat) {
        if let queue = queues[sound] {
            queue.volumeMultiplier = Float(volume)
        }
    }
    
    fileprivate var soundPlayedThisFrame = false

    func playSound(_ sound : SoundType, volume : CGFloat) {
        playSound(sound, volume: volume, force: false)
    }

    func playSound(_ sound : SoundType, volume : CGFloat, force : Bool) {
        let enabled : Bool
        switch sound {
        case .gameWin, .gameLose:
            enabled = soundEnabled || musicEnabled
        default:
            enabled = soundEnabled
        }
        
        if enabled && (force || !soundPlayedThisFrame) {
            guard avAudioEngine.isRunning else { return }
            guard let queue = queues[sound] else { return }
            queue.play(volume: Float(volume), pan: 0, force: force)
            soundPlayedThisFrame = true
        }
    }
    
    func playMusic(position: TimeInterval) {
        playMusic(position : position, stage: currentStage)
    }

    func playMusic(position: TimeInterval, stage: Int) {
        currentStage = stage
        if musicEnabled {
            for channelIndex in 0 ..< musicChannels.count {
                let targetVolume : Float = (channelIndex == stage) ? musicVolume : 0.0
                musicChannels[channelIndex].play(initialVolume: targetVolume, position: position)
            }
        }
    }
    
    func stopMusic() {
        for channel in musicChannels {
            channel.stop()
        }
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = volume
        if !musicEnabled && volume >= 0.01 {
            do { // take sole ownership of audio when we're playing music
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            }
            catch let error as NSError {
                print(error)
            }
            musicEnabled = true
            playMusic(position: 0)
        }
        else if musicEnabled && volume < 0.01 {
            musicEnabled = false
            stopMusic()
            do { // when music is off, allow other apps' audio to play
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            }
            catch let error as NSError {
                print(error)
            }
        }
        else if musicEnabled {
            fadeToMusicStage(currentStage, duration: 0.5)
        }
        if let queue = queues[.gameWin] {
            queue.volumeMultiplier = max(volume, queue.volumeMultiplier)
        }
    }

    func fadeToMusicStage(_ stage : Int) {
        fadeToMusicStage(stage, duration: 0.25)
    }

    func fadeToMusicStage(_ stage : Int, duration: TimeInterval) {
        currentStage = stage
        if musicEnabled {
            for channelIndex in 0 ..< musicChannels.count {
                let targetVolume : Float = (channelIndex == stage) ? musicVolume : 0.0
                musicChannels[channelIndex].beginFade(targetVolume, duration: duration)
            }
        }
    }
    
    func tick(_ deltaTime : CFTimeInterval) {
        soundPlayedThisFrame = false

        for music in musicChannels {
            music.tick(deltaTime)
        }
    }
}
#endif
