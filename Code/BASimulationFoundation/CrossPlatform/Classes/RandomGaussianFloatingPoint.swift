//
//  RandomGaussianFloatingPoint.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 7/15/15.
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
//  Random number sources: 
//  https://developer.apple.com/library/ios/documentation/GameplayKit/Reference/GKRandomSource_Class/
//
//  From the reference:
//
//      GKRandomSource is the superclass for all basic randomization classes in 
//          GameplayKit. In most cases you do not use this class directly;
//          instead, use one of the subclasses ...
//
//      GKARC4RandomSource class uses an algorithm similar to that employed in
//          arc4random family of C functions. (However, instances of this class
//          are independent from calls to the arc4random functions.)
//
//      GKLinearCongruentialRandomSource class uses an algorithm that is faster,
//          but less random, than the GKARC4RandomSource class. (Specifically,
//          the low bits of generated numbers repeat more often than the high
//          bits.) Use this source when performance is more important than robust
//          unpredictability.
//
//      GKMersenneTwisterRandomSource class uses an algorithm that is slower,
//          but more random, than the GKARC4RandomSource class. Use this source
//          when it’s important that your use of random numbers not show
//          repeating patterns and performance is of less concern.
//

import Foundation
import GameplayKit


open class RandomGaussianFloatingPoint: NSCoding {
    
    // MARK: Data
    
    open var mean: Double { return priv_mean }
    open var standardDeviation: Double { return priv_standardDeviation }
    
    open var lowestValue: Double { return priv_lowestValue }
    
    open var highestValue: Double { return priv_highestValue }
    
    open var nextValue: Double { return priv_getNextValue() }
    
    
    // MARK: Initialization
    
    public convenience init(mean: Double = 0.2, standardDeviation: Double = 0.15) {
        
        precondition(standardDeviation > 0.0)
        
        let rawMean: Double = RandomGaussianFloatingPoint.priv_rangeScale * mean
        let rawStandardDeviation: Double = RandomGaussianFloatingPoint.priv_rangeScale * standardDeviation
        
        let threeStdDev = 3.0 * rawStandardDeviation
        
        let minValue = rawMean - threeStdDev
        let maxValue = rawMean + threeStdDev
        
        let randomSource = GKMersenneTwisterRandomSource()
        
        let distribution = GKGaussianDistribution(randomSource: randomSource,
            lowestValue: Int(minValue),
            highestValue: Int(maxValue))
        
        self.init(gaussian: distribution)
    }
    
    
    
    public convenience init(lowestValue: Double, highestValue: Double) {
        
        precondition(lowestValue < highestValue)
        
        let scaledMinimumValue = RandomGaussianFloatingPoint.priv_rangeScale * lowestValue
        let scaledMaximumValue = RandomGaussianFloatingPoint.priv_rangeScale * highestValue
        
        let distribution = GKGaussianDistribution(randomSource: GKRandomSource(),
            lowestValue: Int(scaledMinimumValue),
            highestValue: Int(scaledMaximumValue))
        
        self.init(gaussian: distribution)
    }
    
    
    // MARK: NSCoding
    
    open static var key_mean = "mean"
    open static var key_standardDeviation = "stddev"
    
    @objc public convenience required init?(coder aDecoder: NSCoder) {
        let mean = aDecoder.decodeDouble(forKey: RandomGaussianFloatingPoint.key_mean)
        let stddev = aDecoder.decodeDouble(forKey: RandomGaussianFloatingPoint.key_standardDeviation)
        self.init(mean: mean, standardDeviation: stddev)
    }
    
    @objc open func encode(with aCoder: NSCoder) {
        aCoder.encode(priv_mean, forKey: RandomGaussianFloatingPoint.key_mean)
        aCoder.encode(priv_standardDeviation, forKey: RandomGaussianFloatingPoint.key_standardDeviation)
    }
    
    
    // MARK: Sanity Checks
    
    open func isInRange(_ value: Double) -> Bool {
        return value >= priv_lowestValue && value <= priv_highestValue
    }
    
    
    
    // MARK: *Private* Class Data
    
    static fileprivate var priv_rangeScale: Double = 1000000.0
    
    
    
    // MARK: *Private*
    
    fileprivate init(gaussian: GKGaussianDistribution) {
        priv_distribution = gaussian
        
        priv_mean = Double(priv_distribution.mean)
            / RandomGaussianFloatingPoint.priv_rangeScale
        priv_standardDeviation = Double(priv_distribution.deviation)
            
            / RandomGaussianFloatingPoint.priv_rangeScale
        priv_lowestValue = Double(priv_distribution.lowestValue)
            
            / RandomGaussianFloatingPoint.priv_rangeScale
        priv_highestValue = Double(priv_distribution.highestValue)
            
            / RandomGaussianFloatingPoint.priv_rangeScale
        
        assert(priv_lowestValue < priv_highestValue)
        assert(priv_lowestValue < priv_mean)
        assert(priv_highestValue > priv_mean)
    }
    
    
    fileprivate func priv_scaleRawIntValue(_ rawValue: Int) -> Double {
        return Double(rawValue)/RandomGaussianFloatingPoint.priv_rangeScale
    }
    
    
    fileprivate func priv_getNextValue() -> Double {
        
        let nextScaledValue = priv_scaleRawIntValue(priv_distribution.nextInt())
        
        assert(isInRange(nextScaledValue))
        
        return nextScaledValue
    }
    
    // MARK: *Private* Data
    
    fileprivate let priv_mean: Double
    fileprivate let priv_standardDeviation: Double
    fileprivate let priv_lowestValue: Double
    fileprivate let priv_highestValue: Double
    
    fileprivate let priv_distribution: GKGaussianDistribution
    
} // end class RandomGaussianFloatingPoint

