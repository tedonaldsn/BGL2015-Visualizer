//
//  Triangle.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

// CGFloat is declared in Foundation on MacOS, but in UIKit on iOS,
// even though iOS has a Foundation framework.
//
#if os(OSX)
    import Foundation
#elseif os(iOS)
    import UIKit
#endif



// Triangle
//
// All angles are in radians.
//
// As shown in most texts on Trigonometry, angles are labelled with capital
// A, B, and C. Sides are labelled with lower case a, b, and c.
//
// The side with a lower case a, b, or c, is opposite the uppercase of the same
// letter.
//
// No special meanings are assigned to any of the angles, though C is often used
// to denote the right angle in a right triangle. That is a matter of user 
// convenience and makes no difference to the calculations here.
//
public struct Triangle {
    
    public typealias Vertices = (A: CGFloat, B: CGFloat, C: CGFloat)
    public typealias Sides = (a: CGFloat, b: CGFloat, c: CGFloat)
    
    public let vertices: Vertices
    public let sides: Sides
    
    public var sumOfAngles: CGFloat {
        return vertices.A + vertices.B + vertices.C
    }
    
    public var isRightTriangle: Bool {
        let rightAngle = Trig.degrees90.rounded6
        return vertices.A.rounded6 == rightAngle
            || vertices.B.rounded6 == rightAngle
            || vertices.C.rounded6 == rightAngle
    }
    
    public var isEquilateralTriangle: Bool {
        let angle60 = Trig.degrees60.rounded6
        let sideLength = sides.a.rounded6
        return vertices.A.rounded6 == angle60
            && vertices.B.rounded6 == angle60
            && vertices.C.rounded6 == angle60
            && sides.b.rounded6 == sideLength
            && sides.c.rounded6 == sideLength
    }
    
    
    public var isScaleneTriangle: Bool {
        return vertices.A.rounded6 != vertices.B.rounded6
        && vertices.A.rounded6 != vertices.C.rounded6
        && vertices.B.rounded6 != vertices.C.rounded6
        && sides.a.rounded6 != sides.b.rounded6
        && sides.a.rounded6 != sides.c.rounded6
        && sides.b.rounded6 != sides.c.rounded6
    }
    
    
    public var isAcuteTriangle: Bool {
        return vertices.A < Trig.degrees90
            && vertices.B < Trig.degrees90
            && vertices.C < Trig.degrees90
    }
    
    
    public var isObtuseTriangle: Bool {
        return vertices.A > Trig.degrees90
            || vertices.B > Trig.degrees90
            || vertices.C > Trig.degrees90
    }
    
    
    public var isIsoscelesTriangle: Bool {
        return
            (vertices.A.rounded6 == vertices.B.rounded6
                && sides.a.rounded6 == sides.b.rounded6)
                ||
                (vertices.A.rounded6 == vertices.C.rounded6
                    && sides.a.rounded6 == sides.c.rounded6)
                ||
                (vertices.B.rounded6 == vertices.C.rounded6
                    && sides.b.rounded6 == sides.c.rounded6)
    }
    
    
    // Right triangle where hypotenuse (side c) and one of the non-right angles
    // are known (i.e., not vertex C).
    //
    public init(hypotenuse: CGFloat, vertexA: CGFloat) {
        assert(vertexA < Trig.pi/2)
        let vertexC: CGFloat = Trig.pi/2
        
        // Will solve the triangle, but leaves values in unexpected locations.
        //
        let tri = Triangle(vertexA: vertexC, notConnectingSide: hypotenuse, vertexB: vertexA)
        
        // So swap them around to conform to what the user can expect based on
        // the init() arguments.
        //
        self.vertices.C = tri.vertices.A
        self.vertices.A = tri.vertices.B
        self.vertices.B = tri.vertices.C
        
        self.sides.c = tri.sides.a
        self.sides.a = tri.sides.b
        self.sides.b = tri.sides.c
    }
    
    
    // AAS: Any two angles, and one side, BUT the side must NOT be
    // between the two angles.
    //
    public init(vertexA: CGFloat, notConnectingSide sideA: CGFloat, vertexB: CGFloat) {
        assert(vertexA > 0.0)
        assert(vertexA < Trig.circle)
        assert(sideA > 0.0)
        assert(vertexB > 0.0)
        assert(vertexB < Trig.circle)
        
        self.vertices.A = vertexA
        self.sides.a = sideA
        
        self.vertices.B = vertexB
        self.sides.b = Trig.side2TriangleAAS(angle1: vertexA, angle2: vertexB, side1: sideA)

        let vertexC = Trig.triangle - (vertexA + vertexB)
        self.vertices.C = vertexC
        self.sides.c = Trig.side2TriangleAAS(angle1: vertexA, angle2: vertexC, side1: sideA)
        
        assert(sumOfAngles == Trig.triangle)
    }
    
    
    
    
    // SAS: A side, an angle, and the side connected by the angle to the first side.
    //
    public init(sideA: CGFloat, connectingAngle vertexC: CGFloat, sideB: CGFloat) {
        assert(sideA > 0.0)
        assert(sideB > 0.0)
        assert(vertexC > 0.0)
        assert(vertexC < Trig.circle)
        
        self.sides.a = sideA
        self.sides.b = sideB
        
        self.vertices.C = vertexC
        let sideC = Trig.side3TriangleSAS(side1: sideA, angle3: vertexC, side2: sideB)
        self.sides.c = sideC
        
        // Calculate the angle opposite the shorter side to avoid the SSA case with
        // two solutions.
        //
        if sideA == sideB {
            //
            // Sides are equal. It is an isosceles or equilateral triangle.
            //
            let isoscelesAngle = (Trig.pi - vertexC) / 2.0
            self.vertices.A = isoscelesAngle
            self.vertices.B = isoscelesAngle
            
        } else if sideA < sideC {
            let vertexA = Trig.angle2TriangleSSA(side1: sideC, side2: sideA, angle1: vertexC)
            self.vertices.A = vertexA
            self.vertices.B = Trig.pi - (vertexA + vertexC)
            
        } else {
            let vertexB = Trig.angle2TriangleSSA(side1: sideC, side2: sideB, angle1: vertexC)
            self.vertices.B = vertexB
            self.vertices.A = Trig.pi - (vertexB + vertexC)
        }
        
        assert(sumOfAngles.rounded6 == Trig.triangle.rounded6)
    }
    
    
    
    
    
    // SSA: Two sides and an angle that is NOT the connecting angle where
    // sideA is larger than sideB.
    //
    public init(sideB: CGFloat, sideA: CGFloat, notConnectingAngle vertexA: CGFloat) {
        assert(sideA > sideB)
        
        assert(sideB > 0.0)
        assert(vertexA > 0.0)
        
        self.vertices.A = vertexA
        self.sides.a = sideA
        
        let vertexB = Trig.angle2TriangleSSA(side1: sideA, side2: sideB, angle1: vertexA)
        self.sides.b = sideB
        self.vertices.B = vertexB
        
        let vertexC = Trig.pi - (vertexA + vertexB)
        let sideC = Trig.side2TriangleAAS(angle1: vertexA, angle2: vertexC, side1: sideA)
        self.vertices.C = vertexC
        self.sides.c = sideC
        
        assert(sumOfAngles == Trig.triangle)
    }
    
    
    // Scaling
    
    
    public func scaleSideA(_ scalingFactor: CGFloat) -> Triangle {
        let scaledSideA: CGFloat = sides.a * scalingFactor
        return Triangle(vertexA: vertices.A,
                        notConnectingSide: scaledSideA,
                        vertexB: vertices.B)
    }
    
} // end struct Triangle

