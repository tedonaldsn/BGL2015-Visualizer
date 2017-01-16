//
//  Array.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 10/17/15.
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



extension Array {
    
    public mutating func randomizeInPlace(_ randomizer: GKRandomDistribution? = nil) -> Void {
        
            precondition(randomizer == nil || randomizer!.lowestValue == 0)
            precondition(randomizer == nil || randomizer!.highestValue == count-1)

        let distribution = randomizer ?? self.randomizer
        
        for ix in 0..<self.count {
            let randomIndex = distribution.nextInt()
            let item = self[ix]
            self[ix] = self[randomIndex]
            self[randomIndex] = item
        }
    }
    
    public var randomizer: GKRandomDistribution {
        return GKRandomDistribution(randomSource: GKMersenneTwisterRandomSource(),
                                    lowestValue: 0,
                                    highestValue: self.count - 1)
    }

} // end extension Array

