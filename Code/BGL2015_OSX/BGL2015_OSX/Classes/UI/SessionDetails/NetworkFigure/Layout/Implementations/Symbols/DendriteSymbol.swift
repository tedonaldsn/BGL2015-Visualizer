//
//  DendriteSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/6/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


// Class DendriteSymbol
//
// Symbol representing the receiving side of a synapse. A dendrite is logically
// part of the the neuron that is receiving signals (i.e., is part of the 
// postsynaptic unit).
//
// The display "strength" for instances of DendriteSymbol are the default for 
// symbols: 1.0. 
//
// Derived classes that wish to vary the display strength should override
// var presentationStrength
//
// The DendriteSymbol is sometimes just a positional placeholder with no 
// displayable shape.
//
open class DendriteSymbol: BaseSymbol {
    
    public class func defaultShape() -> Identifier { return Identifier(idString: "circle") }
    public class func defaultPadding() -> CGFloat { return 0.0 }
    public class func defaultDiameter() -> CGFloat { return BaseSymbol.initialSize.width / 10.0 }
    public class func defaultRadius() -> CGFloat { return defaultDiameter() / 2.0 }
    public class func defaultInitialSize() -> CGSize {
        return CGSize(width: defaultDiameter(),
                      height: defaultDiameter())
    }
    
    
    
    open class DendriteAppearance: BaseSymbol.BaseSymbolAppearance {
        open var shapeType: Identifier?
        
        public init(shapeType: Identifier?,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle,
                    padding: CGFloat,
                    label: StrengthText?) {
            
            self.shapeType = shapeType
            super.init(fillColor: fillColor,
                       lineStyle: lineStyle,
                       padding: padding,
                       label: label)
        }
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        return DendriteAppearance(
            shapeType: defaultShape(),
            fillColor: StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                     colorAtStrongest: NSColor.white.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.lightGray.cgColor,
                                         colorAtStrongest: NSColor.black.cgColor,
                                         widthAtWeakest: 1.0,
                                         widthAtStrongest: 5.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: defaultPadding(),
            label: nil
        )
    }
    
    
    // MARK: Pre/Post Synaptic Units
    
    // Owner of the receptor.
    //
    open let parentSymbol: RegularShapeSymbol
    //
    // Unit sending activaton to receptor
    //
    open let presynapticSymbol: PresynapticSymbolProtocol
    

    // MARK: Geometry
    
    // Suggested point at which to terminate the presynaptic symbol's
    // axon.
    //
    open var connectionPoint: CGPoint {
        let point = pointAtOffsetFromPath(presynapticSymbol.center, offset: minimumSynapticGap)
        return point
    }
    
    open var minimumSynapticGap: CGFloat {
        return lineStyle.strengthLineWidth.maximum / 2.0
    }
    
    open var hasShape: Bool { return priv_shape != nil }
    
    open var shape: RegularShapeProtocol? {
        return priv_shape ?? priv_shape!.clone()
    }
    
    open var size: CGSize {
        if let shape = priv_shape {
            return shape.size
        }
        return frame.size
    }
    open var radius: CGFloat {
        return diameter / 2.0
    }
    open var center: CGPoint {
        if let shape = priv_shape {
            return shape.center
        }
        return CGPoint(x: frame.midX,
                       y: frame.midY)
    }
    open var diameter: CGFloat {
        if let shape = priv_shape {
            return shape.diameter
        }
        return frame.size.width
    }
    
    
    
    open override var statusSummary: NSAttributedString? {
        let info = NSMutableAttributedString()
        
        if let label = presynapticSymbol.label {
            info.append(label.text)
        }
        
        info.append(NSAttributedString(string: " - "))
        
        if let label = parentSymbol.label {
            info.append(label.text)
        }
        
        return info
    }

    
    // MARK: Initialization
    
    public init(parentSymbol: RegularShapeSymbol,
                presynapticSymbol: PresynapticSymbolProtocol,
                appearance: BaseLayout.BaseAppearance? = nil) {
        
        self.parentSymbol = parentSymbol
        self.presynapticSymbol = presynapticSymbol
        
        let myAppearance = appearance != nil
            ? appearance!
            : DendriteSymbol.defaultAppearance()
        
        super.init(appearance: myAppearance)
        
        var receptorAppearance: DendriteAppearance!
        
        if appearance is DendriteAppearance {
            receptorAppearance = myAppearance as! DendriteAppearance
        } else {
            receptorAppearance = DendriteSymbol.defaultAppearance() as! DendriteAppearance
        }
        
        if let shapeType = receptorAppearance.shapeType {
            assert(Shapes.sharedInstance.contains(shapeType))
            
            let initialRect = CGRect(origin: CGPoint(),
                                     size: DendriteSymbol.defaultInitialSize())
            let padding = receptorAppearance.padding
            let symbolInsetRect = CGRect(x: padding,
                                         y: padding,
                                         width: initialRect.width - (2 * padding),
                                         height: initialRect.height - (2 * padding))
            
            priv_shape = Shapes.sharedInstance.create(shapeType,
                                                      centeredInRect: symbolInsetRect)!
            
            extendFrameToInclude(rect: initialRect)
        }
        
        // Move self into position on the parent neuron symbol. Want to sit on
        // the neuron symbol's border at the point closest to the presynaptic
        // symbol.
        //
        let toPoint = parentSymbol.pointAtOffsetFromPath(presynapticSymbol.center,
                                                         offset: 0.0)
        let fromPoint = center
        
        translate(xBy: toPoint.x - fromPoint.x,
                  yBy: toPoint.y - fromPoint.y)
        
    } // end init
    
    
    
    // MARK: Search
    
    open override func deepestSymbolLayoutContaining(point: CGPoint) -> BaseSymbol? {
        if priv_shape != nil && priv_shape!.contains(point: point) {
            return self
        }
        return nil
    }
    
    
    
    // MARK: Trigonometry
    //
    // Shape-related functions for placement of the shape and other graphics
    // that related to it. If the receptor symbol does not have a shape, uses
    // frame as reference.
    
    // Radian angle from center in the direction of a point.
    //
    open func headingToPoint(_ towardPoint: CGPoint) -> CGFloat {
        return Trig.angle(fromPoint: center, toPoint: towardPoint)
    }
    
    // Point at the specified distance from the center of the shape on the
    // specified outbound heading from due east.
    //
    open func pointAt(_ outboundHeading: CGFloat, distanceFromCenter: CGFloat) -> CGPoint {
        return Trig.pointAt(distance: distanceFromCenter,
                            heading: outboundHeading,
                            fromPoint: center)
    }
    
    // Point offset from the shape's path in the direction of a particular point.
    //
    open func pointAtOffsetFromPath(_ towardPoint: CGPoint, offset: CGFloat) -> CGPoint {
        let heading = headingToPoint(towardPoint)
        return pointAtOffsetFromPath(heading, offset: offset)
    }
    
    // Point offset from the shape's path in on the specified heading.
    //
    open func pointAtOffsetFromPath(_ headingRadians: CGFloat, offset: CGFloat) -> CGPoint {
        let distance = priv_shape != nil
            ? priv_shape!.distanceToPath(headingRadians)
            : 0.0
        let distanceToOffset = distance + offset
        return Trig.pointAt(distance: distanceToOffset,
                            heading: headingRadians,
                            fromPoint: center)
    }
    
    
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) -> Void {
        guard scalingFactor != 1.0 else { return }
        
        super.scale(scalingFactor)
        if let shape = priv_shape {
            shape.scale(scalingFactor)
        }
    }
    
    // MARK: Repositioning
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
        
        super.translate(xBy: deltaX, yBy: deltaY)
        if let shape = priv_shape {
            shape.translate(xBy: deltaX, yBy: deltaY)
        }
    }
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        
        if let shape = priv_shape {
            let fillColor: NSColor = NSColor(cgColor: strengthAdjustedFillColor)!
            fillColor.setFill()
            shape.fill()
            
            shape.lineWidth = strengthAdjustedLineWidth
            let lineColor: NSColor = NSColor(cgColor: strengthAdjustedLineColor)!
            lineColor.setStroke()
            shape.stroke()
            
            if let label = label {
                let rect: CGRect = shape.bounds
                let strength: CGFloat = rawPresentationStrength
                label.draw(inRect: rect, atStrength: strength)
            }
        }
        
    } // end draw

    
    
    
    // MARK: *Private* Data
    
    
    fileprivate var priv_shape: RegularShapeProtocol? = nil
    
} // end class DendriteSymbol


