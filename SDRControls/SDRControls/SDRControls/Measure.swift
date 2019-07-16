import Foundation

class Measure {
    private static var time: [String: UInt64] = [:]
    
    class func start(tag: String) {
        
        time[tag] = mach_absolute_time()
    }
    
    class func end(tag: String) {
        
        let t2 = mach_absolute_time()
        
        if let t1 = time.removeValue(forKey: tag) {
            
            let elapsed = t2 - t1
            var timeBaseInfo = mach_timebase_info_data_t()
            mach_timebase_info(&timeBaseInfo)
            let elapsedTime = elapsed * UInt64(timeBaseInfo.numer) / UInt64(timeBaseInfo.denom) / 1000
            
            print("elapsed (us) for \(tag): \(elapsedTime)")
        }
    }
    
    class func time(tag: String, _ block: (() -> ())) {
        
        let t1 = mach_absolute_time()
        
        block()
        
        let t2 = mach_absolute_time()
        
        let elapsed = t2 - t1
        var timeBaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timeBaseInfo)
        let elapsedTime = elapsed * UInt64(timeBaseInfo.numer) / UInt64(timeBaseInfo.denom) / 1000
        print("elapsed (us) for \(tag): \(elapsedTime)")
    }
}
