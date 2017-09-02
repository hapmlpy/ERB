//
//  MapVC+drawMap.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/1/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox

extension MapViewController {
  
  // MARK: - set initial style of layers
  func addLayer(to style: MGLStyle){
    //三部曲：source -> layer -> style
    let properties = MapVCProperties()
    
    let color1 = properties.color1
    let color2 = properties.color2
    let color3 = properties.color3
    
    let stopColor = [
      0: MGLStyleValue<UIColor>(rawValue: color1),
      5: MGLStyleValue<UIColor>(rawValue: color2),
      12: MGLStyleValue<UIColor>(rawValue: color3)
    ]
    
    let stopOpacity = [
      0: MGLStyleValue<NSNumber>(rawValue: 0.8),
      5: MGLStyleValue<NSNumber>(rawValue: 0.4),
      12: MGLStyleValue<NSNumber>(rawValue: 0.4)
    ]
    
    let stopOpacityforNode = [
      0: MGLStyleValue<NSNumber>(rawValue: 0.4),
      5: MGLStyleValue<NSNumber>(rawValue: 0.2),
      12: MGLStyleValue<NSNumber>(rawValue: 0.2)
    ]
    //add node layer
    addCirclePolyLayer(stopColor: stopColor as! Dictionary<Int, MGLStyleValue<AnyObject>>, stopOpacityforNode: stopOpacityforNode, color: color3)
    
    addLineLayer(stopColor:stopColor as! Dictionary<Int, MGLStyleValue<AnyObject>>,stopOpacity:stopOpacity,lineColor: color3)
    
  }
  func addCirclePolyLayer(stopColor: Dictionary<Int,AnyObject>, stopOpacityforNode: Dictionary<Int,AnyObject>, color:UIColor){
    let nodeSource = MGLShapeSource(identifier: "node", shape: nil, options: nil)
    let style = mapView.style
    style?.addSource(nodeSource)
    pointSource = nodeSource
    let nodeLayer = MGLCircleStyleLayer(identifier: "node", source: nodeSource)
    nodeLayer.circleColor = MGLStyleValue(interpolationMode: .exponential,
                                          sourceStops: stopColor as? [AnyHashable : MGLStyleValue<UIColor>],
                                          attributeName: "level",
                                          options: [.defaultValue: MGLStyleValue(rawValue:color)])
    
    nodeLayer.circleOpacity = MGLStyleValue(interpolationMode: .exponential,
                                            sourceStops: stopOpacityforNode as? [AnyHashable : MGLStyleValue<NSNumber>],
                                            attributeName: "level",
                                            options: [.defaultValue: MGLStyleValue<NSNumber>(rawValue:0.5)])
    nodeLayer.circleRadius = MGLStyleValue(interpolationMode: .exponential,
                                           cameraStops: [12: MGLStyleValue(rawValue: 6),
                                                         22: MGLStyleValue(rawValue: 220)],
                                           options: [.defaultValue: 10])

    nodeLayer.circleStrokeColor = MGLStyleValue(interpolationMode: .exponential,
                                                sourceStops: stopColor as? [AnyHashable : MGLStyleValue<UIColor>],
                                                attributeName: "level",
                                                options: [.defaultValue: MGLStyleValue(rawValue:color)])
    
    nodeLayer.circleStrokeOpacity = MGLStyleValue(interpolationMode: .exponential,
                                                  sourceStops: [
                                                    0: MGLStyleValue<NSNumber>(rawValue: 0.8),
                                                    5: MGLStyleValue<NSNumber>(rawValue: 0.6),
                                                    12: MGLStyleValue<NSNumber>(rawValue: 0.6)],
                                                  attributeName: "level",
                                                  options: [.defaultValue: MGLStyleValue<NSNumber>(rawValue:0.5)])
    
    nodeLayer.circleStrokeWidth = MGLStyleValue(rawValue: 0.5)
    
    style?.addLayer(nodeLayer)
  }
  
  func addLineLayer(stopColor: Dictionary<Int,AnyObject>,stopOpacity:Dictionary<Int,AnyObject>, lineColor: UIColor){
    let lineSource = MGLShapeSource(identifier: "route", shape: nil, options: nil)
    let style = mapView.style
    style?.addSource(lineSource)
    polyLineSource = lineSource
    let lineLayer = MGLLineStyleLayer(identifier: "route", source: lineSource)
    
    lineLayer.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
    lineLayer.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .round))
    
    lineLayer.lineWidth = MGLStyleValue(interpolationMode: .exponential,
                                        cameraStops: [8: MGLStyleValue<NSNumber>(rawValue: 0.1),
                                                      18: MGLStyleValue<NSNumber>(rawValue: 1.8)],
                                        options: [.defaultValue : MGLConstantStyleValue<NSNumber>(rawValue: 1.5)])
    
    
    lineLayer.lineColor = MGLStyleValue(interpolationMode: .exponential,
                                        sourceStops: stopColor as? [AnyHashable : MGLStyleValue<UIColor>],
                                        attributeName: "level",
                                        options: [.defaultValue: MGLStyleValue(rawValue:lineColor)])
    
    
    
    lineLayer.lineOpacity = MGLStyleValue(interpolationMode: .exponential,
                                          sourceStops: stopOpacity as? [AnyHashable : MGLStyleValue<NSNumber>],
                                          attributeName: "level",
                                          options: [.defaultValue: MGLStyleValue<NSNumber>(rawValue:0.5)])
    
    style?.addLayer(lineLayer)
  }
  
  
  // MARK: - draw graphs
  func markers(nodeType: NodeType, node: Node) {
    var getLine = [RouteLine]()
    var getNode = [Node]()
    switch nodeType {
    case .base:
      drawBase(node: node)
    case .infrastructure:
      drawInfrastructure(node: node)
    default:
      break
    }
    //print("\n")
    for graph in graphs {
      if let g = graph {
        let lines = g.getLine()
        getLine += lines
        let nodes = g.getNode()
        getNode += nodes
        //g.printWebLevel()
      }
    }
    //print("get totaly \(getNode.count) nodes")
    linesToSource(routeLines: getLine)
    nodesToSource(nodes: getNode)
    
    //建立annotation
    var annotations = [NodeAnnotioan]()
    for node in getNode{
      let pointAnnotation = NodeAnnotioan(node: node)
      pointAnnotation.willUseImage = false
      if node.nodeType == .base{
        pointAnnotation.reuseIdentifier = "base"
      }else{
        pointAnnotation.reuseIdentifier = "bin"
      }
      annotations.append(pointAnnotation)
    }
    if let oldAnnotations = mapView.annotations{
      mapView.removeAnnotations(oldAnnotations)
    }
    mapView.addAnnotations(annotations)
  }
  
  func  drawBase(node: Node){
    //建立新的graph
    let graph = WebGraph(center: node)
    graph.addNode(node: node, nodetype: .base, webIDs: &webIDs)
    basesLocation.append(node.location)
    //建立 <base - bins> 的线条
    if let bins = findInfrastructuresForBase(base: node, infras: infrastructures){
      //print("base find \(bins.count) bins")
      for bin in bins{
        graph.addLine(source: node, destination: bin, lineID: &lineID)
      }
      graph.addNode(nodes: bins)
      
      var i = 0
      var deleteConut = 0
      for graph in graphs{
        if graph?.graphtype == .suspend {
          if (graph?.canvas.count)!<1{
            let temp = graph!
            graphs.remove(at: i)
            graphs.append(temp)
            deleteConut += 1
          }else{
          }
        }
        i = i+1
      }
      for _ in 0..<deleteConut {
        if let last = graphs.last{
          last?.cleanGraph(webIDs: &webIDs)
        }
        graphs.removeLast()
      }
    }else{
      //print("base find nothing, create node only")
    }
    bases.append(node)
    graphs.append(graph)
  }
  
  func drawInfrastructure(node: Node){
    //建立bin - base or bin - bin 的线条annotion
    if let base = findBaseforInfrastructure(infra: node, bases: bases) {
      //搜索哪个graph里包含这个base,把节点加到这个graph里
      for searchGraph in graphs {
        if base.belongTo == searchGraph {
          searchGraph?.addNode(node: node, nodetype: .infrastructure, webIDs: &webIDs)
          searchGraph?.addLine(source: base, destination: node, lineID: &lineID)
        }
      }
    }else{
      //没找到base，找最近的bins
      let findBins = addNodeAomgMultiGraph(this: node, those: infrastructures)
      
      if !findBins {
        //悬置bin
        let graph = WebGraph(center:node)
        graph.addNode(node: node, nodetype: .suspend, webIDs: &webIDs)
        graph.graphtype = .suspend
        graphs.append(graph)
      }
    }
    infrastructures.append(node)
  }
  
  func routeLinesToFeatures (routeLines: [RouteLine]) -> MGLShapeCollectionFeature?{
    var feaures = [MGLPolylineFeature]()
    for line in routeLines{
      if let getfeature = line.convertToPolyLineFeatre(){
        feaures.append(getfeature)
      }else{
        print("<convert multiple lines to features>: 错误：无法获得feature")
        return nil
      }
    }
    let multi = MGLShapeCollectionFeature(shapes: feaures)
    return multi
    
  }
  
  func linesToSource(routeLines: [RouteLine]){
    if routeLines.count > 0{
      let multi = routeLinesToFeatures(routeLines: routeLines)
      polyLineSource?.shape = multi
    }else{
      //print("<feed lines into source>: 错误：没有线条可供导入")
    }
  }
  
  func nodesToSource(nodes: [Node]) {
    var features = [MGLPointFeature]()
    if nodes.count > 0 {
      for node in nodes {
        let coord = node.location
        let feature = MGLPointFeature()
        feature.coordinate = coord
        if let tryLevel = node.level{
          let value = NSNumber(integerLiteral: tryLevel)
          feature.attributes = ["level" : value]
          features.append(feature)
        }else{
          print("<convert line to featre>: 错误：level值为空，无法转换为featrue属性")
          return
        }
      }
    }else{
      print("there are no node in sence")
    }
    let multi = MGLShapeCollectionFeature(shapes: features)
    pointSource?.shape = multi
    
  }

  func getLinesFromRoutesLine(routeLines: [RouteLine]) -> [MGLPolyline] {
    var lines = [MGLPolyline]()
    for route in routeLines {
      lines.append(route.line)
    }
    return lines
  }
  
  func webLinkage (start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> MGLPolyline {
    let link = [start, end]
    return MGLPolyline(coordinates: link, count: UInt(2))
  }
  
  
  func findBaseforInfrastructure(infra: Node, bases: [Node]) -> Node? {
    var disStorage = [Double]()
    
    let lat_infra: CLLocationDegrees = infra.location.latitude
    let long_infra: CLLocationDegrees = infra.location.longitude
    let location_infra: CLLocation = CLLocation(latitude: lat_infra, longitude: long_infra)
    for base in bases {
      //print("..current base:NO.\(base.id), type :\(base.nodeType),level:\(base.level)")
      let lat_base: CLLocationDegrees = base.location.latitude
      let long_base: CLLocationDegrees = base.location.longitude
      let location_base: CLLocation = CLLocation(latitude: lat_base, longitude: long_base)
      
      let distanceInMeters = location_infra.distance(from: location_base)
      
      disStorage.append(distanceInMeters)
      
    }
    
    if disStorage.count == 0{
      return nil
    }else{
      
      //见https://stackoverflow.com/questions/32568397/how-to-find-filter-the-array-element-with-the-smallest-positive-difference?rq=1
      let enumerate = disStorage.enumerated()
      let closest = enumerate.min(by: {a, b in a.element < b.element})!
      if closest.element < searchDistance {
        //print("..finded base level is \(bases[closest.offset].level)")
        return bases[closest.offset]
        
      }else{
        return nil
      }
    }
    
  }
  
  func findInfrastructuresForBase(base: Node, infras: [Node]) -> [Node]? {
    var lessThan500m = [Node]()
    
    let lat_base: CLLocationDegrees = base.location.latitude
    let long_base: CLLocationDegrees = base.location.longitude
    let location_base: CLLocation = CLLocation(latitude: lat_base, longitude: long_base)
    
    for infra in infras {
      let lat_infra: CLLocationDegrees = infra.location.latitude
      let long_infra: CLLocationDegrees = infra.location.longitude
      let location_infra: CLLocation = CLLocation(latitude: lat_infra, longitude: long_infra)
      
      let distanceInMeters = location_base.distance(from: location_infra)
      if distanceInMeters < searchDistance {
        lessThan500m.append(infra)
      }
    }
    if lessThan500m.count < 1{
      return nil
    }else{
      return lessThan500m
    }
  }
  
  func findInfrastructureForInfrastructure(this: Node, those: [Node]) -> Node? {
    
    let lat_this: CLLocationDegrees = this.location.latitude
    let long_this: CLLocationDegrees = this.location.longitude
    let location_this: CLLocation = CLLocation(latitude: lat_this, longitude: long_this)
    
    var disStorage = [Double]()
    for infra in those {
      let lat_infra: CLLocationDegrees = infra.location.latitude
      let long_infra: CLLocationDegrees = infra.location.longitude
      let location_infra: CLLocation = CLLocation(latitude: lat_infra, longitude: long_infra)
      
      let distanceInMeters = location_this.distance(from: location_infra)
      disStorage.append(distanceInMeters)
    }
    
    if disStorage.count == 0{
      
      return nil
      
    }else{
      
      //见https://stackoverflow.com/questions/32568397/how-to-find-filter-the-array-element-with-the-smallest-positive-difference?rq=1
      let enumerate = disStorage.enumerated()
      let closest = enumerate.min(by: {a, b in a.element < b.element})!
      
      if closest.element < searchDistance {
        //当前的bin是新找到bin的下一个(注意要判断是不是悬置bin)
        return those[closest.offset]
        
      }else{
        return nil
      }
    }
  }
  func addNodeAomgMultiGraph(this: Node, those: [Node]) -> Bool {
    //找到附近500米内的点
    if let proximitNodes = findInfrastructuresForBase(base: this, infras: those){
      //获得这些点graph的分组信息
      guard let groupedNode = groupNodesInSameGraph(searchIn: proximitNodes) else{
        return false
      }
      //解析组
      
      var closestNodes = [Node]()
      for group in groupedNode{
        let thisGraph = group.key
        //print("this group is bind by graph\(thisGraph.webID)")
        let saveNode = group.value
        //找到当前graph里距离自己最近的node
        if let closestNodeInGraph = findInfrastructureForInfrastructure(this: this, those: saveNode){
          //print("in graph\(thisGraph.webID!), closest node is \(closestNodeInGraph.id!)")
          closestNodes.append(closestNodeInGraph)
          //连线
          thisGraph.addLine(source: closestNodeInGraph, destination: this, lineID: &lineID)
        }
        
      }
      //判断自己和哪个组的node最近就去那个组
      if let belongToNode = findInfrastructureForInfrastructure(this: this, those: closestNodes){
        //print("closet node is No.\(belongToNode.id!)")
        this.level = (belongToNode.level)!+1
        this.web?.key = (belongToNode.web?.key)!
        this.web?.value = this.level!
        
        let newGraph = belongToNode.belongTo
        this.belongTo = newGraph
        newGraph?.appendNodetoCanvas(node: this)
        
        return true
      }else{
        return false
      }
    }
    return false
  }
  
  func groupNodesInSameGraph(searchIn nodes: [Node]) -> [(key: WebGraph, value: [Node])]? {
    guard nodes.count > 0 else {
      return nil
    }
    
    var grouping = [(key: WebGraph, value: Node)]()
    
    
    for node in nodes {
      
      let graph:WebGraph = node.belongTo!
      let needToappend = (key:graph, value:node)
      
      grouping.append(needToappend)
    }
    
    
    var groups = [(key: WebGraph, value: [Node])]()
    var categoryNodes = [(Node)]()
    //分组信息
    for (graph,graph_nodes) in grouping.categorise({ $0.key }){
      for singleNode in graph_nodes{
        let node = singleNode.value
        categoryNodes.append(node)
      }
      let group = (key:graph,value:categoryNodes)
      groups.append(group)
    }
    
    
    return groups
  }
  
  /*
   //没有使用寻路连线的方法，因为此服务每次调用只提供一条路径
   func getRoutes(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> MGLPolyline {
   let MapboxAccessToken = "pk.eyJ1IjoiaGFwbWxweSIsImEiOiJjajR0NXFzM2wwNHBjMzJvOHJvd2h2bHVlIn0.6H3rU6CtFzIS9TwuBNtIyQ"
   let waypoints = [
   Waypoint(
   coordinate: start,name: "start point"),
   Waypoint(
   coordinate: end,name: "end point"),
   ]
   
   let options = RouteOptions(waypoints: waypoints, profileIdentifier: .walking)
   options.includesSteps = true
   
   _ = Directions(accessToken: MapboxAccessToken).calculate(options){
   (waypoints, routes, error) in
   guard error == nil else{
   print("Error calculating directions: \(error!)")
   return
   }
   //MBRRoute包括距离、时间、拐弯点
   if let route = routes?.first{
   if route.coordinateCount > 0 {
   var routeCoordinates = route.coordinates!
   self.routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
   print("建立一根线")
   }
   }
   }
   return routeLine
   }
   */

  // MARK: - Annotation Appearance
  
  func colorFitLevel(level: Double) -> UIColor {
    
    //使用https://www.ralfebert.de/snippets/ios/swift-uicolor-picker/ 选颜色
    var hue = CGFloat()
    var saturation = CGFloat()
    var brightness = CGFloat()
    var alpha = CGFloat()
    var color = UIColor.black
    
    if level > 2000 {
      color = UIColor(hue: 209/360, saturation: 19/100, brightness: 46/100, alpha: 0.5)
    }else if level > 8 {
      
      hue = CGFloat(modulateMapping(oldValue: level, oldMin: 8, oldMax: 16, newMin: 104, newMax: 209))
      saturation = CGFloat(modulateMapping(oldValue: level, oldMin: 8, oldMax: 16, newMin: 57, newMax: 19))
      brightness = CGFloat(modulateMapping(oldValue: level, oldMin: 8, oldMax: 18, newMin: 83, newMax: 46))
      alpha = CGFloat(modulateMapping(oldValue: level, oldMin: 8, oldMax: 16, newMin: 0.7, newMax: 0.5))
      
      color = UIColor(hue: CGFloat(hue/360), saturation: CGFloat(saturation/100), brightness: CGFloat(brightness/100), alpha: CGFloat(alpha))
      
    }else{
      
      hue = CGFloat(modulateMapping(oldValue: level, oldMin: 0, oldMax: 8, newMin: 66, newMax: 104))
      saturation = CGFloat(modulateMapping(oldValue: level, oldMin: 0, oldMax: 8, newMin: 72, newMax: 57))
      brightness = CGFloat(modulateMapping(oldValue: level, oldMin: 0, oldMax: 8, newMin: 90, newMax: 83))
      alpha = CGFloat(modulateMapping(oldValue: level, oldMin: 0, oldMax: 8, newMin: 1, newMax: 0.7))
      
      color = UIColor(hue: CGFloat(hue/360), saturation: CGFloat(saturation/100), brightness: CGFloat(brightness/100), alpha: CGFloat(alpha))
    }
    return color
    
  }
}
