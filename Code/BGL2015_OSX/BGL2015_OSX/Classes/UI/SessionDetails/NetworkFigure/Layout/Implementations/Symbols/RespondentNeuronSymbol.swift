//
//  RespondentNeuronSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 1/1/17.
//  
//  Copyright © 2017 Tom Donaldson.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

//


import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


// RespondentNeuronSymbol
//
// Two activation modes: respondent and operant. Respondent activation has 
// priority. If no respondent connections are activated, then activation of
// the neuron is based on operant connections.
//
open class RespondentNeuronSymbol: OperantNeuronSymbol {
    
    open class RespondentNeuronAppearance: OperantNeuronSymbol.OperantNeuronAppearance {
        
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
        // dendriteAppearance.shapeType = Identifier(idString: "hexagon")
        
        let axonAppearance =
            AxonSymbol.defaultAppearance() as! AxonSymbol.AxonAppearance
        
        return RespondentNeuronAppearance(
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
    
    
    open var respondentNeuron: BASelectionistNeuralNetwork.RespondentNeuron {
        return operantNeuron as! RespondentNeuron
    }
    
    
    
    // MARK: Initialization
    
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : RespondentNeuronSymbol.defaultAppearance()
        
        super.init(rootLayout: rootLayout,
                   node: node,
                   appearance: myAppearance)
        
    } // end init
    
    
    
    
    
    
    // Called by requestConnectionsFromPresynapticSymbols() if there are no
    // dendrites defined when it is called.
    //
    open override func initializeDendriteSymbols() -> Void {
        super.initializeDendriteSymbols()
        
        let respondent: RespondentNeuron = respondentNeuron
        
        var presynapticAxons: [Axon] = respondent.respondentExcitatoryAxons
        presynapticAxons.append(contentsOf: respondent.respondentInhibitoryAxons)
        
        for presynapticAxon in presynapticAxons {
            let presynapticNeuron = presynapticAxon.neuron
            let connectionAttributes =
                respondent.connectionAttributes(presynapticNeuron)!
            let dendriteSymbol = LearningDendriteSymbol(parentNeuronSymbol: self,
                                                        connectionAttributes: connectionAttributes,
                                                        appearance: dendriteSymbolAppearance)
            appendDendriteSymbol(dendriteSymbol: dendriteSymbol)
        }
        
    } // end initializeDendriteSymbols


} // end class RespondentNeuronSymbol
