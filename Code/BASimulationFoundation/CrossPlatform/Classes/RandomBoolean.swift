//
//  RandomBoolean.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 12/7/15.
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



/*
    Class RandomBoolean

    Returns true with the probability specified at initialization time
    using a uniform distribution.
*/
final public class RandomBoolean {
    
    public let withProbability: Scaled0to1Value

    public var next: Bool { return priv_nextBooleanValue() }

    
    public var isSampling: Bool = false
    public var trueSamples: Int { return priv_trueCount }
    public var falseSamples: Int { return priv_falseCount }
    public var totalSamples: Int { return trueSamples + falseSamples }
    public var proportionTrue: Double { return Double(priv_trueCount) / Double(totalSamples) }
    public var proportionFalse: Double { return 1.0 - proportionTrue }
    
    
    
    public init(withProbability: Scaled0to1Value) {
        precondition(withProbability.rawValue > 0)

        self.withProbability = withProbability
        
        let randomSource = GKMersenneTwisterRandomSource()
        priv_distribution
            = GKRandomDistribution(randomSource: randomSource,
                lowestValue: 1,
                highestValue: priv_valueCount)
        
        priv_maxTrueValue
            = Int(Double(priv_valueCount) * withProbability.rawValue)
    }
    
    public convenience init(withProbability: Double) {
        self.init(withProbability: Scaled0to1Value(rawValue: withProbability))
    }

    // MARK: *Private*
    
    fileprivate func priv_nextBooleanValue() -> Bool {
        let rawValue = priv_distribution.nextInt()
        let boolValue = rawValue <= priv_maxTrueValue
        if isSampling {
            if boolValue { priv_trueCount += 1 }
            else { priv_falseCount += 1 }
        }
        return boolValue
    }
    
    fileprivate let priv_valueCount = 100000
    fileprivate let priv_maxTrueValue: Int
    
    fileprivate let priv_distribution: GKRandomDistribution
    
    fileprivate var priv_trueCount = 0
    fileprivate var priv_falseCount = 0
    
    
} // end class RandomBoolean

