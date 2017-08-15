//
//  Stack.swift
//  streetClean
//
//  Created by JIAN LI on 8/10/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation

public class Stack<T> {
    fileprivate var array: [T] = []
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    var count: Int {
        return array.count
    }
    
    public init() {}
    
    public func push(_ element: T) {
        array.append(element)
    }
    
    public func pop() -> T? {
        return array.popLast()
    }
    
    public func peek() -> T? {
        return array.last
    }
}

extension Stack: CustomStringConvertible {
    public var description: String {
        let topDivider = "---Stack---\n"
        let bottomDivider = "\n-----------\n"
        
        let stackElements = array.map { "\($0)" }.reversed().joined(separator: "\n")
        return topDivider + stackElements + bottomDivider
    }
}
