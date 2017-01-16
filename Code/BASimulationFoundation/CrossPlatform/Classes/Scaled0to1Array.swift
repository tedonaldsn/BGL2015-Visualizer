//
//  Scaled0to1Array.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 7/3/15.
//  
//  Copyright © 2017 Tom Donaldson.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

//

import Foundation

/*:
# struct Scaled0to1Array

Array of range restricted double precision floating point numbers.

## Range: <0.0...1.0>

Restriction is to the range of values used within the simulation to represent
activation levels, connection weights, and others.

Assertions guarantee that at least during debugging the value cannot be out
of range.

## Performance

Everything that can be explicitly inlined, is. The Swift compiler always removes
assert() in optimized code, so the assertions that guarantee the range
restriction will not affect release code.
*/




public struct Scaled0to1Array: Sequence {
    
    // MARK: Data
    
    public var count: Int { return priv_list.count }
    public var isEmpty: Bool { return priv_list.isEmpty }
    
    public var rawValues: [Double] {
        get { return priv_list }
        set {
            let _ = removeAll()
            let _ = appendContentsOf(newValue)
        }
    }
    
    
    public var values: [Scaled0to1Value] {
        get {
            return priv_list.map( {
                (value: Double) -> Scaled0to1Value in Scaled0to1Value(rawValue: value)
            } )
        }
        set {
            let _ = removeAll()
            let _ = appendContentsOf(newValue)
        }
    }
    
    
    // MARK: Initialization
    
    public init() {
        
    }
    
    
    // MARK: Build
    
    public mutating func append(_ rawValue: Double) -> Scaled0to1Array {
        assert(Scaled0to1Value.isWithinLimits(rawValue))
        priv_list.append(rawValue)
        return self
    }
    
    public mutating func append(_ value: Scaled0to1Value) -> Scaled0to1Array {
        priv_list.append(value.rawValue)
        return self
    }
    
    
    public mutating func appendContentsOf(_ array: Scaled0to1Array) -> Scaled0to1Array {
        priv_list.append(contentsOf: array.priv_list)
        return self
    }
    public mutating func appendContentsOf(_ array: [Scaled0to1Value]) -> Scaled0to1Array {
        for element in array {
            let _ = append(element)
        }
        return self
    }
    public mutating func appendContentsOf(_ array: [Double]) -> Scaled0to1Array {
        assert(Scaled0to1Value.isWithinLimits(array))
        priv_list.append(contentsOf: array)
        return self
    }
    
    // MARK: Tear Down
    
    public mutating func removeAll() -> Scaled0to1Array {
        priv_list.removeAll()
        return self
    }
    
    // MARK: Filter, Map, Reduce
    
    public func filter(_ includeElement: (Double) -> Bool) -> [Double] {
        return priv_list.filter(includeElement)
    }
    
    public func map<ToResultType>(_ transform: (Double) -> ToResultType) -> [ToResultType] {
        return priv_list.map(transform)
    }
    
    public func reduce<ToResultType>(_ initial: ToResultType,
        combine: (ToResultType, Double) -> ToResultType) -> ToResultType {
            return priv_list.reduce(initial, combine)
    }
    
    
    // MARK: Subscript
    
    subscript (index: Int) -> Double {
        get { return priv_list[index] }
        set {
            assert(Scaled0to1Value.isWithinLimits(newValue))
            priv_list[index] = newValue
        }
    }
    
    subscript (index: Int) -> Scaled0to1Value {
        get { return Scaled0to1Value(rawValue: priv_list[index]) }
        set { priv_list[index] = newValue.rawValue }
    }
    
    
    // MARK: SequenceType
    
    public func makeIterator() -> IndexingIterator<Array<Double>> {
        return priv_list.makeIterator()
    }
    
    
    
    // MARK: *Private* Data
    
    var priv_list = [Double]()
    
} // end struct Scaled0to1Array

