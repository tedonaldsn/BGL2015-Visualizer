//
//  CircularSegment.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 12/23/16.
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




// https://en.wikipedia.org/wiki/Circular_segment

public struct CircularSegment {
    
    // MARK: Data

    // Circle on which the segment is inscribed
    //
    public let circle: Circle
    
    // Distance from chord to circumference of the segment
    //
    public let sagittaHeight: CGFloat
    
    // Distance from center to chord
    //
    public let triangularHeight: CGFloat
    
    // Chord (baseline) length, center point
    //
    public let chordLength: CGFloat
    public let chordRadians: CGFloat
    public let chordCenterPoint: CGPoint

    // Angles, clockwise from 0.0 radians (i.e., from due east).
    //
    public let fromRadians: CGFloat
    public let centerRadians: CGFloat
    public let toRadians: CGFloat
    
    public let arcStartPoint: CGPoint
    public let arcCenterPoint: CGPoint
    public let arcEndPoint: CGPoint
    
    
    // MARK: Initialization
    
    // Define a circular segment on the circle starting at fromRadians
    // through toRadians.
    //
    // Angles are clockwise from the 0.0 radian, which is due east.
    //
    public init(circle: Circle, fromRadians: CGFloat, toRadians: CGFloat) {
        
        let centerRadians = fromRadians + (toRadians - fromRadians) / 2.0
        
        let arcStartPoint = Trig.pointAt(distance: circle.radius,
                                      heading: fromRadians,
                                      fromPoint: circle.center)
        let arcCenterPoint = Trig.pointAt(distance: circle.radius,
                                        heading: centerRadians,
                                        fromPoint: circle.center)
        let arcEndPoint = Trig.pointAt(distance: circle.radius,
                                    heading: toRadians,
                                    fromPoint: circle.center)
        
        let chordLength = Trig.distance(fromPoint: arcStartPoint,
                                        toPoint: arcEndPoint)
        let chordRadians = Trig.angle(fromPoint: arcStartPoint,
                                      toPoint: arcEndPoint)
        let chordCenterPoint = Trig.pointAt(distance: chordLength / 2.0,
                                            heading: chordRadians,
                                            fromPoint: arcStartPoint)
        
        let triangularHeight = Trig.distance(fromPoint: circle.center,
                                             toPoint: chordCenterPoint)
        let sagittaHeight = Trig.distance(fromPoint: chordCenterPoint,
                                          toPoint: arcCenterPoint)
        
        self.circle = circle
        self.sagittaHeight = sagittaHeight
        self.triangularHeight = triangularHeight
        self.chordLength = chordLength
        self.chordRadians = chordRadians
        self.chordCenterPoint = chordCenterPoint
        self.fromRadians = fromRadians
        self.centerRadians = centerRadians
        self.toRadians = toRadians
        self.arcStartPoint = arcStartPoint
        self.arcCenterPoint = arcCenterPoint
        self.arcEndPoint = arcEndPoint
        
    } // end init
    
    
    public init(center: CGPoint, radius: CGFloat, fromRadians: CGFloat, toRadians: CGFloat) {
        self.init(circle: Circle(center: center, radius: radius),
                  fromRadians: fromRadians,
                  toRadians: toRadians)
    }
    
    
    
    
    

    // MARK: Transforms
    
    // Returns a new segment on a new circle. Chord end points are the same,
    // but the height of the segment from chord to the center point of the
    // arc will be adjusted by the delta amount, which requires that the circle
    // be different (i.e., different radius and center).
    //
    public func changeSagittaHeight(delta: CGFloat) -> CircularSegment {
        
        let newArcCenterPoint = Trig.pointAt(distance: delta,
                                             heading: centerRadians,
                                             fromPoint: arcCenterPoint)

        let newCircle = Circle(point1: arcStartPoint,
                               point2: newArcCenterPoint,
                               point3: arcEndPoint)
        
        let newFromRadians = Trig.angle(fromPoint: newCircle.center,
                                        toPoint: arcStartPoint)
        let newToRadians = Trig.angle(fromPoint: newCircle.center,
                                      toPoint: arcEndPoint)
        
        return CircularSegment(circle: newCircle,
                               fromRadians: newFromRadians,
                               toRadians: newToRadians)
        
    } // end changeSagittaHeight
    
    

    
} // end struct CircularSegment

