//
//  InternedStrings.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 2/11/15.
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
//  Interned strings are used in cases in which equality tests must be exceptionally
//  fast. If it is known that two two strings are "interned", the "===" operator
//  can be used to test equality. 
//
//  Note that "===" does not work with Swift strings, probably because Swift strings
//  are structs rather than classes. Therefore, the interned values are NSString
//  which is a class and for which the "===" identity operator does work.



import Foundation





final public class InternedStrings: NSObject, NSCoding {
    
    // MARK: Class Methods
    
    public class func sharedInstance() -> InternedStrings {
        return priv_sharedInternedStrings
    }
    
    public static var key_sharedInstance = "InternedStrings"
    
    public class func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(priv_sharedInternedStrings, forKey: key_sharedInstance)
    }
    public class func decodeWithCoder(_ aDecoder: NSCoder) {
        priv_sharedInternedStrings = aDecoder.decodeObject(forKey: key_sharedInstance) as! InternedStrings
    }
    
    // MARK: Instance Data
    
    public var count: Int { return priv_strings.count }
    public var isEmpty: Bool { return priv_strings.isEmpty }
    
    // MARK: Instance Methods
    
    // Returns interned string containing the same sequence of characters as the
    // input raw string. If such an interned string does not already exist, one
    // is created and returned.
    //
    // Note that the query string is canonicalized before the lookup, and if a
    // new string is inserted, it is the canonical version.
    //
    // All subsequent requests will return the same NSString object.
    //
    public func internedString(_ rawString: String) -> NSString {
        let canonicalString = rawString.precomposedStringWithCompatibilityMapping
        
        if let internedString: NSString = priv_strings[canonicalString] {
            return internedString
        }
        
        priv_strings[canonicalString] = canonicalString as NSString?
        return priv_strings[canonicalString]!
    }
    
    public func containsInternedString(_ rawString: String) -> Bool {
        return existingInternedString(rawString) != nil
    }
    
    public func existingInternedString(_ rawString: String) -> NSString? {
        let canonicalString = rawString.precomposedStringWithCompatibilityMapping
        return priv_strings[canonicalString]
    }
    
    public func containsIdenticalObject(_ internalString: NSString) -> Bool {
        if let stringMatch = priv_strings[internalString as String] {
            return stringMatch === internalString
        }
        return false
    }
    
    public func internedSegments(_ segmentedString: String, separator: String) -> [NSString] {
        let segments = segmentedString.components(separatedBy: separator)
        return internalizeSegments(segments)
    }
    
    public func internalizeSegments(_ idSegments: [String]) -> [NSString] {
        var internedSegments = [NSString]()
        
        for segment in idSegments {
            let internedString: NSString = self.internedString(segment)
            internedSegments.append(internedString)
        }
        
        return internedSegments
    }
    
    
    
    
    // MARK: Protocol NSCoding
    
    public static var key_strings = "strings"
    
    @objc public init?(coder aDecoder: NSCoder) {
        priv_strings = aDecoder.decodeObject(forKey: InternedStrings.key_strings) as! Dictionary<String, NSString>
    }
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(priv_strings, forKey: InternedStrings.key_strings)
    }

    // MARK: *Private *

    fileprivate static var priv_sharedInternedStrings = InternedStrings()
    fileprivate override init() { super.init() }
    fileprivate var priv_strings = Dictionary<String, NSString>()
    
} // end class InternedStrings

