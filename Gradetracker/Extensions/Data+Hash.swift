//
//  Data+Hash.swift
//

import Foundation
import CommonCrypto

extension Data {

    var sha256: Data {
        var hashData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = hashData.withUnsafeMutableBytes { digestBytes in
            self.withUnsafeBytes { messageBytes in
                CC_SHA256(messageBytes.baseAddress, CC_LONG(self.count), digestBytes.baseAddress)
            }
        }
        return hashData
    }

}

extension String {
    func sha256(salt: String) -> Data {
        return (self + salt).data(using: .utf8)!.sha256
    }
}

extension Collection where Element: Comparable, Index == Int {
    func binarySearch(for value: Element, in range: Range<Index>? = nil) -> Index? {
        let range = range ?? startIndex..<endIndex
        
        guard range.lowerBound < range.upperBound else {
            return nil
        }
        
        let size = range.upperBound - range.lowerBound
        let midIndex = range.lowerBound + size / 2
        if self[midIndex] == value {
            return midIndex
        } else if self[midIndex] < value {
            return binarySearch(for: value, in: (midIndex + 1)..<range.upperBound)
        } else {
            return binarySearch(for: value, in: range.lowerBound..<(midIndex))
        }
    }
}

extension Array where Element: Comparable {
    mutating func quickSort() {
        quickSortHelper(start: 0, end: count - 1)
    }
    
    private mutating func quickSortHelper(start: Int, end: Int) {
        if start < end {
            let pivotIndex = partition(start: start, end: end)
            quickSortHelper(start: start, end: pivotIndex - 1)
            quickSortHelper(start: pivotIndex + 1, end: end)
        }
    }
    
    private mutating func partition(start: Int, end: Int) -> Int {
        let pivot = self[end]
        var i = start - 1
        
        for j in start..<end {
            if self[j] <= pivot {
                i += 1
                swapAt(i, j)
            }
        }
        
        swapAt(i + 1, end)
        return i + 1
    }
}
