//
//  Queue.swift
//  Beeee
//
//  Created by Powley, Edward on 07/09/2015.
//  Copyright (c) 2018 ThoseMetamakers. All rights reserved.
//

import Foundation

private class QueueNode<T> {
    let element : T
    var next : QueueNode<T>? = nil
    
    init(element : T) {
        self.element = element
    }
}

class Queue<T> {
    fileprivate var head : QueueNode<T>? = nil
    fileprivate var tail : QueueNode<T>? = nil
    fileprivate(set) var count : Int = 0
    
    func isEmpty() -> Bool {
        return head == nil
    }
    
    func getCount() -> Int {
        return count
    }
    
    func enqueue(_ element: T) {
        let newNode = QueueNode(element: element)
        
        if isEmpty() {
            head = newNode
            tail = newNode
        }
        else {
            tail!.next = newNode
            tail = newNode
        }
        
        count += 1
    }
    
    func dequeue() -> T? {
        if isEmpty() {
            return nil
        }
        else {
            let result = head!.element
            
            head = head!.next
            
            if head == nil {
                tail = nil
            }
            
            count -= 1
            
            return result
        }
    }
    
    func peek() -> T? {
        if isEmpty() {
            return nil
        }
        else {
            return head!.element
        }
    }
    
}
