//
//  TestLifoStack.swift
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

class TestLifoStack: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        var value: Int = 0
        var lookahead: Int = 0
        
        let lifo = LifoStack<Int>()
        XCTAssertTrue(lifo.count == 0)
        let _ = lifo.push(9)
        XCTAssertTrue(lifo.count == 1)
        let _ = lifo.push(8)
        XCTAssertTrue(lifo.count == 2)
        let _ = lifo.push(7)
        XCTAssertTrue(lifo.count == 3)
        
        lookahead = lifo.lookAhead()
        XCTAssertTrue(lookahead == 7)
        value = lifo.pop()
        XCTAssertTrue(lifo.count == 2)
        XCTAssertTrue(value == 7)
        
        lookahead = lifo.lookAhead()
        XCTAssertTrue(lookahead == 8)
        value = lifo.pop()
        XCTAssertTrue(lifo.count == 1)
        XCTAssertTrue(value == 8)
        
        lookahead = lifo.lookAhead()
        XCTAssertTrue(lookahead == 9)
        value = lifo.pop()
        XCTAssertTrue(lifo.count == 0)
        XCTAssertTrue(value == 9)
        
    }

} // end class TestLifoStack


