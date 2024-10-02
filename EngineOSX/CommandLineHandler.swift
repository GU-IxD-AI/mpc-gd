//
//  CommandLineHandler.swift
//  Engine
//
//  Created by Powley, Edward on 14/04/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import Cocoa

class CommandLineHandler {
    static var hasStarted = false
    static var quitAfterOneGame = false
    
    static func onStartup(scene: MainScene) {
        if !hasStarted {
            hasStarted = true
            
            // Disable stdout buffering
            setbuf(__stdoutp, nil)
            
            var argIndex = 1
            while argIndex < Process.arguments.count {
                let arg = Process.arguments[argIndex]
                switch arg {
                case "-windowPos":
                    argIndex += 1; let x = CGFloat((Process.arguments[argIndex] as NSString).floatValue)
                    argIndex += 1; let y = CGFloat((Process.arguments[argIndex] as NSString).floatValue)
                    argIndex += 1; let w = CGFloat((Process.arguments[argIndex] as NSString).floatValue)
                    argIndex += 1; let h = CGFloat((Process.arguments[argIndex] as NSString).floatValue)
                    
                    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDel.window.setFrame(CGRect(x: x, y: y, width: w, height: h), display: true, animate: false)
                    
                case "-borderless":
                    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDel.window.styleMask = NSBorderlessWindowMask
                    
                case "-bringToFront":
                    UIApplication.sharedApplication().activateIgnoringOtherApps(true)
                    
                case "-showDebugStats":
                    scene.view!.showsFPS = true
                    scene.view!.showsDrawCount = true
                    scene.view!.showsNodeCount = true
                    scene.view!.showsQuadCount = true
                    
                case "-loadBaseCamp":
                    argIndex += 1
                    let basecampName = Process.arguments[argIndex]
                    FascinatorLoader.loadBaseCampFascinator(basecampName, baseCampType: .Base, designerInterface: scene.designerInterface, scene: scene)
                    
                case "-quitAfterOneGame":
                    quitAfterOneGame = true
                    
                default:
                    print("Unknown argument '\(arg)'")
                }
                
                argIndex += 1
            }
        }
    }
    
    static func onGameEnd() {
        if quitAfterOneGame {
            exit(0)
        }
    }
}
