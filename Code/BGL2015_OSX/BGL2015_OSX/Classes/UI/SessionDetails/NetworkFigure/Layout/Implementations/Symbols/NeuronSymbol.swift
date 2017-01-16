//
//  NeuronSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/6/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class NeuronSymbol: RegularShapeSymbol, PresynapticSymbolProtocol, PostsynapticSymbolProtocol {
    
    open class NeuronAppearance: RegularShapeSymbol.RegularShapeSymbolSymbolAppearance {
        open var dendrite: DendriteSymbol.DendriteAppearance?
        open var axon: AxonSymbol.AxonAppearance?
        
        public init(dendrite: DendriteSymbol.DendriteAppearance?,
                    axon: AxonSymbol.AxonAppearance?,
                    shapeType: Identifier,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle,
                    padding: CGFloat,
                    label: StrengthText?) {
            
            self.dendrite = dendrite
            self.axon = axon
            
            super.init(shapeType: shapeType,
                       fillColor: fillColor,
                       lineStyle: lineStyle,
                       padding: padding,
                       label: label)
        }
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        let dendrite =
            DendriteSymbol.defaultAppearance() as! DendriteSymbol.DendriteAppearance
        let axonAppearance =
            AxonSymbol.defaultAppearance() as! AxonSymbol.AxonAppearance
        
        return NeuronAppearance(
            dendrite: dendrite,
            axon: axonAppearance,
            shapeType: Identifier(idString: "circle"),
            fillColor: StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                     colorAtStrongest: NSColor.white.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.lightGray.cgColor,
                                         colorAtStrongest: NSColor.black.cgColor,
                                         widthAtWeakest: 1.0,
                                         widthAtStrongest: 5.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: ActivatableNodeSymbol.defaultPadding,
            label: nil
        )
    }
    
    
    
    // MARK: Data
    
    
    
    open var neuron: BASelectionistNeuralNetwork.Neuron {
        return activatableNode as! Neuron
    }
    
    
    // Symbols for connections to other neural units from this one.
    //
    open var axonSymbols: [AxonSymbol] {
        return priv_axonSymbols
    }
    
    
    // Symbols for connections to this neuron from other neural units.
    //
    open var dendriteSymbols: [DendriteSymbol] {
        return priv_dendriteSymbols
    }
    

    open var dendriteSymbolAppearance: DendriteSymbol.DendriteAppearance

    open var axonSymbolAppearance: AxonSymbol.AxonAppearance {
        return priv_axonSymbolAppearance!
    }
    
    
    
    // MARK: Initialization
    
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : NeuronSymbol.defaultAppearance()
        
        let neuronAppearance: NeuronSymbol.NeuronAppearance
            = myAppearance is NeuronAppearance
                ? myAppearance as! NeuronAppearance
                : NeuronSymbol.defaultAppearance() as! NeuronAppearance
        
        if let dendriteAppearance = neuronAppearance.dendrite {
            self.dendriteSymbolAppearance = dendriteAppearance
        } else {
            self.dendriteSymbolAppearance =
                DendriteSymbol.defaultAppearance() as! DendriteSymbol.DendriteAppearance
        }
        
        super.init(rootLayout: rootLayout,
                   node: node,
                   appearance: myAppearance)
        
        priv_axonSymbolAppearance = neuronAppearance.axon
        
    } // end init
    
    
    
    
    
    
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
        for axonSymbol in priv_axonSymbols {
            if let target = axonSymbol.deepestSymbolLayoutContaining(point: point) {
                return target
            }
        }
        */
        for dendriteSymbol in dendriteSymbols {
            if let target = dendriteSymbol.deepestSymbolLayoutContaining(point: point) {
                return target
            }
        }
        return super.deepestSymbolLayoutContaining(point: point)
    }
    
    
    
    // Derived class responsibility. 
    //
    // Called by requestConnectionsFromPresynapticSymbols() if there are no
    // dendrites defined when it is called.
    //
    open func initializeDendriteSymbols() -> Void {
    }
    
    
    // Called by derived class initializeDendriteSymbols() to save dendrite
    // symbol.
    //
    open func appendDendriteSymbol(dendriteSymbol: DendriteSymbol) -> Void {
        priv_dendriteSymbols.append(dendriteSymbol)
    }
    
    
    // For each dendrite, request that the presynaptic unit's symbol draw
    // an axon symbol to the dendrite.
    //
    open func requestConnectionsFromPresynapticSymbols() -> Void {
        
        if priv_dendriteSymbols.isEmpty {
            initializeDendriteSymbols()
        }
        
        for dendrite in priv_dendriteSymbols {
            let presynapticSymbol = dendrite.presynapticSymbol
            presynapticSymbol.connectAxonTo(dendrite: dendrite)
        }
    }
    
    
    // Invoked by requestConnectionsFromPresynapticSymbols() when the
    // dendrites are created on the postsynaptic symbol.
    //
    open func connectAxonTo(dendrite: DendriteSymbol) -> Void {
        
        // Create axon and save reference to it for scaling and translation,
        // but NOT drawing. The axon will automatically register itself
        // with the root neural network layout for drawing in a "layer" of its
        // own.
        //
        let axonSymbol = AxonSymbol(parentNeuronSymbol: self,
                                    targetDendrite: dendrite,
                                    appearance: axonSymbolAppearance)
        
        priv_axonSymbols.append(axonSymbol)
        
    } // end connectAxonTo
    
    

    
    
    
    
    
    // MARK: Sizing and Positioning
    
    
    open override func scale(_ scalingFactor: CGFloat) -> Void {
        guard scalingFactor != 1.0 else { return }
        
        super.scale(scalingFactor)
        
        for dendrite in priv_dendriteSymbols {
            dendrite.scale(scalingFactor)
        }
        for axon in priv_axonSymbols {
            axon.scale(scalingFactor)
        }
    }
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
        
        super.translate(xBy: deltaX, yBy: deltaY)
        
        for dendrite in priv_dendriteSymbols {
            dendrite.translate(xBy: deltaX, yBy: deltaY)
        }
        for axon in priv_axonSymbols {
            axon.translate(xBy: deltaX, yBy: deltaY)
        }
    }
    
    open override func draw() -> Void {
        //
        // Draw neuron body.
        //
        super.draw()
        //
        // Draw dendrite symbols on the neuron body.
        //
        for dendrite in priv_dendriteSymbols {
            dendrite.draw()
        }
        //
        // NOTE: Neuron does NOT draw its axon. ALL axons are drawn
        //      after all neurons are drawn so that axons pass over, or on
        //      top of, neurons.
    }
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_dendriteSymbols = [DendriteSymbol]()
    fileprivate var priv_dendriteSymbolAppearance: DendriteSymbol.DendriteAppearance? = nil
    
    fileprivate var priv_axonSymbols = [AxonSymbol]()
    fileprivate var priv_axonSymbolAppearance: AxonSymbol.AxonAppearance? = nil
    
    
    
} // end class NeuronSymbol



