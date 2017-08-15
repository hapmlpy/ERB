//
//  RouteLine.swift
//  streetClean
//
//  Created by JIAN LI on 8/7/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Mapbox

class RouteLine {
    
    var connectToBase = false
    var line = MGLPolyline()
    var level: Int?
    var id: Int?
    
    
    var visited = false
    
    //以下两个相当于线的neigbor
    var source: Node?
    var destination: Node?

    //webs 用来记录当前line属于哪个链接网络的
    var web: (key:Int, value:Int)?
    
    init() {}
    
    init (form source: Node, to destination: Node) {
        line = drawLine(start: source.location, end: destination.location)
        self.source = source
        self.destination = destination
        self.visited = false
        self.id = Int()
    }
    
    func drawLine (start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> MGLPolyline {
        let link = [start, end]
        return MGLPolyline(coordinates: link, count: UInt(2))
    }
    
    func convertToPolyLineFeatre() -> MGLPolylineFeature? {
        //print("<convert line to featre>")
        
        if let sourceCoord = source?.location, let destinCoord = destination?.location{
            let featureCoords: [CLLocationCoordinate2D] = [sourceCoord, destinCoord]
            let feature = MGLPolylineFeature(coordinates: featureCoords, count: 2)
            
            if let tryLevel = self.level{
                let value = NSNumber(integerLiteral: tryLevel)
                feature.attributes = ["level" : value]
            }else{
                print("<convert line to featre>: 错误：level值为空，无法转换为featrue属性")
                return nil
            }
            return feature
        }else{
            print("<convert line to featre>: 错误：无法获得端点坐标")
            return nil
        }
        
        
    }

    //比较2个web组里的值，获得包含的level号最低的web
    func chooseWeb(web1: (key:Int, value:Int), web2: (key:Int, value:Int)) -> (key:Int, value:Int){
        if web1.value > web2.value {
            return web2
        }else{
            return web1
        }
    }
    
    func changeDirection(){
        
//        print("\n")
//        print(">>>>>change line direction<<<<<<")
//        print("before change, line's information: ")
//        print("source id\(self.source?.id)")
//        print("destination id\(self.destination?.id)")
        
        
        for ne in (self.source?.neighbors)! {
            if ((ne.destination?.id = self.destination?.id) != nil){
                //从neighbor中去掉
                //加到upstream中去
                self.source?.neighbors.remove(object: self)
                self.source?.upstreams.append(self)
            }
        }
        //放到destination的neighbor中
        self.destination?.neighbors.append(self)
        
        let temp = self.source
        self.source = self.destination
        self.destination = temp
        
//        print("after change, line's information: ")
//        print("source id\(self.source?.id)")
//        print("destination id\(self.destination?.id)")
        
    }

}

extension RouteLine: Equatable {
    public static func == (lhs: RouteLine, rhs: RouteLine) -> Bool {
        return
            lhs.id == rhs.id
    }
}
