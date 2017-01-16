//
//  ActivationSettings.swift
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



public final class ActivationSettings: NSObject, NSCoding {
    
    // MARK: Equation Terms
    
    // In equations: 𝛕
    // Default: 0.1
    public var temporalSummation = Scaled0to1Value(rawValue: 0.1)
    
    // In equations: 𝜅
    // Default: 0.1
    public var decayRate = Scaled0to1Value(rawValue: 0.1)
    
    // MARK: Reactivation/Decay Threshold
    
    public var reactivationThresholdGenerator: ReactivationThreshold {
        return priv_thresholdGenerator
    }
    public var reactivationThreshold: Double {
        return priv_thresholdGenerator.nextThreshold
    }
    
    
    
    public override var debugDescription: String {
        let desc = "\nActivationSettings: Gain Rate (𝛕): \(temporalSummation), Decay Rate (𝜅): \(decayRate), Reactivation Threshold Mean: \(priv_thresholdGenerator.mean), Reactivation Threshold Standard Deviation: \(priv_thresholdGenerator.standardDeviation), Is Threshold Random: \(priv_thresholdGenerator.isRandom)"
        return desc
    }
    
    
    
    // MARK: Initialization
    
    public override init() {
        self.priv_thresholdGenerator = ReactivationThreshold()
    }
    public convenience init(initFrom: ActivationSettings) {
        self.init()
        self.temporalSummation = initFrom.temporalSummation
        self.decayRate = initFrom.decayRate
        self.priv_thresholdGenerator = ReactivationThreshold(initFrom: initFrom.priv_thresholdGenerator)
    }
    public func clone() -> ActivationSettings {
        return ActivationSettings(initFrom: self)
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_temporalSummation = "temporalSummation"
    public static var key_decayRate = "decayRate"
    public static var key_thresholdGenerator = "thresholdGenerator"
    
    
    @objc public required init?(coder aDecoder: NSCoder) {
        
        temporalSummation.rawValue =
            aDecoder.decodeDouble(forKey: ActivationSettings.key_temporalSummation)
        
        decayRate.rawValue =
            aDecoder.decodeDouble(forKey: ActivationSettings.key_decayRate)
        
        priv_thresholdGenerator =
            aDecoder.decodeObject(forKey: ActivationSettings.key_thresholdGenerator) as! ReactivationThreshold
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(temporalSummation.rawValue,
            forKey: ActivationSettings.key_temporalSummation)
        
        aCoder.encode(decayRate.rawValue,
            forKey: ActivationSettings.key_decayRate)
        
        aCoder.encode(priv_thresholdGenerator,
            forKey: ActivationSettings.key_thresholdGenerator)
    }
    
    // MARK: *Private*
    
    
    fileprivate var priv_thresholdGenerator: ReactivationThreshold!
    
} // end class ActivationSettings


