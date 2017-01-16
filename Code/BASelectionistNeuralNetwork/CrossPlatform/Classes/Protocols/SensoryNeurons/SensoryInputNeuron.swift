//
//  SensoryInputNeuron.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/1/15.
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



import BASimulationFoundation



public protocol SensoryInputNeuron: Neuron {
    
    
    // Sensor from which this neuron takes its input. Once sensor per 
    // sensory input neuron.
    //
    var sensor: Sensor { get set }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // init?(coder aDecoder: NSCoder)
    // func encodeWithCoder(aCoder: NSCoder)
    
    // Initialization
    
    init(environment: Node, identifier: Identifier?)
    
} // end protocol SensoryInputNeuron




extension SensoryInputNeuron {
    
    public func sendExcitation(_ neuron: SensoryInterneuron) -> Void {
        neuron.receiveExcitation(self)
    }
    public func sendInhibition(_ neuron: SensoryInterneuron) -> Void {
        neuron.receiveInhibition(self)
    }
}
