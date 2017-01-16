//
//  StrengthScaledValue.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 8/10/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import BASimulationFoundation



//  StrengthScaledValue
//
//  
//
open class StrengthScaledValue {
    
    // MARK: Data
    
    open var valueAtWeakest: CGFloat
    open var valueAtStrongest: CGFloat
    
    open var valueSpread: CGFloat {
        return valueAtStrongest - valueAtWeakest
    }
    
    open var maximum: CGFloat {
        return max(valueAtWeakest, valueAtStrongest)
    }
    open var minimum: CGFloat {
        return min(valueAtWeakest, valueAtStrongest)
    }
    
    
    // MARK: Initialization
    
    public init(valueAtWeakest: CGFloat, valueAtStrongest: CGFloat) {
        self.valueAtWeakest = valueAtWeakest
        self.valueAtStrongest = valueAtStrongest
    }
    
    
    open func value(_ atStrength: CGFloat) -> CGFloat {
        assert(atStrength >= 0.0 && atStrength <= 1.0)
        
        let delta = valueSpread * atStrength
        return valueAtWeakest + delta
    }
    
    open func strength(_ atRawValue: CGFloat) -> CGFloat {
        assert(atRawValue >= valueAtWeakest && atRawValue <= valueAtStrongest)
        
        let delta = atRawValue - valueAtWeakest
        return delta / valueSpread
    }
    
    
    open func scale(_ scalingFactor: CGFloat) -> Void {
        valueAtWeakest = valueAtWeakest * scalingFactor
        valueAtStrongest = valueAtStrongest * scalingFactor
    }
    
} // end class StrengthScaledValue

