//
//  BaseAnnotation.swift
//  streetClean
//
//  Created by JIAN LI on 8/6/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox


class NodeAnnotioan: MGLPointAnnotation {
  
  static var nextUid = 0
  static func generateUid() -> Int {
    nextUid += 1
    return nextUid
  }
  
  var uid: Int
  var nodeType: NodeType = .null
  var level: Int?
  var willUseImage: Bool = false
  var imageName: String!
  var reuseIdentifier: String?
  var readable = true
  
  override init(){
    self.uid = NodeAnnotioan.generateUid()
    super.init()
    
  }
  
  init(node:Node){
    self.uid = NodeAnnotioan.generateUid()
    super.init()
    self.coordinate = node.location
    if node.nodeType == .base{
      self.nodeType = .base
      self.imageName = "baseM"
      self.readable = true
    }
    if node.nodeType == .infrastructure || node.nodeType == .suspend || node.nodeType == .null {
      self.nodeType = .infrastructure
      self.imageName = "binM"
      self.readable = true
    } 
    if node.nodeType == .unRegist{
      self.nodeType = .unRegist
      self.imageName = "binM"
      self.readable = false
    }
    
    if let title = node.id {
      self.title = "\(title)"
    }
    self.level = node.level!
  }
  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
    
    
}
extension NodeAnnotioan {
  open override var hashValue: Int {
    return "\(uid=0)".hashValue
  }
  
  open static func == (lhs: NodeAnnotioan, rhs: NodeAnnotioan) -> Bool {
    return
      lhs.uid == rhs.uid
  }
}
