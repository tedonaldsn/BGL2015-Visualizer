//
//  Identifier.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 1/14/15.
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
//  Identifiers are "interned strings" that act as quick-equality test symbols.
//  The interned NSString representation permits use of the object equality
//  test, "===", which does not work on structs such as Swift's String.
//
//  Strings are canonicalized using using String method
//  precomposedStringWithCanonicalMapping (Unicode Normalization Form KC).
//  This is "Compatibility Decomposition, followed by Canonical Composition",
//  which loses some formatting information, but provides maximum comparability
//  among various incoming character forms.
//
//  http://unicode.org/reports/tr15/tr15-18.html
//
//  Identifiers must be valid as enforced by IdentifierRegEx
//



import Foundation




final public class Identifier: NSObject, NSCopying, NSCoding, Comparable {
    
    // MARK: Class methods
    
    public static var systemIdentifierTag = "_"
    
    public class func isSystemIdentifierString(_ idString: String) -> Bool {
        return idString.hasPrefix(systemIdentifierTag) || idString.hasSuffix(systemIdentifierTag)
    }
    
    public class func isValidIdentifierString(_ idString: String) -> Bool {
        return IdentifierRegEx.sharedInstance().isValidIdentifier(idString)
    }

    public class func timeStampedIdentifier(_ baseIdentifier: Identifier) -> Identifier {
        return timeStampedIdentifierFromString(baseIdentifier.asString)
    }

    public class func timeStampedIdentifierFromString(_ baseIdentifierString: String) -> Identifier {
        precondition(isValidIdentifierString(baseIdentifierString),
            "baseline id \"\(baseIdentifierString)\" is invalid format")
        
        let timeStampedId = "\(baseIdentifierString)_\(Date.timeIntervalSinceReferenceDate)"
        
        assert(isValidIdentifierString(timeStampedId))
        
        return Identifier(idString: timeStampedId)
    }

    public class func backingStore() -> InternedStrings {
        return InternedStrings.sharedInstance()
    }
    
    public class func toStrings(_ identifiers: [Identifier]) -> [String] {
        var list = [String]()
        for id in identifiers {
            list.append(id.asString)
        }
        return list
    }
    
    
    // MARK: Data
    
    public let idString: NSString
    
    public var isSystemIdentifier: Bool {
        return idString.hasPrefix(Identifier.systemIdentifierTag)
    }
    public var isNilIdentifier: Bool {
        return self == PredefinedIdentifiers.nilIdentifier
    }
    
    public override var description: String { return asString }
    
    public override var debugDescription: String { return "\nIdentifier: idString: \(asString)" }
    
    public var asString: String { return idString as String }
    
    
    // MARK: Hashable Protocol
    //
    public override var hashValue: Int {
        let value = idString.hashValue
        return value
    }

    
    
    
    // MARK: Initialization
    
    public init(idString: String) {
        precondition(Identifier.isValidIdentifierString(idString),
            "not a valid identifier string: \"\(idString)\"")
        
        let interns = Identifier.backingStore()
        self.idString = interns.internedString(idString)
    }
    
    public convenience init(nsIdString: NSString) {
        self.init(idString: nsIdString as String)
    }
    
    // Zones are no longer used, but this is a function required by the
    // NSCopying protocol, which is needed for inclusion of NSObject subclasses
    // in a hash table (a.k.a., dictionary). Keys are always copied.
    //
    public func copy(with zone: NSZone?) -> Any {
        return Identifier(nsIdString: idString)
    }
    
    
    // Required override of NSObject method. The Hashable protocol will not
    // work correctly without it.
    //
    public override func isEqual(_ object: Any?) -> Bool {
        if let otherIdentifier = object as? Identifier {
            let isEq = idString === otherIdentifier.idString
            return isEq
        }
        return false
    }
    
    
    // MARK: Protocol NSCoding
    //
    // Archive: An identifier encodes its internal idString as a Swift String.
    // 
    // Unarchive: Decodes the saved string, re-canonicalizes it, and gets the
    //      matching interned string. The result is an identifier that has the
    //      same internal representation as any other equivalent identifier
    //      in the executable.
    //
    // Note that the internal id string MUST be an interned string from the
    // current Identifier.backingStore() for Identifier equality to work.
    //
    public static var key_item = "item"
    
    @objc public init?(coder aDecoder: NSCoder) {
        let interns = Identifier.backingStore()
        let stringValue: String = aDecoder.decodeObject(forKey: Identifier.key_item) as! String
        self.idString = interns.internedString(stringValue)
    }
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(idString, forKey: Identifier.key_item)
    }
    
    
} // end class Identifier




// MARK: Equatable

public func ==(lhs: Identifier, rhs: Identifier) -> Bool {
    return lhs.isEqual(rhs)
}

public func ==(lhs: Identifier, rhs: String) -> Bool {
    return lhs.idString.isEqual(to: rhs)
}

public func ==(lhs: String, rhs: Identifier) -> Bool {
    return rhs.idString.isEqual(to: lhs)
}


// MARK: Comparable

public func <(lhs: Identifier, rhs: Identifier) -> Bool {
    if lhs.isEqual(rhs) { return false }
    
    let leftString: String = lhs.idString as String
    let rightString: String = rhs.idString as String
    return leftString < rightString
}

public func <(lhs: Identifier, rhs: String) -> Bool {
    let leftString: String = lhs.idString as String
    return leftString < rhs
}

public func <(lhs: String, rhs: Identifier) -> Bool {
    let rightString: String = rhs.idString as String
    return lhs < rightString
}







