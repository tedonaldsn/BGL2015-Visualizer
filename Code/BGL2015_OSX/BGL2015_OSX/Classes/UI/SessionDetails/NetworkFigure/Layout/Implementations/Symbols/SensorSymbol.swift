//
//  SensorSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/22/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class SensorSymbol: RegularShapeSymbol, PresynapticSymbolProtocol {
    
    
    open class SensorAppearance: RegularShapeSymbol.RegularShapeSymbolSymbolAppearance {
        open var axon: AxonSymbol.AxonAppearance?
        
        public init(axon: AxonSymbol.AxonAppearance?,
                    shapeType: Identifier,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle,
                    padding: CGFloat,
                    label: StrengthText?) {
            
            self.axon = axon
            
            super.init(shapeType: shapeType,
                       fillColor: fillColor,
                       lineStyle: lineStyle,
                       padding: padding,
                       label: label)
        }
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        let axonAppearance =
            AxonSymbol.defaultAppearance() as! AxonSymbol.AxonAppearance
        axonAppearance.lineStyle.dashPattern = [ 9, 3 ]
        
        let terminalAppearance = AxonSymbolTerminalBase.defaultAppearance()
        terminalAppearance.terminalType = Identifier(idString: "arrow")
        
        axonAppearance.terminalSymbol = terminalAppearance
        
        return SensorAppearance(
            axon: axonAppearance,
            shapeType: Identifier(idString: "square"),
            fillColor: StrengthColor(colorAtWeakest: NSColor.clear.cgColor,
                                     colorAtStrongest: NSColor.white.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.clear.cgColor,
                                         colorAtStrongest: NSColor.white.cgColor,
                                         widthAtWeakest: 1.0,
                                         widthAtStrongest: 5.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: ActivatableNodeSymbol.defaultPadding,
            label: nil
        )
    }
    
    
    open var sensor: Sensor {
        return node as! Sensor
    }
    
    open var axonSymbols: [AxonSymbol] {
        return [priv_axonSymbol!]
    }
    
    open var axonSymbolAppearance: AxonSymbol.AxonAppearance? = nil
    
    
    // MARK: Initialization
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : SensorSymbol.defaultAppearance()
        
        super.init(rootLayout: rootLayout,
                   node: node,
                   appearance: myAppearance)
        
        if let neuronAppearance = myAppearance as? SensorAppearance {
            axonSymbolAppearance = neuronAppearance.axon
        }
        

    } // end init
    

    
    
    open func connectAxonTo(dendrite: DendriteSymbol) -> Void {
        
        assert(priv_axonSymbol == nil)
        priv_axonSymbol = AxonSymbol(parentNeuronSymbol: self,
                                     targetDendrite: dendrite,
                                     appearance: axonSymbolAppearance)
        
    } // end connectAxonTo
    
    
    
    
    
    
    
    // MARK: Search
    
    open override func deepestSymbolLayoutContaining(point: CGPoint) -> BaseSymbol? {
        //
        // Do NOT check axons here. The bounding rectangle around an axon that
        // stretches across the network will mask a lot of other symbols.
        //
        // Axons will be checked last at a higher level IF no other symbol
        // claims the point.
        //
        /*
        if let target = priv_axonSymbol?.deepestSymbolLayoutContaining(point: point) {
            return target
        }
        */
        return super.deepestSymbolLayoutContaining(point: point)
    }
    
    
    // MARK: Sizing and Positioning
    
    
    open override func scale(_ scalingFactor: CGFloat) -> Void {
        guard scalingFactor != 1.0 else { return }
        
        super.scale(scalingFactor)
        
        if let axon = priv_axonSymbol {
            axon.scale(scalingFactor)
        }
    }
    
    
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
        
        super.translate(xBy: deltaX, yBy: deltaY)
        
        if let axon = priv_axonSymbol {
            axon.translate(xBy: deltaX, yBy: deltaY)
        }
    }
    
    open override func draw() -> Void {
        //
        // Draw neuron body.
        //
        super.draw()
        
        //
        // NOTE: Neuron does NOT draw its axon. ALL axons are drawn
        //      after all neurons are drawn so that axons pass over, or on
        //      top of, neurons.
    }

    
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_axonSymbol: AxonSymbol? = nil
    
} // end SensorSymbol


