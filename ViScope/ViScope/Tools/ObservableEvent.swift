import Foundation

public class ObservableEvent<Value> {
    
    public typealias ObservableEventHandler = (Value) -> ()
    private var eventHandlers: [ObservableEventHandlerWrapper<Value>] = []
    
    private var onLastUnsubscribe: (() -> Void)?
    
    init(onLastUnsubscribe: (() -> Void)? = nil) {
        self.onLastUnsubscribe = onLastUnsubscribe
    }
    
    public func subscribe(_ handler: @escaping ObservableEventHandler) -> Disposable {
        let wrapper = ObservableEventHandlerWrapper(handler, observer: self)
        eventHandlers.append(wrapper)
        
        return DisposableImpl {
            if let index = self.eventHandlers.index(where: { $0 === wrapper }) {
                self.eventHandlers.remove(at: index)
            } else {
                assertionFailure()
            }
        }
    }
    
    public func subscribe(_ observer: AnyObject, _ handler: @escaping ObservableEventHandler) {
        if (eventHandlers.contains { (wrapper: ObservableEventHandlerWrapper<Value>) -> Bool in
            if let wrapperObserver = wrapper.observer, wrapperObserver === observer {
                return true
            }
            return false
        }) {
            return
        }
        
        let wrapper = ObservableEventHandlerWrapper(handler, observer: observer)
        eventHandlers.append(wrapper)
    }
    
    public func unsubscribe(_ observer: AnyObject) {
        eventHandlers = eventHandlers.filter { (event: ObservableEventHandlerWrapper<Value>) -> Bool in
            if let obs = event.observer {
                return obs !== observer
            }
            
            // Also remove nil objects
            return false
        }
        
        checkEventHandlers()
    }
    
    func raise(_ value: Value) {
        removeInvalidObservers()
        eventHandlers.forEach { $0.raise(value) }
    }
    
    private func removeInvalidObservers() {
        eventHandlers = eventHandlers.filter { (event: ObservableEventHandlerWrapper<Value>) -> Bool in
            return event.observer != nil
        }
        
        checkEventHandlers()
    }
    
    private func checkEventHandlers() {
        if eventHandlers.isEmpty {
            onLastUnsubscribe?()
        }
    }
}

fileprivate class ObservableEventHandlerWrapper<Value> {
    private let handler: ObservableEvent<Value>.ObservableEventHandler
    weak var observer: AnyObject?
    
    init(_ handler: @escaping ObservableEvent<Value>.ObservableEventHandler, observer: AnyObject) {
        self.handler = handler
        self.observer = observer
    }
    
    func raise(_ value: Value) {
        if observer == nil { return }
        handler(value)
    }
}

public class ObservableProperty<Value>: ObservableEvent<Value> {
    public var value: Value {
        didSet {
            if shouldRaise(new: value, old: oldValue) {
                super.raise(value)
            }
        }
    }
    
    init(value: Value) {
        self.value = value
    }
    
    override func raise(_ value: Value) {
        self.value = value
    }
    
    func shouldRaise(new: Value, old: Value) -> Bool {
        return true
    }
    
    // MARK: - Subscribers with raise
    
    func subscribeWithRaise(_ observer: AnyObject, _ handler: @escaping (Value) -> ()) {
        handler(self.value)
        
        super.subscribe(observer, handler)
    }
    
    func subscribeWithRaise(_ handler: @escaping (Value) -> ()) -> Disposable {
        handler(self.value)
        
        let disposable = super.subscribe(handler)
        return disposable
    }
}

public class ObservableFilteredProperty<Value: Equatable>: ObservableProperty<Value> {
    override func shouldRaise(new: Value, old: Value) -> Bool {
        return old != new
    }
}
