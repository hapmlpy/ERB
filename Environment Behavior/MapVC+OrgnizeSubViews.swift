//
//  MapVC+OrgnizeSubViews.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/1/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox
import AMPopTip

extension MapViewController{
  
  //MARK: - Manage Map View
  func initMapView(){
    mapView.delegate = self
    mapView.zoomLevel = 14
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .follow
    
    initMapViewElements()
  }
  
  func initMapViewElements(){
    addGameIcon()
    addReturnIcon()
  }
  
  // MARK: - Set Game Icons
  func addGameIcon(){
    baseButton = UIButton(frame: CGRect.zero)
    setGameIconAppearance(icon: baseButton,iconType: .base)
    baseButton.frame = setGameIconPosition(icon: baseButton, index: 0)
    setGameIconFunction(icon: baseButton,iconType: .base)
    mapView.addSubview(baseButton)
    
    infraButton = UIButton(frame: CGRect.zero)
    setGameIconAppearance(icon: infraButton,iconType: .infrastructure)
    infraButton.frame = setGameIconPosition(icon: infraButton, index: 1)
    setGameIconFunction(icon: infraButton, iconType: .infrastructure)
    mapView.addSubview(infraButton)
    
  }
  func setGameIconAppearance(icon:UIButton,iconType: NodeType){
    let properity = MapVCProperties()
    icon.backgroundColor = .clear
    icon.layer.cornerRadius = properity.iconSzie/4
    icon.layer.borderWidth = properity.iconborderWidth
    icon.layer.borderColor = properity.closeToWhite.cgColor
    icon.layer.backgroundColor = properity.gray.cgColor
    
    
    if iconType == .base {
//      let image = UIImage(named: "base") as UIImage?
//      icon.setImage(image, for: .normal)
    }
    if iconType == .infrastructure {
//      let image = UIImage(named: "infrastructure") as UIImage?
//      icon.setImage(image, for: .normal)
    }
  }
  
  func setGameIconFunction(icon:UIButton,iconType: NodeType){
    if iconType == .base {
      icon.addTarget(self, action: #selector(activeBase), for: .touchUpInside)
    }
    if iconType == .infrastructure {
      icon.addTarget(self, action: #selector(activeInfrastructure), for: .touchUpInside)
    }
  }
  
  func setGameIconPosition(icon: UIButton,index: Int) -> CGRect{
    let properity = MapVCProperties()
    let x = properity.widthBig - (properity.iconSzie+properity.itemsTraniling)
    let y = properity.gameIconInitY
    let size = properity.iconSzie
    let yIncreament = y!+(properity.iconSzie+properity.gameIconGap)*CGFloat(index)
    let rect = CGRect(x: x, y: yIncreament, width: size, height: size)
    return rect
  }
  
  // MARK: - Set Funtion Icons
  func addReturnIcon(){
    returnButton = UIButton(frame: CGRect.zero)
    
    let properity = MapVCProperties()
    returnButton.backgroundColor = .clear
    returnButton.layer.cornerRadius = properity.iconSzie/4
    returnButton.layer.borderWidth = 1
    returnButton.layer.borderColor = properity.closeToWhite.cgColor
    returnButton.layer.backgroundColor = properity.gray.cgColor
    
    let x = properity.itemsLeading
    let y = properity.itemstop
    let size = properity.iconSzie
    
    let rect = CGRect(x: x, y: y, width: size, height: size)
    returnButton.frame = rect
    
    returnButton.addTarget(self, action: #selector(backToBehaviorVC), for: .touchUpInside)
    mapView.addSubview(returnButton)
  }
}
