//
//  ViewController.swift
//  Environment Behavior
//
//  Created by JIAN LI on 8/15/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Mapbox
import CoreLocation
import AMPopTip

struct MapVCProperties {
  
  let color1 = UIColor(hue: 66/360, saturation: 72/100, brightness: 90/100, alpha: 1.0)
  let color2 = UIColor(hue: 104/360, saturation: 57/100, brightness: 83/100, alpha: 1.0)
  let color3 = UIColor(hue: 209/360, saturation: 19/100, brightness: 46/100, alpha: 1.0)
  let mapDark = UIColor(red: 34.0/255.0, green: 35.0/255.0, blue: 44.0/255.0, alpha: 1.0)
  let mapLight = UIColor(red: 67.0/255.0, green: 71.0/255.0, blue: 86.0/255.0, alpha: 1.0)
  
  let closeToWhite = UIColor(red: 226.0/255.0, green: 251.0/255.0, blue: 250.0/255.0, alpha: 1.0)
  let gray = UIColor(red: 198.0/255.0, green: 200.0/255.0, blue: 206.0/255.0, alpha: 1.0)
  
  let widthBig = UIScreen.main.bounds.size.width
  let heightBig = UIScreen.main.bounds.size.height
  let itemstop: CGFloat = 30
  let itemsLeading: CGFloat = 20
  let itemsTraniling: CGFloat = 20
  
  
  let iconSzie: CGFloat = 40
  let iconborderWidth: CGFloat = 2
  let gameIconGap: CGFloat = 20
  let gameIconInitY: CGFloat!
  
  var detailViewRect = CGRect()
  
  init(){
    gameIconInitY = itemstop+20
    
    let dWith = widthBig*0.75
    let dheight = heightBig*0.65
    let dx = (widthBig-dWith)/2
    let dy = heightBig*0.15
    detailViewRect = CGRect(x: dx, y: dy, width: dWith, height: dheight)
  }

}

class MapViewController: UIViewController {

  @IBOutlet weak var mapView: MGLMapView!
  
  // map view elements
  var baseButton: UIButton!
  var infraButton: UIButton!
  var returnButton: UIButton!
  var binDetailView: UIView!

  // fake datas
  var bases = [Node]()
  var infrastructures = [Node]()
  var basesLocation = [CLLocationCoordinate2D]()
  var infrastrcturesLocation = [CLLocationCoordinate2D]()
  
  
  // map data (GIS)
  var polyLineSource: MGLShapeSource?
  var polyLineFeatures = [MGLShape]()
  var pointSource: MGLShapeSource?

  //commnication with other vc
  var isReturnFromOtherVC : Bool?

  
  //从上一页获得的数据
  var dataModel = DataModel()
  
  //获得core data的context,用于储存小型数据
  var managedObjectContext: NSManagedObjectContext!
  
  let pro = MapVCProperties()
  
  // values for drawing map
  var webIDs = [Int]()
  var graphs = [WebGraph?]()
  var nodeID = 0
  var lineID = 0
  let lat = Double(39.915002)
  let long = Double(116.386414)
  let searchDistance = Double(500)
  var activeType: NodeType = .null
  
  var willCreatMarker = Bool()
  
  override var preferredStatusBarStyle: UIStatusBarStyle{
    return.lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initMapView()

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}








