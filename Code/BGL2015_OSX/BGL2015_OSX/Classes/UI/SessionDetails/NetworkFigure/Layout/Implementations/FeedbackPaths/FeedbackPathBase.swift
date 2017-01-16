//
//  FeedbackPathBase.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/30/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork




open class FeedbackPathBase: BaseSymbol {
    
    // Non-content display settings
    //
    open class FeedbackPathAppearance: BaseSymbol.BaseSymbolAppearance {
        
        public override init(fillColor: StrengthColor,
                             lineStyle: StrengthLineStyle,
                             padding: CGFloat,
                             label: StrengthText?) {
            
            super.init(fillColor: fillColor,
                       lineStyle: lineStyle,
                       padding: padding,
                       label: label)
        }
    }

    open class func defaultHippocampalSignalAppearance() -> FeedbackPathBase.FeedbackPathAppearance {

        let colorAtWeakest: CGColor = NSColor.fromRGB(red: 202,
                                                      green: 225,
                                                      blue: 255).cgColor

        let colorAtStrongest: CGColor = NSColor.fromRGB(red: 100,
                                                        green: 144,
                                                        blue: 255).cgColor
        
        let widthAtWeakest = DendriteSymbol.defaultDiameter()
        let widthAtStrongest = widthAtWeakest * 2.0
        
        return FeedbackPathAppearance(
            fillColor: StrengthColor(colorAtWeakest: colorAtWeakest,
                                     colorAtStrongest: colorAtStrongest),
            lineStyle: StrengthLineStyle(colorAtWeakest: colorAtWeakest,
                                         colorAtStrongest: colorAtStrongest,
                                         widthAtWeakest: widthAtWeakest,
                                         widthAtStrongest: widthAtStrongest,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: 0.0,
            label: nil
        )
    }
    //
    // http://cloford.com/resources/colours/500col.htm
    //
    open class func defaultDopaminergicSignalAppearance() -> FeedbackPathBase.FeedbackPathAppearance {
        //
        // thistle
        //
        let colorAtWeakest: CGColor = NSColor.fromRGB(red: 216,
                                                      green: 191,
                                                      blue: 216).cgColor
        //
        // magenta3
        //
        let colorAtStrongest: CGColor = NSColor.fromRGB(red: 205,
                                                        green: 0,
                                                        blue: 205).cgColor
        
        let widthAtWeakest = DendriteSymbol.defaultDiameter()
        let widthAtStrongest = widthAtWeakest * 2.0
        
        return FeedbackPathAppearance(
            fillColor: StrengthColor(colorAtWeakest: colorAtWeakest,
                                     colorAtStrongest: colorAtStrongest),
            lineStyle: StrengthLineStyle(colorAtWeakest: colorAtWeakest,
                                         colorAtStrongest: colorAtStrongest,
                                         widthAtWeakest: widthAtWeakest,
                                         widthAtStrongest: widthAtStrongest,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: 0.0,
            label: nil
        )
    }
    
    
    // MARK: Data
    
    public unowned let rootLayout: NeuralNetworkLayout
    
    open let isSensory: Bool
    open var isMotor: Bool { return !isSensory }
    
    open override var presentationStrength: Scaled0to1Value {
        
        let strength = isSensory
            ? rootLayout.hippocampalSignal
            : rootLayout.dopaminergicSignal
        
        return strength
    }
    
    public var path: NSBezierPath {
        return priv_path
    }
    
    
    
    // MARK: Initialization
    
    
    // This private initializer does all of the actual work of setting up a
    // path for a layer.
    //
    public init(rootLayout: NeuralNetworkLayout,
                 isSensory: Bool,
                 appearance: FeedbackPathBase.FeedbackPathAppearance? = nil) {
        
        self.rootLayout = rootLayout
        self.isSensory = isSensory
        
        var myAppearance: FeedbackPathBase.FeedbackPathAppearance? = appearance
        if myAppearance == nil {
            myAppearance = isSensory
                ? FeedbackPathBase.defaultHippocampalSignalAppearance()
                : FeedbackPathBase.defaultDopaminergicSignalAppearance()
        }
        
        priv_path = NSBezierPath()

        // priv_path.lineCapStyle = NSLineCapStyle.buttLineCapStyle
        // priv_path.lineCapStyle = NSLineCapStyle.squareLineCapStyle
        priv_path.lineCapStyle = NSLineCapStyle.roundLineCapStyle
        
        // priv_path.lineJoinStyle = NSLineJoinStyle.bevelLineJoinStyle
        // priv_path.lineJoinStyle = NSLineJoinStyle.miterLineJoinStyle
        priv_path.lineJoinStyle = NSLineJoinStyle.roundLineJoinStyle
        
        super.init(appearance: myAppearance)
        
        if label == nil {
            label = StrengthText()
        }

    } // end init
    
    
    
    // MARK: Search
    
    open override func deepestSymbolLayoutContaining(point: CGPoint) -> BaseSymbol? {
        if priv_path.contains(point) {
            return self
        }
        
        return super.deepestSymbolLayoutContaining(point: point)
    }
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) -> Void {
        guard scalingFactor != 1.0 else { return }
        
        super.scale(scalingFactor)
        var transform = AffineTransform.identity
        transform.scale(scalingFactor)
        priv_path.transform(using: transform)
    }
    
    
    
    // MARK: Repositioning
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
        
        super.translate(xBy: deltaX, yBy: deltaY)
        
        let transform = AffineTransform(translationByX: deltaX, byY: deltaY)
        priv_path.transform(using: transform)
    }
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        super.draw()
        
        /*
        let fillColor: NSColor = NSColor(cgColor: strengthAdjustedFillColor)!
        fillColor.setFill()
        priv_path.fill()
        */
        
        priv_path.lineWidth = strengthAdjustedLineWidth
        let lineColor: NSColor = NSColor(cgColor: strengthAdjustedLineColor)!
        lineColor.setStroke()
        priv_path.stroke()
        
    } // end draw
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_path: NSBezierPath
    
    
} // end class FeedbackPathBase

