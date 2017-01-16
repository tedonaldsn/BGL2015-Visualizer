//
//  LearningSettings.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 8/13/15.
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
import BASimulationFoundation


// Burgos and García-Leal (2015) only have one gain rate and one loss
// rate, but that experiment only deals with excitation. On the other hand,
// Donahoe, Burgos, and Palmer (1993) have separate gain/loss rates for 
// excitation and inhibition, though they only implement excitation so the
// inhibition rates are unused.
//
public final class LearningSettings: NSObject, NSCoding {
    
    // MARK: Data
    
    // In equations: α
    // Default: 0.5
    public var excitationGainRate = Scaled0to1Value(rawValue: 0.5)
    
    // In equations: α'
    // Default: 0.5
    public var inhibitionGainRate = Scaled0to1Value(rawValue: 0.5)
    
    // In equations: β
    // Default: 0.1
    public var excitationLossRate = Scaled0to1Value(rawValue: 0.1)
    
    // In equations: β'
    // Default: 0.1
    public var inhibitionLossRate = Scaled0to1Value(rawValue: 0.1)
    
    // In equations: d(t) threshold
    // Default: 0.05
    public var weightGainThreshold = Scaled0to1Value(rawValue: 0.05)
    
    public override var debugDescription: String {
        let desc = "\nLearningSettings: Weight Gain Rate (α): \(excitationGainRate), Weight Loss Rate (β): \(excitationLossRate), Weight Gain Threshold: \(weightGainThreshold)"
        return desc
    }
    
    
    // MARK: Initialization
    
    public override init() {}
    public convenience init(initFrom: LearningSettings) {
        self.init()
        self.excitationGainRate = initFrom.excitationGainRate
        self.excitationLossRate = initFrom.excitationLossRate
        self.weightGainThreshold = initFrom.weightGainThreshold
    }
    public func clone() -> LearningSettings {
        return LearningSettings(initFrom: self)
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_excitationGainRate = "excitGainRate"
    public static var key_inhibitionGainRate = "inhibGainRate"
    
    public static var key_excitationLossRate = "excitLossRate"
    public static var key_inhibitionLossRate = "inhibLossRate"

    public static var key_weightGainThreshold = "gainThreshold"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        
        excitationGainRate.rawValue =
            aDecoder.decodeDouble(forKey: LearningSettings.key_excitationGainRate)
        
        inhibitionGainRate.rawValue =
            aDecoder.decodeDouble(forKey: LearningSettings.key_inhibitionGainRate)
        
        excitationLossRate.rawValue =
            aDecoder.decodeDouble(forKey: LearningSettings.key_excitationLossRate)
        
        inhibitionLossRate.rawValue =
            aDecoder.decodeDouble(forKey: LearningSettings.key_inhibitionLossRate)
        
        weightGainThreshold.rawValue =
            aDecoder.decodeDouble(forKey: LearningSettings.key_weightGainThreshold)
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(excitationGainRate.rawValue,
            forKey: LearningSettings.key_excitationGainRate)
        
        aCoder.encode(inhibitionGainRate.rawValue,
            forKey: LearningSettings.key_inhibitionGainRate)
        
        aCoder.encode(excitationLossRate.rawValue,
            forKey: LearningSettings.key_excitationLossRate)
        
        aCoder.encode(inhibitionLossRate.rawValue,
            forKey: LearningSettings.key_inhibitionLossRate)
        
        aCoder.encode(weightGainThreshold.rawValue,
            forKey: LearningSettings.key_weightGainThreshold)
    }
    
} // end class LearningSettings


