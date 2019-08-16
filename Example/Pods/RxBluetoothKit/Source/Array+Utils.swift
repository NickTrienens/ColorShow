import Foundation

extension Array where Element: Equatable {
    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = firstIndex(of: object) {
            remove(at: index)
            return true
        }
        return false
    }
}
