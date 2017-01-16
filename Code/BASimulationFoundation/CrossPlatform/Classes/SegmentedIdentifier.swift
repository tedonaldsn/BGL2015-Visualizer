//
//  SegmentedIdentifier.swift
//  BASimulation
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
//  The SegmentedIdentifier is used where (a) identifiers are period (".")
//  delimited segments, and (b) segments are not subdivisible for purposes
//  of matching.
//
//  Identifier segments are "interned" strings. Thus, comparing two 
//  SegmentedIdentifier instances only requires comparing "pointers" using
//  NSObject's "===" operator, rather than a much much slower character by
//  character comparison (and Swift string content comparisons are purportedly
//  very slow).
//
//  Note that it IS possible to use Swift's ObjectIdentity() in comparisons,
//  but such comparisons appear to be very unreliable.


import Foundation



final public class SegmentedIdentifier {
    
    public class func separator() -> String {
        return "."
    }
    
    public class func isValidIdentifierString(_ idString: String) -> Bool {
        let segments = idString.components(separatedBy: separator())
        for segment in segments {
            if !Identifier.isValidIdentifierString(segment) { return false }
        }
        return true
    }
    
    // MARK: Data
    
    public let segments: [NSString]
    public var stringSegments: [String] {
        get {
            var strings = [String]()
            for nsStringValue in segments {
                strings.append(nsStringValue as String)
            }
            return strings
        }
    }
    public var asString: String {
        get {
            return stringSegments.joined(separator: SegmentedIdentifier.separator())
        }
    }
    
    public var isEmpty: Bool { return segments.isEmpty }
    public var segmentCount: Int { return segments.count }
    
    public var isSystemIdentifier: Bool {
        return isEmpty ? false : segments[0].hasPrefix(Identifier.systemIdentifierTag)
    }
    
    
    // MARK: Initialization
    
    
    public init(identifierString: String) {
        precondition(SegmentedIdentifier.isValidIdentifierString(identifierString),
            "not a valid identifier string: \"\(identifierString)\"")
        
        let internedStrings = InternedStrings.sharedInstance()
        let sep = SegmentedIdentifier.separator()
        
        let idSegments = internedStrings.internedSegments(identifierString, separator: sep)
        
        self.segments = idSegments
    }
    
    public func isEqual(_ other: SegmentedIdentifier) -> Bool {
        let segCount = segmentCount
        var isEq = segCount == other.segmentCount
        
        if isEq {
            for ix in 0 ..< segCount {
                let mySegment: NSString = self.segments[ix]
                let otherSegment: NSString = other.segments[ix]
                isEq = mySegment === otherSegment

                if !isEq {
                    break
                }
            }
        }
        
        return isEq
    }
    
} // end class SegmentedIdentifier



