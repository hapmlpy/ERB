//
//  MapVC+UserInteraction.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/1/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox

extension MapViewController{
  
  func handleTap(_ gesture: UITapGestureRecognizer){
    if willCreatMarker {
      let spot = gesture.location(in: mapView)
      let spotCoordinate = mapView.convert(spot, toCoordinateFrom: mapView)
 
      let node = Node(id: nodeID, location: spotCoordinate)
      markers(nodeType: activeType, node: node) 
      nodeID = nodeID + 1
      
      willCreatMarker = false
    }
    
  }
  
  func activeBase(sender: AnyObject){
    activeType = .base
    willCreatMarker = true
  }
  func activeInfrastructure(sender: AnyObject){
    activeType = .infrastructure
    willCreatMarker = true
  }
 
  
  // fro return button
  func backToBehaviorVC(sender: Any){
//    if let delegate = self.transitioningDelegate as? TransitionDelegate{
//      delegate.interactiveDismiss = false
//    }
//    //使用代理通知上一页本页状态变化
//    if registerTaskFinished == true {
//      mapvcDelegate?.registerFinished(isFinished: registerTaskFinished)
//    }
//    dismiss(animated: true, completion: nil)
  }
  
}
