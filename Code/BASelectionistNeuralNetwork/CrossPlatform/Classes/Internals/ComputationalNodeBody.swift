//
//  ComputationalNodeBody.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/22/15.
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





public struct ComputationalNodeBody: CustomDebugStringConvertible {
    
    // MARK: Data
    
    public var environment: ComputationalNode { return priv_parent }
    public var network: Network { return priv_parent.network }
    public var logger: Logger
    
    public var hasIdentifier: Bool { return priv_identifier.hasIdentifier }
    public var identifier: Identifier? { return priv_identifier.identifier }
    
    public var activationSettings: ActivationSettings {
        get { return priv_activationSettings != nil
            ? priv_activationSettings!
            : priv_parent.activationSettings
        }
        set { priv_activationSettings = newValue.clone() }
    }
    public var learningSettings: LearningSettings {
        get { return priv_learningSettings != nil
            ? priv_learningSettings!
            : priv_parent.learningSettings
        }
        set { priv_learningSettings = newValue.clone() }
    }
    
    public var debugDescription: String {
        return "\nComputationalNodeBody:\npriv_identifier: \(priv_identifier)\nActivationSettings: \(priv_activationSettings)\nLearningSettings: \(priv_learningSettings)"
    }
    
    
    
    // MARK: Initialization
    
    public init(environment: ComputationalNode, identifier: Identifier? = nil) {
        priv_identifier = IdentifiedImpl(identifier: identifier)
        priv_parent = environment
        logger = environment.logger
    }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_parent = "parent"
    public static var key_activationSettings = "activation"
    public static var key_learningSettings = "learning"
    
    public init?(coder aDecoder: NSCoder) {
        priv_parent = aDecoder.decodeObject(forKey: ComputationalNodeBody.key_parent) as! ComputationalNode
        priv_identifier = IdentifiedImpl(coder: aDecoder)!
        priv_activationSettings =
            aDecoder.decodeObject(forKey: ComputationalNodeBody.key_activationSettings) as! ActivationSettings?
        priv_learningSettings =
            aDecoder.decodeObject(forKey: ComputationalNodeBody.key_learningSettings) as! LearningSettings?
        logger = priv_parent.logger
    }
    
    public func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encodeConditionalObject(priv_parent, forKey: ComputationalNodeBody.key_parent)
        priv_identifier.encodeWithCoder(aCoder)
        aCoder.encode(priv_activationSettings, forKey: ComputationalNodeBody.key_activationSettings)
        aCoder.encode(priv_learningSettings, forKey: ComputationalNodeBody.key_learningSettings)
    }
    
    
    // MARK: *Private*
    fileprivate unowned var priv_parent: ComputationalNode
    fileprivate let priv_identifier: IdentifiedImpl
    
    fileprivate var priv_activationSettings: ActivationSettings? = nil
    fileprivate var priv_learningSettings: LearningSettings? = nil
    
} // end struct ComputationalNodeBody



