import Foundation

extension NSSet {
    /// Converts NSSet to array
    func toArray<T>() -> [T]? {
        return self.allObjects as? [T]
    }
}
