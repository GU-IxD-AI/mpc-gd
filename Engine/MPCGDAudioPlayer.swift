//
//  MPCGDAudioPlayer.swift
//  MPCGD
//
//  Created by Simon Colton on 09/05/2017.
//  Copyright © 2017 Simon Colton. All rights reserved.
//

import Foundation
import AVFoundation

class MPCGDSounds {
    
    static var sounds = [MPCGDSounds.bounce, MPCGDSounds.gainPoints, MPCGDSounds.losePoints, MPCGDSounds.tap, MPCGDSounds.winGame, MPCGDSounds.loseGame, MPCGDSounds.explode, MPCGDSounds.loseLife]
    
    static var soundsAllowed = [MPCGDSounds.bounce, MPCGDSounds.gainPoints, MPCGDSounds.losePoints, MPCGDSounds.tap, MPCGDSounds.winGame, MPCGDSounds.loseGame, MPCGDSounds.explode, MPCGDSounds.loseLife]
    
    static let sfxPackNames = ["8-bit", "arcade", "cartoon", "drums", "farm", "glass", "magic", "space", "sport"]
    
    static var bounce = "arcade_bounce.aiff"
    static var explode = "arcade_explode.aiff"
    static var gainPoints = "arcade_gain_points.aiff"
    static var loseGame = "arcade_lose_game.aiff"
    static var loseLife = "arcade_lose_life.aiff"
    static var losePoints = "arcade_lose_points.aiff"
    static var tap = "arcade_tap.aiff"
    static var winGame = "arcade_win_game.aiff"
    
    static func precache(packName: String) {
        
        MPCGDSounds.bounce = packName + "_bounce.aiff"
        MPCGDSounds.explode = packName + "_explode.aiff"
        MPCGDSounds.gainPoints = packName + "_gain_points.aiff"
        MPCGDSounds.loseGame = packName + "_lose_game.aiff"
        MPCGDSounds.loseLife = packName + "_lose_life.aiff"
        MPCGDSounds.losePoints = packName + "_lose_points.aiff"
        MPCGDSounds.tap = packName + "_tap.aiff"
        MPCGDSounds.winGame = packName + "_win_game.aiff"
        
        MPCGDSounds.sounds = [MPCGDSounds.bounce, MPCGDSounds.gainPoints, MPCGDSounds.losePoints, MPCGDSounds.tap, MPCGDSounds.winGame, MPCGDSounds.loseGame, MPCGDSounds.explode, MPCGDSounds.loseLife]
        
        _ = MPCGDAudio.loadAudioBuffer(MPCGDSounds.bounce)
        _ = MPCGDAudio.loadAudioBuffer(MPCGDSounds.explode)
        _ = MPCGDAudio.loadAudioBuffer(MPCGDSounds.gainPoints)
        _ = MPCGDAudio.loadAudioBuffer(MPCGDSounds.losePoints)
        _ = MPCGDAudio.loadAudioBuffer(MPCGDSounds.loseLife)
        _ = MPCGDAudio.loadAudioBuffer(MPCGDSounds.losePoints)
        _ = MPCGDAudio.loadAudioBuffer(MPCGDSounds.tap)
        _ = MPCGDAudio.loadAudioBuffer(MPCGDSounds.winGame)
        
    }
}

protocol MPCGDAudioTracker {
    func onSubmit();
    func onPlay(_ wallclock: Date);
    func onStop(_ wallclock: Date);
}

class MPCGDSoundLimiter : MPCGDAudioTracker {
    let name: String
    let limit: Int
    let rate: ClosedRange<Double>
    
    var active: Int
    var submitted: Int
    var wallclock: Date
    var lastPlayedAt: Date
    var timeSinceLastPlay: CFTimeInterval
    var playRate: CFTimeInterval
    
    init(_ id: String, limit: Int, rate: ClosedRange<Double> = 0...(1.0/60.0)) {
        self.name = id
        self.limit = limit
        self.rate = rate
        self.active = 0
        self.submitted = 0
        self.wallclock = Date()
        self.lastPlayedAt = self.wallclock
        self.timeSinceLastPlay = 9999999
        self.playRate = rate.lowerBound
    }
    
    func onSubmit() {
        submitted += 1
    }
    
    func onPlay(_ wallclock: Date) {
        active += 1
        lastPlayedAt = wallclock
        //print("\(name).onPlay: \(wallclock), active=\(active)")
    }
    
    func onStop(_ wallclock: Date) {
        active -= 1
        //print("\(name).onStop: \(wallclock), active=\(active)")
    }
    
    func canPlay() -> Bool {
        return (submitted < limit) && (timeSinceLastPlay > playRate)
    }
    
    func tick(wallclock: Date) {
        timeSinceLastPlay = wallclock.timeIntervalSince(lastPlayedAt)
        
        if timeSinceLastPlay > rate.upperBound {
            playRate = CFTimeInterval(RandomUtils.randomFloat(CGFloat(rate.lowerBound), upperInc: CGFloat(rate.upperBound)))
        }
        submitted = 0
        self.wallclock = wallclock
    }
}

class MPCGDAudio {
    struct StreamRequest {
        var index: Int
        var path: String!
        var volume: Float
        var rate: Float
        
        init(_ i: Int, _ p: String, _ v: Float = 1.0, _ r: Float = 1.0) {
            index = i
            path = p
            volume = v
            rate = r
        }
    }

    struct SoundRequest {
        let priority: Float
        let volume: Float
        let rate: Float
        let path: String
        let buffer: AVAudioPCMBuffer!
        let tracker: MPCGDAudioTracker?
        
        init(path: String, volume: Float, rate: Float, priority: Float, buffer: AVAudioPCMBuffer!, tracker: MPCGDAudioTracker?) {
            self.priority = priority
            self.volume = volume
            self.rate = rate
            self.path = path
            self.buffer = buffer
            self.tracker = tracker
        }
    }
    
    class Fader {
        var timeRemaining: Float
        let target: Float
        let delta: Float
        let completion: (()->())?
        
        init(to: Float, from: Float = -1.0, duration: Float = 0.0, completion fn: (()->())? = nil) {
            timeRemaining = duration
            target = to
            delta = (from < 0 || abs(duration) < 0.01) ? 0.0 : (to - from) / duration
            completion = fn
        }
    }
    
    class Stream {
        let playback = AVAudioUnitVarispeed()
        let player = AVAudioPlayerNode()
        var path: String! = nil
        var file: AVAudioFile! = nil
        var volume: Float = 1.0
        var rate: Float = 1.0
        var elapsed: CFTimeInterval = 0.0
        var fader: Fader? = nil
        
        func looper() {
            if player.isPlaying && file != nil {
                player.scheduleFile(file, at: nil, completionHandler: self.looper)
            }
        }
    }
    
    class Sound {
        var priority: Float = 0.0
        var elapsed: CFTimeInterval = 0.0
        var playing: Bool = false
        var tracker: MPCGDAudioTracker? = nil

        let index: Int
        let playback = AVAudioUnitVarispeed()
        let player = AVAudioPlayerNode()
        var path: String! = nil
        var buffer: AVAudioPCMBuffer! = nil
        var rate: Float = 1.0
        var volume: Float = 1.0
        
        init(_ i: Int) {
            index = i
        }
    }
    
    static let maxStreams = 5
    static let maxSounds = 5
    static let maxSoundsPerFrame = 3

    
    static var engine : AVAudioEngine! = nil
    static var streams: [Stream] = []
    static var sounds: [Sound] = []
    static var soundIndex = 0
    static var outputStreamVolume: Float = 0.0
    static var masterStreamVolume: Float = 1.0
    static var masterSoundVolume: Float = 1.0
    static var audioBufferCache : [String : AVAudioPCMBuffer] = [:]
    static var shouldInitializeOnlyOnce = true
    static var shouldRestart = false
    
    static var streamRequests: [StreamRequest] = []
    static var soundRequests: [SoundRequest] = []
    static var masterStreamFader: Fader? = nil
    static var wallclock: Date! = nil
    
    static func loadAudioFile(_ soundName: String) -> AVAudioFile? {
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
    
    static func loadAudioBuffer(_ soundName: String) -> AVAudioPCMBuffer? {
        if let cached = audioBufferCache[soundName] {
            return cached
        }
        
        guard let file = loadAudioFile(soundName) else { return nil }
        let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        if buffer != nil {
            do {
                try file.read(into: buffer!)
                audioBufferCache[soundName] = buffer
                return buffer
            }
            catch {}
        }
        print("Failed to read sound \(soundName) into buffer")
        return nil
    }
    
    static func initialize() {
        if shouldInitializeOnlyOnce {
            NotificationCenter.default.addObserver(self, selector: #selector(MPCGDAudio.audioConfigurationChanged), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: nil)
            for _ in 0..<maxStreams { streams.append(Stream()) }
            for i in 0..<maxSounds { sounds.append(Sound(i)) }
            shouldInitializeOnlyOnce = false
        }
        
        engine = AVAudioEngine()
        _ = engine.mainMixerNode
        
        for s in streams {
            engine.attach(s.playback)
            engine.attach(s.player)
            engine.connect(s.player, to: s.playback, format: nil)
            engine.connect(s.playback, to: engine.mainMixerNode, format: nil)
        }
        
        for s in sounds {
            engine.attach(s.playback)
            engine.attach(s.player)
            engine.connect(s.player, to: s.playback, format: nil)
            engine.connect(s.playback, to: engine.mainMixerNode, format: nil)
        }
        _ = start()
        outputStreamVolume = 0.0
    }
    
    static func deinitialize() {
        engine.stop()
        masterStreamFader = nil
        for s in streams {
            s.player.stop()
            engine.disconnectNodeInput(s.playback)
            engine.disconnectNodeOutput(s.playback)
            engine.disconnectNodeInput(s.player)
            engine.disconnectNodeOutput(s.player)
            engine.detach(s.playback)
            engine.detach(s.player)
            s.file = nil
            s.fader = nil
        }
        
        for s in sounds {
            s.player.stop()
            s.tracker?.onStop(wallclock)
            engine.disconnectNodeInput(s.playback)
            engine.disconnectNodeOutput(s.playback)
            engine.disconnectNodeInput(s.player)
            engine.disconnectNodeOutput(s.player)
            engine.detach(s.playback)
            engine.detach(s.player)
            s.path = nil
            s.buffer = nil
            s.tracker = nil
        }
        engine = nil
    }
    
    static func start(_ retries : Int = 20) -> NSException? {
        let error = tryBlock {
            do {
                try engine.start()
            }
            catch {
                print("Debug: Failed to start audio")
            }
        }
        
        if error != nil && retries > 0 {
            print("audio broken")
            sleep(1)
            _ = start(retries-1)
            return nil
        } else {
            return error
        }
    }
    
    static private func restart() {
        deinitialize()
        initialize()
        
        for i in 0..<maxStreams {
            guard let path = streams[i].path else { continue }
            let v = streams[i].volume
            let r = streams[i].rate
            playStream(index: i, path: path, volume: v, rate: r)
        }
        shouldRestart = false
    }
    
    // Called when audio configuration changes, e.g. when plugging or unplugging headphones.
    @objc static func audioConfigurationChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            shouldRestart = true
        }
    }
    
    static func playStream(index i: Int, path: String, volume: Float = 1.0, rate: Float = 1.0) {
        streamRequests.append(StreamRequest(i, path, volume, rate))
        streams[i].player.stop()
    }
    
    static private func playSoundRequest(_ s: Sound, _ r: SoundRequest) {
        let old_tracker = s.tracker
        let new_tracker = r.tracker

        s.path = r.path
        s.buffer = r.buffer
        s.priority = r.priority
        s.volume = r.volume
        s.playback.rate = r.rate
        s.player.stop()
        s.player.scheduleBuffer(s.buffer!, at: nil, options: .interrupts, completionHandler: {
            DispatchQueue.main.async {
                s.player.stop();
                s.playing = false
            }
        })
        s.player.volume = masterSoundVolume * r.volume
        s.player.play()
        s.playing = true
        s.elapsed = 0.0
        s.tracker = new_tracker
        
        old_tracker?.onStop(wallclock)
        new_tracker?.onPlay(wallclock)
    }
    
    static func playSound(path: String, volume: Float = 1.0, rate: Float = 1.0, priority: Float = 0.0, tracker: MPCGDAudioTracker? = nil) {
        guard MPCGDSounds.soundsAllowed.contains(path) else { return }
        guard let b = loadAudioBuffer(path) else { return }
        soundRequests.append(SoundRequest(path: path, volume: volume, rate: rate, priority: priority, buffer: b, tracker: tracker))
        tracker?.onSubmit()
    }

    static func setMasterStreamVolume(to volume: Float, duration d: Float = 0.0, completion fn: (()->())? = nil) {
        masterStreamFader = Fader(to: volume, from: masterStreamVolume, duration: d, completion: fn)
    }
    
    static func setStreamVolume(index i: Int, to volume: Float, duration d: Float = 0.0, completion fn: (()->())? = nil) {
        streams[i].fader = Fader(to: volume, from: streams[i].volume, duration: d, completion: fn)
    }
    
    static func tick(_ dt: CFTimeInterval) {
        if shouldRestart {
            restart()
        }

        // Notify all trackers who ended during last tick
        for s in sounds {
            if s.tracker != nil && !s.playing {
                s.tracker!.onStop(wallclock)
                s.tracker = nil
            }
        }
        wallclock = Date();
        
        if masterStreamFader != nil || outputStreamVolume != masterStreamVolume {

            if let fader = masterStreamFader {
                fader.timeRemaining -= Float(dt)
                if fader.timeRemaining <= 0 {
                    masterStreamFader = nil
                    masterStreamVolume = fader.target
                    fader.completion?()
                } else {
                    masterStreamVolume += fader.delta * Float(dt)
                }
            }

            do {
                if outputStreamVolume < 0.01 && masterStreamVolume >= 0.01 {
                    // take sole ownership of audio when we're playing music
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
                }
                else if outputStreamVolume >= 0.01 && masterStreamVolume < 0.01 {
                    // If we've turned music off, allow other apps' audio to play
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                }
            }
            catch let error as NSError {
                print(error)
            }

            outputStreamVolume = masterStreamVolume
        }
        
        for rq in streamRequests {
            let s = streams[rq.index]
            
            if s.path != rq.path || s.file == nil {
                s.path = rq.path
                s.file = loadAudioFile(rq.path)
                s.elapsed = 0.0
            }
            s.volume = rq.volume
            s.rate = rq.rate
            s.player.stop()

            if let file = s.file {
                let startingFrame = AVAudioFramePosition(s.elapsed * file.processingFormat.sampleRate) % file.length
                let frameCount = AVAudioFrameCount(file.length - startingFrame)
                s.player.scheduleSegment(s.file, startingFrame: startingFrame, frameCount: frameCount, at: nil, completionHandler: s.looper)
                s.player.play()
            }
        }
        streamRequests.removeAll()

        for s in streams {
            if let fader = s.fader {
                fader.timeRemaining -= Float(dt)
                if fader.timeRemaining <= 0 {
                    s.fader = nil
                    s.volume = fader.target
                    fader.completion?()
                } else {
                    s.volume += fader.delta * Float(dt)
                }
            }
            s.playback.rate = s.rate
            s.player.volume = s.volume * masterStreamVolume
            s.elapsed += dt
        }
        
        for s in sounds {
            s.player.volume = s.volume * masterSoundVolume
            s.elapsed += dt
        }
        
        if soundRequests.count > 0 {
            // Sort sound requests by priority/volume/rate
//            print(">>>>>>>>>>>>>")
            let requests = soundRequests.sorted {
                if $0.priority != $1.priority { return $0.priority > $1.priority }
                if $0.volume != $1.volume { return $0.volume > $1.volume }
                return $0.rate > $1.rate
            }
//            for rq in requests {
//                print("\(rq.priority), \(rq.volume): \(rq.path)")
//            }
//            print("-----------")
            // Sort active sounds such that most important/playing will be used last
            let active = sounds.sorted {
                if $0.playing != $1.playing { return !$0.playing }
                if $0.priority != $1.priority { return $0.priority < $1.priority }
                return $0.elapsed > $1.elapsed
            }
//            for ac in active {
//                print("\(ac.playing), \(ac.priority), \(ac.elapsed): \(ac.path)")
//            }
//            print("!!!!!!!!!!!!")
            // Sound requests can only play on a free slot, or interrupt
            // and existing playing sound if the priority is higher
            for i in 0..<min(requests.count, maxSoundsPerFrame) {
                let s = active[i]
                let r = requests[i]
                if s.playing && r.priority < s.priority {
                    // No more free sound channels left
                    break
                }
//                print("\(r.priority), \(r.volume): \(r.path)")
                playSoundRequest(s, r)
            }
            soundRequests.removeAll()
        }
    }
}

class MPCGDAudioPlayer{
    
    static let musicNames = ["Mystery", "Journey", "Racer", "Trap", "Jangle", "Tink"]
    
    static func getMusicChannelNames(MPCGDGenome: MPCGDGenome) -> [String]{
        switch MPCGDGenome.musicChoice{
        case 0: return ["Mystery", "Bell", "Beat", "Echo", "Dink"]
        case 1: return ["Journey", "Blip", "Knock", "Chord", "Dink"]
        case 2: return ["Racer", "Scale", "Bing", "Bass", "Double"]
        case 3: return ["Trap", "Boing", "Echo", "Counter", "Smooth"]
        case 4: return ["Jangle", "Blip", "Chord", "Retro", "Boink"]
        case 5: return ["Tink", "Speed", "Note", "Scale", "Vibrato"]
        default: return []
        }
        
    }
    
    static func getAmbianceCategoryNames() -> [String]{
        return ["Animals", "Insects", "Music", "Vehicles", "Weather"]
    }
    
    static func getAmbianceTrackNames() -> [String]{
        return ["Off", "Birds", "Frogs", "Monkeys", "Owls", "Seagulls", "Sheep",
                "Bats", "Bees", "Cicadas", "Jungle", "Swarm", "Wings", "Chimes", "Drums", "Flute", "Guitar", "Khim", "Didge", "Copter", "Drone", "Plane", "Siren", "Traffic", "UFO", "Fire", "Rain", "Thunder", "Water", "Waves", "Wind"]
    }
    
    static func handleGenomeChange(MPCGDGenome: MPCGDGenome){
        print("Reacting to genome change")

        let vols = [MPCGDGenome.channelVolume1, MPCGDGenome.channelVolume2, MPCGDGenome.channelVolume3, MPCGDGenome.channelVolume4, MPCGDGenome.channelVolume5]
        let tempos = [MPCGDGenome.channelTempo1, MPCGDGenome.channelTempo2, MPCGDGenome.channelTempo3, MPCGDGenome.channelTempo4, MPCGDGenome.channelTempo5]
        
        if MPCGDGenome.soundtrackPack == 0{
            setAppAudioVolume(volume: 0)
        }
        else if MPCGDGenome.soundtrackPack == 1{
            setAppAudioVolume(volume: 1)
            for channel in 1...5{
                let mult = Float(MPCGDGenome.soundtrackMasterVolume)/Float(30)
                let trackName = "Music_\(MPCGDGenome.musicChoice + 1)_\(channel).m4a"
                let vol = mult * Float(vols[channel - 1])/Float(30)
                let rate = calculateRate(genomeTempo: tempos[channel - 1])
                loadAndPlayAudio(trackName: trackName, channelNum: channel, volume: vol, rate: rate)
            }
        }
        else if MPCGDGenome.soundtrackPack == 2{
            setAppAudioVolume(volume: 1)
            let nums = [MPCGDGenome.ambiance1, MPCGDGenome.ambiance2, MPCGDGenome.ambiance3, MPCGDGenome.ambiance4, MPCGDGenome.ambiance5]
            for channel in 1...5{
                let trackNum = nums[channel - 1]
                if trackNum == 0{
                    setVolume(channelNum: channel, volume: 0)
                }
                else{
                    let trackNames = getAmbianceTrackNames()
                    let trackName = trackNames[trackNum] + ".m4a"
                    let mult = Float(MPCGDGenome.soundtrackMasterVolume)/Float(30)
                    let vol = mult * Float(vols[channel - 1])/Float(61)
                    let rate = calculateRate(genomeTempo: tempos[channel - 1])
                    loadAndPlayAudio(trackName: trackName, channelNum: channel, volume: vol, rate: rate)
                }
            }
        }
    }
    
    static func calculateRate(genomeTempo: Int) -> Float{
        if genomeTempo >= 14 && genomeTempo <= 16{
            return 1.0
        }
        else if genomeTempo < 14{
            let prop = Float(genomeTempo)/Float(14)
            return 0.2 + (0.8 * prop)
        }
        else{
            let prop = Float(genomeTempo - 16)/Float(14)
            return Float(1.0) + (4 * prop)
        }
    }
    
    static func playSoloChannel(channelNum: Int){
        
        // This will quickly fade out all the channels except channelNum, and
        // fade up channelNum to maximum volume
        
        for channel in 1...5{
            MPCGDAudioPlayer.setVolume(channelNum: channel, volume: 0)
        }
        MPCGDAudioPlayer.setVolume(channelNum: channelNum, volume: 1)
    }
    
    static func loadAndPlayAudio(trackName: String, channelNum: Int, volume: Float, rate: Float){
        // channelNum will be between 0 and 4
        
        // This will quickly fade out the existing track in this channel if there
        // is one, and then fade in the new track
        
        // This starts the track from the beginning
        // This channel must be played on a loop
        
        print("Playing \(trackName) in channel \(channelNum) at rate \(rate)")
        do {
            let i = channelNum-1
            MPCGDAudio.setStreamVolume(index: i, to: 0.0, duration: 0.2, completion: {
                MPCGDAudio.playStream(index: i, path: trackName, volume: 0.0, rate: rate)
                MPCGDAudio.setStreamVolume(index: i, to: volume, duration: 0.2)
            })
        }
    }
    
    static func setVolume(channelNum: Int, volume: CGFloat){
        
        // volume will be between 0 and 1, with 0 turning off the audio in this channel entirely
        // the audio in the channel should fade (in/out) quickly to the new volume
        
        print("Changing channel \(channelNum) volume to \(volume)")
        do {
            let i = channelNum-1
            MPCGDAudio.setStreamVolume(index: i, to: Float(volume), duration: 0.2)
        }
    }
    
    static func setTempo(channelNum: Int, tempo: CGFloat){
        
        // tempo will be between 0.2 and 5
        
        print("Changing channel \(channelNum) tempo to \(tempo)")
        do {
            let i = channelNum-1
            MPCGDAudio.streams[i].rate = Float(tempo)
        }
    }
    
    static func setAppAudioVolume(volume: CGFloat){

        // volume will be between 0 and 1, with 0 turning off the audio in the app entirely
        // the app audio should fade (in/out) quickly to the new volume
        
        print("Changing overall app volume to \(volume)")
        for i in 0..<MPCGDAudio.maxStreams {
            MPCGDAudio.setStreamVolume(index: i, to: 0.0, duration: 0.2)
        }
    }
    
    static func setAppAudioTempo(tempo: CGFloat){
        
        // this sets the same tempo for all the channels
        // tempo will be between 0.1 and 5 (TBD)
        
        print("Changing audio tempo to \(tempo)")
        for i in 0..<MPCGDAudio.maxStreams {
            MPCGDAudio.streams[i].rate = Float(tempo)
        }
    }
    
    static func setSoundEffectsVolume(volume: CGFloat){
        // this should be done immediately with no fading
        MPCGDAudio.masterSoundVolume = Float(volume)
    }
    
    static func loadAndPlaySoundEffect(effectName: String){
        // This should play the sound effect, not on a loop
        print("PLAYING: \(effectName)")
        MPCGDAudio.playSound(path: effectName)
    }
}
