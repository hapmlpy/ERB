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
    
    var nodeType: NodeType = .null
    var level: Int?
    var willUseImage: Bool = false
    var imageName: String!
    var reuseIdentifier: String?
    
    override init(){
        super.init()
    }
    
    init(node:Node){
        super.init()
        self.coordinate = node.location
        if node.nodeType == .base{
            self.nodeType = .base
            self.imageName = "base"
        }
        if node.nodeType == .infrastructure || node.nodeType == .suspend || node.nodeType == .null {
            self.nodeType = .infrastructure
            self.imageName = "bin"
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
    
    
}
