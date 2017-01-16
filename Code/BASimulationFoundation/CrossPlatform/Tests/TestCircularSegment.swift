//
//  TestCircularSegment.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 12/23/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import XCTest

class TestCircularSegment: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testChangeLeftFacingSagittaHeight() {
        let fromRadians = Trig.pi - Trig.degrees30
        let toRadians = Trig.pi + Trig.degrees30
        
        let segment1 = CircularSegment(center: CGPoint(x: 100.0, y: 100.0),
                                       radius: 10.0,
                                       fromRadians: fromRadians,
                                       toRadians: toRadians)

        // Change sagitta: Returned segment should be identical to original,
        // disregarding rounding errors.
        //
        let segment2 = segment1.changeSagittaHeight(delta: 0.0)
        
        XCTAssert(segment2.circle.center.rounded6 == segment1.circle.center.rounded6)
        XCTAssert(segment2.circle.radius.rounded6 == segment1.circle.radius.rounded6)
        
        XCTAssert(segment2.arcStartPoint.rounded6 == segment1.arcStartPoint.rounded6)
        XCTAssert(segment2.arcCenterPoint.rounded6 == segment1.arcCenterPoint.rounded6)
        XCTAssert(segment2.arcEndPoint.rounded6 == segment1.arcEndPoint.rounded6)
        
        XCTAssert(segment2.sagittaHeight.rounded6 == segment1.sagittaHeight.rounded6)
        XCTAssert(segment2.triangularHeight.rounded6 == segment1.triangularHeight.rounded6)
        
        XCTAssert(segment2.chordLength.rounded6 == segment1.chordLength.rounded6)
        XCTAssert(segment2.chordCenterPoint.rounded6 == segment1.chordCenterPoint.rounded6)
        
        
        // Increase sagitta by a small amount. The only attributes that are 
        // functionally equal in the new segment will be the chord end points.
        // The increase in the arc will necessitate a new circle with a smaller
        // radius.
        //
        let delta: CGFloat = segment1.sagittaHeight * 0.1
        let segment3 = segment1.changeSagittaHeight(delta: delta)
        
        XCTAssert(segment3.sagittaHeight.rounded6 == (segment1.sagittaHeight + delta).rounded6)
        
        XCTAssert(segment3.arcStartPoint.rounded6 == segment1.arcStartPoint.rounded6)
        XCTAssert(segment3.arcEndPoint.rounded6 == segment1.arcEndPoint.rounded6)
        
        XCTAssert(segment3.circle.radius < segment1.circle.radius)
        
        // With shorter radius, the angles from the center of the new circle
        // to the same old chord end points will be opened up.
        //
        XCTAssert(segment3.fromRadians.rounded6 < segment1.fromRadians.rounded6)
        XCTAssert(segment3.toRadians.rounded6 > segment1.toRadians.rounded6)
        
    } // end testChangeLeftFacingSagittaHeight

    
    
    
    func testChangeDownFacingSagittaHeight() {
        let fromRadians = Trig.degrees90 - Trig.degrees30
        let toRadians = Trig.degrees90 + Trig.degrees30
        
        let segment1 = CircularSegment(center: CGPoint(x: 100.0, y: 100.0),
                                       radius: 10.0,
                                       fromRadians: fromRadians,
                                       toRadians: toRadians)
        
        // Change sagitta: Returned segment should be identical to original,
        // disregarding rounding errors.
        //
        let segment2 = segment1.changeSagittaHeight(delta: 0.0)
        
        XCTAssert(segment2.circle.center.rounded6 == segment1.circle.center.rounded6)
        XCTAssert(segment2.circle.radius.rounded6 == segment1.circle.radius.rounded6)
        
        XCTAssert(segment2.arcStartPoint.rounded6 == segment1.arcStartPoint.rounded6)
        XCTAssert(segment2.arcCenterPoint.rounded6 == segment1.arcCenterPoint.rounded6)
        XCTAssert(segment2.arcEndPoint.rounded6 == segment1.arcEndPoint.rounded6)
        
        XCTAssert(segment2.sagittaHeight.rounded6 == segment1.sagittaHeight.rounded6)
        XCTAssert(segment2.triangularHeight.rounded6 == segment1.triangularHeight.rounded6)
        
        XCTAssert(segment2.chordLength.rounded6 == segment1.chordLength.rounded6)
        XCTAssert(segment2.chordCenterPoint.rounded6 == segment1.chordCenterPoint.rounded6)
        
        
        // Increase sagitta by a small amount. The only attributes that are
        // functionally equal in the new segment will be the chord end points.
        // The increase in the arc will necessitate a new circle with a smaller
        // radius.
        //
        let delta: CGFloat = segment1.sagittaHeight * 0.1
        let segment3 = segment1.changeSagittaHeight(delta: delta)
        
        XCTAssert(segment3.sagittaHeight.rounded6 == (segment1.sagittaHeight + delta).rounded6)
        
        XCTAssert(segment3.arcStartPoint.rounded6 == segment1.arcStartPoint.rounded6)
        XCTAssert(segment3.arcEndPoint.rounded6 == segment1.arcEndPoint.rounded6)
        
        XCTAssert(segment3.circle.radius < segment1.circle.radius)
        
        // With shorter radius, the angles from the center of the new circle
        // to the same old chord end points will be opened up.
        //
        XCTAssert(segment3.fromRadians.rounded6 < segment1.fromRadians.rounded6)
        XCTAssert(segment3.toRadians.rounded6 > segment1.toRadians.rounded6)
        
    } // end testChangeDownFacingSagittaHeight
    
    
    
    
    
    func testOrientations() {
        
        let center = CGPoint(x: 0, y: 0)
        let radius: CGFloat = 100
        
        let segment0 = CircularSegment(center: center,
                                         radius: radius,
                                         fromRadians: Trig.radians(fromDegrees: 120.0),
                                         toRadians: Trig.radians(fromDegrees: 0.0))
        
        XCTAssert(segment0.circle.center.rounded6 == center)
        XCTAssert(segment0.circle.radius.rounded6 == radius)
        
        
        
        let segment180 = CircularSegment(center: center,
                                         radius: radius,
                                         fromRadians: Trig.radians(fromDegrees: 120.0),
                                         toRadians: Trig.radians(fromDegrees: 180.0))
        
        XCTAssert(segment180.circle.center.rounded6 == center)
        XCTAssert(segment180.circle.radius.rounded6 == radius)
        
    } // end testOrientations
    
    
    

} // end class TestCircularSegment


