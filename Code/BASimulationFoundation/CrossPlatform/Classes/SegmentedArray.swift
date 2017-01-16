//
//  SegmentedArray.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 7/28/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//

import Foundation
import GameplayKit



public class SegmentedArrayGeneratorBase<ItemType: AnyObject>: GeneratorType {
    public func next() -> ItemType? {
        return nil
    }
}



public final class SegmentedArrayGenerator<ItemType: AnyObject>: SegmentedArrayGeneratorBase<ItemType> {
    private var priv_indexOfNext: Int = 0
    private let priv_list: SegmentedArray<ItemType>
    
    public init(list: SegmentedArray<ItemType>) {
        priv_list = list
    }
    
    public override func next() -> ItemType? {
        if priv_indexOfNext < priv_list.count {
            let item = priv_list[priv_indexOfNext]
            priv_indexOfNext += 1
            return item
        }
        return nil
    }
} // end class SegmentedArrayGenerator<ItemType>




public final class RandomizedSegmentedArrayGenerator<ItemType: AnyObject>: SegmentedArrayGeneratorBase<ItemType> {
    
    private let priv_list: Array<ItemType>
    private var priv_index: Int = 0
    
    public init(list: SegmentedArray<ItemType>) {
        let randomizer = GKRandomDistribution(randomSource: GKRandomSource(),
            lowestValue: 0,
            highestValue: list.count - 1)

        var randomizedArray = list.array
        let itemCount = randomizedArray.count
        for ix in 0..<itemCount {
            let randIx = randomizer.nextInt()
            let item = randomizedArray[ix]
            randomizedArray[ix] = randomizedArray[randIx]
            randomizedArray[randIx] = item
        }
        
        priv_list = randomizedArray
    }
    
    public override func next() -> ItemType? {
        var item: ItemType? = nil
        if priv_index < priv_list.count {
            item = priv_list[priv_index]
            priv_index += 1
        }
        return item
    }
    
    // MARK: *Private* Data
    
    
} // end class RandomizedSegmentedArrayGenerator<ItemType>






public struct SegmentedArray<ItemType: AnyObject>: SequenceType {
    
    // MARK: Data
    
    public var count: Int { return priv_count }
    public var isEmpty: Bool { return priv_count == 0 }
    
    public var segments: [SegmentedArraySegment<ItemType>] {
        return priv_segments
    }
    public var array: Array<ItemType> {
        var list = [ItemType]()
        for segment in segments { list.appendContentsOf(segment.array) }
        return list
    }
    
    // MARK: Initialization
    
    public init(segments: [SegmentedArraySegment<ItemType>]? = nil) {
        if let initialSegments = segments {
            self.appendContentsOf(initialSegments)
        }
    }
    
    
    // MARK: Build
    
    public mutating func append(segment: SegmentedArraySegment<ItemType>) -> SegmentedArray<ItemType> {
        segment.indexOfFirstItem = priv_count
        priv_segments.append(segment)
        priv_count += segment.count
        return self
    }
    
    // WARNING: indexOfFirstItem will be modified in segments.
    //
    public mutating func appendContentsOf(newSegments: [SegmentedArraySegment<ItemType>]) -> SegmentedArray<ItemType> {
        for segment in newSegments {
            append(segment)
        }
        return self
    }
    
    
    // MARK: Filter, Map, Reduce
    
    public func filter(includeElement: (ItemType) -> Bool) -> [ItemType] {
        var filtered = [ItemType]()
        for item in self {
            if includeElement(item) {
                filtered.append(item)
            }
        }
        return filtered
    }
    
    public func map<ToResultType>(transform: (ItemType) -> ToResultType) -> [ToResultType] {
        var mapping = [ToResultType]()
        for item in self {
            mapping.append(transform(item))
        }
        return mapping
    }
    
    public func reduce<ToResultType>(initial: ToResultType,
        combine: (ToResultType, ItemType) -> ToResultType) -> ToResultType {
            
            var result = initial
            for item in self {
                result = combine(result, item)
            }
            return result
    }
    
    
    // MARK: Indexed Access
    
    public func itemAtIndex(index: Int) -> ItemType? {
        assert(index < count)
        
        var item: ItemType? = nil
        
        for segment in priv_segments {
            if segment.isIndexInRange(index) {
                let rawIndex = index - segment.indexOfFirstItem
                item = segment.itemAtIndex(rawIndex)
            }
        }
        assert(item != nil)
        return item
    }
    
    
    // MARK: Subscript
    
    subscript(index: Int) -> ItemType {
        get {
            let item: ItemType? = itemAtIndex(index)
            return item!
        }
    }
    
    
    // MARK: SequenceType
    
    public func generate() -> SegmentedArrayGenerator<ItemType> {
        return SegmentedArrayGenerator<ItemType>(list: self)
    }
    
    // MARK: *Private* Methods
    
    
    
    // MARK: *Private* Data
    
    private var priv_count: Int = 0
    private var priv_segments = [SegmentedArraySegment<ItemType>]()
    
    
} // end struct SegmentedArray<ItemType>

