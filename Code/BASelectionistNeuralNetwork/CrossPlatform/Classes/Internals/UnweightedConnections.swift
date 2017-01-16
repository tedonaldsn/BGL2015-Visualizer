//
//  UnweightedConnections.swift
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



public struct UnweightedConnections: CustomDebugStringConvertible {
    
    
    // MARK: Data
    
    public var isExcitatory: Bool { return priv_isExcitatory }
    public var isInhibitory: Bool { return !priv_isExcitatory }
    
    public var count: Int { return priv_axons.count }
    public var isEmpty: Bool { return priv_axons.isEmpty }
    
    public var preSynapticAxons: [Axon] { return priv_axons }
    public var preSynapticActivationLevels: [Double] {
        var levels = [Double]()
        for axon in priv_axons {
            levels.append(axon.activationLevel.rawValue)
        }
        return levels
    }
    
    public var activation: Scaled0to1Value {
        var highestLevel = Scaled0to1Value()
        for axon in priv_axons {
            let axonLevel = axon.activationLevel
            if axonLevel > highestLevel {
                highestLevel = axonLevel
            }
        }
        return highestLevel
    }
    
    public var excitation: Scaled0to1Value { return activation }
    
    public var axonsAsNSArray: NSArray {
        get {
            let array = NSMutableArray()
            for axon in priv_axons {
                array.add(axon)
            }
            return array
        }
        set {
            priv_axons = [Axon]()
            for axon in newValue {
                priv_axons.append(axon as! Axon)
            }
        }
    }
    
    // MARK: Debug
    
    public var debugDescription: String {
        var desc = "\nUnweightedConnections (count: \(count)): ["
        
        for ix in 0..<priv_axons.count {
            let activation: Double = priv_axons[ix].activationLevel.rawValue
            if ix > 0 { desc += ", " }
            desc += "(a: \(activation))"
        }
        desc += "]"
        return desc
    }
    
    
    // MARK: Initialization
    
    public init(isExcitatory: Bool) {
        priv_isExcitatory = isExcitatory
    }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_axons = "axons"
    
    // Assumption here is that an object has, at most, two instances of the
    // UnweightedConnections structure, and that one is for excitatory connections
    // and the other is for inhibitory. Because structs do not save an id that is
    // used to qualify dictionary entries in the archive, we fake it using a
    // qualifier that indicates to which of the two sets of connections an
    // archived field belongs.
    //
    public func axonsKey() -> String {
        let qualifier = priv_isExcitatory ? "exc" : "inh"
        return "unweighted_\(WeightedConnections.key_axons)_\(qualifier)"
    }
    
    public init?(coder aDecoder: NSCoder, isExcitatory: Bool) {
        priv_isExcitatory = isExcitatory
        
        let nsarray: NSArray = aDecoder.decodeObject(forKey: axonsKey()) as! NSArray
        axonsAsNSArray = nsarray
    }
    
    public func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(axonsAsNSArray, forKey: axonsKey())
    }
    
    
    // MARK: Access
    
    public func hasPresynapticNeuron(_ targetIdentifier: Identifier) -> Bool {
        return findPresynapticNeuron(targetIdentifier) != nil
    }
    
    public func findPresynapticNeuron(_ targetIdentifier: Identifier) -> Neuron? {
        for axon in priv_axons {
            if let identifier = axon.neuron.identifier {
                if identifier == targetIdentifier {
                    let target = axon.neuron
                    return target
                }
            }
        }
        return nil
    }
    
    
    // MARK: Build
    
    public mutating func append(_ afferent: Axon) -> Void {
        priv_axons.append(afferent)
    }
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_isExcitatory: Bool = true
    
    fileprivate var priv_axons = [Axon]()
    
    
} // end struct UnweightedConnections

