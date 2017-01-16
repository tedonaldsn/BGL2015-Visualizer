//
//  OperantNeuronSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/19/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//




import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


// OperantNeuronSymbol
//
// Only learning mode is operant.
//
open class OperantNeuronSymbol: NeuronSymbol {
    
    open class OperantNeuronAppearance: NeuronSymbol.NeuronAppearance {
        
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
        let dendriteAppearance =
            DendriteSymbol.defaultAppearance() as! DendriteSymbol.DendriteAppearance
        let axonAppearance =
            AxonSymbol.defaultAppearance() as! AxonSymbol.AxonAppearance
        
        return OperantNeuronAppearance(
            dendrite: dendriteAppearance,
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
    
    
    open var operantNeuron: BASelectionistNeuralNetwork.OperantNeuron {
        return neuron as! OperantNeuron
    }
    
    
    
    // MARK: Initialization
    
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : OperantNeuronSymbol.defaultAppearance()
        
        super.init(rootLayout: rootLayout,
                   node: node,
                   appearance: myAppearance)
        
    } // end init
    
    
    
    
    
    
    // Called by requestConnectionsFromPresynapticSymbols() if there are no
    // dendrites defined when it is called.
    //
    open override func initializeDendriteSymbols() -> Void {

        var presynapticAxons: [Axon] = operantNeuron.operantExcitatoryAxons
        presynapticAxons.append(contentsOf: operantNeuron.operantInhibitoryAxons)
        
        for presynapticAxon in presynapticAxons {
            let presynapticNeuron = presynapticAxon.neuron
            let connectionAttributes =
                operantNeuron.connectionAttributes(presynapticNeuron)!
            let dendriteSymbol = LearningDendriteSymbol(parentNeuronSymbol: self,
                                                        connectionAttributes: connectionAttributes,
                                                        appearance: dendriteSymbolAppearance)
            appendDendriteSymbol(dendriteSymbol: dendriteSymbol)
        }


    } // end initializeDendriteSymbols
    

    
    
    
    
    
    // MARK: *Private* Data
    
    
    
} // end class OperantNeuronSymbol

