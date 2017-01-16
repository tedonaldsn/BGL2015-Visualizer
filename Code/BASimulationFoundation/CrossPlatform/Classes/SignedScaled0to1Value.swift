//
//  SignedScaled0to1Value.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 10/24/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//
// Signed version of SignedScaled0to1Value. Required for dopaminergic discrepancy
// signal. Other uses: ?



import Foundation





public struct SignedScaled0to1Value: CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: Global
    
    public enum Limits: Double { case Minimum = -1.0, Mean = 0.0, Maximum = 1.0 }
    
    public static var maximum = SignedScaled0to1Value(rawValue: SignedScaled0to1Value.Limits.Maximum.rawValue)
    public static var mean = SignedScaled0to1Value(rawValue: SignedScaled0to1Value.Limits.Mean.rawValue)
    public static var minimum = SignedScaled0to1Value(rawValue: SignedScaled0to1Value.Limits.Minimum.rawValue)
    
    public static func isWithinLimits(rawValue: Double) -> Bool {
        return rawValue >= Limits.Minimum.rawValue && rawValue <= Limits.Maximum.rawValue
    }
    public static func isWithinLimits(rawValues: [Double]) -> Bool {
        for rawValue in rawValues {
            if !isWithinLimits(rawValue) {
                return false
            }
        }
        return true
    }
    
    public static func truncate(value: Double) -> Double {
        if value > Limits.Maximum.rawValue {
            return maximum.rawValue
            
        } else if value < Limits.Minimum.rawValue {
            return minimum.rawValue
        }
        return value
    }
    
    public static func isWithin(value1: Double, value2: Double, distance: Double) -> Bool {
        let diff = fabs(value1 - value2)
        return diff <= distance
    }
    
    // MARK: Data
    
    public var rawValue: Double {
        willSet { precondition(SignedScaled0to1Value.isWithinLimits(newValue)) }
    }
    public var isZero: Bool { return rawValue == 0.0 }
    public var isPositive: Bool { return rawValue >= 0.0 }
    public var isNegative: Bool { return rawValue < 0.0 }
    
    
    
    // MARK: Initialization
    
    public init(rawValue: Double = 0.0) {
        self.rawValue = rawValue
    }
    
    
    public mutating func truncate(newValue: Double) -> SignedScaled0to1Value {
        rawValue = SignedScaled0to1Value.truncate(newValue)
        return self
    }
    
    
    // MARK: Comparison
    
    public func within(distance: Scaled0to1Value, of: SignedScaled0to1Value) -> Bool {
        return SignedScaled0to1Value.isWithin(rawValue, value2: of.rawValue, distance: distance.rawValue)
    }
    
    // MARK: Printing
    
    // Used for general printing
    public var description: String { return "\(rawValue)" }
    
    // Used for printing in debugger and Playground
    public var debugDescription: String { return "SignedScaled0to1Value.rawValue: \(rawValue)" }
    
    
    
    
} // end struct SignedScaled0to1Value


// MARK: Comparison Functions

public func ==(left: SignedScaled0to1Value, right: SignedScaled0to1Value) -> Bool {
    return left.rawValue == right.rawValue
}
public func ==(left: SignedScaled0to1Value, right: Double) -> Bool {
    return left.rawValue == right
}
public func ==(left: Double, right: SignedScaled0to1Value) -> Bool {
    return left == right.rawValue
}

public func !=(left: SignedScaled0to1Value, right: SignedScaled0to1Value) -> Bool {
    return left.rawValue != right.rawValue
}
public func !=(left: SignedScaled0to1Value, right: Double) -> Bool {
    return left.rawValue != right
}
public func !=(left: Double, right: SignedScaled0to1Value) -> Bool {
    return left != right.rawValue
}


public func >(left: SignedScaled0to1Value, right: SignedScaled0to1Value) -> Bool {
    return left.rawValue > right.rawValue
}
public func >(left: SignedScaled0to1Value, right: Double) -> Bool {
    return left.rawValue > right
}
public func >(left: Double, right: SignedScaled0to1Value) -> Bool {
    return left > right.rawValue
}


public func >=(left: SignedScaled0to1Value, right: SignedScaled0to1Value) -> Bool {
    return left.rawValue >= right.rawValue
}
public func >=(left: SignedScaled0to1Value, right: Double) -> Bool {
    return left.rawValue >= right
}
public func >=(left: Double, right: SignedScaled0to1Value) -> Bool {
    return left >= right.rawValue
}


public func <(left: SignedScaled0to1Value, right: SignedScaled0to1Value) -> Bool {
    return left.rawValue < right.rawValue
}
public func <(left: SignedScaled0to1Value, right: Double) -> Bool {
    return left.rawValue < right
}
public func <(left: Double, right: SignedScaled0to1Value) -> Bool {
    return left < right.rawValue
}


public func <=(left: SignedScaled0to1Value, right: SignedScaled0to1Value) -> Bool {
    return left.rawValue <= right.rawValue
}
public func <=(left: SignedScaled0to1Value, right: Double) -> Bool {
    return left.rawValue <= right
}
public func <=(left: Double, right: SignedScaled0to1Value) -> Bool {
    return left <= right.rawValue
}



// MARK: Inplace Math Functions

public func +=(inout left: SignedScaled0to1Value, right: SignedScaled0to1Value) -> Void {
    left.rawValue += right.rawValue
}
public func +=(inout left: SignedScaled0to1Value, right: Double) -> Void {
    left.rawValue += right
}
public func +=(inout left: Double, right: SignedScaled0to1Value) -> Void {
    left += right.rawValue
}


