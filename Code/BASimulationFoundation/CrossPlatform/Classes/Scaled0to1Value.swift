//
//  Scaled0to1Value.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 6/30/15.
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
# struct Scaled0to1Value

Range restricted double precision floating point number.

## Range: <0.0...1.0>

Restriction is to the range of values used within the simulation to represent
activation levels, connection weights, and others.

Assertions guarantee that at least during debugging the value cannot be out
of range.
*/





public struct Scaled0to1Value: CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: Global
    
    public enum Limits: Double { case minimum = 0.0, mean = 0.5, maximum = 1.0 }
    
    public static var maximum = Scaled0to1Value(rawValue: Scaled0to1Value.Limits.maximum.rawValue)
    public static var mean = Scaled0to1Value(rawValue: Scaled0to1Value.Limits.mean.rawValue)
    public static var minimum = Scaled0to1Value(rawValue: Scaled0to1Value.Limits.minimum.rawValue)
    
    public static func isWithinLimits(_ rawValue: Double) -> Bool {
        return rawValue >= Limits.minimum.rawValue && rawValue <= Limits.maximum.rawValue
    }
    public static func isWithinLimits(_ rawValues: [Double]) -> Bool {
        for rawValue in rawValues {
            if !isWithinLimits(rawValue) {
                return false
            }
        }
        return true
    }
    
    public static func truncate(_ value: Double) -> Double {
        if value > Limits.maximum.rawValue {
            return maximum.rawValue
            
        } else if value < Limits.minimum.rawValue {
            return minimum.rawValue
        }
        return value
    }
    
    public static func isWithin(_ value1: Double, value2: Double, distance: Double) -> Bool {
        let diff = fabs(value1 - value2)
        return diff <= distance
    }
    
    
    public static var approximationProportion = 0.0001
    public static func isApproximately(_ value1: Double, value2: Double) -> Bool {
        let distance = value1 * approximationProportion
        return isWithin(value1, value2: value2, distance: distance)
    }
    
    
    
    
    
    
    // MARK: Data
    
    public var rawValue: Double {
        willSet { assert(Scaled0to1Value.isWithinLimits(newValue)) }
    }
    // Cannot do this on iOS just importing Foundation: 
    //      public var toCGFloat: CGFloat { return CGFloat(rawValue) }
    
    public var isZero: Bool { return rawValue == 0.0 }
    
    
    
    // MARK: Initialization
    
    public init(rawValue: Double = Limits.minimum.rawValue) {
        self.rawValue = rawValue
    }
    
    
    // MARK: NSCoding
    
    public static var key_rawValue = "rawValue"
    
    public init?(coder aDecoder: NSCoder) {
        rawValue = aDecoder.decodeDouble(forKey: Scaled0to1Value.key_rawValue)
    }
    
    public func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(rawValue, forKey: Scaled0to1Value.key_rawValue)
    }
    
    
    // MARK: Forced Value
    
    public mutating func truncate(_ newValue: Double) -> Scaled0to1Value {
        rawValue = Scaled0to1Value.truncate(newValue)
        return self
    }
    
    
    // MARK: Comparison
    
    public func within(_ distance: Scaled0to1Value, of: Scaled0to1Value) -> Bool {
        return Scaled0to1Value.isWithin(rawValue, value2: of.rawValue, distance: distance.rawValue)
    }
    
    public func approximately(_ otherValue: Scaled0to1Value) -> Bool {
        return Scaled0to1Value.isApproximately(rawValue, value2: otherValue.rawValue)
    }
    
    public func approximately(_ otherRawValue: Double) -> Bool {
        return Scaled0to1Value.isApproximately(rawValue, value2: otherRawValue)
    }
    
    
    
    // MARK: Printing
    
    // Used for general printing
    public var description: String { return "\(rawValue)" }
    
    // Used for printing in debugger and Playground
    public var debugDescription: String { return "Scaled0to1Value.rawValue: \(rawValue)" }

    
    
} // end struct Scaled0to1Value



// MARK: Comparison Functions

infix operator ≈ : ComparisonPrecedence

public func ≈(left: Scaled0to1Value, right: Scaled0to1Value) -> Bool {
    return Scaled0to1Value.isApproximately(left.rawValue, value2: right.rawValue)
}
public func ≈(left: Scaled0to1Value, right: Double) -> Bool {
    return Scaled0to1Value.isApproximately(left.rawValue, value2: right)
}
public func ≈(left: Double, right: Scaled0to1Value) -> Bool {
    return Scaled0to1Value.isApproximately(left, value2: right.rawValue)
}
public func ≈(left: Double, right: Double) -> Bool {
    return Scaled0to1Value.isApproximately(left, value2: right)
}

public func ==(left: Scaled0to1Value, right: Scaled0to1Value) -> Bool {
    return left.rawValue == right.rawValue
}
public func ==(left: Scaled0to1Value, right: Double) -> Bool {
    return left.rawValue == right
}
public func ==(left: Double, right: Scaled0to1Value) -> Bool {
    return left == right.rawValue
}

public func !=(left: Scaled0to1Value, right: Scaled0to1Value) -> Bool {
    return left.rawValue != right.rawValue
}
public func !=(left: Scaled0to1Value, right: Double) -> Bool {
    return left.rawValue != right
}
public func !=(left: Double, right: Scaled0to1Value) -> Bool {
    return left != right.rawValue
}


public func >(left: Scaled0to1Value, right: Scaled0to1Value) -> Bool {
    return left.rawValue > right.rawValue
}
public func >(left: Scaled0to1Value, right: Double) -> Bool {
    return left.rawValue > right
}
public func >(left: Double, right: Scaled0to1Value) -> Bool {
    return left > right.rawValue
}


public func >=(left: Scaled0to1Value, right: Scaled0to1Value) -> Bool {
    return left.rawValue >= right.rawValue
}
public func >=(left: Scaled0to1Value, right: Double) -> Bool {
    return left.rawValue >= right
}
public func >=(left: Double, right: Scaled0to1Value) -> Bool {
    return left >= right.rawValue
}


public func <(left: Scaled0to1Value, right: Scaled0to1Value) -> Bool {
    return left.rawValue < right.rawValue
}
public func <(left: Scaled0to1Value, right: Double) -> Bool {
    return left.rawValue < right
}
public func <(left: Double, right: Scaled0to1Value) -> Bool {
    return left < right.rawValue
}


public func <=(left: Scaled0to1Value, right: Scaled0to1Value) -> Bool {
    return left.rawValue <= right.rawValue
}
public func <=(left: Scaled0to1Value, right: Double) -> Bool {
    return left.rawValue <= right
}
public func <=(left: Double, right: Scaled0to1Value) -> Bool {
    return left <= right.rawValue
}



// MARK: Inplace Math Functions

public func +=(left: inout Scaled0to1Value, right: Scaled0to1Value) -> Void {
    left.rawValue += right.rawValue
}
public func +=(left: inout Scaled0to1Value, right: Double) -> Void {
    left.rawValue += right
}
public func +=(left: inout Double, right: Scaled0to1Value) -> Void {
    left += right.rawValue
}



