//
//  AxonSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/1/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



public class AxonSymbol: BaseSymbol {
    
    open class AxonAppearance: BaseSymbol.BaseSymbolAppearance {
        open var terminalSymbol: AxonSymbolTerminalBase.BaseTerminalAppearance?
        
        public init(terminalSymbol: AxonSymbolTerminalBase.BaseTerminalAppearance?,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle,
                    padding: CGFloat,
                    label: StrengthText?) {
            
            self.terminalSymbol = terminalSymbol
            
            super.init(fillColor: fillColor,
                       lineStyle: lineStyle,
                       padding: padding,
                       label: label)
        }
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        
        let terminal = AxonSymbolTerminalBase.defaultAppearance()
        
        terminal.terminalType = AxonSymbolTerminalConcave.axonTerminalType()
        
        return AxonAppearance(
            terminalSymbol: terminal,
            fillColor: StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                     colorAtStrongest: NSColor.white.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.darkGray.cgColor,
                                         colorAtStrongest: NSColor.black.cgColor,
                                         widthAtWeakest: 1.0,
                                         widthAtStrongest: 5.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: 0.0,
            label: nil
        )
    }
    
    
    // MARK: Neural Units
    
    open var parentNeuronSymbol: PresynapticSymbolProtocol
    open unowned var targetDendrite: DendriteSymbol
    
    open override var presentationStrength: Scaled0to1Value {
        return parentNeuronSymbol.activationLevel
    }
    
    
    open var heading: CGFloat {
        return Trig.angle(fromPoint: parentNeuronSymbol.center, toPoint: targetDendrite.center)
    }
    
    // MARK: Initialization
    
    
    public init(parentNeuronSymbol: PresynapticSymbolProtocol,
                targetDendrite: DendriteSymbol,
                appearance: BaseLayout.BaseAppearance?) {
        
        self.parentNeuronSymbol = parentNeuronSymbol
        self.targetDendrite = targetDendrite
        
        let myAppearance = appearance != nil
            ? appearance!
            : AxonSymbol.defaultAppearance()
        
        priv_path = NSBezierPath()

        super.init(appearance: myAppearance)
        
        let dendriteConnectionPoint = targetDendrite.connectionPoint
        let basePoint = parentNeuronSymbol.pointAtOffsetFromPath(dendriteConnectionPoint, offset: 0.0)
        
        let totalDistance = Trig.distance(fromPoint: basePoint, toPoint: dendriteConnectionPoint)
        var terminalSymbolLength: CGFloat = 0.0

        if let appearance = myAppearance as? AxonSymbol.AxonAppearance {
            
            if let terminalAppearance = appearance.terminalSymbol {
                
                let terminalType = terminalAppearance.terminalType
                
                let terminalFactory = AxonSymbolTerminals.sharedInstance
                assert(terminalFactory.contains(terminalType: terminalType))
                
                priv_terminal =
                    terminalFactory.create(terminalType: terminalType,
                                           parentAxonSymbol: self,
                                           appearance: terminalAppearance)
                
                terminalSymbolLength = priv_terminal!.length
            }
        }

        let axonLineLength = totalDistance - terminalSymbolLength
        let targetPoint = Trig.pointAt(distance: axonLineLength, heading: heading, fromPoint: basePoint)
        
        priv_path.move(to: basePoint)
        priv_path.line(to: targetPoint)
        
        if let terminal = priv_terminal {
            let connectionPoint = terminal.connectionPoint

            let deltaX = targetPoint.x - connectionPoint.x
            let deltaY = targetPoint.y - connectionPoint.y
            
            terminal.translate(xBy: deltaX, yBy: deltaY)
            
            terminal.rotate(toHeading: heading)
        }
        
        
        extendFrameToInclude(rect: priv_path.bounds)
        
        // Add self to the axon symbol display list for the neural network.
        // The display list effectively is a "layer" in that all axons are 
        // drawn at the same time over any symbols already drawn, and under
        // any symbols drawn afterward.
        //
        parentNeuronSymbol.rootLayout.appendToAxonSymbolDisplayList(axonSymbol: self)

    } // end init
    
    
    // MARK: Search
    
    open override func deepestSymbolLayoutContaining(point: CGPoint) -> BaseSymbol? {
        if priv_terminal != nil && priv_terminal!.contains(point: point) {
            return self
        }
        return super.deepestSymbolLayoutContaining(point: point)
    }
    
    
    
    open override func scale(_ scalingFactor: CGFloat) -> Void {
        var transform = AffineTransform.identity
        transform.scale(scalingFactor)
        priv_path.transform(using: transform)
        
        if let terminal = priv_terminal {
            terminal.scale(scalingFactor)
        }
    }
    
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        super.translate(xBy: deltaX, yBy: deltaY)
        let transform = AffineTransform(translationByX: deltaX, byY: deltaY)
        priv_path.transform(using: transform)
        
        if let terminal = priv_terminal {
            terminal.translate(xBy: deltaX, yBy: deltaY)
        }
    }
    
    
    open override func draw() -> Void {
        super.draw()
        
        // let fillColor = strengthAdjustedFillColor
        
        if let dashesPattern = lineStyle.dashPattern {
            let dashesPhase = lineStyle.dashPatternPhase
            priv_path.setLineDash(dashesPattern,
                                  count: dashesPattern.count,
                                  phase: dashesPhase)
        }
        
        let lineWidth = strengthAdjustedLineWidth
        let lineColor: NSColor = NSColor(cgColor: strengthAdjustedLineColor)!
        
        lineColor.setStroke()
        priv_path.lineWidth = lineWidth
        priv_path.stroke()
        
        if let terminal = priv_terminal {
            terminal.draw()
        }

    } // end draw
    
    
    
    // MARK: *Private*
    
    fileprivate var priv_path: NSBezierPath
    fileprivate var priv_terminal: AxonSymbolTerminalProtocol? = nil
    
} // end class AxonSymbol

