//
//  TestRandomBoolean.swift
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

import XCTest

class TestRandomBoolean: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testProportions() {
        let p = Scaled0to1Value(rawValue: 0.75)
        let randomBoolean = RandomBoolean(withProbability: p)
        randomBoolean.isSampling = true
        
        let sampleCount = 100000
        for _ in 1...sampleCount {
            let _ = randomBoolean.next
        }
        
        print("Total Samples: \(randomBoolean.totalSamples), True: \(randomBoolean.trueSamples) (\(randomBoolean.proportionTrue*100)%), False: \(randomBoolean.falseSamples) (\(randomBoolean.proportionFalse*100)%)")
        
        XCTAssertTrue(p.within(Scaled0to1Value(rawValue: 0.01),
            of: Scaled0to1Value(rawValue: randomBoolean.proportionTrue)))
    }

} // end class TestRandomBoolean
