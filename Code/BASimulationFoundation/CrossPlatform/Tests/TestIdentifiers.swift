//
//  TestIdentifiers.swift
//  BASimulation
//
//  Created by Tom Donaldson on 1/14/15.
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

import BASimulationFoundation
import XCTest

class TestIdentifiers: XCTestCase {
    

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIdentifiers() {
        
        let goodIds = ["a", "_a", "a_1_b_2_cpriv_3", "_a_1_b_2_cpriv_3", "_system_crap_9_", "butterkäse", "Josè_B_", "Preis_in_Euro"]
        let badIds = [".", "1_a", "a_1.b-2.cpriv_3", "$a_1.b-2.cpriv_3^", "-_a_1.b-2.cpriv_3", "._system.crap-9.", "foobar?", "butter käse", "Josè_😎", "Preis_in_€"]
        
        for goodId in goodIds {
            XCTAssertTrue(Identifier.isValidIdentifierString(goodId), "Identifier string \"\(goodId)\" is not valid")
        }
        for badId in badIds {
            XCTAssertFalse(Identifier.isValidIdentifierString(badId), "Identifier string \"\(badId)\" is valid, but should not be")
        }

    } // end testIdentifiers
    
    
    func testSegmentedIdentifiers() {
        
        let goodIds = ["a", "_a", "a_1.b_2.cpriv_3", "_a_1.b_2.cpriv_3", "_system.crap_9", "butterkäse", "Josè_B", "Preis_in_Euro"]
        let badIds = [".", "1_a", "a_1.b-2.cpriv_3", "$a_1.b-2.cpriv_3^", "-_a_1.b-2.cpriv_3", "_system.crap_9.", "._system.crap-9.", "foobar?", "butter käse", "Josè_B.", "Josè_😎", "Preis_in_€"]
        
        for goodId in goodIds {
            XCTAssertTrue(SegmentedIdentifier.isValidIdentifierString(goodId), "Identifier string \"\(goodId)\" is not valid")
        }
        for badId in badIds {
            XCTAssertFalse(SegmentedIdentifier.isValidIdentifierString(badId), "Identifier string \"\(badId)\" is valid, but should not be")
        }

    } // end testSegmentedIdentifiers
    
    
    
    
    func testArchiveIdentifiers() {
        let idStrings = ["a", "_a", "a_1_b_2_cpriv_3", "_a_1_b_2_cpriv_3", "_system_crap_9_", "butterkäse", "Josè_B", "Preis_in_Euro"]

        let identifiers = NSMutableArray()
        
        for idString in idStrings {
            identifiers.add(Identifier(idString: idString))
        }
        
        let archive = NSKeyedArchiver.archivedData(withRootObject: identifiers)
        let unarchivedIdentifiers = NSKeyedUnarchiver.unarchiveObject(with: archive) as! NSArray

        XCTAssertTrue(identifiers.count == unarchivedIdentifiers.count)

        for ix in 0..<identifiers.count {
            let original = identifiers.object(at: ix) as! Identifier
            let unarchived = unarchivedIdentifiers.object(at: ix) as! Identifier
            XCTAssertTrue(original == unarchived,
                          "Original and unarchived identifiers are not internally equal: \"\(original.idString)\" != \"\(unarchived.idString)\"")
        }
        
    } // end testArchiveIdentifiers
    
    

} // end TestIdentifiers
