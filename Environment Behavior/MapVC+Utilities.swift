//
//  MapVC+Utilities.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/1/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox

extension MapViewController {
  func modulateMapping(oldValue: Double, oldMin: Double, oldMax: Double, newMin: Double, newMax: Double ) -> Double {
    let oldRange = oldMax-oldMin
    if oldRange == 0 {
      return 0
    }else{
      let newRange = newMax-newMin
      return (((oldValue - oldMin) * newRange) / oldRange) + newMin
    }
  }
  func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}

extension MGLSymbolStyleLayer {
  
  func className() -> String {
    return("SymbolLayer")
  }
}
