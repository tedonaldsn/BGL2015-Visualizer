//
//  TestDictionary.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 5/15/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import XCTest


func ==(lhs: TestDictionary.UserDefinedObject, rhs: TestDictionary.UserDefinedObject) -> Bool {
    return lhs.stringValue == rhs.stringValue && lhs.integerValue == rhs.integerValue
}


class TestDictionary: XCTestCase {
    
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

    func testStringStringDictionaryArchive() {
        let dict: [String:Int] = [
            "Fred": 11,
            "Ethyl": 22,
            "Wilbur": 33,
            "Sarah": 44
        ]
        let archive = NSKeyedArchiver.archivedData(withRootObject: dict)
        
        let duplicate: [String:Int] =
            (NSKeyedUnarchiver.unarchiveObject(with: archive) as? [String:Int])!
        
        XCTAssertTrue(dict.count == duplicate.count)
        
        guard dict.count == duplicate.count else { return }
        
        for key in dict.keys {
            let original = dict[key]
            let dup = duplicate[key]
            XCTAssertTrue(original == dup)
        }
    }
    
    
    
    
    func testStringObjectDictionaryArchive() {
        let objects:[UserDefinedObject] = [
            UserDefinedObject(stringValue: "Fred", integerValue: 11),
            UserDefinedObject(stringValue: "Ethyl", integerValue: 22),
            UserDefinedObject(stringValue: "Wilbur", integerValue: 33),
            UserDefinedObject(stringValue: "Sarah", integerValue: 44),
            ]
        var dict = [String: UserDefinedObject]()
        for object in objects {
            dict[object.stringValue] = object
        }
        
        let archive = NSKeyedArchiver.archivedData(withRootObject: dict)
        
        let duplicate: [String:UserDefinedObject] =
            (NSKeyedUnarchiver.unarchiveObject(with: archive) as? [String:UserDefinedObject])!
        
        XCTAssertTrue(dict.count == duplicate.count)
        
        guard dict.count == duplicate.count else { return }
        
        for key in dict.keys {
            let original: UserDefinedObject = dict[key]!
            let dup: UserDefinedObject = duplicate[key]!
            XCTAssertTrue(original == dup)
        }
    }
    
    
    
    
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

} // end class TestDictionary


