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
import Hero
import MapboxStatic

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
    addGradientMask()
    addGameIcon()
    addReturnIcon()
  }
  func annotationFitScreen(coordinate: CLLocationCoordinate2D, completionHandeler: (() -> Void)?){
    let camera = MGLMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 1000)
    mapView.fly(to: camera, withDuration: 0.5, completionHandler: completionHandeler)
  }
  
  func takeMapSnapShot(coordinate: CLLocationCoordinate2D) -> (UIView){
    //https://github.com/mapbox/MapboxStatic.swift
    let styleURL = URL(string: "mapbox://styles/hapmlpy/cj5410a8n0uk92spb2hufzx7k")
    let myToken = "pk.eyJ1IjoiaGFwbWxweSIsImEiOiJjajR0NXFzM2wwNHBjMzJvOHJvd2h2bHVlIn0.6H3rU6CtFzIS9TwuBNtIyQ"
    let camera = SnapshotCamera(lookingAtCenter: coordinate, fromDistance: 1000, pitch: 0.0, heading: 0.0)
    let bounds = self.mapView.bounds
    let size = bounds.size
    let options = SnapshotOptions(styleURL: styleURL!, camera: camera, size: size)
    let snapImage = Snapshot(options: options, accessToken: myToken)
    let snapshot = UIImageView(frame: bounds)
    snapshot.image = snapImage.image
    
    //偏移图片，保证在pop view的中间
    let offsetx = -pro.detailViewRect.minX
    let offsety = -pro.detailViewRect.minY
    let snapFrame = CGRect(x: offsetx, y: offsety, width: pro.widthBig, height: pro.heightBig)
    snapshot.frame = snapFrame
    snapshot.tag = 112
    return snapshot
  }
  
  func takeMapSnapShot() -> UIView {
    mapPrepareForShot(isShot: true)
    let snapshot = mapView.snapshotView(afterScreenUpdates: true)
    snapshot?.isUserInteractionEnabled = false
    
    //此时把虚化背景做了
    addBlurOverlay(mapShot: snapshot!)
    
    //偏移图片，保证在pop view的中间
    let offsetx = -pro.detailViewRect.minX
    let offsety = -pro.detailViewRect.minY
    let snapFrame = CGRect(x: offsetx, y: offsety, width: pro.widthBig, height: pro.heightBig)
    snapshot?.frame = snapFrame
    
    mapPrepareForShot(isShot: false)
    return snapshot!
  }
  
  func mapPrepareForShot(isShot: Bool){
    if isShot == true {
      baseButton.alpha = 0
      infraButton.alpha = 0
      returnButton.alpha = 0
    }else{
      baseButton.alpha = 1
      infraButton.alpha = 1
      returnButton.alpha = 1
    }
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
    icon.backgroundColor = .clear
    icon.layer.cornerRadius = pro.iconSzie/4
    icon.layer.borderWidth = pro.iconborderWidth
    icon.layer.borderColor = pro.closeToWhite.cgColor
    icon.layer.backgroundColor = pro.gray.cgColor
    
    
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
  
  // MARK: - Effective View
  func addGradientMask(){
    let mask = UIColor(red: 34.0/255.0, green: 35.0/255.0, blue: 44.0/255.0, alpha: 1.0).cgColor
    let clear = UIColor.clear.cgColor
    let gradient = CAGradientLayer()
    gradient.frame = mapView.superview?.bounds ?? CGRect.null
    gradient.colors = [mask, mask, clear, clear]
    gradient.locations = [0.0, 0.06, 0.3, 1.0]
    
    let maskView: UIView = UIView(frame: view.bounds)
    maskView.layer.addSublayer(gradient)
    
    maskView.isUserInteractionEnabled = false
    mapView.addSubview(maskView)
  }
  
  // MARK: - Annotation Detail and Transition Aniamtion with HERO
  func showBinDetailViewAndTransitToBinVC(coordinate: CLLocationCoordinate2D){
    mapView.isUserInteractionEnabled = false

    //最底层的view
    binDetailView = UIView(frame: pro.detailViewRect)
    //bindetailview dissmiss action
    binDetailView.tag = 100
    let rect = binDetailView.bounds
    binDetailView.backgroundColor = UIColor.clear
   
    //特效view(倒角、投影）
    let shadowView = createShadowView(rect: rect)
    let roundView = createRoundView(rect: rect)
   
    binDetailView.addSubview(shadowView)
    binDetailView.addSubview(roundView)
    view.addSubview(binDetailView)
    
    //垃圾箱信息界面显示动画
    detailViewShow(mView: binDetailView)
    
    //获得地图截图,添加虚化效果()
    let mapSnap = takeMapSnapShot()
    
    
    //制作垃圾箱界面的各个view元素
    addBrandView(superView: roundView, snapMap: mapSnap)
    addBarView(superView: roundView)
    addDetailBtn(superView: roundView)
  }
  
  //create blur view
  func addBlur(){
    mapPrepareForShot(isShot: true)
    let rect = CGRect(x: 0, y: 0, width: pro.widthBig, height: pro.heightBig)
    
    //create snap shot for mapview
    UIGraphicsBeginImageContextWithOptions(rect.size, true, 1)
    mapView.drawHierarchy(in: rect, afterScreenUpdates: true)
    let mapShot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    //create effect
    let beginImage = CIImage(image: mapShot!)
    let filter = CIFilter(name: "CIGaussianBlur")
    filter?.setValue(beginImage, forKey: kCIInputImageKey)
    filter?.setValue(10, forKey: kCIInputRadiusKey)
    
    let cropFilter = CIFilter(name: "CICrop")
    cropFilter?.setValue(filter?.outputImage, forKey: kCIInputImageKey)
    cropFilter?.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
    
    let vignette = CIFilter(name: "CIVignette")
    vignette?.setValue(cropFilter?.outputImage, forKey: kCIInputImageKey)
    vignette?.setValue(0.3, forKey: kCIInputIntensityKey)
    vignette?.setValue(30, forKey: kCIInputRadiusKey)
    
    // set up cicontext, use it to draw cgimage
    let outputImage = vignette!.outputImage
    let context = CIContext(options: nil)
    let cgimg = context.createCGImage(outputImage!, from: (outputImage?.extent)!)
    
    // get uiimage from cgimage
    let blurImage = UIImage(cgImage: cgimg!)
    
    let blurView = UIImageView(image: blurImage)
    blurView.frame = view.bounds
    blurView.tag = 60
    view.insertSubview(blurView, aboveSubview: mapView)
  }
  
  func addBlurOverlay(mapShot: UIView){
    mapPrepareForShot(isShot: true)
    // Blur Effect
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.bounds
    
    // Vibrancy Effect
    let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
    let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
    vibrancyEffectView.frame = view.bounds
    vibrancyEffectView.contentView.addSubview(mapShot)
    // Add the vibrancy view to the blur view
    blurEffectView.contentView.addSubview(vibrancyEffectView)
    
    blurEffectView.isUserInteractionEnabled = false
    blurEffectView.tag = 60
    view.insertSubview(blurEffectView, aboveSubview: mapView)
  }
  
  func detailViewShow(mView: UIView){
    //mView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    mView.alpha = 0
    let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut)
    animator.addAnimations {
      mView.transform = CGAffineTransform.identity
      mView.alpha = 1
    }
    animator.startAnimation(afterDelay: 0)
  }
  
  func createShadowView(rect: CGRect) -> UIView {
    let shadowView = UIView(frame: rect)
    let size = CGSize(width: 8.0, height: 8.0)
    let mp = UIBezierPath(roundedRect: rect,
                          byRoundingCorners: [.topLeft,.topRight,.bottomLeft,.bottomRight],
                          cornerRadii: size)
    
    //add shadow
    shadowView.layer.masksToBounds = false
    shadowView.layer.shadowPath = mp.cgPath
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowRadius = 20//blur
    shadowView.layer.shadowOpacity = 0.8
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
    return shadowView
  }
  
  func createRoundView(rect: CGRect) -> UIView {
    let roundView = UIView(frame: rect)
    let size = CGSize(width: 8.0, height: 8.0)
    let mp = UIBezierPath(roundedRect: rect,
                          byRoundingCorners: [.topLeft,.topRight,.bottomLeft,.bottomRight],
                          cornerRadii: size)
    let mask = CAShapeLayer()
    mask.frame = rect
    mask.path = mp.cgPath
    roundView.layer.mask = mask
    roundView.backgroundColor = UIColor.clear
    roundView.clipsToBounds = true
    return roundView
  }
  func addBrandView(superView: UIView, snapMap: UIView){
    let gRect = superView.bounds
    let height = gRect.height*0.6
    let rect = CGRect(x: 0, y: 0, width: gRect.width, height: height)
    let brandView = UIView(frame: rect)
    brandView.addSubview(snapMap)
    brandView.tag = 110

    //set properties for sending to next view
    snapMap.heroID = "profile"
    snapMap.tag = 111
    
    brandView.heroID = "brand"
    superView.addSubview(brandView)
    brandView.clipsToBounds = true
  }
  
  func addBarView(superView: UIView){
    let gRect = superView.bounds
    let height = gRect.height*0.2
    let y = superView.frame.height*0.6
    let rect = CGRect(x: 0, y: y, width: gRect.width, height: height)
    let barView = UIView(frame: rect)
    barView.backgroundColor = pro.color2
    barView.heroID = "bar"
    superView.addSubview(barView)
    barView.clipsToBounds = true
  }
  func addDetailBtn(superView: UIView){
    let gRect = superView.bounds
    let y = gRect.height*0.8
    let height = superView.frame.height*0.2
    let rect = CGRect(x: 0, y: y, width: gRect.width, height: height)
    let detailBtn = UIButton(frame: rect)
    detailBtn.backgroundColor = pro.color3
    superView.addSubview(detailBtn)
    detailBtn.clipsToBounds = true
    
    detailBtn.addTarget(self, action: #selector(toBinInfromationVC(_:)), for: .touchUpInside)
    
  }
  
  func toBinInfromationVC(_ sender: AnyObject){
    if let binInfroVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "binInfroVC") as? BinInfromationViewController{
      binInfroVC.heroModalAnimationType = .cover(direction: .up)
      hero_replaceViewController(with: binInfroVC)
    }
    //dismiss detailView
    if let roundview = sender.superview{
      if let detailview = roundview?.superview{
        dismissDetailView(rootView: detailview)
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first{
      if let v = touch.view{
        if v.tag != 100{
          if let dv = touch.view?.viewWithTag(100){
            dismissDetailView(rootView: dv)
          }
        }
      }
    }
    let blurView = view.viewWithTag(60)
    blurView?.removeFromSuperview()
    
    mapPrepareForShot(isShot: false)
    mapView.isUserInteractionEnabled = true
  }
  //dismiss detail View
  func dismissDetailView(rootView: UIView){
    //dismiss animation
    let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut)
    animator.addAnimations {
      rootView.alpha = 0
    }
    animator.startAnimation(afterDelay: 0)
    
    for subv in rootView.subviews {
      subv.removeFromSuperview()
    }
    rootView.removeFromSuperview()
  }
}
