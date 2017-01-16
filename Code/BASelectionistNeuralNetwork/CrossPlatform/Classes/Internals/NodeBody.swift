//
//  NodeBody.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/1/15.
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




public struct NodeBody: CustomDebugStringConvertible {
    
    // MARK: Data
    
    public var network: Network { return priv_network }
    public var hasIdentifier: Bool { return priv_identifier.hasIdentifier }
    public var identifier: Identifier? { return priv_identifier.identifier }
    public var logger: Logger
    
    public var debugDescription: String {
        let desc = "\nNodeBody: priv_identifier: \(priv_identifier)"
        return desc
    }

    
    // MARK: Initialization
    
    public init(network: Network, identifier: Identifier? = nil) {
        priv_network = network
        priv_identifier = IdentifiedImpl(identifier: identifier)
        logger = priv_network.logger
    }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_network = "neuralNet"
    
    public init?(coder aDecoder: NSCoder) {
        priv_identifier = IdentifiedImpl(coder: aDecoder)!
        priv_network = aDecoder.decodeObject(forKey: NodeBody.key_network) as! Network
        logger = priv_network.logger
    }
    
    public func encodeWithCoder(_ aCoder: NSCoder) {
        priv_identifier.encodeWithCoder(aCoder)
        aCoder.encode(priv_network, forKey: NodeBody.key_network)
    }
    
    
    // MARK: *Private*
    
    fileprivate let priv_identifier: IdentifiedImpl
    fileprivate unowned var priv_network: Network
    
} // end struct NodeBody
