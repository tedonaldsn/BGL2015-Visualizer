//
//  PresynapticSymbolProtocol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/12/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


public protocol PresynapticSymbolProtocol: RegularShapeSymbolProtocol {
    
    var rootLayout: NeuralNetworkLayout { get }
    var activationLevel: Scaled0to1Value { get }
    
    var axonSymbols: [AxonSymbol] { get }
    
    func connectAxonTo(dendrite: DendriteSymbol) -> Void
    
}
