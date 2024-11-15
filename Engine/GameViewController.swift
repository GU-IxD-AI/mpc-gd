//
//  GameViewController.swift
//  Engine
//
//  Created by Simon Colton on 09/10/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import SpriteKit
import SpriteKit

class GameViewController: UIViewController {
    
    static var user : User = User(userID: "None", userName: "Human")
    
    var scene: MainScene! = nil

    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        let skView = self.view as! SKView
        if skView.scene == nil {
            DispatchQueue.main.async {
                self.setUser()
                self.scene = MainScene()
                self.scene.viewController = self
                self.scene.scaleMode = .aspectFill
                skView.presentScene(self.scene)}
        }
    }
    
    override var shouldAutorotate : Bool {
    if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
        UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
        UIDevice.current.orientation == UIDeviceOrientation.unknown) {
        return false
    }
    else {
        return true
    }
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return [.portrait ,.portraitUpsideDown]
        case .pad:
            return [.portrait ,.portraitUpsideDown]
        default:
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    /**
     Either retrieves the user from the database or asks the user to enter a new username
     */
    func setUser() {
        
        if let tempUser = UserHandler.retrieveUser() {
            GameViewController.user = tempUser
            UserHandler.retrieveTutorialStatus(tempUser.userID)
        } else {
            let tempUser = User(userID: UUID().uuidString, userName: "H-\(self.generateNameSuffix())")
            GameViewController.user = tempUser
            UserHandler.saveUser(tempUser)
                
        }
        UserHandler.retrievePresetStatus(GameViewController.user.userID)
    }
    
    static func getReferenceDate() -> Date {
        
        let dateAsString = "01-01-1970 00:01"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let newDate = formatter.date(from: dateAsString)
        
        return newDate!
    }
    
    func generateNameSuffix() -> String{
        let time : Double = Date().timeIntervalSince(GameViewController.getReferenceDate())
        let lTime : Int64 = Int64(time * 10)
        
        //let hex = String(format: "%X",lTime)
        let alpha = GameViewController.intToBase62String(lTime)
        
        return alpha
    }
    
    static let alpha09AZaz : [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    
    static func intToBase62String(_ number : Int64) -> String {
        var result = ""
        var num = number
        if number == 0 {
            return "0"
        }
        
        while (num > 0) {
            let remainder  = num % 62
            let remainderChar = alpha09AZaz[Int(remainder)]
            result = String(remainderChar) + result
            num = (num - remainder) / 62;
        }
        return result;
        
    }
    
//    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
//        if(event!.subtype == UIEventSubtype.MotionShake) {
//            scene.handleShake()
//        }
//    }
}
