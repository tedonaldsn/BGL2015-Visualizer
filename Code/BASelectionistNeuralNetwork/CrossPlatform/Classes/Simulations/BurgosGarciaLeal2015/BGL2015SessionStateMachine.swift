//
//  BGL2015SessionStateMachine.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 11/30/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation
import BASimulationStateMachine




final public class BGL2015SessionStateMachine {
    
    public static let defaultSourceFileName = "BGL2015SessionStateMachine.xml"
    
    public var hasStateChart: Bool {
        return stateChart != nil && stateChart.isStructureFinalized
    }
    public var stateChart: StateMachine!
    
    
    public func load(resourceDir: String,
        fileName: String? = nil,
        logger: Logger,
        configuration: XmlParserConfiguration?) throws {
            
            let sourceFile = fileName != nil
                ? fileName!
                : BGL2015SessionStateMachine.defaultSourceFileName
            
            let filePath = "\(resourceDir)/\(sourceFile)"
            
            stateChart = try StateMachine.stateMachineFromXmlFile(filePath,
                                                                  logger: logger,
                                                                  configuration: configuration)
            
            try stateChart.finalizeStructure()

    } // end load
    
} // end class BGL2015StateMachine
