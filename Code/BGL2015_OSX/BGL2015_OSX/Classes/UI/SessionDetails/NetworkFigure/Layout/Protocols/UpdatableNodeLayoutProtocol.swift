//
//  UpdatableNodeLayoutProtocol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/5/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork




public protocol UpdatableNodeLayoutProtocol: NodeLayoutProtocol {
    
    func isValidNodeForTimestepUpdate(_ nodeState: Node) -> Bool
    func updateForTimestep(_ nodeState: Node) -> Void
    
} // end protocol UpdatableNodeLayoutProtocol




public extension UpdatableNodeLayoutProtocol {
    
    func basicIsValidNodeForTimestepUpdate(_ nodeState: Node) -> Bool {
        guard type(of: node) == type(of: nodeState) else { return false }
        guard node.hasIdentifier == nodeState.hasIdentifier else { return false }
        
        guard node.hasIdentifier else { return true }
        
        return node.identifier == nodeState.identifier
    }
    
} // end extension UpdatableNodeLayoutProtocol


