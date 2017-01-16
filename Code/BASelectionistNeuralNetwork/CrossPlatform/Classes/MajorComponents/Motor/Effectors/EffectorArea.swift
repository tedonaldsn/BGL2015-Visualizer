//
//  EffectorArea.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/4/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Foundation
import BASimulationFoundation


final public class EffectorArea: NSObject, NeuralSingleLayerArea {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    // MARK: NeuralArea Protocol
    
    public var maxLayerDepth: Int { return 1 }
    public var maxNodeWidth: Int { return priv_effectors.count }
    
    
    // MARK: NeuralLayer Protocol
    
    public var nodeCount: Int { return priv_effectors.count }
    public var nodes: [ActivatableNode] {
        return priv_effectors.map() { (effector: Effector) -> ActivatableNode in return effector }
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
        for effector in priv_effectors {
            effector.prepareActivation()
        }
    }
    
    public func commitActivation() -> Void {
        for effector in priv_effectors {
            effector.commitActivation()
        }
    }
    
    public func resetActivation() -> Void {
        for effector in priv_effectors {
            effector.resetActivation()
        }
    }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_effectors = "effectors"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = NodeBody(coder: aDecoder)!
        let objArray: NSArray = aDecoder.decodeObject(forKey: EffectorArea.key_effectors) as! NSArray
        for neuron in objArray {
            priv_effectors.append(neuron as! Effector)
        }
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        let objArray: NSMutableArray = NSMutableArray()
        for effector in priv_effectors {
            objArray.add(effector)
        }
        aCoder.encode(objArray, forKey: EffectorArea.key_effectors)
    }
    
    
    // MARK: Append
    
    public func append(_ effector: Effector) -> Effector {
        precondition(!isStructureLocked)
        precondition(!network.isRegisteredNode(effector))
        if effector.hasIdentifier {
            network.registerNode(effector)
        }
        priv_effectors.append(effector)
        return effector
    }
    
    
    
    // MARK: Access
    
    
    public subscript(index: Int) -> Effector {
        return priv_effectors[index]
    }
    
    
    
    
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: NodeBody
    
    fileprivate var priv_effectors = [Effector]()
    
} // end class EffectorArea

