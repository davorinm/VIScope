
import Foundation

final class LinkedListNode<T> {
    fileprivate var next: LinkedListNode?
    fileprivate weak var previous: LinkedListNode?
    
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}


final class LinkedList<T> {
    typealias Node = LinkedListNode<T>
    
    private (set) var first: Node?
    private (set) var last: Node?
    var isEmpty: Bool { return first == nil }
    
    
    @discardableResult
    func addFirst(_ value: T) -> Node {
        let node = LinkedListNode(value)
        addFirst(node: node)
        return node
    }
    
    func addFirst(node: Node) {
        assert(node.next == nil)
        assert(node.previous == nil)
        
        if isEmpty {
            first = node
            last = node
        } else {
            first?.previous = node
            node.next = first
            first = node
        }
    }
    
    func remove(_ node: Node) {
        node.previous?.next = node.next
        node.next?.previous = node.previous
        
        if first === node {
            first = node.next
        }
        
        if last === node {
            last = node.previous
        }
        
        node.next = nil
        node.previous = nil
    }
    
    func removeAll() {
        first = nil
        last = nil
    }
    
    func forEach(body: (Node) -> ()) {
        var node = first
        while(node != nil) {
            body(node!)
            node = node?.next
        }
    }
}
