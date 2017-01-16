//
//  NodeInfo.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 4/6/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Foundation
import BASimulationFoundation


// Class NodeInfo
//
// Provides expanded human readable information for nodes in the network.
//
// Most important objects in a BASelectionistNeuralNetwork.Network
// implements the Node protocol. Part of the Node protocol is an optional
// identifier. Only Node's that have identifiers can be found by the
// Network's findNode() method.
//
// Class NodeInfo allows for maintenance of additional information for a node.
// The expectation is that some user interfaces will want to display something
// more than the potentially cryptic identifier and the node's data to users.
//
// Examples in comments below are based on:
//
//      Burgos, José E., García-Leal, Óscar (2015). Autoshaped
//      choice in artificial neural networks: Implications for behavioral
//      economics and neuroeconomics. Behavioural Processes, 114, 63-71
// 
final public class NodeInfo: NSObject, NSCopying, NSCoding {
    
    // The identifier is used as a system key for the node. It is not
    // necessarily pretty, and must follow the rules defined in
    // the BASimulationFoundation.Identifier class.
    //
    // Example: M_Prime_1
    //
    public let identifier: Identifier
    
    // The name is intended to be a very very short human readable string
    // meaningful in the context of the application, experiment, whatever.
    //
    // Example (identifier cannot include punctuation): M'1
    //
    public var name: String = ""
    
    // The title is intended to be somewhat more descriptive than the name,
    // but short enough to include in a key for a graph or table of data.
    //
    // Example: 
    //
    //  Output unit whose activation is intended to simulate a primary-motor
    //  precursor of a response R1.
    //
    public var title: String = ""
    
    // The explanation is a summary description of the node's role in the
    // network, and presumably, why it is important enough to be identified
    // in the first place.
    //
    // Note: Can NOT call this field "description", which has special meaning
    //       within the XCode/OS X/iOS environment.
    //
    public var explanation: String = ""
    
    
    // MARK: Initialization
    
    public init(identifier: Identifier) {
        self.identifier = identifier
    }
    
    public func clone() -> NodeInfo {
        let another = NodeInfo(identifier: self.identifier)
        another.name = self.name
        another.title = self.title
        another.explanation = self.explanation
        return another
    }
    
    // MARK: Hashable Protocol
    //
    public override var hashValue: Int {
        return identifier.hashValue
    }
    
    // Zones are no longer used, but this is a function required by the
    // NSCopying protocol, which is needed for inclusion of NSObject subclasses
    // in a hash table (a.k.a., dictionary). Keys are always copied.
    //
    public func copy(with zone: NSZone?) -> Any {
        return clone()
    }
    
    // Required override of NSObject method. The Hashable protocol will not
    // work correctly without it.
    //
    public override func isEqual(_ object: Any?) -> Bool {
        if let otherNodeInfo = object as? NodeInfo {
            return identifier == otherNodeInfo.identifier
        }
        return false
    }
    
    // MARK: Protocol NSCoding
    //
    public static var key_identifier = "identifier"
    public static var key_name = "name"
    public static var key_title = "title"
    public static var key_explanation = "explanation"
    
    @objc public init?(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObject(forKey: NodeInfo.key_identifier) as! Identifier
        name = aDecoder.decodeObject(forKey: NodeInfo.key_name) as! String
        title = aDecoder.decodeObject(forKey: NodeInfo.key_title) as! String
        explanation = aDecoder.decodeObject(forKey: NodeInfo.key_explanation) as! String
    }
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: NodeInfo.key_identifier)
        aCoder.encode(name, forKey: NodeInfo.key_name)
        aCoder.encode(title, forKey: NodeInfo.key_title)
        aCoder.encode(explanation, forKey: NodeInfo.key_explanation)
    }
    
} // end class NodeInfo




// MARK: Equatable


public func ==(lhs: NodeInfo, rhs: NodeInfo) -> Bool {
    return lhs.isEqual(rhs)
}


