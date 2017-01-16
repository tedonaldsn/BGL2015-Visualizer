//
//  TestNetworkContainers.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/20/15.
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

class TestNetworkContainers: XCTestCase {
    
    var net: Network!
    
    override func setUp() {
        super.setUp()
        
        net = Network(identifier: Identifier(idString: "TestNetworkContainers"))
        
        // These areas within the neural network are usually created as part
        // of creating neurons that belong on the respective areas. However,
        // in these tests no neurons are created, so we must manually create
        // the default (i.e., the 0-th) areas.
        //
        net.sensoryInputRegion.createArea()
        net.sensoryAssociationRegion.createArea()
        net.motorAssociationRegion.createArea()
    }
    
    override func tearDown() {
        net = nil
        
        super.tearDown()
    }
    
    
    

    func testSignalPropogation() {

        var dopaminergicTestSignal: Double = 0.111
        var hippocampalTestSignal: Double = dopaminergicTestSignal / 3.0
        
        net.forceDopaminergicSignal(dopaminergicTestSignal)
        net.forceHippocampalSignal(hippocampalTestSignal)
        
        XCTAssertNotEqual(dopaminergicTestSignal, hippocampalTestSignal)
        
        XCTAssertEqual(net.dopaminergicSignal, dopaminergicTestSignal)
        XCTAssertEqual(net.hippocampalSignal, hippocampalTestSignal)
        
        dopaminergicTestSignal /= 2.0
        hippocampalTestSignal /= 2.0
        
        net.forceDopaminergicSignal(dopaminergicTestSignal)
        net.forceHippocampalSignal(hippocampalTestSignal)
        
        XCTAssertNotEqual(dopaminergicTestSignal, hippocampalTestSignal)
        
        XCTAssertEqual(net.dopaminergicSignal, dopaminergicTestSignal)
        XCTAssertEqual(net.hippocampalSignal, hippocampalTestSignal)
        
        
    } // end testSignalPropogation

} // end TestNetworkContainers


