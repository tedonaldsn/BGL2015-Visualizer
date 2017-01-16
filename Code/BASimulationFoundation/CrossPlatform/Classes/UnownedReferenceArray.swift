//
//  UnownedReferenceArray.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 7/4/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//

import Foundation


/*:
# struct UnownedReferenceArray<ItemType: AnyObject>

Generic array of "weak" references to class instances.

Used when a collection of objects is needed without causing circular references
that would prevent automatic deallocation of object. Useful in structures such 
as neural nets where there will be many mutual references, direct and indirect.

Note that the UnownedReferenceArray<ItemType> interface accepts and returns ItemType,
not the UnownedReference<ItemType> wrapper that it holds internally.



# struct UnownedReference<ItemType: AnyObject>

The wrapper item used by UnownedReferenceArray<ItemType> to maintain an 
unowned reference to an object.



# UnownedReferenceArrayGenerator<ItemType: AnyObject>

Used to fullfil the SequenceType protocol on UnownedReferenceArray<ItemType>.
This generator returns ItemType rather than the UnownedReference<ItemType>.

*/




public struct UnownedReference<ItemType: AnyObject> {
    public unowned let item: ItemType
}




public struct UnownedReferenceArrayGenerator<ItemType: AnyObject>: GeneratorType {
    private var priv_indexOfNext: Int = 0
    private let priv_referenceList: UnownedReferenceArray<ItemType>
    
    public init(unownedObjects: UnownedReferenceArray<ItemType>) {
        priv_referenceList = unownedObjects
    }
    
    @inline(__always) public mutating func next() -> ItemType? {
        if priv_indexOfNext < priv_referenceList.count {
            let item = priv_referenceList[priv_indexOfNext]
            priv_indexOfNext += 1
            return item
        }
        return nil
    }
} // end class UnownedReferenceArrayGenerator<ItemType>





public struct UnownedReferenceArray<ItemType: AnyObject>: SequenceType {
    
    // MARK: Data
    
    public var count: Int {
        @inline(__always) get { return priv_list.count }
    }
    public var isEmpty: Bool {
        @inline(__always) get { return priv_list.isEmpty }
    }
    
    
    // MARK: Initialization
    
    public init() {
        
    }
    
    
    // MARK: Build
    
    @inline(__always) public mutating
    func append(item: ItemType) -> UnownedReferenceArray<ItemType> {
        priv_list.append(UnownedReference<ItemType>(item: item))
        return self
    }
    
    @inline(__always) public mutating
    func extend(array: UnownedReferenceArray<ItemType>) -> UnownedReferenceArray<ItemType> {
        priv_list.appendContentsOf(array.priv_list)
        return self
    }
    @inline(__always) public mutating
    func extend(array: [ItemType]) -> UnownedReferenceArray<ItemType> {
        for element in array { append(element) }
        return self
    }
    
    // MARK: Tear Down
    
    public mutating func removeAll() -> UnownedReferenceArray<ItemType> {
        priv_list.removeAll()
        return self
    }
    
    // MARK: Raw List
    
    public func asRawArray() -> [ItemType] {
        var list = [ItemType]()
        for item in self {
            list.append(item)
        }
        return list
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
    
    
    // MARK: Subscript
    
    subscript (index: Int) -> ItemType {
        @inline(__always) get { return priv_list[index].item }
        @inline(__always) set { priv_list[index] = UnownedReference<ItemType>(item: newValue) }
    }
    

    // MARK: SequenceType
    
    public func generate() -> UnownedReferenceArrayGenerator<ItemType> {
        return UnownedReferenceArrayGenerator<ItemType>(unownedObjects: self)
    }
    
    
    // MARK: *Private* Data
    
    var priv_list = [UnownedReference<ItemType>]()
    
} // end struct UnownedReferenceArray<ItemType>



