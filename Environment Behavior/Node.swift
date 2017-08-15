//
//  Node.swift
//  streetClean
//
//  Created by JIAN LI on 8/7/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox



public class Node{
    
    var location = CLLocationCoordinate2D()
    var level: Int?
    var id: Int?
  
    //用于检索
    var visited = false
    
    //前后标记
    var front = false
    var back = false
    
    var neighbors: Array<RouteLine>
    var upstreams: Array<RouteLine>
    
    weak var belongTo: WebGraph?
    
    //webs 用来记录当前line属于哪个链接网络的
    var web: (key:Int, value:Int)?
    
    var nodeType: NodeType = .null
    
    init(id:Int, location: CLLocationCoordinate2D) {
        self.id = id
        self.location = location
        self.neighbors = Array<RouteLine>()
        self.upstreams = Array<RouteLine>()
        visited = false
        front = false
        back = false
        level = 0
    }
    
    func changeBelonging (newGraph: WebGraph) {
        guard self.belongTo != newGraph else {
            return
        }
        let old = self.belongTo
        old?.canvas.remove(object: self)
        self.belongTo = newGraph
        newGraph.appendNodetoCanvas(node: self)
    }
        
    //比较web组里的值，获得包含的level号最低的web
    func chooseWeb(webs: [Int:Int]) -> (key:Int, value:Int){
        let web = webs.min(by: {a, b in a.value < b.value})
        return web!
    }
    
}

extension Node: Hashable {
    public var hashValue: Int {
        return "\(id=0)".hashValue
    }
}

extension Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return
            lhs.id == rhs.id
    }
}
