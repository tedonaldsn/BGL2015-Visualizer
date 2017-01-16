//
//  EffectorRegion.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/4/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import BASimulationFoundation



// EffectorRegion
//
// Transducer region that converts activation levels of the motor output
// region into signals useful outside the neural network. This region consists
// of parallel areas, each area potentially taking input from different areas
// of the motor output region.
//
// Effectors all take activation levels of 0-1 as input. The output is entirely
// the domain of the individual effector types.
//
final public class EffectorRegion: NSObject, NeuralRegion {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    // MARK: NeuralRegion Protocol
    
    public var maxLayerDepth: Int { return 1 }
    public var maxNodeWidth: Int {
        return priv_areas.reduce(0) {
            (total: Int, area: EffectorArea) -> Int in return total + area.maxNodeWidth
        }
    }
    
    public var areaCount: Int { return priv_areas.count }
    public var areas: [NeuralArea] {
        return priv_areas.map() { (area: NeuralArea) -> NeuralArea in return area }
    }
    
    
    // MARK: Initialization
    
    public init(network: Network, identifier: Identifier? = nil) {
        priv_node = NodeBody(network: network, identifier: identifier)
    }
    public convenience init(environment: ComputationalNode, identifier: Identifier? = nil) {
        self.init(network: environment.network, identifier: identifier)
    }
    
    
    
    // MARK: Effecting
    
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
    
    public func resetActivation() -> Void {
        for area in priv_areas {
            area.resetActivation()
        }
    }
    
    
    // MARK: Append
    
    public func append(_ effector: Effector, areaIndex: Int = 0) -> Effector {
        precondition(!isStructureLocked)
        createArea(areaIndex)
        return priv_areas[areaIndex].append(effector)
    }
    
    public func createArea(_ index: Int = 0) -> Void {
        while index >= priv_areas.count {
            precondition(!isStructureLocked)
            
            let id = Identifier(idString: "EffectorArea_\(index)")
            priv_areas.append(EffectorArea(network: network, identifier: id))
        }
    }
    
    // MARK: Access
    
    
    public subscript(index: Int) -> EffectorArea {
        return priv_areas[index]
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_effectors = "effectors"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = NodeBody(coder: aDecoder)!
        priv_areas = aDecoder.decodeObject(forKey: EffectorRegion.key_effectors) as! [EffectorArea]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_areas, forKey: EffectorRegion.key_effectors)
    }
    
    
    
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: NodeBody
    
    fileprivate var priv_areas = [EffectorArea]()
    
    
    
} // end class EffectorRegion


