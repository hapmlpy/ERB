//
//  DataModel.swift
//  Environment Behavior
//
//  Created by JIAN LI on 8/25/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox

class DataModel {
  
  var isHasBase = false
  var pointAnnotations: [NodeAnnotioan]?
  var undetermintedAnnotations: [NodeAnnotioan]?
  var currentRegion = MGLCoordinateBounds()
  
  init(){
    loadBaseState()
    pointAnnotations = Array<NodeAnnotioan>()
    undetermintedAnnotations = Array<NodeAnnotioan>()
  }
  
  //data path
  func documentsDirectory() -> URL {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return path[0]
  }
  func dataFilePaht() -> URL {
    return documentsDirectory().appendingPathComponent("isHaveBaseData.plist")
  }
  
  func saveBaseState() {
    let data = NSMutableData()
    let archive = NSKeyedArchiver(forWritingWith: data)
    archive.encode(isHasBase,forKey: "isHaveBaseData")
    archive.finishEncoding()
    data.write(to: dataFilePaht(), atomically: true)
  }
  
  func loadBaseState() {
    let path = dataFilePaht()
    if let data = try? Data(contentsOf: path){
      let unarchiver = NSKeyedArchiver(forWritingWith: data as! NSMutableData)
      isHasBase = unarchiver.decodeObject(forKey: "isHaveBaseData") as! Bool
      unarchiver.finishEncoding()
    }
  }
}
