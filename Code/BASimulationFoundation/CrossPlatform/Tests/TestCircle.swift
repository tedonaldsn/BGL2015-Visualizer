//
//  TestCircle.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 12/22/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import XCTest

class TestCircle: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testStraightLineDetection() {
        
        let pt1straight = CGPoint(x: 56.0, y: 75.0)
        let pt2straight = CGPoint(x: 40.0, y: 75.0)
        let pt3straight = CGPoint(x: 13.0, y: 75.0)
        
        let pt1curve1 = CGPoint(x: 56.0, y: 75.0)
        let pt2curve1 = CGPoint(x: 40.0, y: 100.0)
        let pt3curve1 = CGPoint(x: 56.0, y: 125.0)
        
        let pt1curve2 = CGPoint(x: 56.0, y: 75.0)
        let pt2curve2 = CGPoint(x: 55.999999, y: 100.0)
        let pt3curve2 = CGPoint(x: 56.0, y: 125.0)
        
        // Circle.isStraightLine() is used within the Circle.init() as a
        // precondition check. The Circle.init() cannot handle points in
        // a straight line ... is not part of a circle.
        //
        XCTAssert(Circle.isStraightLine(point1: pt1straight,
                                        point2: pt2straight,
                                        point3: pt3straight))
        
        XCTAssert(!Circle.isStraightLine(point1: pt1curve1,
                                         point2: pt2curve1,
                                         point3: pt3curve1))
        
        XCTAssert(!Circle.isStraightLine(point1: pt1curve2,
                                         point2: pt2curve2,
                                         point3: pt3curve2))
    } // end testStraightLineDetection
    
    
    

    func testInitFromThreePoints() {
        
        let center = CGPoint(x: 100.0, y: 100.0)
        let radius: CGFloat = 30.0
        
        let pt1 = CGPoint(x: center.x, y: center.y + radius) // @ 270º
        let pt2 = CGPoint(x: center.x - radius, y: center.y) // @ 180
        let pt3 = CGPoint(x: center.x, y: center.y - radius) // @ 90º
        let pt4 = CGPoint(x: center.x + radius, y: center.y) // @ 0º
        
        let sampleCircle = Circle(center: center, radius: radius)
        
        let pt270 = sampleCircle.pointAt(degrees: 270.0)
        let pt180 = sampleCircle.pointAt(degrees: 180.0)
        let pt90 = sampleCircle.pointAt(degrees: 90.0)
        let pt0 = sampleCircle.pointAt(degrees: 0.0)
        
        XCTAssert(pt270.x.rounded6 == pt1.x)
        XCTAssert(pt270.y.rounded6 == pt1.y)
        XCTAssert(pt180.x.rounded6 == pt2.x)
        XCTAssert(pt180.y.rounded6 == pt2.y)
        XCTAssert(pt90.x.rounded6 == pt3.x)
        XCTAssert(pt90.y.rounded6 == pt3.y)
        XCTAssert(pt0.x.rounded6 == pt4.x)
        XCTAssert(pt0.y.rounded6 == pt4.y)
        
        let testCircle = Circle(point1: pt270, point2: pt180, point3: pt90)
        
        XCTAssert(testCircle.center.x.rounded6 == center.x)
        XCTAssert(testCircle.center.y.rounded6 == center.y)
        XCTAssert(testCircle.radius.rounded6 == radius)
        
    } // end testInitFromThreePoints
    
    

} // end class TestCircle


