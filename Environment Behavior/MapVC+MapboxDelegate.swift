//
//  MapVC+MapboxDelegate.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/1/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox

extension MapViewController: MGLMapViewDelegate {
  
  func mapView(_ mapView:MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool{
    return true
  }
  func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
    return StyleCalloutView(representedObject: annotation)
  }
  
  func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    let queue = DispatchQueue.global()
    queue.async {
      self.addLayer(to:style)
      let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
      //见文档https://www.mapbox.com/ios-sdk/api/3.6.0/Classes/MGLMapView.html
      for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
        gesture.require(toFail: recognizer)
      }
      mapView.addGestureRecognizer(gesture)
    }
    
  }
  
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
    guard annotation is MGLPointAnnotation else {
      return nil
    }
    
    let nodeAnnotation = annotation as? NodeAnnotioan
    if nodeAnnotation?.willUseImage == false {
      return nil
    }
    let imagePick = UIImage(named: (nodeAnnotation?.imageName)!)
    
    let reuseIdentifier = nodeAnnotation?.reuseIdentifier
    if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier!) {
      return annotationImage
    }else{
      //把annotation这层移到style最上面去
      let symbolSource = MGLShapeSource(identifier: "annotation")
      var symbolLayer = MGLSymbolStyleLayer(identifier: "annotation", source: symbolSource)
      let layers = mapView.style?.layers
      for layer in layers!{
        if type(of: layer).description() == "MGLSymbolStyleLayer" {
          symbolLayer = layer as! MGLSymbolStyleLayer
          mapView.style?.removeLayer(layer)
        }
      }
      mapView.style?.addLayer(symbolLayer)
      //print(symbolLayer)
      
      return MGLAnnotationImage(image: imagePick!, reuseIdentifier: reuseIdentifier!)
      
    }
  }
  
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    //使用自定义的annotation class
    guard annotation is MGLPointAnnotation else {
      return nil
    }
    let nodeAnnotation = annotation as? NodeAnnotioan
    if nodeAnnotation?.willUseImage == true{
      return nil
    }
    var image = UIImage()
    if nodeAnnotation?.nodeType == .base{
      image = UIImage(named: "baseM")!
    }else{
      image = UIImage(named: "binM")!
    }
    
    let reuseIdentifier = nodeAnnotation?.reuseIdentifier
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier!)
    if annotationView == nil {
      
      let level = Double((nodeAnnotation?.level)!)
      let color = colorFitLevel(level: level)
      
      //设置view
      annotationView = StyleAnnotationView(reuseIdentifier: reuseIdentifier!, size:10, image: image,color:color)
    }
    return annotationView
  }
  
  func mapView(_ mapView: MGLMapView, didAdd annotationViews: [MGLAnnotationView]) {
    //print("didAdd: time\(tempC), there are \(annotationViews.count) annotationView")
  }
  
  func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
    //print("didSelect annotationView ")
  }
  
  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
  }
}


