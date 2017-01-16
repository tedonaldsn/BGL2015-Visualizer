//
//  EffectorSymbol.swift
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



open class EffectorSymbol: RegularShapeSymbol, PostsynapticSymbolProtocol {
    
    
    open class EffectorAppearance: RegularShapeSymbol.RegularShapeSymbolSymbolAppearance {
        
        public override init(shapeType: Identifier,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle,
                    padding: CGFloat,
                    label: StrengthText?) {
            
            super.init(shapeType: shapeType,
                       fillColor: fillColor,
                       lineStyle: lineStyle,
                       padding: padding,
                       label: label)
        }
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        
        return EffectorAppearance(
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
    
    
    // MARK: Data
    
    open var effector: Effector {
        return node as! Effector
    }
    open var presynapticNeuron: MotorOutputNeuron {
        return effector.receiveFrom
    }
    open var presynapticNeuronSymbol: RespondentNeuronSymbol {
        let targetNeuron = presynapticNeuron
        return rootLayout.updatableNodeLayouts.find(targetNeuron) as! RespondentNeuronSymbol
    }
    
    open override var presentationStrength: Scaled0to1Value {
        return effector.activationLevel
    }
    
    
    // MARK: Initialization
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        assert(node is Effector)
        
        let myAppearance = appearance != nil
            ? appearance!
            : EffectorSymbol.defaultAppearance()
        
        super.init(rootLayout: rootLayout,
                   node: node,
                   appearance: myAppearance)

    } // end init
    
    
    
    
    open func requestConnectionsFromPresynapticSymbols() -> Void {
        let presynapticUnit = presynapticNeuronSymbol
        let dendrite = DendriteSymbol(parentSymbol: self,
                                      presynapticSymbol: presynapticUnit)
        presynapticUnit.connectAxonTo(dendrite: dendrite)
    }
    

} // end class EffectorSymbol


