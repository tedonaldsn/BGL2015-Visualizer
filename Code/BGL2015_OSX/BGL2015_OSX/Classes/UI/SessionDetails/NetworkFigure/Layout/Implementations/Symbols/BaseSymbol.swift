//
//  BaseSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/1/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


open class BaseSymbol: BaseLayout, BaseSymbolProtocol {
    
    
    // Symbols are displayed in a square area. Initial dimension is the length
    // of the sides at the time a symbol is created.
    //
    // Symbols are initially the same size as a spacer.
    //
    public static let initialSize: CGSize = SpacerLayout.initialSize
    public static let defaultPadding: CGFloat = 8.0
    
    
    
    // Non-content display settings
    //
    open class BaseSymbolAppearance: BaseLayout.BaseAppearance {
        open var fillColor: StrengthColor
        open var lineStyle: StrengthLineStyle
        open var label: StrengthText?
        
        public init(fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle,
                    padding: CGFloat,
                    label: StrengthText?) {
            
            self.fillColor = fillColor
            self.lineStyle = lineStyle
            self.label = label
            super.init(padding: padding)
        }
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        return BaseSymbol.BaseSymbolAppearance(
            fillColor: StrengthColor(colorAtWeakest: NSColor.clear.cgColor,
                                     colorAtStrongest: NSColor.clear.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.clear.cgColor,
                                         colorAtStrongest: NSColor.clear.cgColor,
                                         widthAtWeakest: 0.0,
                                         widthAtStrongest: 0.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: 0.0,
            label: nil
        )
    }
    
    
    
    
    // MARK: Class Data and Methods
    
    public static let floatingPointFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 1
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    public class func format(value: Double) -> String {
        return floatingPointFormatter.string(from: NSNumber(value: value))!
    }
    public class func format(cgFloatValue: CGFloat) -> String {
        return format(value: Double(cgFloatValue))
    }
    public class func format(scaledValue: Scaled0to1Value) -> String {
        return format(value: scaledValue.rawValue)
    }
    

    
    // MARK: Visual Settings
    
    // When drawing, fill then stroke. The line width will vary with
    // activation level, and may cover part of the fill (versus the
    // fill overwriting part of the line).
    //
    open var fillColor: StrengthColor {
        get { return priv_fillColor }
        set { priv_fillColor = newValue.clone() }
    }
    open var lineStyle: StrengthLineStyle {
        get { return priv_lineStyle }
        set { priv_lineStyle = newValue.clone() }
    }
    
    // Label gets drawn last, over/on symbol.
    //
    open var label: StrengthText? {
        get { return priv_label }
        set { priv_label = newValue?.clone() }
    }
    
    
    
    // MARK: Presentation Strength
    
    // Base level strength is always at max: 1.0. Override this variable
    // to return values appropriate to the type of neural node.
    //
    open var presentationStrength: Scaled0to1Value {
        return Scaled0to1Value(rawValue: 1.0)
    }
    
    
    

    
    
    // MARK: Initialization
    
    public override init(appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : BaseSymbol.defaultAppearance()
        
        super.init(appearance: myAppearance)
        
        
        if let myAppearance = myAppearance as? BaseSymbolAppearance {
            self.fillColor = myAppearance.fillColor
            self.lineStyle = myAppearance.lineStyle
            self.label = myAppearance.label
        }
    }
    
    // MARK: Search
    
    open func deepestSymbolLayoutContaining(point: CGPoint) -> BaseSymbol? {
        if frame.contains(point) {
            return self
        }
        return nil
    }
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) {
        super.scale(scalingFactor)
        
        if scalingFactor != 1.0 {
            if let label = priv_label {
                label.scale(scalingFactor)
            }
            
            priv_lineStyle.scale(scalingFactor)
        }
    }
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_label: StrengthText? = nil
    fileprivate var priv_lineStyle = StrengthLineStyle()
    fileprivate var priv_fillColor = StrengthColor()
    
} // end class BaseSymbol

