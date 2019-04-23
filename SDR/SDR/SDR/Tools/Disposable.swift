import Foundation

public protocol Disposable: class {
    func dispose()
}

public class DisposableImpl: Disposable {
    var onDispose: (() -> Void)?
    
    init() {
    }
    
    init(onDispose: @escaping () -> Void) {
        self.onDispose = onDispose
    }
    
    deinit {
        dispose()
    }
    
    public func dispose() {
        if let block = onDispose {
            onDispose = nil
            block()
        }
    }
}

