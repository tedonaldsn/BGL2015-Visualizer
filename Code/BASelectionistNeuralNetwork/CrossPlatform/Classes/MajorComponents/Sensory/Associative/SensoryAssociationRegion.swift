//
//  SensoryAssociationRegion.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/8/15.
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


// SensoryAssociationRegion
//
// Collection of parallel sensory-interneuron areas. The separate areas may
// be treated as servicing different sets of sensors, as in a visual area,
// an auditory area. 
//
// There can be only one "layer" of areas. Layer depth of the region is
// determined by the sensory association areas.
//
final public class SensoryAssociationRegion: NSObject, NeuralRegion, ComputationalNode {
    
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
    
    public var maxLayerDepth: Int {
        let maxDepth = priv_areas.reduce(0) {
            (currentMax: Int, area: SensoryAssociationArea) -> Int in
            return area.layerCount > currentMax ? area.layerCount : currentMax
        }
        return maxDepth
    }
    public var maxNodeWidth: Int {
        return priv_areas.reduce(0) {
            (currentWidth: Int, area: SensoryAssociationArea) -> Int in
            let areaWidth = area.maxNodeWidth
            return areaWidth > currentWidth ? areaWidth : currentWidth
        }
    }
    
    public var areaCount: Int { return priv_areas.count }
    public var areas: [NeuralArea] {
        return priv_areas.map() {
            (area: NeuralArea) -> NeuralArea in return area
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
        priv_areas = aDecoder.decodeObject(forKey: SensoryAssociationRegion.key_neurons) as! [SensoryAssociationArea]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_areas, forKey: SensoryAssociationRegion.key_neurons)
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
                       areaIndex: Int = 0,
                       layerIndex: Int = 0) -> SensoryInterneuron {
        precondition(!isStructureLocked)
        
        createArea(areaIndex)
        let neuron = priv_areas[areaIndex].create(identifier, layerIndex: layerIndex)
        
        return neuron
    }
    
    public subscript(index: Int) -> SensoryAssociationArea {
        return priv_areas[index]
    }
    public func createArea(_ index: Int = 0) -> Void {
        while index >= priv_areas.count {
            precondition(!isStructureLocked)
            
            let id = Identifier(idString: "SensoryAssociationArea_\(index)")
            priv_areas.append(SensoryAssociationArea(environment: self, identifier: id))
        }
    }
    
    public func getOperantNeurons(_ neurons: inout [OperantNeuron]) -> Void {
        for area in priv_areas {
            area.getOperantNeurons(&neurons)
        }
    }
    
    public func activate(_ autoPropogate: Bool) -> Void {
        for area in priv_areas {
            area.activate(autoPropogate)
        }
    }
    
    public func commitActivation() -> Void {
        for area in priv_areas {
            area.commitActivation()
        }
    }
    
    public func learn() -> Void {
        for area in priv_areas {
            area.learn()
        }
    }
    
    public func resetActivation(_ autoPropogate: Bool) -> Void {
        for area in priv_areas {
            area.resetActivation(autoPropogate)
        }
    }
    
    
    // MARK: Learn
    
    public func setConnectionWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try setExcitatoryWeights(newValue)
        try setInhibitoryWeights(newValue)
    }
    public func setExcitatoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        for area in priv_areas {
            try area.setExcitatoryWeights(newValue)
        }
    }
    public func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        for area in priv_areas {
            try area.setInhibitoryWeights(newValue)
        }
    }
    
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: ComputationalNodeBody
    fileprivate var priv_areas = [SensoryAssociationArea]()
    
} // end class SensoryAssociationRegion

