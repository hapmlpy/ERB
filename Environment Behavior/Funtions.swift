//
//  Funtions.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/6/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import UIKit

extension CALayer{
  
  func useImageAlpha(alpha: UIImage, alphaScale: CGFloat, color: UIColor, length: CGFloat) {
    let rect = CGRect(x: 0, y: 0, width: length, height: length)
    let markerLayer = CALayer()
    markerLayer.frame = rect
    let radius = length/2
    markerLayer.cornerRadius = radius
    markerLayer.backgroundColor = color.cgColor
    self.insertSublayer(markerLayer, at: 1)
    
    let maskLayer = CALayer()
    let ratio: CGFloat = alphaScale
    let width = length*ratio
    let height = length*ratio
    let mid = markerLayer.bounds.midX - width/2.0
    let rect1 = CGRect(x: mid, y: mid, width: width, height: height)
    maskLayer.frame = rect1
    maskLayer.contents = alpha.cgImage
    markerLayer.addSublayer(maskLayer)
    markerLayer.mask = maskLayer
    markerLayer.masksToBounds = true
  }
  
}

// group function
public extension Sequence {
  func categorise<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
    var dict: [U:[Iterator.Element]] = [:]
    for el in self {
      let key = key(el)
      if case nil = dict[key]?.append(el) { dict[key] = [el] }
    }
    return dict
  }
}
//appen element in dictionary
extension Dictionary {
  mutating func merge(with dictionary: Dictionary) {
    dictionary.forEach { updateValue($1, forKey: $0) }
  }
  
  func merged(with dictionary: Dictionary) -> Dictionary {
    var dict = self
    dict.merge(with: dictionary)
    return dict
  }
}
