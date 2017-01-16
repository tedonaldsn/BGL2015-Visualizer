//
//  IdentifierRegEx.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 1/13/15.
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
//  Stringized identifiers used throughout the simulation environment.
//  Loosely based on SCXML IDs which defines an id as a xs:NCName
//
//  http://www.w3.org/TR/1999/REC-xml-names-19990114/#NT-NCName
//
//  Identifier can start with a letter or underscore, followed by letters,
//  digits, periods, underscores.
//
//  Major incompatibilities with SCXML: 
//
//      1) Hyphens (i.e., dashes) are excluded from identifiers. They cause 
//          usability problems in expressions where a dash (i.e., hyphen) is
//          also a minus sign. Rather than require that users remember to put
//          spaces around minus signs, we will just NOT support dashes in
//          identifiers.
//
//      2) Periods (i.e., dots) are excluded from identifiers. They are not
//          allowed in field names in some databases. Cannot be field names
//          in Core Data automatically generated code.
//
//  http://userguide.icu-project.org/strings/regexp
//  http://unicode.org/reports/tr18/
//
//  Note that letters may be any code point with Unicode property "L" (letter),
//  though some code may choke on such characters. Your mileage may vary.
//
//  Also see class UniCharClassifier


import Foundation


final public class IdentifierRegEx {
    
    public class func sharedInstance() -> IdentifierRegEx {
        return priv_sharedInstance
    }
    fileprivate static var priv_sharedInstance = IdentifierRegEx()
    
    
    
    public let headPattern = "[\\p{L}_]"
    public let tailPattern = "[\\p{L}\\d\\_]*"
    public let fullPattern = "[\\p{L}_][\\p{L}\\d\\_]*"
    
    public let options = NSRegularExpression.Options(rawValue: 0)
    
    public let headRegEx: NSRegularExpression!
    public let tailRegEx: NSRegularExpression!
    public let fullRegEx: NSRegularExpression!
    
    public init() {
        fullRegEx = try! NSRegularExpression(pattern: fullPattern, options: options)
        headRegEx = try! NSRegularExpression(pattern: headPattern, options: options)
        tailRegEx = try! NSRegularExpression(pattern: tailPattern, options: options)
    }
    
    public func isValidIdentifier(_ idString: String) -> Bool {
        return priv_test(fullRegEx, stringValue: idString)
    }
    public func isValidIdentifierHeadCharacter(_ idHeadChar: UniChar) -> Bool {
        return priv_test(headRegEx, stringValue: String(idHeadChar))
    }
    public func isValidIdentifierTailCharacter(_ idTailChar: UniChar) -> Bool {
        return priv_test(tailRegEx, stringValue: String(idTailChar))
    }
    
    
    fileprivate func priv_test(_ regEx: NSRegularExpression, stringValue: String) -> Bool {
        let len = stringValue.characters.count
        let inputRange = NSMakeRange(0, len)
        let matchRange = regEx.rangeOfFirstMatch(in: stringValue, options: [], range: inputRange)
        let isMatch = (matchRange.location == inputRange.location) && (matchRange.length == inputRange.length)
        
        return isMatch
    }
    
    
    
} // end class IdentifierRegEx
