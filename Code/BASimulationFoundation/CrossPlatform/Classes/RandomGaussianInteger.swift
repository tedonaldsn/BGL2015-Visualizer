//
//  RandomGaussianInteger.swift
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
//
//  TO BE DONE: Add switchable diagnostics: collect counts of values returned by
//  stddev or fractional stddev.



import Foundation
import GameplayKit


open class RandomGaussianInteger: NSCoding {
    
    open class func randomSource() -> GKRandom {
        return GKMersenneTwisterRandomSource()
    }
    
    // MARK: Data
    
    open var lowestValue: Int { return priv_distribution.lowestValue }
    open var highestValue: Int { return priv_distribution.highestValue }
    open var mean: Double { return Double(priv_distribution.mean) }
    open var standardDeviation: Double { return Double(priv_distribution.deviation) }
    
    
    
    open var nextValue: Int { return priv_distribution.nextInt() }
    
    
    // MARK: Initialization
    
    
    
    
    public init(lowestValue: Int, highestValue: Int) {
        
        precondition(lowestValue < highestValue)
        
        let randomSource = RandomGaussianInteger.randomSource()
        
        priv_distribution = GKGaussianDistribution(randomSource: randomSource,
                                                   lowestValue: lowestValue,
                                                   highestValue: highestValue)
    }
    
    
    public init(mean: Double, standardDeviation: Double) {
        
        precondition(standardDeviation > 0.0)
        
        let randomSource = RandomGaussianInteger.randomSource()
        
        priv_distribution = GKGaussianDistribution(randomSource: randomSource,
                                                   mean: Float(mean),
                                                   deviation: Float(standardDeviation))
    }
    
    
    // MARK: NSCoding
    
    open static var key_lowest = "lowest"
    open static var key_highest = "highest"
    
    @objc public convenience required init?(coder aDecoder: NSCoder) {
        let lowest = aDecoder.decodeInteger(forKey: RandomGaussianInteger.key_lowest)
        let highest = aDecoder.decodeInteger(forKey: RandomGaussianInteger.key_highest)
        self.init(lowestValue: lowest, highestValue: highest)
    }
    
    @objc open func encode(with aCoder: NSCoder) {
        aCoder.encode(lowestValue, forKey: RandomGaussianInteger.key_lowest)
        aCoder.encode(highestValue, forKey: RandomGaussianInteger.key_highest)
    }
    

    // MARK: *Private* Data
    
    fileprivate let priv_distribution: GKGaussianDistribution
    
} // end class RandomGaussianInteger

