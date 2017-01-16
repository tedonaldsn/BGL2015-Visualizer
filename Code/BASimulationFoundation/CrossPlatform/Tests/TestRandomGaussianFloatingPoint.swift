//
//  TestRandomGaussianFloatingPoint.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/17/15.
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

import XCTest

import BASimulationFoundation




class TestRandomGaussianFloatingPoint: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here.
    }
    
    override func tearDown() {
        // Put teardown code here.
        super.tearDown()
    }
    
    
    func testDistribution() {
        let mean: Double = 0.2
        let stdDev: Double = 0.15

        let gaussian: RandomGaussianFloatingPoint = RandomGaussianFloatingPoint(mean: mean, standardDeviation: stdDev)
        
        var counts: [Int] = [0, 0, 0, 0, 0, 0]
        var proportions: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        let sampleCount = 100000
        
        for _ in 1..<sampleCount {
            let num = gaussian.nextValue
            
            if num < (mean - (2 * stdDev)) { // -3 SD
                counts[0] += 1
            } else if num < (mean - stdDev) { // -2 SD
                counts[1] += 1
            } else if num < mean { // -1 SD
                counts[2] += 1
            } else if num < (mean  + stdDev) { // +1 SD
                counts[3] += 1
            } else if num < (mean + (2 * stdDev)) { // +2 SD
                counts[4] += 1
            } else { // +3 SD
                counts[5] += 1
            }
        }

        // Generation of bins of numbers to check distribution doubles as a
        // performance test.
        //
        self.measure {
            for ix in 0 ..< counts.count {
                proportions[ix] = Double(counts[ix]) / Double(sampleCount)
            }
        }
        
        // Proportion of values per standard deviation: http://hyperphysics.phy-astr.gsu.edu/hbase/math/gaufcn.html
    
        let sd1Target: Double = 0.3413
        let sd2Target: Double = 0.1359
        let sd3Target: Double = 0.0214
        
        let toleranceProportion: Double = 0.025
        
        let sd1Tolerance: Double = sd1Target * toleranceProportion
        let sd2Tolerance: Double = sd2Target * toleranceProportion
        let sd3Tolerance: Double = sd2Target * toleranceProportion
        
        XCTAssertTrue(within(proportions[0], target: sd3Target, distance: sd3Tolerance),
            "\(proportions[0]) is not within \(sd3Tolerance) of \(sd3Target)")
        XCTAssertTrue(within(proportions[1], target: sd2Target, distance: sd2Tolerance),
            "\(proportions[1]) is not within \(sd2Tolerance) of \(sd2Target)")
        XCTAssertTrue(within(proportions[2], target: sd1Target, distance: sd1Tolerance),
            "\(proportions[2]) is not within \(sd1Tolerance) of \(sd1Target)")
        XCTAssertTrue(within(proportions[3], target: sd1Target, distance: sd1Tolerance),
            "\(proportions[3]) is not within \(sd1Tolerance) of \(sd1Target)")
        XCTAssertTrue(within(proportions[4], target: sd2Target, distance: sd2Tolerance),
            "\(proportions[4]) is not within \(sd2Tolerance) of \(sd2Target)")
        XCTAssertTrue(within(proportions[5], target: sd3Target, distance: sd3Tolerance),
            "\(proportions[5]) is not within \(sd3Tolerance) of \(sd3Target)")
        
        /*
        print(counts)
        print(proportions)
        print("\n")
        */
        
    } // end testDistribution
    
    
    
    func within(_ value: Double, target: Double, distance: Double) -> Bool {
        let diff = fabs(value - target)
        return diff <= distance
    }
    
    
    

    
    
    func testInitializerEquivalence() {
        
        let mean: Double = 0.2
        let stdDev: Double = 0.15
        let min: Double = -0.25
        let max: Double = 0.65
        
        let random1 = RandomGaussianFloatingPoint(mean: mean, standardDeviation: stdDev)
        
        XCTAssertEqual(random1.mean, mean)
        XCTAssertEqual(random1.standardDeviation, stdDev)
        XCTAssertEqual(random1.lowestValue, min)
        XCTAssertEqual(random1.highestValue, max)
        
        let random2 = RandomGaussianFloatingPoint(lowestValue: min, highestValue: max)
        
        XCTAssertEqual(random2.mean, mean)
        XCTAssertEqual(random2.standardDeviation, stdDev)
        XCTAssertEqual(random2.lowestValue, min)
        XCTAssertEqual(random2.highestValue, max)

    } // end testInitializerEquivalence
    
    
    
    

} // end class TestRandomGaussianFloatingPoint

