//
//  Hippocampus.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/7/15.
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



// Hippocampus
//
// A layer of hippocampal units, where each hippocampal unit may primarily
// receive input from distinct sensory regions.
//
final public class Hippocampus: NSObject, NeuralRegion, NeuralSingleLayerArea, ComputationalNode {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var environment: ComputationalNode { return priv_node.environment }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    // MARK: NeuralRegion Protocol
    
    // public var maxLayerDepth: Int { return 1 }
    // public var maxNodeWidth: Int { return priv_neurons.count }
    
    public var areaCount: Int { return 1 }
    public var areas: [NeuralArea] { return [self] }
    
    // MARK: ComputationalNode Protocol
    
    final public var activationSettings: ActivationSettings {
        get { return priv_node.activationSettings }
        set { priv_node.activationSettings = newValue }
    }
    final public var learningSettings: LearningSettings {
        get { return priv_node.learningSettings }
        set { priv_node.learningSettings = newValue }
    }
    
    // MARK: NeuralSingleLayerArea Protocol
    
    public var maxLayerDepth: Int { return 1 }
    public var maxNodeWidth: Int { return priv_neurons.count }
    
    
    
    public var nodeCount: Int { return priv_neurons.count }
    public var nodes: [ActivatableNode] {
        return priv_neurons.map() {
            (neuron: ActivatableNode) -> ActivatableNode in return neuron
        }
    }
    

    // Signal that will be provided to all sensory interneurons by sensory areas.
    // This will be the average discrepancySignal output by all hippocampal units
    // within this Hippocampus.
    //
    public var hippocampalSignal: Double {
        let sum: Double = priv_neurons.reduce(0.0) {
            (sum: Double, neuron: HippocampalNeuron) in sum + neuron.discrepancySignal
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
        priv_neurons = aDecoder.decodeObject(forKey: Hippocampus.key_neurons) as! [HippocampalUnit]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_neurons, forKey: Hippocampus.key_neurons)
    }
    
    
    // MARK: Create/Access
    
    // Creates hippocampal neuron. If specified containers do not exist,
    // also creates them with default identifiers.
    //
    // If neuron identifier is empty, creates the neuron
    // unconditionally. But if a non-empty identifier is specified and
    // an neuron already exists with the given non-empty identifier
    // in the specified containers, throws an exception.
    //
    public func create(_ identifier: Identifier? = nil) -> HippocampalNeuron {
        precondition(!isStructureLocked)
        precondition(!network.isRegisteredNode(identifier))
        
        let neuron = HippocampalUnit(environment: self, identifier: identifier)
        if neuron.hasIdentifier {
            network.registerNode(neuron)
        }
        priv_neurons.append(neuron)
        return neuron
    }
    
    public subscript(index: Int) -> HippocampalNeuron {
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
    fileprivate var priv_neurons = [HippocampalUnit]()
    
} // end class Hippocampus

