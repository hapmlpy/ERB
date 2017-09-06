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
