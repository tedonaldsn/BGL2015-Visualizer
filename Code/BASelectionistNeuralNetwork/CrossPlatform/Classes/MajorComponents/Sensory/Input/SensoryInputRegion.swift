//
//  SensoryInputRegion.swift
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

// SensoryInputRegion
//
// Region of the network that acts as the primary interface to sensors. Passes
// sensor input along to sensory interneurons and hippocampal neurons.
//
// The region consists of parallel areas of input neurons, where each input
// area is one layer deep.
//
final public class SensoryInputRegion: NSObject, NeuralRegion, ComputationalNode {
    
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
    
    
    // MARK: NeuralRegion Protocol
    
    public var maxLayerDepth: Int { return 1 }
    public var maxNodeWidth: Int {
        return priv_areas.reduce(0) {
            (currentWidth: Int, area: NeuralArea) -> Int in currentWidth + area.maxNodeWidth
        }
    }
    
    public var areaCount: Int { return priv_areas.count }
    public var areas: [NeuralArea] {
        return priv_areas.map() { (area: NeuralArea) -> NeuralArea in return area }
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
        priv_areas = aDecoder.decodeObject(forKey: SensoryInputRegion.key_neurons) as! [SensoryInputArea]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_areas, forKey: SensoryInputRegion.key_neurons)
    }
    
    
    // MARK: Create
    
    public func create(_ identifier: Identifier? = nil,
                       areaIndex: Int = 0) -> SensoryInputNeuron {
        precondition(!isStructureLocked)
        createArea(areaIndex)
        let sensor = priv_areas[areaIndex].create(identifier)
        return sensor
    }
    
    public func createRespondent(_ identifier: Identifier? = nil,
                                areaIndex: Int = 0) -> SensoryInputNeuron {
        precondition(!isStructureLocked)
        createArea(areaIndex)
        let sensor = priv_areas[areaIndex].createRespondent(identifier)
        return sensor
    }
    
    public func createArea(_ index: Int = 0) -> Void {
        while index >= priv_areas.count {
            precondition(!isStructureLocked)
            let id = Identifier(idString: "SensoryInputArea_\(index)")
            priv_areas.append(SensoryInputArea(environment: self, identifier: id))
        }
    }
    
    
    
    // MARK: Access
    
    
    public subscript(index: Int) -> SensoryInputArea {
        return priv_areas[index]
    }
    
    
    
    // MARK: Activation & Learning
    
    public func prepareActivation() -> Void {
        for area in priv_areas {
            area.prepareActivation()
        }
    }
    
    public func commitActivation() -> Void {
        for area in priv_areas {
            area.commitActivation()
        }
    }
    
    
    
    public func resetActivation(_ autoPropogate: Bool) -> Void {
        for area in priv_areas {
            area.resetActivation(autoPropogate)
        }
    }
    
    
    
    // MARK: Testing/Debugging
    
    public func createOperantTestInputNeuron(_ identifier: Identifier? = nil,
                                             areaIndex: Int = 0) -> OperantTestInput {
        createArea(areaIndex)
        let sensor = priv_areas[areaIndex].createOperantTestInputNeuron(identifier)
        return sensor
    }
    
    public func createRespondentTestInputNeuron(_ identifier: Identifier? = nil,
                                               areaIndex: Int = 0) -> RespondentTestInput {
        createArea(areaIndex)
        let sensor = priv_areas[areaIndex].createRespondentTestInputNeuron(identifier)
        return sensor
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: ComputationalNodeBody
    
    fileprivate var priv_areas = [SensoryInputArea]()
    
    
    
} // end class SensoryInputRegion

