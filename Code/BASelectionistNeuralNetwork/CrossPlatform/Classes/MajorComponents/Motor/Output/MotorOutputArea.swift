//
//  MotorOutputArea.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/5/15.
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



final public class MotorOutputArea: NSObject, NeuralSingleLayerArea, ComputationalNode {
    
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
    
    // MARK: NeuralArea Protocol
    
    public var maxLayerDepth: Int { return 1 }
    public var maxNodeWidth: Int { return nodeCount }
    
    
    // MARK: NeuralLayer Protocol
    
    public var nodeCount: Int { return priv_neurons.count }
    public var nodes: [ActivatableNode] {
        return priv_neurons.map() { (neuron: ActivatableNode) -> ActivatableNode in return neuron }
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
        priv_neurons = aDecoder.decodeObject(forKey: MotorOutputArea.key_neurons) as! [MotorNeuron]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_neurons, forKey: MotorOutputArea.key_neurons)
    }
    
    
    // MARK: Create/Access
    
    public func create(_ identifier: Identifier? = nil) -> MotorOutputNeuron {
        precondition(!isStructureLocked)
        precondition(!network.isRegisteredNode(identifier))
        
        let sensor = MotorNeuron(environment: self, identifier: identifier)
        if sensor.hasIdentifier {
            network.registerNode(sensor)
        }
        priv_neurons.append(sensor)
        return sensor
    }
    
    public subscript(index: Int) -> MotorOutputNeuron {
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
    
    fileprivate var priv_neurons = [MotorNeuron]()
    
} // end class MotorOutputArea

