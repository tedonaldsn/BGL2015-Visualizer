//
//  DataKeyPathSearchIterator.swift
//  BASimStateMachine
//
//  Created by Tom Donaldson on 3/22/15.
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
//  Iterator used in search for matching items down through an object
//  hierarchy. Iterates forward only, but permits seeing all elements
//  in the path, unlike generators.
//
//  Used to implement something akin to Cocoa's Objective-C key-value
//  encoding.
//
//  Expectation is that a receiver that can satisfy the entire remaining
//  path and only return the final object should do so. This is in contrast
//  to Apple's get/set value-at-key in that receivers can see the entire
//  path, versus one segment at a time. It is possible to short-circuit
//  the search path if a receiver is going to be the final destination
//  anyway.






final public class DataKeyPathSearchIterator {
    
    public var asString: String {
        return hasPath ? priv_path!.asString : "<nil>"
    }
    
    public var hasPath: Bool {
        return priv_path != nil
    }
    public var path: DataKeyPath {
        precondition(hasPath)
        return priv_path!
    }
    
    public var count: Int { return path.count }
    public var isEmpty: Bool { return path.isEmpty }
    
    public var index: Int {
        get { return priv_index }
        set {
            precondition(newValue >= 0)
            precondition(newValue <= path.count)
            priv_index = newValue
        }
    }
    
    public var isAtFirst: Bool { return priv_index == 0 }
    public var isAtEnd: Bool { return priv_index == path.count }
    public var isCurrent: Bool { return !isAtEnd }
    
    public var isTerminal: Bool { return priv_index == path.count - 1 }
    public var terminal: Identifier {
        return isTerminal ? current : PredefinedIdentifiers.nilIdentifier
    }
    
    
    public var lookBehind: Identifier {
        return !isAtFirst ? path[priv_index - 1] : PredefinedIdentifiers.nilIdentifier
    }
    public var current: Identifier {
        return isCurrent ? path[priv_index] : PredefinedIdentifiers.nilIdentifier
    }
    public var lookAhead: Identifier {
        return !isAtEnd ? path[priv_index + 1] : PredefinedIdentifiers.nilIdentifier
    }
    
    public var next: Identifier {
        precondition(!isAtEnd)
        let nx = path[priv_index]
        priv_index += 1
        return nx
    }
    

    // MARK: Initialization
    
    public init(path: DataKeyPath) {
        priv_path = path
    }
    
    public convenience init(dotDelimitedKeyPath: String) {
        self.init(path: DataKeyPath(dotDelimitedKeyPath: dotDelimitedKeyPath))
    }
    

    public convenience init(copyFrom: DataKeyPathSearchIterator) {
        precondition(copyFrom.hasPath)
        self.init(path: copyFrom.path)
        priv_index = copyFrom.index
    }
    
    public func clone() -> DataKeyPathSearchIterator {
        return DataKeyPathSearchIterator(copyFrom: self)
    }
    
    public func cloneAtNext() -> DataKeyPathSearchIterator {
        return clone().advanceToNext()
    }
    
    
    // MARK: Reposition
    
    public func resetToFirst() -> DataKeyPathSearchIterator {
        priv_index = 0
        return self
    }
    public func advanceToNext() -> DataKeyPathSearchIterator {
        if !isAtEnd {
            priv_index += 1
        }
        return self
    }
    
    
    // MARK: Matching
    
    public func isQualifiedWith(_ id: Identifier) -> Bool {
        return path.isQualifiedWith(id)
    }
    public func isCurrentMatch(_ id: Identifier) -> Bool {
        return path.isMatchAt(priv_index, with: id)
    }
    public func isTerminalMatch(_ id: Identifier) -> Bool {
        return path.isMatchAt(count - 1, with: id)
    }
    
    public func isBehindMatch(_ id: Identifier) -> Bool {
        return path.isMatchAt(priv_index - 1, with: id)
    }
    public func isAheadMatch(_ id: Identifier) -> Bool {
        return path.isMatchAt(priv_index + 1, with: id)
    }
    
    // MARK: *Private*
    
    fileprivate var priv_path: DataKeyPath? = nil
    fileprivate var priv_index: Int = 0
    
    
    
} // end class DataKeyPathSearchIterator
