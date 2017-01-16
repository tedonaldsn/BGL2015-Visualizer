//
//  SensoryInputNeuronSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/29/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class SensoryInputNeuronSymbol: NeuronSymbol {
    
    
    open class SensoryInputNeuronAppearance: NeuronSymbol.NeuronAppearance {
        
        public override init(dendrite: DendriteSymbol.DendriteAppearance?,
                    axon: AxonSymbol.AxonAppearance?,
                    shapeType: Identifier,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle,
                    padding: CGFloat,
                    label: StrengthText?) {
            
            super.init(dendrite: dendrite,
                       axon: axon,
                       shapeType: shapeType,
                       fillColor: fillColor,
                       lineStyle: lineStyle,
                       padding: padding,
                       label: label)
        }
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        let neuronAppearance =
            (NeuronSymbol.defaultAppearance() as! NeuronSymbol.NeuronAppearance)

        neuronAppearance.dendrite?.shapeType = nil
        
        return SensoryInputNeuronAppearance(
            dendrite: neuronAppearance.dendrite,
            axon: neuronAppearance.axon,
            shapeType: Identifier(idString: "square"),
            fillColor: StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                     colorAtStrongest: NSColor.white.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.lightGray.cgColor,
                                         colorAtStrongest: NSColor.white.cgColor,
                                         widthAtWeakest: 1.0,
                                         widthAtStrongest: 5.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: ActivatableNodeSymbol.defaultPadding,
            label: nil
        )
    }
    
    open var sensoryInputNeuron: SensoryInputNeuron {
        return activatableNode as! SensoryInputNeuron
    }
    

    open var sensorySymbol: SensorSymbol {
        return priv_sensorSymbol!
    }
    
    // Initialized to non-nil in init(). Nil when no longer needed or useful,
    // that is, after call to initializeDendriteSymbols()
    //
    open var dendriteAppearance: DendriteSymbol.DendriteAppearance?
    
    
    // MARK: Initialization
    

    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : SensoryInputNeuronSymbol.defaultAppearance()
        
        super.init(rootLayout: rootLayout,
                   node: node,
                   appearance: myAppearance)
        
        let symbol = updatableNodeLayouts.find(sensoryInputNeuron.sensor)
        assert(symbol is SensorSymbol)
        priv_sensorSymbol = symbol as? SensorSymbol
        
        if let inputNeuronAppearance = myAppearance as? SensoryInputNeuronAppearance {
            dendriteAppearance = inputNeuronAppearance.dendrite
        } else {
            let defaultAppearance = SensoryInputNeuronSymbol.defaultAppearance() as! SensoryInputNeuronAppearance
            dendriteAppearance = defaultAppearance.dendrite
        }
        
        
    } // end init
    
    
    // Called by requestConnectionsFromPresynapticSymbols() if there are no
    // dendrites defined when it is called.
    //
    open override func initializeDendriteSymbols() -> Void {
        assert(priv_sensorSymbol != nil)

        let dendrite = DendriteSymbol(parentSymbol: self,
                                      presynapticSymbol: priv_sensorSymbol!,
                                      appearance: dendriteAppearance)
        
        appendDendriteSymbol(dendriteSymbol: dendrite)
        
        dendriteAppearance = nil

    } // end initializeDendriteSymbols


    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_sensorSymbol: SensorSymbol? = nil
    
    
} // end SensoryInputNeuronSymbol


