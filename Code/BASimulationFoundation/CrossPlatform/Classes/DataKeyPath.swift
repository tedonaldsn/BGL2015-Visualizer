//
//  DataKeyPath.swift
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





final public class DataKeyPath: Sequence, Equatable {
    
    // MARK: Class Methods
    
    public class func dotDelimitedStringsToIdentifiers(_ dotDelimitedStrings: String) -> [Identifier] {
        let pathOfStrings = dotDelimitedStringsToPathOfStrings(dotDelimitedStrings)
        return pathOfStringsToIdentifiers(pathOfStrings)
    }
    
    public class func dotDelimitedStringsToPathOfStrings(_ dotDelimitedStrings: String) -> [String] {
        return dotDelimitedStrings.components(separatedBy: ".")
    }
    
    public class func pathOfStringsToIdentifiers(_ pathOfStrings: [String]) -> [Identifier] {
        var identifiers = [Identifier]()
        for stringSeg in pathOfStrings {
            let ident = Identifier(idString: stringSeg)
            identifiers.append(ident)
        }
        return identifiers
    }
    
    
    public class func isValidPathOfStrings(_ pathOfStrings: [String]) -> Bool {
        return indexOfInvalidString(pathOfStrings) >= 0
    }
    public class func isValidDotDelimitedStrings(_ dotDelimitedStrings: String) -> Bool {
        let pathOfStrings = dotDelimitedStringsToPathOfStrings(dotDelimitedStrings)
        return isValidPathOfStrings(pathOfStrings)
    }
    
    // Return negative number if no invalid strings found.
    //
    public class func indexOfInvalidString(_ pathOfStrings: [String]) -> Int {
        var foundAtIndex = -1
        var ix = 0
        for stringId in pathOfStrings {
            if !Identifier.isValidIdentifierString(stringId) {
                foundAtIndex = ix
                break
            }
            ix += 1
        }
        return foundAtIndex
    }
    public class func indexOfInvalidComponent(_ dotDelimitedStrings: String) -> Int {
        let pathOfStrings = dotDelimitedStringsToPathOfStrings(dotDelimitedStrings)
        return indexOfInvalidString(pathOfStrings)
    }
    
    // MARK: Data
    
    public let keys: [Identifier]
    public var count: Int { return keys.count }
    public var isEmpty: Bool { return keys.isEmpty }
    
    public var asString: String {
        let stringKeys: [String] = keys.map({ (key) -> String in key.asString } )
        return stringKeys.joined(separator: ".")
    }
    
    public var first: Identifier {
        precondition(!isEmpty)
        return self[0]
    }
    public var last: Identifier {
        precondition(!isEmpty)
        return self[count - 1]
    }
    
    public var head: DataKeyPath { return DataKeyPath(path: [first]) }
    public var tail: DataKeyPath {
        var list: [Identifier] = keys
        list.self.remove(at: 0)
        return DataKeyPath(path: list)
    }
    

    
    // MARK: Initialization
    //
    //  WARNING: CAUTION: All of these initializers will assert fail if any of
    //      the components in the path are not valid identifiers.
    //
    //      When in doubt, use the class-function validity checks.
    //
    //      The underlying check is Identifier.isValidIdentifierString()
    //
    //  See IdentifierRegEx class for patterns that are acceptable.
    //
    //  Nil data type id is valid for accessing data definitions during
    //  initialization, but may be rejected for accessing data values.
    //
    public init(path: [Identifier]) {
        self.keys = path
    }
    
    public convenience init(pathOfStrings: [String]) {
        let identifiers = DataKeyPath.pathOfStringsToIdentifiers(pathOfStrings)
        self.init(path: identifiers)
    }
    
    public convenience init(dotDelimitedKeyPath: String) {
        let identifiers = DataKeyPath.dotDelimitedStringsToIdentifiers(dotDelimitedKeyPath)
        self.init(path: identifiers)
    }
    
    public convenience init(copyFrom: DataKeyPath) {
        self.init(path: copyFrom.keys)
    }
    
    
    public func prepend(_ headId: Identifier) -> DataKeyPath {
        var newPath: [Identifier] = [headId]
        newPath.append(contentsOf: self.keys)
        return DataKeyPath(path: newPath)
    }
    
    public func append(_ tailId: Identifier) -> DataKeyPath {
        var newPath: [Identifier] = keys
        newPath.append(tailId)
        return DataKeyPath(path: newPath)
    }
    
    
    // MARK: Tests
    
    public func isInRange(_ index: Int) -> Bool {
        return index >= 0 && index < count
    }
    
    public func isMatchAt(_ index: Int, with: Identifier) -> Bool {
        return isInRange(index) ? keys[index] == with : false
    }
    
    public func isQualifiedWith(_ identifier: Identifier) -> Bool {
        return isMatchAt(0, with: identifier)
    }
    
    
    public func isEqual(_ other: DataKeyPath) -> Bool {
        if count != other.count {
            return false
        }
        for ix in 0  ..< count {
            if keys[ix] != other.keys[ix] {
                return false
            }
        }
        return true
    }
    
    
    
    // MARK: Access
    
    
    
    subscript (index: Int) -> Identifier {
        get {
            precondition(isInRange(index))
            return keys[index]
        }
    }
    
    public func makeIterator() -> IndexingIterator<Array<Identifier>> {
        return keys.makeIterator()
    }
    
    public func searchIterator() -> DataKeyPathSearchIterator {
        return DataKeyPathSearchIterator(path: self)
    }
    
} // end class DataKeyPath




// MARK: Equatable


public func ==(lhs: DataKeyPath, rhs: DataKeyPath) -> Bool {
    return lhs.isEqual(rhs)
}



