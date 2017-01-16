//
//  TestLogger.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 6/1/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import XCTest

class TestLogger: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    
    
    
    

    func testArchiving() {
        
        let settings = Logger.defaultSettings
        
        var archived = NSKeyedArchiver.archivedData(withRootObject: settings)
        
        var unarchived = NSKeyedUnarchiver.unarchiveObject(with: archived) as? Logger.Settings
        
        XCTAssertTrue(settings == unarchived)
        
        settings.isTraceEnabled = !settings.isTraceEnabled
        
        archived = NSKeyedArchiver.archivedData(withRootObject: settings)
        
        unarchived = NSKeyedUnarchiver.unarchiveObject(with: archived) as? Logger.Settings
        
        XCTAssertTrue(settings == unarchived)
        
    } // end testArchiving
    
    
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

} // end class TestLogger


