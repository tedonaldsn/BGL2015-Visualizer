//
//  AxonSymbolTerminalArrow.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/15/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation



public class AxonSymbolTerminalArrow: AxonSymbolTerminalBase, AxonSymbolTerminalProtocol {
    
    
    public override class func axonTerminalType() -> Identifier {
        return Identifier(idString: "arrow")
    }
    

    public static let defaultPointAngle: CGFloat = Trig.pi / 3.0
    public static let defaultBladeEdgeLength: CGFloat = BaseSymbol.initialSize.width / 10.0
    public static let defaultBladeCenterLength: CGFloat = defaultBladeEdgeLength * 0.5
    
    // Non-content display settings
    //
    open class TerminalArrowAppearance: AxonSymbolTerminalBase.BaseTerminalAppearance {
        open var pointAngle: CGFloat
        open var bladeCenterLength: CGFloat
        open var bladeEdgeLength: CGFloat
        
        public init(pointAngle: CGFloat,
                    bladeCenterLength: CGFloat,
                    bladeEdgeLength: CGFloat,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle) {
            
            assert(pointAngle > 0.0)
            assert(pointAngle < Trig.pi)
            assert(bladeCenterLength > 0.0)
            assert(bladeEdgeLength > 0.0)
            
            self.bladeCenterLength = bladeCenterLength
            self.pointAngle = pointAngle
            self.bladeEdgeLength = bladeEdgeLength
            
            super.init(terminalType: AxonSymbolTerminalArrow.axonTerminalType(),
                       fillColor: fillColor,
                       lineStyle: lineStyle)
        }
    }
    
    open override class func defaultAppearance() -> AxonSymbolTerminalBase.BaseTerminalAppearance {
        
        let baseAppearance = AxonSymbolTerminalBase.defaultAppearance()
        baseAppearance.fillColor.colorAtWeakest = NSColor.lightGray.cgColor
        baseAppearance.lineStyle.strengthColor.colorAtWeakest = NSColor.lightGray.cgColor
        
        return TerminalArrowAppearance(pointAngle: AxonSymbolTerminalArrow.defaultPointAngle,
                                       bladeCenterLength: AxonSymbolTerminalArrow.defaultBladeCenterLength,
                                       bladeEdgeLength: AxonSymbolTerminalArrow.defaultBladeEdgeLength,
                                       fillColor: baseAppearance.fillColor,
                                       lineStyle: baseAppearance.lineStyle)
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
    
    // Length from connection point to the point closest to the target.
    //
    open var length: CGFloat {
        return priv_centerLength
    }
    
    
    // MARK: Initialization
    
    
    public required init(parentAxonSymbol: AxonSymbol,
                         appearance: AxonSymbolTerminalBase.BaseTerminalAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : AxonSymbolTerminalArrow.defaultAppearance()
        
        var arrowAppearance = myAppearance as? AxonSymbolTerminalArrow.TerminalArrowAppearance
        if arrowAppearance == nil {
            arrowAppearance =
                (AxonSymbolTerminalArrow.defaultAppearance() as! AxonSymbolTerminalArrow.TerminalArrowAppearance)
        }

        priv_centerLength = arrowAppearance!.bladeCenterLength
        let bladeEdgeLength = arrowAppearance!.bladeEdgeLength
        let pointAngle = arrowAppearance!.pointAngle


        priv_path = NSBezierPath()
        
        super.init(parentAxonSymbol: parentAxonSymbol,
                   appearance: myAppearance)

        // Start the path far enough into Cartesian Quadrant I that all points
        // will fall within Quadrant I.
        //
        let arrowTipPoint = CGPoint(x: bladeEdgeLength * 2.0,
                                    y: bladeEdgeLength * 2.0)
        let initialConnectionPoint = Trig.pointAt(distance: priv_centerLength,
                                                  heading: Trig.pi,
                                                  fromPoint: arrowTipPoint)
        
        let topAngle = Trig.pi + pointAngle / 2.0
        let bottomAngle = Trig.pi - pointAngle / 2.0
        
        let topPoint = Trig.pointAt(distance: bladeEdgeLength,
                                    heading: topAngle,
                                    fromPoint: arrowTipPoint)
        let bottomPoint = Trig.pointAt(distance: bladeEdgeLength,
                                       heading: bottomAngle,
                                       fromPoint: arrowTipPoint)
        
        priv_path.move(to: arrowTipPoint) // element 0
        priv_path.line(to: initialConnectionPoint) // element 1
        priv_path.line(to: topPoint) // element 2
        priv_path.line(to: arrowTipPoint) // element 3
        priv_path.line(to: bottomPoint) // element 4
        priv_path.line(to: initialConnectionPoint) // element 5
        priv_path.close() // element 6

        
        // Ensure that we actually get the correct point back from extracting
        // our connection point from the Bezier path
        //
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
        
        priv_centerLength = priv_centerLength * scalingFactor
        
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
    
    // The path is created by a move(to:) the top end of the angle, then
    // a line(tipOfTheArrow), then a line to the bottom end of the angle.
    // The connection point will always be the associated tip of the arrow 
    // point.
    //
    fileprivate let priv_connectionPointElementIndex = 1
    
    fileprivate var priv_centerLength: CGFloat
    
    fileprivate var priv_path: NSBezierPath
    
} // end class AxonSymbolTerminalArrow

