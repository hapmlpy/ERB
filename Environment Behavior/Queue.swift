/*
  First-in first-out queue (FIFO)

  New elements are added to the end of the queue. Dequeuing pulls elements from
  the front of the queue.

  http://waynewbishop.com/swift/stacks-queues
*/
import Foundation

class QNode<T> {
    var Key: T?
    var next: QNode?
    init (){
        Key = nil
        next = nil
    }
}

public class Queue<T> {
  
    var top: QNode<T>?
    
    public var inEmpty: Bool {
        if let _: T = self.top?.Key {
            return false
        }else{
            return true
        }
    }

    public var count: Int {
        if top?.Key == nil {
            return 0
        }else{
            var current: QNode<T> = top!
            var x: Int = 1
            
            while current.next != nil {
                current = current.next!
                x += 1
            }
            return x
        }
    }

  //加入queue队尾,形成链表
    public func enqueue(Key: T) {

        if top == nil {
            top = QNode<T>()
        }
        if top?.Key == nil {
            top?.Key = Key
            return
        }

        var current: QNode = top!

        while current.next != nil {
            current = current.next!
        }

        let childToUse: QNode<T> = QNode<T>()
        childToUse.Key = Key
        current.next = childToUse
    }

    
    //把队头删掉一个，下一个补上
    public func dequeue() -> T? {

        let testitem: T? =  self.top?.Key
        if testitem == nil { return nil }

        let topitem: T? = top?.Key

        if let nextitem = top?.next {
            top = nextitem
        }else{
            top = nil
        }
        return topitem
    }
    //获得列队头
    public func peek() -> T? {
        return top?.Key!
    }

}
