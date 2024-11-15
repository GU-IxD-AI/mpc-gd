//
//  ThreadUtils.swift
//  Engine
//
//  Created by Simon Colton on 12/10/2015.
//  Copyright © 2018 ThoseMetamakers. All rights reserved.
//
#if false
import Foundation

class ThreadUtils{
    
    static func runInHighPriorityThread(_ codeBlock: @escaping () -> ()){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: codeBlock)
    }
    
    static func runInMainThread(_ codeBlock: @escaping () -> ()){
        DispatchQueue.main.async(execute: codeBlock)
    }
    
}
#endif
