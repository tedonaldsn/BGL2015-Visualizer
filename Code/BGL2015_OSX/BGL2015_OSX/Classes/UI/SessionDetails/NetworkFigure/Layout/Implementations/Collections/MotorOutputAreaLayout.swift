//
//  MotorOutputAreaLayout.swift
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



open class MotorOutputAreaLayout: LayerLayout {
    
    // MARK: Data
    
    open var motorOutputArea: MotorOutputArea {
        return node as! MotorOutputArea
    }
    
    
    // MARK: Initialization
    
    public init(rootLayout: NeuralNetworkLayout, areaNode: Node) {
        
        assert(areaNode is MotorOutputArea)
        
        super.init(rootLayout: rootLayout, node: areaNode)
    }
    
    
    
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        super.draw()
    }
    
    
} // end class MotorOutputAreaLayout

