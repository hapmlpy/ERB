//
//  ViewController.swift
//  Environment Behavior
//
//  Created by JIAN LI on 8/15/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Foundation
import Mapbox
import CoreLocation

enum NodeType {
    case null
    case base
    case infrastructure
    case suspend
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var baseButton: UIButton!
    @IBOutlet weak var infraButton: UIButton!
    
    var routeLines = [MGLPolyline]()
    var routes = [RouteLine]()
    
    var bases = [Node]()
    var infrastructures = [Node]()
    
    var basesLocation = [CLLocationCoordinate2D]()
    var infrastrcturesLocation = [CLLocationCoordinate2D]()
    
    
    var activeType: NodeType = .null
    
    var polyLineSource: MGLShapeSource?
    var polyLineFeatures = [MGLShape]()
    
    var pointSource: MGLShapeSource?
    
    var annotations = [NodeAnnotioan]()
    
    
    var webIDs = [Int]()
    var graphs = [WebGraph?]()
    var nodeID = 0
    var lineID = 0
    
    let lat = Double(39.915002)
    let long = Double(116.386414)
    
    let searchDistance = Double(500)
    
    @IBAction func activeBase() {
        activeType = .base
    }
    @IBAction func activeInfra() {
        activeType = .infrastructure
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMapView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMapView(){
        mapView.delegate = self
        mapView.zoomLevel = 14
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

}

extension MapViewController: MGLMapViewDelegate{
    func mapView(_ mapView:MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool{
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        let queue = DispatchQueue.global()
        queue.async {
            self.addLayer(to:style)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:style:)))
            //见文档https://www.mapbox.com/ios-sdk/api/3.6.0/Classes/MGLMapView.html
            for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
                gesture.require(toFail: recognizer)
            }
            mapView.addGestureRecognizer(gesture)
        }
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        let nodeAnnotation = annotation as? NodeAnnotioan
        if nodeAnnotation?.willUseImage == false {
            return nil
        }
        let imagePick = UIImage(named: (nodeAnnotation?.imageName)!)
        
        let reuseIdentifier = nodeAnnotation?.reuseIdentifier
        if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier!) {
            return annotationImage
        }else{
            return MGLAnnotationImage(image: imagePick!, reuseIdentifier: reuseIdentifier!)

        }
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        //使用自定义的annotation class
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        
        let nodeAnnotation = annotation as? NodeAnnotioan
        if nodeAnnotation?.willUseImage == true{
            return nil
        }
        
        
        let reuseIdentifier = "markers"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = StyleAnnotationView(reuseIdentifier: reuseIdentifier, size:8)
            
            //使用https://www.ralfebert.de/snippets/ios/swift-uicolor-picker/ 选颜色
            let level = Double((nodeAnnotation?.level)!)
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
            
            
            annotationView!.layer.backgroundColor = color.cgColor
            annotationView!.layer.opacity = 1
            print(level)
        }
        return annotationView
    }
    
    
    
    func addLayer(to style: MGLStyle){
        //三部曲：source -> layer -> style
        
        let color1 = UIColor(hue: 66/360, saturation: 72/100, brightness: 90/100, alpha: 1.0)
        let color2 = UIColor(hue: 104/360, saturation: 57/100, brightness: 83/100, alpha: 1.0) /* #7cd65c */
        let color3 = UIColor(hue: 209/360, saturation: 19/100, brightness: 46/100, alpha: 1.0) /* #22232b */
        
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
        //add line layer
        let lineSource = MGLShapeSource(identifier: "route", shape: nil, options: nil)
        style.addSource(lineSource)
        polyLineSource = lineSource
        let lineLayer = MGLLineStyleLayer(identifier: "route", source: lineSource)
        
        lineLayer.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        lineLayer.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .round))
        
        lineLayer.lineWidth = MGLStyleValue(interpolationMode: .exponential,
                                            cameraStops: [8: MGLStyleValue<NSNumber>(rawValue: 0.3),
                                                          18: MGLStyleValue<NSNumber>(rawValue: 3)],
                                            options: [.defaultValue : MGLConstantStyleValue<NSNumber>(rawValue: 1.5)])
        
        
        lineLayer.lineColor = MGLStyleValue(interpolationMode: .exponential,
                                            sourceStops: stopColor,
                                            attributeName: "level",
                                            options: [.defaultValue: MGLStyleValue(rawValue:color3)])
        
        
        
        lineLayer.lineOpacity = MGLStyleValue(interpolationMode: .exponential,
                                              sourceStops: stopOpacity,
                                              attributeName: "level",
                                              options: [.defaultValue: MGLStyleValue<NSNumber>(rawValue:0.5)])
        
        style.addLayer(lineLayer)
        
        
        
        
        //add node layer
        let nodeSource = MGLShapeSource(identifier: "node", shape: nil, options: nil)
        style.addSource(nodeSource)
        
        pointSource = nodeSource
        
        let nodeLayer = MGLCircleStyleLayer(identifier: "node", source: nodeSource)
        
        nodeLayer.circleColor = MGLStyleValue(interpolationMode: .exponential,
                                              sourceStops: stopColor,
                                              attributeName: "level",
                                              options: [.defaultValue: MGLStyleValue(rawValue:color3)])
        
        
        
        nodeLayer.circleOpacity = MGLStyleValue(interpolationMode: .exponential,
                                                sourceStops: stopOpacityforNode,
                                                attributeName: "level",
                                                options: [.defaultValue: MGLStyleValue<NSNumber>(rawValue:0.5)])
        
        
//        nodeLayer.circleRadius = MGLStyleValue(interpolationMode: .exponential,
//                                               cameraStops: [12: MGLStyleValue(rawValue: 6),
//                                                             22: MGLStyleValue(rawValue: 220)],
//                                               options: [.defaultValue: 10])
        
        nodeLayer.circleRadius = MGLStyleValue(rawValue: 0.01)
        
        nodeLayer.circleStrokeColor = MGLStyleValue(interpolationMode: .exponential,
                                                    sourceStops: stopColor,
                                                    attributeName: "level",
                                                    options: [.defaultValue: MGLStyleValue(rawValue:color3)])
        
        nodeLayer.circleStrokeOpacity = MGLStyleValue(interpolationMode: .exponential,
                                                      sourceStops: [
                                                        0: MGLStyleValue<NSNumber>(rawValue: 0.8),
                                                        5: MGLStyleValue<NSNumber>(rawValue: 0.6),
                                                        12: MGLStyleValue<NSNumber>(rawValue: 0.6)],
                                                      attributeName: "level",
                                                      options: [.defaultValue: MGLStyleValue<NSNumber>(rawValue:0.5)])
        
        
        
        nodeLayer.circleStrokeWidth = MGLStyleValue(rawValue: 0.5)
        
        
        style.insertLayer(nodeLayer, above: lineLayer)
        
        
    }
    
    func handleTap(_ gesture: UITapGestureRecognizer, style: MGLStyle){
        
        let spot = gesture.location(in: mapView)
        let spotCoordinate = mapView.convert(spot, toCoordinateFrom: mapView)
        
        let node = Node(id: nodeID, location: spotCoordinate)
        markers(nodeType: activeType, node: node)
        
        nodeID = nodeID + 1
        
        activeType = .null
    }
    
    func markers(nodeType: NodeType, node: Node) {
        var getLine = [RouteLine]()
        var getNode = [Node]()
        switch nodeType {
        case .base:
            //建立新的graph
            let graph = WebGraph(center: node)
            graph.addNode(node: node, nodetype: .base, webIDs: &webIDs)
            basesLocation.append(node.location)
            //建立 <base - bins> 的线条
            if let bins = findInfrastructuresForBase(base: node, infras: infrastructures){
                //print("base find \(bins.count) bins")
                var i = 0
                for bin in bins{
                    //print("the \(i+1) bin...")
                    graph.addLine(source: node, destination: bin, lineID: &lineID)
                    i = i+1
                }
                graph.addNode(nodes: bins)
                
                var j = 0
                var deleteConut = 0
                for graph in graphs{
                    if graph?.graphtype == .suspend {
                        if (graph?.canvas.count)!<1{
                            let temp = graph!
                            graphs.remove(at: j)
                            graphs.append(temp)
                            deleteConut += 1
                        }else{
                        }
                    }
                    j = j+1
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
            
        case .infrastructure:
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
            pointAnnotation.willUseImage = true
            if node.nodeType == .base{
                pointAnnotation.reuseIdentifier = "base"
            }else{
                pointAnnotation.reuseIdentifier = "bin"
            }
            
            annotations.append(pointAnnotation)
        }
        mapView.addAnnotations(annotations)
        
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
    
}
// some functions
extension MapViewController {
    
    func modulateMapping(oldValue: Double, oldMin: Double, oldMax: Double, newMin: Double, newMax: Double ) -> Double {
        let oldRange = oldMax-oldMin
        if oldRange == 0 {
            return 0
        }else{
            let newRange = newMax-newMin
            return (((oldValue - oldMin) * newRange) / oldRange) + newMin
        }
        
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //func
    
    
}

// group function
public extension Sequence {
    func categorise<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = key(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
//appen element in dictionary
extension Dictionary {
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}




