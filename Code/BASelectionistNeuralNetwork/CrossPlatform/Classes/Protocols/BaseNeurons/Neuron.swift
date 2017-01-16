//
//  Neuron.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 8/14/15.
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
//  Note: The Scaled0to1Value enforces its range even when set using its
//        rawValue attribute via a precondition.





import BASimulationFoundation


public protocol Neuron: ActivatableNode, Axon {
    
    
    // MARK: Query Connections
    
    func containsPresynapticConnection(_ targetIdentifier: Identifier) -> Bool
    func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron?
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // init?(coder aDecoder: NSCoder)
    // func encodeWithCoder(aCoder: NSCoder)

} // end protocol Neuron


public extension Neuron {
    
    public func isBackConnectionTo(_ neuron: Neuron) -> Bool {
        if let targetIdentifier = neuron.identifier {
            return containsPresynapticConnection(targetIdentifier)
        }
        return false
    }
    
    public func isForwardConnectionTo(_ neuron: Neuron) -> Bool {
        return neuron.isBackConnectionTo(self)
    }
}
