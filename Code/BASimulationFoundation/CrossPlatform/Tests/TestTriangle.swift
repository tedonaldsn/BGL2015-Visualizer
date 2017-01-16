//
//  TestTriangle.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 12/21/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//
//  See:
//
//  http://www.mathwarehouse.com/geometry/triangles/triangle-types.php

import XCTest

class TestTriangle: XCTestCase {
    
    let sideLength10: CGFloat = 10.0
    let sideLength5: CGFloat = 5.0
    
    let degrees165: CGFloat = Trig.degreeToRadianFactor * 165.0
    let degrees150: CGFloat = Trig.degreeToRadianFactor * 150.0
    let degrees85: CGFloat = Trig.degreeToRadianFactor * 85.0
    let degrees75: CGFloat = Trig.degreeToRadianFactor * 75.0
    let degrees20: CGFloat = Trig.degreeToRadianFactor * 20.0
    let degrees10: CGFloat = Trig.degreeToRadianFactor * 10.0
    let degrees5: CGFloat = Trig.degreeToRadianFactor * 5.0
    

    var obtuseTriangle: Triangle!
    var acuteTriangle: Triangle!
    var scaleneTriangle: Triangle!
    var isoscelesTriangle: Triangle!
    var equilateralTriangle: Triangle!
    var rightTriangle: Triangle!
    

    override func setUp() {
        super.setUp()
        
        // Obtuse Triangle: A: 165º, B: 5º, C: 10º
        //
        obtuseTriangle = Triangle(vertexA: degrees165, notConnectingSide: sideLength10, vertexB: degrees5)
        
        // Acute Triangle: A: 85º, B: 75º, C: 20º; a: 10
        //
        acuteTriangle = Triangle(vertexA: degrees85, notConnectingSide: sideLength10, vertexB: degrees75)
        
        // Scalene Triangle: A: 150º, B: 10º, C: 20º
        //
        scaleneTriangle = Triangle(vertexA: degrees150, notConnectingSide: sideLength10, vertexB: degrees10)
        
        // Isosceles Triangle: A & B: 75º, C: 30º; a & b: 10
        //
        isoscelesTriangle = Triangle(sideA: sideLength10, connectingAngle: Trig.degrees30, sideB: sideLength10)
        
        // Equilateral Triangle: A, B, C: 60º; a, b, c: 10
        //
        equilateralTriangle = Triangle(sideA: sideLength10, connectingAngle: Trig.degrees60, sideB: sideLength10)
        
        // Right Triangle: C: 90º, A: 60º, B: 30º; c: 10
        //
        rightTriangle = Triangle(hypotenuse: sideLength10, vertexA: Trig.degrees60)

    } // end setUp
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testSetup() {
        
        // Obtuse Triangle
        
        XCTAssertTrue(obtuseTriangle.isObtuseTriangle)
        XCTAssertTrue(obtuseTriangle.vertices.A == degrees165)
        XCTAssertTrue(obtuseTriangle.vertices.B == degrees5)
        XCTAssertTrue(obtuseTriangle.vertices.C.rounded6 == degrees10.rounded6)
        XCTAssertTrue(obtuseTriangle.sides.a == sideLength10)
        
        
        // Acute Triangle
        
        XCTAssertTrue(acuteTriangle.isAcuteTriangle)
        XCTAssertTrue(acuteTriangle.vertices.A == degrees85)
        XCTAssertTrue(acuteTriangle.vertices.B == degrees75)
        XCTAssertTrue(acuteTriangle.vertices.C.rounded6 == degrees20.rounded6)
        XCTAssertTrue(acuteTriangle.sides.a == sideLength10)
        
        
        // Scalene Triangle
        
        XCTAssertTrue(scaleneTriangle.isScaleneTriangle)
        XCTAssertTrue(scaleneTriangle.vertices.A == degrees150)
        XCTAssertTrue(scaleneTriangle.vertices.B == degrees10)
        XCTAssertTrue(scaleneTriangle.vertices.C.rounded6 == degrees20.rounded6)
        XCTAssertTrue(scaleneTriangle.sides.a == sideLength10)
        
        // Isosceles Triangle
        
        XCTAssertTrue(isoscelesTriangle.isIsoscelesTriangle)
        XCTAssertTrue(isoscelesTriangle.sides.a == sideLength10)
        XCTAssertTrue(isoscelesTriangle.sides.b == sideLength10)
        
        XCTAssertTrue(isoscelesTriangle.vertices.C == Trig.degrees30)
        XCTAssertTrue(isoscelesTriangle.vertices.A.rounded6 == degrees75.rounded6)
        XCTAssertTrue(isoscelesTriangle.vertices.B.rounded6 == degrees75.rounded6)
        
        // Equilateral Triangle
        //
        XCTAssertTrue(equilateralTriangle.isEquilateralTriangle)
        XCTAssertTrue(equilateralTriangle.sides.a == sideLength10)
        
        // Square Triangle
        //
        XCTAssertTrue(rightTriangle.isRightTriangle)
        XCTAssertTrue(rightTriangle.vertices.C == Trig.degrees90)
        XCTAssertTrue(rightTriangle.vertices.A.rounded6 == Trig.degrees60.rounded6)
        XCTAssertTrue(rightTriangle.vertices.B.rounded6 == Trig.degrees30.rounded6)
        
        XCTAssertTrue(rightTriangle.sides.c == sideLength10)
        let expectedSideA: CGFloat = Trig.side2TriangleAAS(angle1: Trig.degrees90,
                                                           angle2: Trig.degrees60,
                                                           side1: sideLength10)
        XCTAssertTrue(expectedSideA.rounded6 == rightTriangle.sides.a.rounded6)
        let expectedSideB: CGFloat = Trig.side2TriangleAAS(angle1: Trig.degrees90,
                                                           angle2: Trig.degrees30,
                                                           side1: sideLength10)
        XCTAssertTrue(expectedSideB.rounded6 == rightTriangle.sides.b.rounded6)
        
    } // end testSetup
    
    
    

    func testSSA() {
        let sideA = rightTriangle.sides.c
        let sideB = rightTriangle.sides.b
        let vertexA = rightTriangle.vertices.C
        
        // SSA: Two sides and an angle that is NOT the connecting angle where
        // sideA is larger than sideB.
        //
        let ssaInitializedTriangle = Triangle(sideB: sideB,
                                              sideA: sideA,
                                              notConnectingAngle: vertexA)
        
        XCTAssertTrue(ssaInitializedTriangle.isRightTriangle)
        XCTAssertTrue(ssaInitializedTriangle.vertices.A == Trig.degrees90)
        XCTAssertTrue(ssaInitializedTriangle.vertices.B.rounded6 == rightTriangle.vertices.B.rounded6)
        XCTAssertTrue(ssaInitializedTriangle.vertices.C.rounded6 == rightTriangle.vertices.A.rounded6)
        XCTAssertTrue(ssaInitializedTriangle.sides.c.rounded6 == rightTriangle.sides.a.rounded6)
        
    } // end testSSA
    
    


} // end class TestTriangle

