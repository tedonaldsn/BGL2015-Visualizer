//
//  SensoryInputArea.swift
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



final public class SensoryInputArea: NSObject, NeuralSingleLayerArea {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    // MARK: NeuralArea Protocol
    
    public var maxLayerDepth: Int { return 1 }
    public var maxNodeWidth: Int { return priv_neurons.count }
    
    
    // MARK: NeuralLayer Protocol
    
    public var nodeCount: Int { return priv_neurons.count }
    public var nodes: [ActivatableNode] {
        return priv_neurons.map() {
            (neuron: Neuron) -> ActivatableNode in return neuron
        }
    }
    
    
    // MARK: Data
    
    public var sensoryInputNeurons: [SensoryInputNeuron] { return priv_neurons }
    
    
    // MARK: Initialization
    
    public init(environment: ComputationalNode, identifier: Identifier? = nil) {
        priv_node = NodeBody(network: environment.network, identifier: identifier)
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_neurons = "neurons"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = NodeBody(coder: aDecoder)!
        let objArray: NSArray = aDecoder.decodeObject(forKey: SensoryInputArea.key_neurons) as! NSArray
        for neuron in objArray {
            priv_neurons.append(neuron as! SensoryInputNeuron)
        }
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        let objArray: NSMutableArray = NSMutableArray()
        for neuron in priv_neurons {
            objArray.add(neuron)
        }
        aCoder.encode(objArray, forKey: SensoryInputArea.key_neurons)
    }
    
    
    // MARK: Create
    
    public func create(_ identifier: Identifier? = nil) -> SensoryInputNeuron {
        precondition(!isStructureLocked)
        precondition(!network.isRegisteredNode(identifier))
        let sensor = OperantInputNeuron(environment: self, identifier: identifier)
        if sensor.hasIdentifier {
            network.registerNode(sensor)
        }
        priv_neurons.append(sensor)
        return sensor
    }
    
    public func createRespondent(_ identifier: Identifier? = nil) -> SensoryInputNeuron {
        precondition(!isStructureLocked)
        precondition(!network.isRegisteredNode(identifier))
        let sensor = RespondentInputNeuron(environment: self, identifier: identifier)
        if sensor.hasIdentifier {
            network.registerNode(sensor)
        }
        priv_neurons.append(sensor)
        return sensor
    }


    // MARK: Access
    
    public subscript(index: Int) -> SensoryInputNeuron {
        return priv_neurons[index]
    }
    
    
    
    // MARK: Activation & Learning
    
    public func prepareActivation() -> Void {
        for neuron in priv_neurons {
            neuron.commitActivation()
        }
    }
    
    public func commitActivation() -> Void {
        for neuron in priv_neurons {
            neuron.prepareActivation()
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
    
    // MARK: Testing/Debugging
    
    
    
    public func createOperantTestInputNeuron(_ identifier: Identifier? = nil) -> OperantTestInput {
        precondition(!network.isRegisteredNode(identifier))
        let sensor = OperantTestInput(environment: self, identifier: identifier)
        priv_neurons.append(sensor)
        return sensor
    }
    public func createRespondentTestInputNeuron(_ identifier: Identifier? = nil) -> RespondentTestInput {
        precondition(!network.isRegisteredNode(identifier))
        let sensor = RespondentTestInput(environment: self, identifier: identifier)
        priv_neurons.append(sensor)
        return sensor
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: NodeBody
    
    fileprivate var priv_neurons = [SensoryInputNeuron]()
    
} // end class SensoryInputArea

