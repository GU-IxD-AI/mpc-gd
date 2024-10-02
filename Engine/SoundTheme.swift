//
//  SoundTheme.swift
//  Engine
//
//  Created by Powley, Edward on 24/06/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//
#if false
import Foundation

class SoundTheme {
    
    let musicFiles : [String]
    let soundFiles : [SoundType : [String]]
    
    init(musicFiles : [String], soundFiles : [SoundType : [String]]) {
        self.musicFiles = musicFiles
        self.soundFiles = soundFiles
    }
    
    fileprivate static func initAll() -> [SoundTheme] {
        var result : [SoundTheme] = []

        /*
        for i in [1, 2, 3, 5] {
            var music : [String] = []
            for j in 0 ... 4 {
                let name : String
                if j == 0 {
                    name = "Track_0\(i)_Base.aac"
                }
                else {
                    name = "Track_0\(i)_Ball_0\(j).aac"
                }
                music.append(name)
            }
            
            var sound : [SoundType : [String]] = [:]
            sound[.BallHit] = ["Ball_Bounce_Pitched_01.wav", "Ball_Bounce_Pitched_02.wav", "Ball_Bounce_Pitched_03.wav", "Ball_Bounce_Pitched_04.wav", "Ball_Bounce_Pitched_05.wav"]
            sound[.BallExplode] = ["Ball_Explosion_Short.aif"]
            
            if i <= 3 {
                sound[.BallLanded] = ["Ball_Land_0\(i).aif"]
                sound[.GameWin] = ["Game_Win_0\(i).aif"]
                sound[.BallStuck] = ["Ball_Stick_0\(i).aif"]
            }
            else {
                sound[.BallLanded] = ["Ball_Land_01.aif"]
                sound[.GameWin] = ["Game_Win_01.aif"]
                sound[.BallStuck] = ["Ball_Stick_01.aif"]
            }
            
            let theme = SoundTheme(musicFiles: music, soundFiles: sound)
            result.append(theme)
        }
         */
        
        // UIImage(named: "Lounge")!, UIImage(named: "Atonal")!, UIImage(named: "Hype")!, UIImage(named: "Lift")!, UIImage(named: "Street")!, UIImage(named: "Dance")!, UIImage(named: "Jingle")!, UIImage(named: "Christmas")!
        
        let theme = SoundTheme(musicFiles: ["sidewalk_shade.aiff", "atonal_in_c.aiff", "professor_umlaut.aiff", "the_lift.aiff", "lobby_time.aiff", "run_amok.aiff", "up_on_a_housetop.aiff", "wish_you_a_merry_xmas.aiff"], soundFiles: [.whiteCluster : ["long_pop_high.aiff"], .blueCluster : ["long_pop_low.aiff"], .blueTap : ["short_pop_low.aiff"], .gameWin : ["tada.aiff"]])

        //        let theme = SoundTheme(musicFiles: ["sidewalk_shade.aiff", "the_lift.aiff", "atonal_in_c.aiff", "lobby_time.aiff", "professor_umlaut.aiff", "run_amok.aiff", "up_on_a_housetop.aiff", "wish_you_a_merry_xmas.aiff"],
        //                       soundFiles: [.WhiteCluster : ["long_pop_high.aiff"], .BlueCluster : ["long_pop_low.aiff"], .BlueTap : ["short_pop_low.aiff"]])
        result.append(theme)
        
        return result
    }
    
    static let all = SoundTheme.initAll()
}
#endif
