//
//  NodeLayoutProtocol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/5/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork




public protocol NodeLayoutProtocol: AnyObject {
    
    var node: BASelectionistNeuralNetwork.Node { get }
    
} // end protocol NodeLayoutProtocol




public extension NodeLayoutProtocol {
    
    var hasNodeIdentifier: Bool {
        return node.hasIdentifier
    }
    
    var nodeIdentifier: Identifier? {
        return node.identifier
    }
    
} // end extension NodeLayoutProtocol


