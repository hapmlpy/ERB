//
//  Array+RemovObject.swift
//  streetClean
//
//  Created by JIAN LI on 8/9/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
