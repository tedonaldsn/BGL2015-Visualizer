//
//  UpdatableNodeLayoutRegistry.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/7/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


// Registry of all layout wrappers for all nodes.
//
// The registry is initialized during configuration of the neural network 
// view. 
//
// The node referenced by a wrapper can change with each time step, but all
// node instances referenced by a wrapper are logically the same objects
// with different state appropriate to different simulation time steps.
//
// The find() and contains() methods are not valid during a time step update
// when symbols are being given new versions of their nodes.
//
final public class UpdatableNodeLayoutRegistry {
    
    public init() {}
    
    public func append(_ nodeWrapper: UpdatableNodeLayoutProtocol) {
        assert(!contains(nodeWrapper.node))
        priv_nodeWrappers.append(nodeWrapper)
    }
    
    
    public func contains(_ forNode: Node) -> Bool {
        return find(forNode) != nil
    }
    public func find(_ forNode: Node) -> UpdatableNodeLayoutProtocol? {
        for nodeWrapper in priv_nodeWrappers {
            if nodeWrapper.node === forNode {
                return nodeWrapper
            }
        }
        return nil
    }
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_nodeWrappers = [UpdatableNodeLayoutProtocol]()
    
} // end class UpdatableNodeLayoutRegistry

