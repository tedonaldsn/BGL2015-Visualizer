//
//  MotorOutputNeuronSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 1/2/17.
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


open class MotorOutputNeuronSymbol: RespondentNeuronSymbol {
    
    open class MotorOutputNeuronAppearance: RespondentNeuronSymbol.RespondentNeuronAppearance {
        
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
        axonAppearance.lineStyle.dashPattern = [ 9, 3 ]
        
        let terminalAppearance = AxonSymbolTerminalBase.defaultAppearance()
        terminalAppearance.terminalType = Identifier(idString: "arrow")
        
        axonAppearance.terminalSymbol = terminalAppearance
        
        return MotorOutputNeuronAppearance(
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
    
    
    open var motorOutputNeuron: BASelectionistNeuralNetwork.MotorOutputNeuron {
        return respondentNeuron as! MotorOutputNeuron
    }
    
    
    
    // MARK: Initialization
    
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : MotorOutputNeuronSymbol.defaultAppearance()
        
        super.init(rootLayout: rootLayout,
                   node: node,
                   appearance: myAppearance)
        
    } // end init
    
} // end class MotorOutputNeuronSymbol

