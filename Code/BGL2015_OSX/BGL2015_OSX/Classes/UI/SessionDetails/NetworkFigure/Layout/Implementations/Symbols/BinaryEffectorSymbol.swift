//
//  BinaryEffectorSymbol.swift
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


open class BinaryEffectorSymbol: EffectorSymbol {
    
    
    // MARK: Data
    
    open var binaryEffector: BinaryEffector {
        return effector as! BinaryEffector
    }
    
    open var isOn: Bool {
        return binaryEffector.isOn
    }
    
    open override var presentationStrength: Scaled0to1Value {
        let value = isOn ? Scaled0to1Value.maximum : Scaled0to1Value.minimum
        return value
    }
    
    open override var statusSummary: NSAttributedString? {
        let info = NSMutableAttributedString(attributedString: super.statusSummary!)
        
        info.append(NSAttributedString(string: "\nOn: \(isOn)"))
        
        return info
    }
    
    
    // MARK: Initialization
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        assert(node is BinaryEffector)
        
        super.init(rootLayout: rootLayout,
                   node: node,
                   appearance: appearance)
        
    } // end init
    
    
} // end class BinaryEffectorSymbol


