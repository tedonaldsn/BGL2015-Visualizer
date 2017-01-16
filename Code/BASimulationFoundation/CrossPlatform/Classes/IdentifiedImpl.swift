//
//  IdentifiedImpl.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 11/12/15.
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


public struct IdentifiedImpl: CustomDebugStringConvertible, CustomStringConvertible {
    
    public var hasIdentifier: Bool { return priv_identifier != nil }
    public var identifier: Identifier? { return priv_identifier }
    
    public var asString: String { return hasIdentifier ? priv_identifier!.asString : "" }
    
    public var description: String { return asString }
    public var debugDescription: String {
        return "\nIdentifiedImpl: priv_identifier: \(asString)"
    }
    
    
    // MARK: Initialization
    
    public init(identifier: Identifier? = nil) {
        self.priv_identifier = identifier
    }
    
    
    // MARK: NSCoding
    
    public static var key_name = "identifier"
    
    public init?(coder aDecoder: NSCoder) {
        priv_identifier = aDecoder.decodeObject(forKey: IdentifiedImpl.key_name) as! Identifier?
    }
    
    public func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(priv_identifier, forKey: IdentifiedImpl.key_name)
    }
    
    // MARK: *Private*
    
    fileprivate var priv_identifier: Identifier? = nil
    
    
} // end IdentifiedImpl

