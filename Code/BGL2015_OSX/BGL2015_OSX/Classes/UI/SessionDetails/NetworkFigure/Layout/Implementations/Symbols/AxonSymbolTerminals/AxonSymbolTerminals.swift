//
//  AxonSymbolTerminals.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/17/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Foundation
import BASimulationFoundation



final public class AxonSymbolTerminals {
    
    public static let sharedInstance = AxonSymbolTerminals()
    
    
    // MARK: Initialization
    
    public init() {
    }
    
    
    
    // MARK: Access
    
    public func contains(terminalType: Identifier) -> Bool {
        return priv_terminalConstructors[terminalType] != nil
    }
    
    
    
    // MARK: Create
    
    public func create(terminalType: Identifier,
                       parentAxonSymbol: AxonSymbol,
                       appearance: AxonSymbolTerminalBase.BaseTerminalAppearance?) -> AxonSymbolTerminalProtocol? {
        
        if let ctor = priv_terminalConstructors[terminalType] {
            return ctor.init(parentAxonSymbol: parentAxonSymbol, appearance: appearance)
        }
        
        return nil
    }
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_terminalConstructors: [Identifier: AxonSymbolTerminalProtocol.Type] = [
        
        AxonSymbolTerminalArrow.axonTerminalType() : AxonSymbolTerminalArrow.self,
        AxonSymbolTerminalConcave.axonTerminalType() : AxonSymbolTerminalConcave.self
        
    ]
    
} // end class AxonSymbolTerminals

