import Foundation

public class ObservableEvent<Value> {
    public typealias ObservableEventHandler = (Value) -> Void
    private var eventHandlers: [ObservableEventHandlerWrapper<Value>] = []
    
    private var onFirstSubscribe: (() -> Void)?
    private var onSubscribe: (() -> Void)?
    private var onLastUnsubscribe: (() -> Void)?
    
    init(onFirstSubscribe: (() -> Void)? = nil, onSubscribe: (() -> Void)? = nil, onLastUnsubscribe: (() -> Void)? = nil) {
        self.onFirstSubscribe = onFirstSubscribe
        self.onSubscribe = onSubscribe
        self.onLastUnsubscribe = onLastUnsubscribe
    }
    
    public func subscribe(_ handler: @escaping ObservableEventHandler) -> Disposable {
        if eventHandlers.isEmpty {
            onFirstSubscribe?()
        }
        
        onSubscribe?()
        
        let wrapper = ObservableEventHandlerWrapper(handler, observer: self)
        eventHandlers.append(wrapper)
        
        return DisposableImpl {
            if let index = self.eventHandlers.firstIndex(where: { $0 === wrapper }) {
                self.eventHandlers.remove(at: index)
            } else {
                assertionFailure()
            }
        }
    }
    
    public func subscribe(_ observer: AnyObject?, _ handler: @escaping ObservableEventHandler) {
        if eventHandlers.isEmpty {
            onFirstSubscribe?()
        }
        
        onSubscribe?()
        
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

private class ObservableEventHandlerWrapper<Value> {
    private let handler: ObservableEvent<Value>.ObservableEventHandler
    weak var observer: AnyObject?
    
    init(_ handler: @escaping ObservableEvent<Value>.ObservableEventHandler, observer: AnyObject?) {
        self.handler = handler
        self.observer = observer
    }
    
    func raise(_ value: Value) {
        if observer == nil {
            return
        }
        
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
    
    init(value: Value, onFirstSubscribe: (() -> Void)? = nil, onSubscribe: (() -> Void)? = nil, onLastUnsubscribe: (() -> Void)? = nil) {
        self.value = value
        super.init(onFirstSubscribe: onFirstSubscribe, onSubscribe: onSubscribe, onLastUnsubscribe: onLastUnsubscribe)
    }
    
    override func raise(_ value: Value) {
        self.value = value
    }
    
    func shouldRaise(new: Value, old: Value) -> Bool {
        return true
    }
    
    // MARK: - Subscribers with raise
    
    func subscribeAndRaise(_ observer: AnyObject?, _ handler: @escaping ObservableEventHandler) {
        super.subscribe(observer, handler)
        
        DispatchQueue.main.async {
            super.raise(self.value)
        }
    }
    
    func subscribeAndRaise(_ handler: @escaping ObservableEventHandler) -> Disposable {
        let disposable = super.subscribe(handler)
        
        DispatchQueue.main.async {
            super.raise(self.value)
        }
        
        return disposable
    }
}

public class ObservableFilteredProperty<Value: Equatable>: ObservableProperty<Value> {
    override func shouldRaise(new: Value, old: Value) -> Bool {
        return old != new
    }
}
