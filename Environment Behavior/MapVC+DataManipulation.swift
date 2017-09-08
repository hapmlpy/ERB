//
//  MapVC+DataManipulation.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/8/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox

extension MapViewController{
  
  func saveCurrentMapRegion(){
    let coordBounds = mapView.visibleCoordinateBounds
    dataModel.currentRegion = coordBounds
    print("save map current region:\n \(coordBounds) into data model")

  }
  
}
