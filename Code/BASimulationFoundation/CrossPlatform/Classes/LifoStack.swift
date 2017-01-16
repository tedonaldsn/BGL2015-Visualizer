//
//  LifoStack.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 4/25/15.
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



// Last-In-First-Out LifoStack (versus FIFO)
//
final public class LifoStack<T>: Sequence {
    
    // MARK: Data
    
    fileprivate var priv_items = [T]()
    
    public var isEmpty: Bool { return priv_items.isEmpty }
    public var count: Int { return priv_items.count }
    
    public var asArray: Array<T> {
        var ar = Array<T>()
        ar.append(contentsOf: priv_items)
        // return Array(ar.reverse())
        return ar
    }
    
    // MARK: Initialization
    
    public init() {
    }
    
    public convenience init(lifoItems: [T]) {
        self.init()
        priv_items.append(contentsOf: lifoItems)
    }
    
    public convenience init(lifoStack: LifoStack<T>) {
        self.init(lifoItems: lifoStack.priv_items)
    }
    

    // MARK: Operation
    
    public func clear() -> LifoStack<T> {
        priv_items.removeAll(keepingCapacity: true)
        return self
    }
    
    public func push(_ item: T) -> LifoStack<T> {
        priv_items.append(item)
        return self
    }
    
    public func pop() -> T {
        return priv_items.removeLast()
    }
    
    public func lookAhead() -> T {
        return priv_items.last!
    }
    
    // MARK: Subscript
    
    public subscript (index: Int) -> T {
        get { return priv_items[index] }
    }
    
    
    // MARK: SequenceType
    
    public func makeIterator() -> IndexingIterator<Array<T>> {
        return priv_items.makeIterator()
    }
    
} // end class LifoStack

