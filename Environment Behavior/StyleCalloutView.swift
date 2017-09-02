//
//  StyleCalloutView.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/2/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Mapbox
import Stellar

class StyleCalloutView: UIView, MGLCalloutView {
  var representedObject: MGLAnnotation
  
  var viewInside: UIView!
  let rectG = CGRect(x: 0, y: 0, width: 50, height: 50)
  let tipHeight: CGFloat = 5.0
  let tipWidth: CGFloat = 5.0
  
  // Allow the callout to remain open during panning.
  let dismissesAutomatically: Bool = false
  let isAnchoredToAnnotation: Bool = true

  override var center: CGPoint {
    set {
      var newCenter = newValue
      newCenter.y = newCenter.y - bounds.midY
      super.center = newCenter
    }
    get {
      return super.center
    }
  }
  
  lazy var leftAccessoryView = UIView() /* unused */
  lazy var rightAccessoryView = UIView() /* unused */
  
  weak var delegate: MGLCalloutViewDelegate?
  
  required init(representedObject: MGLAnnotation) {
    self.representedObject = representedObject
    super.init(frame: .zero)
    backgroundColor = .clear
    
    self.viewInside = UIView(frame: .zero)
    viewInside.backgroundColor = UIColor.white
    addSubview(viewInside)

  }
  
  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - MGLCalloutView API
  func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedView: UIView, animated: Bool) {
    if !representedObject.responds(to: #selector(getter: MGLAnnotation.title)) {
      return
    }
    view.addSubview(self)
    
    viewInside.frame = rectG
    viewInside.layer.cornerRadius = rectG.size.width/2
    
    
    // Prepare our frame, adding extra space at the bottom for the tip
    let frameWidth = viewInside.bounds.size.width
    let frameHeight = viewInside.bounds.size.height + tipHeight
    let frameOriginX = rect.origin.x + (rect.size.width/2.0) - (frameWidth/2.0)
    let frameOriginY = rect.origin.y - frameHeight
    let showRect = CGRect(x: frameOriginX, y: frameOriginY, width: frameWidth, height: frameHeight)
    frame = showRect
    
//
//    
//    if animated {
//      frame = CGRect(x: showRect.midX, y: showRect.maxY, width: 0, height: 0)
//      viewInside.frame = CGRect(x: rect.midX, y: rect.maxY, width: 0, height: 0)
//      viewInside.layer.cornerRadius = rectG.size.width/2
//      let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut)
//      animator.addAnimations { [weak self] in
//        self?.alpha = 1
//        self?.frame = showRect
//        self?.viewInside.frame = rect
//      }
//      animator.startAnimation()
//    }else{
//      frame = showRect
//    }
    
    
  }
  
  func dismissCallout(animated: Bool) {
//    let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut)
//    animator.addAnimations {
//      self.frame = CGRect.zero
//      self.alpha = 0
//    }
//    animator.startAnimation()
    self.removeFromSuperview()
  }
  
  // MARK: - Callout interaction handlers
/*
  func isCalloutTappable() -> Bool {
    if let delegate = delegate {
      if delegate.responds(to: #selector(MGLCalloutViewDelegate.calloutViewShouldHighlight)) {
        return delegate.calloutViewShouldHighlight!(self)
      }
    }
    return false
  }
  
  func calloutTapped() {
    if isCalloutTappable() && delegate!.responds(to: #selector(MGLCalloutViewDelegate.calloutViewTapped)) {
      delegate!.calloutViewTapped!(self)
    }
  }
*/
  // MARK: - Custom view styling
  
  override func draw(_ rect: CGRect) {
    // Draw the pointed tip at the bottom
    let fillColor : UIColor = .white
    
    let tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0)
    let tipBottom = CGPoint(x: rect.origin.x + (rect.size.width / 2.0), y: rect.origin.y + rect.size.height)
    let heightWithoutTip = rect.size.height - tipHeight - 1
    
    let currentContext = UIGraphicsGetCurrentContext()!
    
    let tipPath = CGMutablePath()
    tipPath.move(to: CGPoint(x: tipLeft, y: heightWithoutTip))
    tipPath.addLine(to: CGPoint(x: tipBottom.x, y: tipBottom.y))
    tipPath.addLine(to: CGPoint(x: tipLeft + tipWidth, y: heightWithoutTip))
    tipPath.closeSubpath()
    
    fillColor.setFill()
    currentContext.addPath(tipPath)
    currentContext.fillPath()
  }

}
