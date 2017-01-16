//
//  SegmentedArraySegment.swift
//  BASimulationModel
//
//  Created by Tom Donaldson on 7/30/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//

import Foundation



public class SegmentedArraySegment<ItemType> {
    
    // MARK: Data
    
    public var array: [ItemType]
    
    public var indexOfFirstItem: Int = 0 {
        willSet { assert(newValue >= 0) }
    }
    var indexOfLastItem: Int {
        return indexOfFirstItem + (count - 1)
    }
    
    public var count: Int { return array.count }
    public var isEmpty: Bool { return array.isEmpty }
    
    // MARK: Initialization
    
    public init(array: [ItemType]) {
        self.array = array
    }
    
    // MARK: Access
    
    func isIndexInRange(index: Int) -> Bool {
        return !isEmpty && index >= indexOfFirstItem && index <= indexOfLastItem
    }
    public func itemAtIndex(index: Int) -> ItemType {
        return array[index]
    }
    
} // end protocol SegmentedArraySegment




