//
//  UIAlertController.swift
//  Engine
//
//  Created by Powley, Edward on 09/03/2016.
//  Copyright © 2016 Simon Colton. All rights reserved.
//

import Foundation
import AppKit

class UIAlertController {
    enum Style { case Alert }
    
    let alert : NSAlert
    var actions : [UIAlertAction] = []
    private var textField : NSTextField? = nil
    
    var textFields : [NSTextField]? {
        if textField != nil {
            return [textField!]
        }
        else {
            return nil
        }
    }
    
    init(title: String, message: String?, preferredStyle: Style) {
        alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message ?? ""
    }
    
    var message : String! {
        get { return alert.informativeText }
        set { alert.informativeText = newValue ?? "" }
    }
    
    func addAction(action: UIAlertAction) {
        actions.append(action)
        alert.addButtonWithTitle(action.title)
    }
    
    func setValue(value: Any, forKey: String) {
        switch (forKey) {
        case "attributedMessage":
            alert.informativeText = (value as! NSAttributedString).string
            
        default:
            assertionFailure("Invalid key \(forKey)")
        }
    }
    
    class TextConfig {
        var text : String? = nil
        var placeholder : String? = nil
    }
    
    func addTextFieldWithConfigurationHandler(handler: inout TextConfig -> ()) {
        var config = TextConfig()
        handler(&config)
        
        textField = NSTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 24))
        textField!.stringValue = config.text ?? ""
        textField!.placeholderString = config.placeholder
        alert.accessoryView = textField
    }
    
    func showModal() {
        let response = alert.runModal()
        let actionIndex = response - NSAlertFirstButtonReturn
        if let action = actions.getOrNil(actionIndex) {
            if action.handler != nil {
                action.handler!(action)
            }
        }
    }
}

class UIAlertAction {
    enum Style { case Default, Cancel }
    let title: String
    let style: Style
    let handler: (UIAlertAction -> ())?
    
    init(title: String, style: Style, handler: (UIAlertAction -> ())?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension NSTextField {
    var text : String { return self.stringValue }
}