//
//  TestArray.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 5/15/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import XCTest


func ==(lhs: TestArray.UserDefinedObject, rhs: TestArray.UserDefinedObject) -> Bool {
    return lhs.stringValue == rhs.stringValue && lhs.integerValue == rhs.integerValue
}


class TestArray: XCTestCase {
    
    class UserDefinedObject: NSObject, NSCoding {
        enum Keys: String {
            case StringValue = "StringValue"
            case IntegerValue = "IntegerValue"
        }
        let stringValue: String
        let integerValue: Int
        init(stringValue: String, integerValue: Int) {
            self.stringValue = stringValue
            self.integerValue = integerValue
        }
        required init?(coder aDecoder: NSCoder) {
            self.stringValue = (aDecoder.decodeObject(forKey: Keys.StringValue.rawValue) as? String)!
            self.integerValue = aDecoder.decodeInteger(forKey: Keys.IntegerValue.rawValue)
        }
        func encode(with aCoder: NSCoder) {
            aCoder.encode(stringValue, forKey: Keys.StringValue.rawValue)
            aCoder.encode(integerValue, forKey: Keys.IntegerValue.rawValue)
        }
    }
    
    

    override func setUp() {
        super.setUp()
        // Put setup code here.
    }
    
    override func tearDown() {
        // Put teardown code here.
        super.tearDown()
    }
    
    

    func testArchiveStringArray() {
        let names = [ "Fred", "Ethyl", "Wilbur", "Sarah"]
        
        let archive = NSKeyedArchiver.archivedData(withRootObject: names)
        
        let duplicate: [String] =
            (NSKeyedUnarchiver.unarchiveObject(with: archive) as? [String])!
        
        XCTAssertTrue(names.count == duplicate.count)
        
        guard names.count == duplicate.count else { return }
        
        for ix in 0..<names.count {
            let original = names[ix]
            let dup = duplicate[ix]
            XCTAssertTrue(dup == original)
        }
    }
    
    
    func testArchiveUserDefinedObjectArray() {
        
        let objects:[UserDefinedObject] = [
            UserDefinedObject(stringValue: "Fred", integerValue: 11),
            UserDefinedObject(stringValue: "Ethyl", integerValue: 22),
            UserDefinedObject(stringValue: "Wilbur", integerValue: 33),
            UserDefinedObject(stringValue: "Sarah", integerValue: 44),
            ]
        
        let archive = NSKeyedArchiver.archivedData(withRootObject: objects)
        
        let duplicate: [UserDefinedObject] =
            (NSKeyedUnarchiver.unarchiveObject(with: archive) as? [UserDefinedObject])!
        
        XCTAssertTrue(objects.count == duplicate.count)
        
        guard objects.count == duplicate.count else { return }
        
        for ix in 0..<objects.count {
            let original = objects[ix]
            let dup = duplicate[ix]
            XCTAssertTrue(dup == original)
        }
        
    } // end testArchiveUserDefinedObjectArray
    
    
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

} // end TestArray

