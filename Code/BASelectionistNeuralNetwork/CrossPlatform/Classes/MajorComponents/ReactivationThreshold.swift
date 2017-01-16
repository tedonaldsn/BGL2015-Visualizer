//
//  ReactivationThreshold.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 10/30/15.
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
import GameplayKit
import BASimulationFoundation


public final class ReactivationThreshold: NSObject, NSCoding {
    
    // In Burgos and García-Leal, 2015: hardcoded
    //
    public static var defaultMean = Scaled0to1Value(rawValue: 0.2)
    public static var defaultStandardDeviation = Scaled0to1Value(rawValue: 0.15)
    public static var defaultIsRandom = true
    
    public var mean = defaultMean {
        willSet {
            if newValue != mean {
                priv_generator = nil
            }
        }
    }
    
    public var standardDeviation = defaultStandardDeviation {
        willSet {
            if newValue != standardDeviation {
                priv_generator = nil
            }
        }
    }
    
    public var isRandom = defaultIsRandom
    
    public var nextThreshold: Double {
        if isRandom {
            let generator = randomGenerator()
            return generator.nextValue
            
        } else {
            return mean.rawValue
        }
    } // end reactivationThreshold

    
    
    
    // MARK: Initialization
    

    public override init(){
    }
    
    public convenience init(initFrom: ReactivationThreshold) {
        self.init()
        self.mean = initFrom.mean
        self.standardDeviation = initFrom.standardDeviation
        self.isRandom = initFrom.isRandom
    }
    
    
    public func setDefaults() -> Void {
        mean = ReactivationThreshold.defaultMean
        standardDeviation = ReactivationThreshold.defaultStandardDeviation
        isRandom = ReactivationThreshold.defaultIsRandom
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_mean = "mean"
    public static var key_standardDeviation = "standardDeviation"
    public static var key_isRandom = "isRandom"
    
    
    @objc public required init?(coder aDecoder: NSCoder) {
        
        mean.rawValue =
            aDecoder.decodeDouble(forKey: ReactivationThreshold.key_mean)
        
        standardDeviation.rawValue =
            aDecoder.decodeDouble(forKey: ReactivationThreshold.key_standardDeviation)
        
        isRandom =
            aDecoder.decodeBool(forKey: ReactivationThreshold.key_isRandom)
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(mean.rawValue,
            forKey: ReactivationThreshold.key_mean)
        
        aCoder.encode(standardDeviation.rawValue,
            forKey: ReactivationThreshold.key_standardDeviation)
        
        aCoder.encode(isRandom,
            forKey: ReactivationThreshold.key_isRandom)
    }
    
    // MARK: Access
    
    public func randomGenerator() -> RandomGaussianFloatingPoint {
        
        if priv_generator == nil {
            
            priv_generator =
                RandomGaussianFloatingPoint(mean: mean.rawValue,
                    standardDeviation: standardDeviation.rawValue)
        }
        return priv_generator!
    }
    
    // MARK: *Private* Data
    
    fileprivate var priv_generator: RandomGaussianFloatingPoint? = nil
    
    
} // end class ReactivationThreshold

