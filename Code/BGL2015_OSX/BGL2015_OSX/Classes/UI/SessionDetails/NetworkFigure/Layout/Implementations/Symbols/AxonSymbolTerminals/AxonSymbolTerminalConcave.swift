//
//  AxonSymbolTerminalConcave.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/20/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Cocoa
import BASimulationFoundation


// AxonSymbolTerminalConcave
//
// Concave lens shape. Drawn opening facing east (i.e., 0 radians), with the 
// bulging backside facing west (i.e., pi radians).
//
// The radius determines the shape of the inner arc (i.e., the arc closest to
// the target of the terminal). 
//
// The arc angle (in radians) determines the width of the inner arc at the 
// radius. Half of the arc angle will be north of the arc's center line, and 
// half below.
//
// The outer arc will be determined by the thickness appearance variable. The
// outer arc will connect with the ends of the inner arc to form a lens shape.
//
// The initial location of the concave shape will be an arbitrary location.
// Translate the shape into the desired starting position using the connection
// point.
//
// Rotation spins the shape around the connection point.
//
public class AxonSymbolTerminalConcave: AxonSymbolTerminalBase, AxonSymbolTerminalProtocol {
    
    public override class func axonTerminalType() -> Identifier {
        return Identifier(idString: "concave")
    }
    
    
    public static let defaultInnerArcRadius: CGFloat = DendriteSymbol.defaultRadius() + 2.5
    public static let defaultArcWidthAngle: CGFloat = Trig.degrees120
    public static let defaultThickness: CGFloat = 2.5
    
    // Non-content display settings
    //
    open class TerminalConcaveAppearance: AxonSymbolTerminalBase.BaseTerminalAppearance {
        
        open var defaultInnerArcRadius: CGFloat
        open var arcWidthRadians: CGFloat
        open var thickeness: CGFloat
        
        
        public init(defaultInnerArcRadius: CGFloat,
                    arcWidthRadians: CGFloat,
                    thickeness: CGFloat,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle) {
            
            self.defaultInnerArcRadius = defaultInnerArcRadius
            self.arcWidthRadians = arcWidthRadians
            self.thickeness = thickeness
            
            super.init(terminalType: AxonSymbolTerminalArrow.axonTerminalType(),
                       fillColor: fillColor,
                       lineStyle: lineStyle)
        }
    }
    
    open override class func defaultAppearance() -> AxonSymbolTerminalBase.BaseTerminalAppearance {
        
        let baseAppearance = AxonSymbolTerminalBase.defaultAppearance()
        
        return TerminalConcaveAppearance(
            defaultInnerArcRadius: AxonSymbolTerminalConcave.defaultInnerArcRadius,
            arcWidthRadians: AxonSymbolTerminalConcave.defaultArcWidthAngle,
            thickeness: AxonSymbolTerminalConcave.defaultThickness,
            fillColor: baseAppearance.fillColor,
            lineStyle: baseAppearance.lineStyle
        )
    }
    
    
    // MARK: Data
    
    // Point at which the axon should visually connect to the terminal.
    // The terminal symbol is rotated around this point.
    //
    open var connectionPoint: CGPoint {
        var point = CGPoint()
        let _ = priv_path.element(at: priv_connectionPointElementIndex,
                                  associatedPoints: &point)
        return point
    }
    
    
    // Length from connection point to the point closest to the target. It
    // will be half the current thickness of the shape at its thickest point.
    //
    open var length: CGFloat {
        return priv_centerLength
    }
    
    
    
    // MARK: Initialization
    
    
    public required init(parentAxonSymbol: AxonSymbol,
                         appearance: AxonSymbolTerminalBase.BaseTerminalAppearance? = nil) {
        
        super.init(parentAxonSymbol: parentAxonSymbol)
        
        var concaveAppearance = appearance as? AxonSymbolTerminalConcave.TerminalConcaveAppearance
        if concaveAppearance == nil {
            concaveAppearance =
                (AxonSymbolTerminalConcave.defaultAppearance() as! TerminalConcaveAppearance)
        }
        
        let defaultInnerArcRadius = concaveAppearance!.defaultInnerArcRadius
        let arcWidthRadians = concaveAppearance!.arcWidthRadians
        let lensThickness = concaveAppearance!.thickeness
        
        // Final length through the center includes space for the maximum line
        // width, or rather, the half of that maximum width that would extend
        // beyond the path.
        //
        let lineStyle = concaveAppearance!.lineStyle
        priv_centerLength = lensThickness + (lineStyle.strengthLineWidth.maximum / 2.0)
        
        let initialCenter = CGPoint(x: defaultInnerArcRadius * 2.0,
                                    y: defaultInnerArcRadius * 2.0)
        
        let deflection = arcWidthRadians / 2.0
        let fromRadians1 = Trig.pi - deflection
        let toRadians1 = Trig.pi + deflection
        
        let innerArc = CircularSegment(center: initialCenter,
                                       radius: defaultInnerArcRadius,
                                       fromRadians: fromRadians1,
                                       toRadians: toRadians1)
        
        let fromDegrees1: CGFloat = innerArc.fromRadians * Trig.radianToDegreeFactor
        let toDegrees1: CGFloat = innerArc.toRadians * Trig.radianToDegreeFactor
        
        // Mismatch: CircularSegment measures angles clockwise. NSBezierPath measures
        // arc angles counterclockwise. Must convert.
        //
        let fromPathDegrees1 = 360.0 - fromDegrees1
        let toPathDegrees1 = 360.0 - toDegrees1
        
        let innerArcPath = NSBezierPath()
        innerArcPath.appendArc(withCenter: innerArc.circle.center,
                               radius: innerArc.circle.radius,
                               startAngle: fromPathDegrees1,
                               endAngle: toPathDegrees1,
                               clockwise: true)
        
        
        let outerArc = innerArc.changeSagittaHeight(delta: lensThickness)
        
        let fromDegrees2: CGFloat = outerArc.fromRadians * Trig.radianToDegreeFactor
        let toDegrees2: CGFloat = outerArc.toRadians * Trig.radianToDegreeFactor
        
        // Mismatch: CircularSegment measures angles clockwise. NSBezierPath measures
        // arc angles counterclockwise. Must convert.
        //
        let fromPathDegrees2 = 360.0 - fromDegrees2
        let toPathDegrees2 = 360.0 - toDegrees2
        
        let outerArcPath = NSBezierPath()
        outerArcPath.appendArc(withCenter: outerArc.circle.center,
                               radius: outerArc.circle.radius,
                               startAngle: fromPathDegrees2,
                               endAngle: toPathDegrees2,
                               clockwise: true)
        
        priv_path.append(innerArcPath)
        priv_path.append(outerArcPath)
        
        // Fix any gaps left by rounding errors.
        //
        priv_path.move(to: innerArc.arcStartPoint)
        priv_path.line(to: outerArc.arcStartPoint)
        priv_path.move(to: innerArc.arcEndPoint)
        priv_path.line(to: outerArc.arcEndPoint)

        priv_path.close()
        
        priv_path.lineCapStyle = NSLineCapStyle.roundLineCapStyle
        // priv_path.lineCapStyle = NSLineCapStyle.buttLineCapStyle
        // priv_path.lineCapStyle = NSLineCapStyle.squareLineCapStyle
        
        // priv_path.lineJoinStyle = NSLineJoinStyle.bevelLineJoinStyle
        
        priv_path.windingRule = NSWindingRule.evenOddWindingRule

        // Append the connection point as the final element and record
        // the element index. This allows us to reestablish a valid location
        // after a transform of the path.
        //
        let initialConnectionPoint = outerArc.arcCenterPoint
        priv_path.move(to: initialConnectionPoint)
        priv_connectionPointElementIndex = priv_path.elementCount - 1

        let icp = connectionPoint
        assert(icp == initialConnectionPoint)

    } // end init
    
    
    
    
    // MARK: Search
    
    open override func contains(point: CGPoint) -> Bool {
        return priv_path.contains(point)
    }
    
    
    
    
    // MARK: Transforms
    
    open override func scale(_ scalingFactor: CGFloat) -> Void {
        guard scalingFactor != 1.0 else { return }
        
        super.scale(scalingFactor)
        
        var transform = AffineTransform.identity
        transform.scale(scalingFactor)
        priv_path.transform(using: transform)
        
    } // end scale
    
    
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
        
        super.translate(xBy: deltaX, yBy: deltaY)
        
        let transform = AffineTransform(translationByX: deltaX, byY: deltaY)
        priv_path.transform(using: transform)
    }
    
    
    // MARK: Turning
    
    open override func rotate(byRadians byClockwiseRadians: CGFloat) -> Void {
        guard byClockwiseRadians != 0.0 else { return }
        
        let correctConnectionPoint = connectionPoint
        
        super.rotate(byRadians: byClockwiseRadians)
        
        // The affine transform rotates the path COUNTERCLOCKWISE,
        // which is the opposite of what we want. So: adjust the
        // angle passed to the transform.
        //
        let counterclockwiseRadians = Trig.circle - byClockwiseRadians
        
        var transform = AffineTransform.identity
        transform.rotate(byRadians: counterclockwiseRadians)
        priv_path.transform(using: transform)
        
        // The NSBezierPath rotates around the origin of the coordinate system.
        // Thus, after the rotation the path is out of place. Must now
        // translate it back to the connection point.
        //
        let rotatedConnectionPoint = connectionPoint
        
        let deltaX = correctConnectionPoint.x - rotatedConnectionPoint.x
        let deltaY = correctConnectionPoint.y - rotatedConnectionPoint.y
        translate(xBy: deltaX, yBy: deltaY)
        
    } // end rotate
    
    
    
    
    
    
    // MARK: Drawing
    
    // Base level draw does nothing, but calling it is harmless.
    //
    open func draw() -> Void {

        let fillColor: NSColor = NSColor(cgColor: strengthAdjustedFillColor)!
        fillColor.setFill()
        priv_path.fill()

        let lineWidth: CGFloat = strengthAdjustedLineWidth
        let lineColor: NSColor = NSColor(cgColor: strengthAdjustedLineColor)!
        
        lineColor.setStroke()
        priv_path.lineWidth = lineWidth
        priv_path.stroke()
    }
    
    
    
    
    // MARK: *Private* Data
    
    // The connection point is created by an initial move(to:) whose sole
    // purpose is this path element. The point associated with this move
    // is the connection point
    //
    fileprivate var priv_connectionPointElementIndex: Int = 0
    
    fileprivate var priv_path = NSBezierPath()
    
    fileprivate var priv_centerLength: CGFloat = 0.0
    
    
} // end class AxonSymbolTerminalConcave


    
