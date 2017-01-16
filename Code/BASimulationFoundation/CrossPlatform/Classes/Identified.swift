//
//  Identified.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 7/6/15.
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
//  Names are free form identifiers for objects. They are intended to be 
//  human readable and understandable.
//


import Foundation



public protocol Identified: AnyObject, Hashable, NSCoding {
    
    // Returns false if name is nil or empty, true otherwise.
    //
    var hasIdentifier: Bool { get }
    
    // Returns name. If !hasIdentifier returns empty string.
    //
    var identifier: Identifier? { get }
    
    
    // MARK: NSCoding
    //
    // @objc required init?(coder aDecoder: NSCoder)
    //
    // @objc func encodeWithCoder(aCoder: NSCoder)
}


extension Identified {
    
    public var hashValue: Int {
        
        if !hasIdentifier {
            return 0
        } else {
            return identifier!.hashValue
        }
    }
}


public func ==<T: Identified>(left: T, right: T) -> Bool {
    if left.identifier != nil && right.identifier != nil {
        return (left === right) || (left.identifier! == right.identifier!)
    } else {
        return false
    }
}

public func ==<T: Identified>(left: T, right: String) -> Bool {
    if left.identifier != nil {
        return left.identifier! == right
    } else {
        return false
    }
}

public func ==<T: Identified>(left: String, right: T) -> Bool {
    return right == left
}


