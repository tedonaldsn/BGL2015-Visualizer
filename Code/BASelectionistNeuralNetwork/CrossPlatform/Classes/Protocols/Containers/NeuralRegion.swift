//
//  NeuralRegion.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation



public protocol NeuralRegion: Node {
    
    // Maximum depth and width. Indicators of complexity of the net. Also useful
    // in creating grid for graphic representation.
    //
    var maxLayerDepth: Int { get }
    var maxNodeWidth: Int { get }
    
    
    var areaCount: Int { get }
    var areas: [NeuralArea] { get }

} // end protocol NeuralRegion