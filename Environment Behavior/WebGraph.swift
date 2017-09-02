//
//  WebGraph.swift
//  streetClean
//
//  Created by JIAN LI on 8/8/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox

enum GraphType {
    
    case suspend
    case normal
}

enum Visit{
    case source
    case edge(RouteLine)
    
}

class WebGraph {
    
    var canvas: Array<Node>
    var graphtype: GraphType?
    
    var centerNode: Node?
    var id: Int?
    var webID: Int?
    
    init(center: Node) {
        
        canvas = Array<Node>()
        graphtype = .normal
        centerNode = center
        id = centerNode?.id
        
        if let webid = centerNode?.web?.key{
            webID = webid
        }else{
            webID = 1
        }
    }
    
    func cleanGraph(webIDs: inout [Int]) {
        //print("<remove graphs>")
        //这个graph是以悬置bin为核心的
        //合并后，要从数据中去掉这个graph的webid
        let id = self.webID
        for idDelete in webIDs{
            if idDelete == id {
                webIDs.remove(object: idDelete)
                break
            }
        }
        //清理数据
        if self.canvas.count > 0 {self.canvas.removeAll()}
        self.centerNode = nil
        self.graphtype = nil
        self.id = nil
        self.webID = nil
    }
    
    func cleanInformation (startingNode: Node) {
        let graphQueue = Queue<Node>()
        graphQueue.enqueue(Key: startingNode)
        
        while !graphQueue.inEmpty {
            let item = graphQueue.dequeue() as Node!
            item?.level = nil
            item?.web = nil
            item?.belongTo = nil
            //获得队头的所有连线
            for route in (item?.neighbors)! {
                route.level = nil
                route.web = nil
                //找连线终端的node，如果这个node没被检索过
                if route.destination?.visited == false{
                    //把它加入列队
                    graphQueue.enqueue(Key: route.destination!)
                }
            }
            //标记此node已经被检索过了
            item?.visited = true
        }//end while
    }
    
    func removeNode(deleted: Node){
        var uppers = [RouteLine]()
        var lowers = [RouteLine]()
        for node in self.canvas{
            if node.id == deleted.id {
                for neighbor in node.neighbors{
                    //如果suorce既为待删节点，为下一级线条
                    if neighbor.source!.id == deleted.id {
                        lowers.append(neighbor)
                    }else{
                        uppers.append(neighbor)
                    }
                }
            }
        }
        //将上一级线条的终点连到下一级线条终点
        //删掉下一级线条
        for up in uppers {
            for lo in lowers {
                up.destination = lo.destination
            }
        }
        
        lowers.removeAll()
        
        deleted.belongTo = nil
        self.canvas.remove(object: deleted)
        
        //更新level
        for up in uppers{
            if let nodetoupdate = up.source {
                propagateInsideLevel(start: nodetoupdate)
            }
        }        
        
    }
    
    func appendNodetoCanvas(node: Node){
        if !self.canvas.contains(node){
            self.canvas.append(node)
        }else{
            return
        }   
    }
    
    
    func addNode(node: Node, nodetype: NodeType, webIDs: inout [Int]) {
        
        let webid = webCount(webIDs: webIDs)
        
        switch nodetype {
        case .base:
          node.belongTo = self
          node.nodeType = .base
          node.web = (key: webid, value: 0)
          node.level = 0
          webIDs.append(webid)
          
          self.webID = webid
            
        case .infrastructure:
          node.belongTo = self
          node.nodeType = .infrastructure
          node.level = nil
          let graphwebid = self.webID
          node.web?.key = graphwebid!
            
        case .suspend:
          node.belongTo = self
          node.nodeType = .suspend
          node.web = (key: webid, value: 3000)
          node.level = 3000
          webIDs.append(webid)
          //print("add suspend node, webid \(webid)")
          
          self.webID = webid
            
        case .null:
          return
          
        default:
          return
        }
        appendNodetoCanvas(node: node)
    }
    
    
    func connectDownstremNode(startNode: Node, oldLevel: Int){
        resetVisitabel()
        
        print("\n\n ")
        print(">>>>>connet to downstream<<<<<")
        let webid = self.webID!
        
        //取回原来的level，否者此时的level有可能在以前的操作中被改变了
        startNode.web?.key = webid
        startNode.web?.value = oldLevel
        startNode.level = oldLevel
        
        let graphQueue = Queue<Node>()
        graphQueue.enqueue(Key: startNode)
    
        var i = 1
        while !graphQueue.inEmpty {
            
            if let item = graphQueue.dequeue() as Node!{
                print("get item node No.\(String(describing: item.id!)) ")
                print("this node's previous web level\(String(describing: item.web)) ")
                item.belongTo = self
                item.web?.key = webid
                item.web?.value = i
                item.level = i
                appendNodetoCanvas(node: item)
                print("after change, web level\(String(describing: item.web)) ")
                
                for route in (item.neighbors) {
                    route.level = item.level
                    route.web = item.web
                    if route.destination?.visited == false{
                        graphQueue.enqueue(Key: route.destination!)
                    }
                }
                item.visited = true
                i = i + 1
            }
        }//end while
        
    }
    
    func connectUpstreamNode(startNode: Node, oldLevel: Int){
        resetVisitabel()
        
        print("\n\n ")
        print(">>>>>connet to upstream<<<<<")
        var temLine = [RouteLine]()
        let web: (key: Int, value: Int) = (key:self.webID!, value: 1)
        let webid = web.key
        
        //取回原来的level，否者此时的level有可能在以前的操作中被改变了
        startNode.web?.key = webid
        startNode.web?.value = oldLevel
        startNode.level = oldLevel
        
        let stack = Stack<Node>()
        stack.push(startNode)
        //peek是拿出stack里的第一个
        var i = 1
        outer: while let item = stack.peek() {
            //如果再也找不到上游线条了就退出
            guard item.upstreams.count > 0 else{
                print("node No.\(item.id!) don't has upstream line anymore")
                print(">>>>>stop check upsream web<<<<<")
                _ = stack.pop()
                break }
            //不论当前node有多少个web，用最近放进去的一个
            print("get item node No.\(item.id!) ")
            print("..this node's old web level\(item.web!) ")
            let newWeb: (key:Int, value: Int) = (key:webid, value: i)
            if let oldweb = item.web{
                print("..compaire to new web \(newWeb)")
                if oldweb.value > newWeb.value{
                    item.web = newWeb
                    item.level = i
                    item.changeBelonging(newGraph: self)
                    appendNodetoCanvas(node: item)
                    print("..after change, web level\(item.web!) ")
                }else{
                    break
                }
            }
            print("..there are \(item.upstreams.count) upstream line")
            for route in item.upstreams {
                if route.source?.nodeType != .base {
                    //print("..this route source nodetyle\(route.source?.nodeType)) isnot base node, check it")
                    route.web = route.destination?.web
                    route.level = route.destination?.level
                    temLine.append(route)
                    //准备继续逆流而上
                    //print("..if visite upstream node? :\(route.source?.visited)")
                    if route.source?.visited == false{
                        print("..next check its upstream node \((route.source?.id)!)")
                        stack.push(route.source!)
                    }
                }else{
                    //print("..this route source nodetyle\(route.source?.nodeType)) is base node, igore it")
                    continue
                }
                
            }//for end
            item.visited = true
            i = i+1
        }//while end
        //删掉队尾
        _ = stack.pop()
        //处理临时数组里的line
        //print("there are \(temLine.count) lines need to update")
        for line in temLine{
            //print("..line web and level: \(line.web!)")
            //颠倒方向
            line.changeDirection()
        }
    }
    
    func addNode(nodes:[Node]){
        guard nodes.count > 0 else {
            return
        }
        
        for node in nodes {
            node.web?.key = self.webID!
            node.web?.value = 1
            node.level = 1
            //check graph value for this node
            propagateLevel(startNode: node)
            //print("deal with next node \n\n")
        }
        //printWebLevel()
    }
    
    func propagateLevel(startNode: Node){
        let queue = Queue<Node>()
        queue.enqueue(Key: startNode)
        for route in startNode.neighbors{
            route.level = startNode.level
            route.web = startNode.web
        }
        
        let webid = startNode.web?.key
        
        while !queue.inEmpty{
            if let item = queue.dequeue() as Node! {
                let thisLevel = item.level
                item.web = (key:webid!, value:thisLevel!)
                
                item.changeBelonging(newGraph: self)
                
                
                //print("this node\((item.id)!) level is \(thisLevel!)")
                
                //print("there are \(item.neighbors.count) downstream line, for-loop those line..")
                for route in item.neighbors{
                    var destinLevel = route.destination?.level
                    //print("..next node\((route.destination?.id)!) level is \(destinLevel!)")
                    if destinLevel! > thisLevel!+1 {
                        //print("..nextLevel\(destinLevel!) > \(thisLevel!) + 1: \(thisLevel!+1), change it and put it as last of the queue")
                        destinLevel = thisLevel!+1
                        route.destination?.level = destinLevel!
                        //set line web and level
                        route.level = item.level
                        route.web = item.web
                        //print("change destin level as \(destinLevel!)")
                        queue.enqueue(Key: route.destination!)
                    }else{
                        //print("..nextLevel\(destinLevel!) < \(thisLevel!) + 1: \(thisLevel!+1),do nothing")
                    }
                }
                
                //print("there are \(item.upstreams.count) upsttream line, for-loop those line..")
                for route in item.upstreams{
                    var sourceLevel = route.source?.level
                    //print("..previous node\((route.source?.id)!) level is \(sourceLevel!), change it and put it as last of the queue")
                    if sourceLevel! > thisLevel!+1 && route.source?.nodeType != .base {
                        //print("..previous level \(sourceLevel!) > (\(thisLevel!) + 1)=\(thisLevel!+1)")
                        sourceLevel! = thisLevel!+1
                        route.source?.level = sourceLevel!
                        //set line web and level
                        route.level = item.level
                        route.web = item.web
                        //print("change previous node level as \(sourceLevel!)")
                        queue.enqueue(Key: route.source!)
                    }else{
                        if route.source?.nodeType == .base{
                            //print("..previous is a base, do nothing")
                        }
                        if sourceLevel! < thisLevel!+1 {
                            //print("..previous level\(sourceLevel!) < \(thisLevel!) + 1: \(thisLevel!+1),do nothing")
                        }
                    }
                }
            }
        }
        
    }
    
    func addLine(source:Node, destination: Node, lineID: inout Int) {
        //print("<add line into graph>")
        let newLine = RouteLine(form: source, to: destination)
        source.neighbors.append(newLine)
        destination.upstreams.append(newLine)
        //获得起始点的web level
        newLine.web = source.web
        newLine.level = source.level!
        
        lineID += 1
        newLine.id = lineID
        
        //向下一级节点传递web level
        if self.graphtype == .suspend{
            destination.level = newLine.level!-1
            destination.web = (key: newLine.web?.key, value: newLine.level!-1)
                as? (key: Int, value: Int)
        }else{
            if newLine.source?.nodeType == .base {
                destination.level = 1
                destination.web = (key: newLine.web?.key, value: 1)
                    as? (key: Int, value: Int)
            }else{
                destination.level = newLine.level!+1
                destination.web = (key: newLine.web?.key, value: newLine.level!+1)
                    as? (key: Int, value: Int)
            }
        }
    }
    
    func getNode() -> [Node]{
        return canvas
    }
    
    
    func getLine () -> [RouteLine] {
        //这个要放在最前面，因为不知道以前发生过什么
        resetVisitabel()
        var getLines = [RouteLine]()
        var lineCount = 0
        
        let graphQueue = Queue<Node>()
        if let center = self.centerNode {
            graphQueue.enqueue(Key: center)
        }
        
        while !graphQueue.inEmpty {
            let item = graphQueue.dequeue() as Node!
            if let neigborLines = item?.neighbors{
                for route in neigborLines {
                    
                    if !getLines.contains(route){
                        getLines.append(route)
                        lineCount += 1
                    }
                    
                    if route.destination?.visited == false{
                        graphQueue.enqueue(Key: route.destination!)
                    }
                }
                for route in (item?.upstreams)! {
                    if !getLines.contains(route){
                        getLines.append(route)
                        lineCount += 1
                    }
                    if route.source?.visited == false{
                        graphQueue.enqueue(Key: route.source!)
                    }
                }
            }
            item?.visited = true
        }//end while
    
        
        //print("get \(getLines.count)/\(lineCount) lines form the graph\((self.webID)!)")
        return getLines
    }
 
    
    //找到当前最大的webid值
    func webCount(webIDs: [Int]) -> Int {
       
        if webIDs.count == 0{
            return 1
        }
        
        var maxwebid = 0
        var webid = [Int]()
        for id in webIDs {
            webid.append(id)
        }
        maxwebid = webid.max()! + 1
        return maxwebid
    }
  
    func propagateInsideLevel(start: Node) {
        let field = Queue<Node>()
        field.enqueue(Key: start)
        
        let webid = start.web?.key
        
        
        var i = start.level! + 1
        while !field.inEmpty {
            let item = field.dequeue() as Node!
            let newWeb: (key:Int, value: Int) = (key:webid!, value: i)
            if let oldWeb = item?.web {
                if oldWeb.value > newWeb.value{
                    item?.web = newWeb
                    item?.level = i
                }
            }
            for route in (item?.neighbors)! {
                route.web = route.source?.web!
                route.level = (route.source?.level)!
                if route.destination?.visited == false{
                    field.enqueue(Key: route.destination!)
                }
            }
            item?.visited = true
            i = i+1
        }//end while
        resetVisitabel()
    }

    
   
    
    func resetVisitabel(){
        let graphQueue = Queue<Node>()
        graphQueue.enqueue(Key: self.centerNode!)
        
        while !graphQueue.inEmpty {
            let item = graphQueue.dequeue() as Node!
            for route in (item?.neighbors)! {
                //修改这个属性
                if route.destination?.visited == true{
                    graphQueue.enqueue(Key: route.destination!)
                }
            }
            for route in (item?.upstreams)! {
                if route.source?.visited == true{
                    graphQueue.enqueue(Key: route.source!)
                }
            }
            //重置
            item?.visited = false
        }//end while
    }
    
    func printWebLevel() {
        resetVisitabel()
        
        var lineCount = 0
        var saveLines = [RouteLine]()
        
        let graphQueue = Queue<Node>()
        graphQueue.enqueue(Key: self.centerNode!)
        print("\n\n")
        print(">>>>>>print graph information. webid:\((self.webID)!)<<<<<<")
        print("root node is No.\((centerNode?.id)!)")
        while !graphQueue.inEmpty {
            let item = graphQueue.dequeue() as Node!
            print("check node No.\((item?.id)!)..")
            
            if let number = item?.neighbors.count {
                print("it has \(number) downstream lines")
                for route in (item?.neighbors)! {
                    print("check downstream line\((route.id)!) ")
                    if !saveLines.contains(route){
                        print("..put this line in the storage")
                        saveLines.append(route)
                        for line in saveLines{
                            print("..storge have line\((line.id)!)")
                        }
                        lineCount += 1
                    }else{
                        print("..it already is in sotrage")
                        for line in saveLines{
                            print("..storge have line\((line.id)!)")
                        }
                    }
                    
                    print("..its [web:levle] = \((route.web)!)")
                    if let sn = route.source {
                        print("..it source is node No.\((sn.id)!)")
                    }else{
                        print("it don't has source node")
                    }
                    if let dn = route.destination{
                        print("..it destination is node No.\((dn.id)!)")
                        print("..it destination No.\((dn.id)!) visitable is \((dn.visited))")
                    }else{
                        print("..it don't has destination node")
                    }
                    if route.destination?.visited == false{
                        print("..it destination doesn't be visited, check this node ..\n")
                        graphQueue.enqueue(Key: route.destination!)
                        //route.destination?.visited = true
                    }
                }
            }else{
                print("..it has 0 downstream line\n")
            }
            
        
            
            if let number = item?.upstreams.count {
                print("it has \(number) upstream lines")
                for route in (item?.upstreams)! {
                    print("check upstream line\((route.id)!) ")
                    if !saveLines.contains(route){
                        print("..put this line in the storage")
                        saveLines.append(route)
                        for line in saveLines{
                            print("..storge have line\((line.id)!)")
                        }
                        lineCount += 1
                    }else{
                        print("..it already is in sotrage")
                        for line in saveLines{
                            print("..storge have line\((line.id)!)")
                        }
                    }
                    if let sn = route.source {
                        print("..it source is node No.\((sn.id)!)")
                        print("..it source No.\((sn.id)!) visitable is \((sn.visited))")
                        
                    }else{
                        print("it don't has source node")
                    }
                    if let dn = route.destination{
                        print("..it destination is node No.\((dn.id)!)")
                    }else{
                        print("..it don't has destination node")
                    }
                    if route.source?.visited == false{
                        print("..it source doesn't be visited, check this node ..\n")
                        graphQueue.enqueue(Key: route.source!)
                        //route.source?.visited = true
                    }
                }
            }else{
                print("..it has 0 upstream line\n")
            }
            //重置
            item?.visited = true
            print("\n node No.\((item?.id)!) visitable \((item?.visited)!)\n")
        }//end while
        
        print("there are \(lineCount) lines in this graph\((self.webID)!)")
    }
}

extension WebGraph {
    
    func BFSwithDestination(from source: Node, to destination: Node) -> [RouteLine]? {
        resetVisitabel()
        
        let queue = Queue<Node>()
        queue.enqueue(Key: source)
        
        var visits: [Node : Visit] = [source : .source]
        
        while let visitedVertext = queue.dequeue() {
            if visitedVertext == destination {
                var vertex = destination // 1
                var route: [RouteLine] = [] // 2
                
                while let visit = visits[vertex],
                    case .edge(let edge) = visit { // 3
                        
                        route = [edge] + route
                        vertex = edge.source! // 4
                        
                }
                return route // 5
            }
            
            let neighbors = visitedVertext.neighbors
            for edge in neighbors {
                if visits[edge.destination!] == nil {
                    queue.enqueue(Key: edge.destination!)
                    visits[edge.destination!] = .edge(edge)
                }
            }
        }
        return nil
    }
    
    //向下游的广度优先搜索
    func breadFirstSearch(startingNode: Node){
        
        //建立一个列队
        let graphQueue = Queue<Node>()
        
        //放入列队第一个node
        graphQueue.enqueue(Key: startingNode)
        
        while !graphQueue.inEmpty {
            // 不停地获得队头，后面跟上
            let item = graphQueue.dequeue() as Node!
            //获得队头的所有连线
            for route in (item?.neighbors)! {
                //找连线终端的node，如果这个node没被检索过
                if route.destination?.visited == false{
                    //把它加入列队
                    graphQueue.enqueue(Key: route.destination!)
                }
            }
            //标记此node已经被检索过了
            item?.visited = true
        }//end while
    }//end funtion
    
    //向上游的深度优先搜索
    func depthFirstSearch(startingNode: Node){
        var visited = Set<Node>()
        let stack = Stack<Node>()
        
        //放入第一个node
        stack.push(startingNode)
        visited.insert(startingNode)
        
        //peek是拿出stack里的第一个
        outer: while let item = stack.peek() {
            //如果再也找不到上游线条了就退出
            guard item.upstreams.count > 0 else{
                _ = stack.pop()
                return }
            
            for route in item.upstreams {
                if !visited.contains(route.source!){
                    visited.insert(route.source!)
                    //放在队尾
                    stack.push(route.source!)
                    continue outer
                }
            }
            //删掉队尾
            _ = stack.pop()
        }
    }
}


extension WebGraph: Hashable {
    public var hashValue: Int {
        return "\(canvas)^\(webID ?? 0)".hashValue
    }
}

extension WebGraph: Equatable {
    static func == (lhs: WebGraph, rhs: WebGraph) -> Bool {
        return
            lhs.webID == rhs.webID
        //lhs.canvas == rhs.canvas
        
    }
}
