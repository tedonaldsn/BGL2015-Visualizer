//
//  MotorAssociationLayer.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/10/15.
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



import Foundation
import BASimulationFoundation



// MotorAssociationLayer
// 
// One parallel collection of motor inter-neurons.
//
final public class MotorAssociationLayer: NSObject, NeuralLayer, ComputationalNode {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    final public var identifier: Identifier? { return priv_node.identifier }
    final public var environment: ComputationalNode { return priv_node.environment }
    final public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    // MARK: ComputationalNode Protocol
    
    final public var activationSettings: ActivationSettings {
        get { return priv_node.activationSettings }
        set { priv_node.activationSettings = newValue }
    }
    final public var learningSettings: LearningSettings {
        get { return priv_node.learningSettings }
        set { priv_node.learningSettings = newValue }
    }
    
    
    // MARK: NeuralLayer Protocol
    
    public var nodeCount: Int { return priv_neurons.count }
    public var nodes: [ActivatableNode] {
        return priv_neurons.map() {
            (neuron: ActivatableNode) -> ActivatableNode in return neuron
        }
    }
    

    
    // MARK: Initialization
    
    public init(environment: ComputationalNode, identifier: Identifier? = nil) {
        priv_node = ComputationalNodeBody(environment: environment, identifier: identifier)
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_neurons = "neurons"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = ComputationalNodeBody(coder: aDecoder)!
        priv_neurons = aDecoder.decodeObject(forKey: MotorAssociationLayer.key_neurons) as! [MotorAssociativeNeuron]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_neurons, forKey: MotorAssociationLayer.key_neurons)
    }
    
    
    // MARK: Create/Access
    
    // Creates sensory interneuron. If specified containers do not exist,
    // also creates them with default identifiers.
    //
    // If interneuron identifier is empty, creates the interneuron
    // unconditionally. But if a non-empty identifier is specified and
    // an interneuron already exists with the given non-empty identifier
    // in the specified containers, throws an exception.
    //
    public func create(_ identifier: Identifier? = nil) -> MotorInterneuron {
        precondition(!isStructureLocked)
        precondition(!network.isRegisteredNode(identifier))
        
        let neuron = MotorAssociativeNeuron(environment: self, identifier: identifier)
        if neuron.hasIdentifier {
            network.registerNode(neuron)
        }
        priv_neurons.append(neuron)
        return neuron
    }
    
    
    // MARK: Access
    
    public subscript(index: Int) -> MotorInterneuron {
        return priv_neurons[index]
    }
    
    public func getOperantNeurons(_ neurons: inout [OperantNeuron]) -> Void {
        for neuron in priv_neurons {
            neurons.append(neuron)
        }
    }
    
    public func activate(_ autoPropogate: Bool) -> Void {
        for neuron in priv_neurons {
            neuron.prepareActivation()
            if autoPropogate {
                neuron.commitActivation()
            }
        }
    }
    
    public func commitActivation() -> Void {
        for neuron in priv_neurons {
            neuron.commitActivation()
        }
    }
    
    public func learn() -> Void {
        for neuron in priv_neurons {
            neuron.learn()
        }
    }
    
    public func resetActivation(_ autoPropogate: Bool) -> Void {
        for neuron in priv_neurons {
            neuron.resetActivation()
            if autoPropogate {
                neuron.commitActivation()
            }
        }
    }
    
    
    // MARK: Learn
    
    public func setConnectionWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try setExcitatoryWeights(newValue)
        try setInhibitoryWeights(newValue)
    }
    public func setExcitatoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        for neuron in priv_neurons {
            try neuron.setExcitatoryWeights(newValue)
        }
    }
    public func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        for neuron in priv_neurons {
            try neuron.setInhibitoryWeights(newValue)
        }
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: ComputationalNodeBody
    
    fileprivate var priv_neurons = [MotorAssociativeNeuron]()
    
} // end class MotorAssociationLayer.swift

