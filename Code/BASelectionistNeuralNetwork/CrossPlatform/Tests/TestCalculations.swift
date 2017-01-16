//
//  TestCalculations.swift
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

import XCTest

import BASimulationFoundation

class TestCalculations: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // From Burgos & García-Leal (2015)
    // L(x) = 1 / (1 + e(-x+μ)/σ)
    //
    // Where:
    //      μ = 0.5
    //      σ = 0.1
    //
    // Expected values calculated via spreadsheet
    //
    func testLogisticFunction() {
        
        let tolerance = Scaled0to1Value(rawValue: 0.00000001)
        
        var input = Scaled0to1Value()
        var result = Scaled0to1Value()
        
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.00669285)))
        
        input.rawValue = 0.05
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.01098694)))
        
        input.rawValue = 0.10
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.01798621)))
        
        input.rawValue = 0.15
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.02931223)))
        
        input.rawValue = 0.20
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.04742587)))
        
        input.rawValue = 0.25
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.07585818)))
        
        input.rawValue = 0.30
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.11920292)))
        
        input.rawValue = 0.35
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.18242552)))
        
        input.rawValue = 0.40
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.26894142)))
        
        input.rawValue = 0.45
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.37754067)))
        
        input.rawValue = 0.50
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.50000000)))
        
        input.rawValue = 0.55
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.62245933)))
        
        input.rawValue = 0.60
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.73105858)))
        
        input.rawValue = 0.65
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.81757448)))
        
        input.rawValue = 0.70
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.88079708)))
        
        input.rawValue = 0.75
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.92414182)))
        
        input.rawValue = 0.80
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.95257413)))
        
        input.rawValue = 0.85
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.97068777)))
        
        input.rawValue = 0.90
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.98201379)))
        
        input.rawValue = 0.95
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.98901306)))
        
        input.rawValue = 1.00
        result = LogisticSignalClamp.scale(input)
        XCTAssert(result.within(tolerance, of: Scaled0to1Value(rawValue: 0.99330715)))

    
    } // end testLogisticFunction
    
    
    

} // end class TestCalculations

