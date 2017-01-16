//
//  ActivatableNodeSymbolFactory.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/4/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



final public class ActivatableNodeSymbolFactory {
    
    public static let sharedInstance = ActivatableNodeSymbolFactory()
    
    public typealias Constructor = ActivatableNodeSymbol.Type
    
    
    // MARK: Initialization
    
    
    
    // MARK: Symbol Construction
    
    public func create(rootLayout: NeuralNetworkLayout,
                       forNode: ActivatableNode) -> ActivatableNodeSymbol {
        
        let constructor: Constructor = find(node: forNode)
        
        let symbol =
            constructor.init(rootLayout: rootLayout, node: forNode)
        
        return symbol
        
    } // end create
    
    
    
    // MARK: Metadata Access
    
    
    public func find(node: ActivatableNode) -> Constructor {
        if let constructor = findByIdentifier(node: node) {
            return constructor
        }
        if let constructor = findByClass(node: node) {
            return constructor
        }
        if let constructor = findByProtocol(node: node) {
            return constructor
        }
        return ActivatableNodeSymbol.self
    }
    
    
    
    public func findByIdentifier(node: ActivatableNode) -> Constructor? {
        if let identifier = node.identifier {
            return priv_byIdentifier[identifier]
        }
        return nil
    }
    
    public func findByClass(node: ActivatableNode) -> Constructor? {
        let className: String = "\(node.self)"
        return priv_byClass[className]
    }
    
    
    
    public func findByProtocol(node: ActivatableNode) -> Constructor? {
        
        if node is BinarySensor {
            return BinarySensorSymbol.self
        }
        
        if node is Sensor {
            return SensorSymbol.self
        }
        
        if node is SensoryInputNeuron {
            return SensoryInputNeuronSymbol.self
        }
        
        // For the moment, use a base class instead of a specialized
        // class. Will substitute more appropriate specializations
        // as (if) required.
        //
        if node is SensoryInterneuron {
            return OperantNeuronSymbol.self
        }
        
        if node is HippocampalNeuron {
            return OperantNeuronSymbol.self
        }
        
        if node is MotorInterneuron {
            return OperantNeuronSymbol.self
        }
        
        if node is DopaminergicNeuron {
            return RespondentNeuronSymbol.self
        }
        
        if node is MotorOutputNeuron {
            return MotorOutputNeuronSymbol.self
        }
        
        if node is BinaryEffector {
            return BinaryEffectorSymbol.self
        }
        
        if node is Effector {
            return EffectorSymbol.self
        }
        
        return nil
        
    } // end findByProtocol
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_byIdentifier = [Identifier: Constructor]()
    fileprivate var priv_byClass = [String: Constructor]()
    
    
    // MARK: *Private* Methods
    
    
} // end class ActivatableNodeSymbolFactory


