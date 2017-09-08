//
//  popView.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/5/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import MapboxStatic

class PopView: UIView {
  
  var containerView: UIView!
  var roundView: UIView!
  var shadowView: UIView!
  
  var barndView:UIView!
  var barView:UIView!
  var detailBtn: UIButton!

  override init(frame: CGRect) {
    super.init(frame: frame)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup(frame: CGRect){
    
    containerView = UIView(frame: frame)
    
    let rect = containerView.bounds
    containerView.backgroundColor = UIColor.clear
    
    shadowView = createShadowView(rect: rect)
    roundView = createRoundView(rect: rect)
    
    containerView.addSubview(shadowView)
    containerView.addSubview(roundView)
    self.addSubview(containerView)
    
    addDetailBrandView(superView: roundView)
    addDetailBarView(superView: roundView)
    addDetailBtn(superView: roundView)
  }
  
  func createShadowView(rect: CGRect) -> UIView {
    let shadowview = UIView(frame: rect)
    let size = CGSize(width: 8.0, height: 8.0)
    let mp = UIBezierPath(roundedRect: rect,
                          byRoundingCorners: [.topLeft,.topRight,.bottomLeft,.bottomRight],
                          cornerRadii: size)
    
    //add shadow
    shadowview.layer.masksToBounds = false
    shadowview.layer.shadowPath = mp.cgPath
    shadowview.layer.shadowColor = UIColor.black.cgColor
    shadowview.layer.shadowRadius = 20//blur
    shadowview.layer.shadowOpacity = 0.8
    shadowview.layer.shadowOffset = CGSize(width: 0, height: 0)
    return shadowview
  }
  
  func createRoundView(rect: CGRect) -> UIView {
    let roundview = UIView(frame: rect)
    let size = CGSize(width: 8.0, height: 8.0)
    let mp = UIBezierPath(roundedRect: rect,
                          byRoundingCorners: [.topLeft,.topRight,.bottomLeft,.bottomRight],
                          cornerRadii: size)
    let mask = CAShapeLayer()
    mask.frame = rect
    mask.path = mp.cgPath
    roundview.layer.mask = mask
    roundview.backgroundColor = UIColor.clear
    roundview.clipsToBounds = true
    return roundView
  }

  func addDetailBrandView(superView: UIView){
    let gRect = superView.bounds
    let height = gRect.height*0.6
    let rect = CGRect(x: 0, y: 0, width: gRect.width, height: height)
    let imageView = UIImageView(frame: rect)
    imageView.heroID = "brand"
    superView.addSubview(imageView)
    imageView.clipsToBounds = true
  }
  func addDetailBarView(superView: UIView){
    let gRect = superView.bounds
    let height = gRect.height*0.2
    let y = superView.frame.height*0.6
    let rect = CGRect(x: 0, y: y, width: gRect.width, height: height)
    barView = UIView(frame: rect)
    barView.backgroundColor = pro.color2
    superView.addSubview(barView)
    barView.clipsToBounds = true
  }
  func addDetailBtn(superView: UIView){
    let gRect = superView.bounds
    let y = gRect.height*0.8
    let height = superView.frame.height*0.2
    let rect = CGRect(x: 0, y: y, width: gRect.width, height: height)
    detailBtn = UIButton(frame: rect)
    detailBtn.backgroundColor = pro.color3
    superView.addSubview(detailBtn)
    detailBtn.clipsToBounds = true
    
    detailBtn.addTarget(self, action: #selector(toBinInfromationVC(_:)), for: .touchUpInside)
    
  }
  
  func toBinInfromationVC(_ sender: AnyObject){
    let binInfroVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "binInfroVC") as? BinInfromationViewController
    hero_replaceViewController(with: binInfroVC!)
    
  }


}
