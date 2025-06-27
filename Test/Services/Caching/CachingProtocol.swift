import UIKit

protocol CachingProtocol {
    func getObject(forKey key: NSURL) -> UIImage?
    func setObject(_ object: UIImage, forKey key: NSURL, cost: Int)
    func removeObject(forKey key: NSURL)
    func removeAllObjects()
    func trim(toCost cost: Int)
}

final class ImageCache: CachingProtocol {
    private let cache: NSCache<NSURL, UIImage>
    private let queue = DispatchQueue(label: "com.reviewsapp.imagecache", attributes: .concurrent)
    private var keyTracker = NSHashTable<NSURL>.weakObjects()
    private var currentCost: Int = 0
    
    init(countLimit: Int, totalCostLimit: Int) {
        self.cache = NSCache<NSURL, UIImage>()
        self.cache.countLimit = countLimit
        self.cache.totalCostLimit = totalCostLimit
        
        subscribeToNotifications()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    private func subscribeToNotifications() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getObject(forKey key: NSURL) -> UIImage? {
        queue.sync {
            return cache.object(forKey: key)
        }
    }
    
    func setObject(_ object: UIImage, forKey key: NSURL, cost: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            if self.currentCost + cost > self.cache.totalCostLimit {
                self.trim(toCost: Int(Float(self.cache.totalCostLimit) * 0.75))
            }

            self.cache.setObject(object, forKey: key, cost: cost)
            self.keyTracker.add(key)
            self.currentCost += cost
        }
    }
    
    func removeObject(forKey key: NSURL) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            if let object = self.cache.object(forKey: key) {
                let cost = object.cost
                self.currentCost -= cost
            }
            
            self.cache.removeObject(forKey: key)
            self.keyTracker.remove(key)
        }
    }
    
    func removeAllObjects() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            self.cache.removeAllObjects()
            self.keyTracker.removeAllObjects()
            self.currentCost = 0
        }
    }
    
    func trim(toCost targetCost: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let keys = self.keyTracker.allObjects
            
            for key in keys {
                if self.currentCost <= targetCost { break }
                self.removeObject(forKey: key)
            }
        }
    }
    
    // MARK: - Notification Handlers
    
    @objc private func handleMemoryWarning() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.trim(toCost: self.cache.totalCostLimit / 2)
        }
    }
    
    @objc private func handleDidEnterBackground() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.trim(toCost: self.cache.totalCostLimit / 4)
        }
    }
}

private extension UIImage {
    var cost: Int {
        return Int(size.width * size.height * 4)
    }
}

