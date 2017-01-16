//
//  VentralTegmentalArea.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 11/7/15.
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
//  https://en.wikipedia.org/wiki/Ventral_tegmental_area
//



import Foundation
import BASimulationFoundation


final public class VentralTegmentalArea: NSObject, NeuralSingleLayerArea, ComputationalNode {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var environment: ComputationalNode { return priv_node.environment }
    public var network: Network { return priv_node.network }
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
    public var maxNodeWidth: Int { return priv_neurons.count }
    
    
    // MARK: NeuralLayer Protocol
    
    public var nodeCount: Int { return priv_neurons.count }
    public var nodes: [ActivatableNode] {
        return priv_neurons.map() { (neuron: ActivatableNode) -> ActivatableNode in return neuron }
    }
    
    
    // Signal that will be provided to all sensory motor neurons and the hippocampus.
    // This will be the average discrepancySignal output by all dopaminergic units
    // within this VTA.
    //
    public var dopaminergicSignal: Double {
        let sum: Double = priv_neurons.reduce(0.0) {
            (sum: Double, neuron: DopaminergicNeuron) in sum + neuron.discrepancySignal
        }
        let average = sum/Double(priv_neurons.count)
        return average
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
        priv_neurons = aDecoder.decodeObject(forKey: VentralTegmentalArea.key_neurons) as! [DopaminergicUnit]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_neurons, forKey: VentralTegmentalArea.key_neurons)
    }
    
    
    // MARK: Create/Access
    
    // Creates dopaminergic neuron. If specified containers do not exist,
    // also creates them with default identifiers.
    //
    // If neuron identifier is empty, creates the neuron
    // unconditionally. But if a non-empty identifier is specified and
    // an neuron already exists with the given non-empty identifier
    // in the specified containers, throws an exception.
    //
    public func create(_ identifier: Identifier? = nil) -> DopaminergicNeuron {
        precondition(!isStructureLocked)
        precondition(!network.isRegisteredNode(identifier))
        
        let neuron = DopaminergicUnit(environment: self, identifier: identifier)
        if neuron.hasIdentifier {
            network.registerNode(neuron)
        }
        priv_neurons.append(neuron)
        return neuron
    }
    
    
    // MARK: Acesss
    
    public subscript(index: Int) -> DopaminergicNeuron {
        return priv_neurons[index]
    }
    
    public func getOperantNeurons(_ neurons: inout [OperantNeuron]) -> Void {
        for neuron in priv_neurons {
            neurons.append(neuron)
        }
    }
    
    
    // MARK: Activate
    
    public func resetActivation() -> Void {
        for neuron in priv_neurons {
            neuron.resetActivation()
        }
    }
    
    public func prepareActivation() -> Void {
        for neuron in priv_neurons {
            neuron.prepareActivation()
        }
    }
    
    public func commitActivation() {
        for neuron in priv_neurons {
            neuron.commitActivation()
        }
    }
    
    
    // MARK: Learn
    
    public func learn() {
        for neuron in priv_neurons {
            neuron.learn()
        }
    }
    
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
    fileprivate var priv_neurons = [DopaminergicUnit]()
    
} // end class VentralTegmentalArea

