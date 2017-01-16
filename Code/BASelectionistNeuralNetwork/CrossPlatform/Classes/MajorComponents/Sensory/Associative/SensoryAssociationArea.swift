//
//  SensoryAssociationArea.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/9/15.
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



// SensoryAssociationArea
//
// Collection of sensory-interneuron layers within a sensory association region.
// The layers within the area are treated as ranging from those closest to the
// sensory region (i.e., layers[0]) to those furthest from the sensory region and
// closest to the motor regions (i.e., layers[layerCount - 1]). Thus, the layer
// depth and the layer count are equal.
//
final public class SensoryAssociationArea: NSObject, NeuralMultiLayerArea, ComputationalNode {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var environment: ComputationalNode { return priv_node.environment }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    // MARK: ComputationalNode Protocol
    
    public var activationSettings: ActivationSettings {
        get { return priv_node.activationSettings }
        set { priv_node.activationSettings = newValue }
    }
    public var learningSettings: LearningSettings {
        get { return priv_node.learningSettings }
        set { priv_node.learningSettings = newValue }
    }
    
    
    // MARK: NodeContainer Protocol
    
    public var maxLayerDepth: Int { return layerCount }
    public var maxNodeWidth: Int {
        let maxWidth = priv_layers.reduce(0) {
            (currentWidth: Int, layer: SensoryAssociationLayer) -> Int in
            if layer.nodeCount > currentWidth {
                return layer.nodeCount
            }
            return currentWidth
        }
        return maxWidth
    }
    
    public var layerCount: Int { return priv_layers.count }
    public var layers: [NeuralLayer] {
        return priv_layers.map() {
            (layer: NeuralLayer) -> NeuralLayer in return layer
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
        priv_layers = aDecoder.decodeObject(forKey: SensoryAssociationArea.key_neurons) as! [SensoryAssociationLayer]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_layers, forKey: SensoryAssociationArea.key_neurons)
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
    // If necessary, additional containers are created to fill a container
    // array with containers between the beginning of the array and the
    // specified index.
    //
    public func create(_ identifier: Identifier? = nil,
                       layerIndex: Int = 0) -> SensoryInterneuron {
        precondition(!isStructureLocked)
            
            let associationLayer = layer(layerIndex)
            let neuron = associationLayer.create(identifier)
            
            return neuron
    }
    
    public subscript(index: Int) -> SensoryAssociationLayer {
        return layer(index)
    }
    public func layer(_ index: Int = 0) -> SensoryAssociationLayer {
        while index >= priv_layers.count {
            precondition(!isStructureLocked)
            
            let id = Identifier(idString: "SensoryAssociationLayer_\(index)")
            priv_layers.append(SensoryAssociationLayer(environment: self, identifier: id))
        }
        return priv_layers[index]
    }
    
    public func getOperantNeurons(_ neurons: inout [OperantNeuron]) -> Void {
        for layer in priv_layers {
            layer.getOperantNeurons(&neurons)
        }
    }
    
    public func activate(_ autoPropogate: Bool) -> Void {
        for layer in priv_layers {
            layer.activate(autoPropogate)
        }
    }
    
    public func commitActivation() -> Void {
        for layer in priv_layers {
            layer.commitActivation()
        }
    }
    
    public func learn() -> Void {
        for layer in priv_layers {
            layer.learn()
        }
    }
    
    public func resetActivation(_ autoPropogate: Bool) -> Void {
        for layer in priv_layers {
            layer.resetActivation(autoPropogate)
        }
    }
    
    
    // MARK: Learn
    
    public func setConnectionWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try setExcitatoryWeights(newValue)
        try setInhibitoryWeights(newValue)
    }
    public func setExcitatoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        for layer in priv_layers {
            try layer.setExcitatoryWeights(newValue)
        }
    }
    public func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        for layer in priv_layers {
            try layer.setInhibitoryWeights(newValue)
        }
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: ComputationalNodeBody
    fileprivate var priv_layers = [SensoryAssociationLayer]()
    
    
    
} // end class SensoryAssociationArea

