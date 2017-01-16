//
//  RegularShapeSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/7/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class RegularShapeSymbol: ActivatableNodeSymbol {
    
    public static let defaultShape = Identifier(idString: "circle")
    
    
    open class RegularShapeSymbolSymbolAppearance: ActivatableNodeSymbol.ActivatableNodeSymbolAppearance {
        open var shapeType: Identifier
        
        public init(shapeType: Identifier,
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
        return RegularShapeSymbolSymbolAppearance(
            shapeType: defaultShape,
            fillColor: StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                     colorAtStrongest: NSColor.white.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.darkGray.cgColor,
                                         colorAtStrongest: NSColor.black.cgColor,
                                         widthAtWeakest: 1.0,
                                         widthAtStrongest: 5.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: RegularShapeSymbol.defaultPadding,
            label: nil
        )
    }
    
    
    // MARK: Data
    
    open var shape: RegularShapeProtocol {
        return priv_shape.clone()
    }
    
    open var size: CGSize {
        return priv_shape.size
    }
    open var radius: CGFloat {
        return priv_shape.radius
    }
    open var center: CGPoint {
        return priv_shape.center
    }
    open var diameter: CGFloat {
        return priv_shape.diameter
    }
    
    
    // MARK: Initialization
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : RegularShapeSymbol.defaultAppearance()
        
        super.init(rootLayout: rootLayout, node: node, appearance: myAppearance)
        
        
        let initialRect = CGRect(origin: CGPoint(),
                                 size: BaseSymbol.initialSize)
        
        let symbolInsetRect = CGRect(x: frame.origin.x + padding,
                                     y: frame.origin.y + padding,
                                     width: initialRect.width - (2 * padding),
                                     height: initialRect.height - (2 * padding))
        
        var shapeType: Identifier? = nil
        if let myAppearance = myAppearance as? RegularShapeSymbolSymbolAppearance {
            shapeType = myAppearance.shapeType
        } else {
            shapeType = RegularShapeSymbol.defaultShape
        }
        
        assert(Shapes.sharedInstance.contains(shapeType!))
        priv_shape = Shapes.sharedInstance.create(shapeType!,
                                                  centeredInRect: symbolInsetRect)!
        
        extendFrameToInclude(rect: initialRect)
    }
    
    
    
    open func changeShape(toShapeType: Identifier) -> Void {
        precondition(Shapes.sharedInstance.contains(toShapeType))
        let bounds = priv_shape.bounds
        priv_shape = Shapes.sharedInstance.create(toShapeType,
                                                  centeredInRect: bounds)!
    }
    
    
    
    // MARK: Search
    
    open override func deepestSymbolLayoutContaining(point: CGPoint) -> BaseSymbol? {
        if priv_shape.contains(point: point) {
            return self
        }
        return nil
    }
    
    
    // MARK: Trigonometry
    //
    // Shape-related functions for placement of the shape and other graphics
    // that related to it.
    
    // Radian angle from center in the direction of a point.
    //
    open func headingToPoint(_ towardPoint: CGPoint) -> CGFloat {
        return priv_shape.headingToPoint(towardPoint)
    }
    
    // Point at the specified distance from the center of the shape on the
    // specified outbound heading from due east.
    //
    open func pointAt(_ outboundHeading: CGFloat, distanceFromCenter: CGFloat) -> CGPoint {
        return priv_shape.pointAt(outboundHeading, distanceFromCenter: distanceFromCenter)
    }
    
    // Point offset from the shape's path in the direction of a particular point.
    //
    open func pointAtOffsetFromPath(_ towardPoint: CGPoint, offset: CGFloat) -> CGPoint {
        return priv_shape.pointAtOffsetFromPath(towardPoint, offset: offset)
    }
    
    // Point offset from the shape's path in on the specified heading.
    //
    open func pointAtOffsetFromPath(_ headingRadians: CGFloat, offset: CGFloat) -> CGPoint {
        return priv_shape.pointAtOffsetFromPath(headingRadians, offset: offset)
    }
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) -> Void {
        super.scale(scalingFactor)
        priv_shape.scale(scalingFactor)
    }
    
    // MARK: Repositioning
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
        
        super.translate(xBy: deltaX, yBy: deltaY)
        priv_shape.translate(xBy: deltaX, yBy: deltaY)
    }
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        
        // Do not call super: is preconditionFailure("Derived class responsibility")
        // Any classes derived from THIS one must call super.
        
        let fillColor: NSColor = NSColor(cgColor: strengthAdjustedFillColor)!
        fillColor.setFill()
        priv_shape.fill()
        
        priv_shape.lineWidth = strengthAdjustedLineWidth
        let lineColor: NSColor = NSColor(cgColor: strengthAdjustedLineColor)!
        lineColor.setStroke()
        priv_shape.stroke()
        
        if let label = label {
            let rect: CGRect = priv_shape.bounds
            let strength: CGFloat = rawPresentationStrength
            label.draw(inRect: rect, atStrength: strength)
        }
        
    } // end draw
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_shape: RegularShapeProtocol!
    
    
} // end class RegularShapeSymbol

