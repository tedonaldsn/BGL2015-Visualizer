//
//  FeedbackLayer.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/30/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class FeedbackLayer: LayerLayout {
    
    // MARK: Data
    
    open let isSensory: Bool
    open var isMotor: Bool { return !isSensory }
    
    
    public init(rootLayout: NeuralNetworkLayout,
                hippocampus: Hippocampus,
                appearance: BaseLayout.BaseAppearance? = nil) {
        
        self.isSensory = true
        
        super.init(rootLayout: rootLayout, node: hippocampus)
        
    } // end init hippocampus
    
    
    
    public init(rootLayout: NeuralNetworkLayout,
                vta: VentralTegmentalArea,
                appearance: BaseLayout.BaseAppearance? = nil) {
        
        self.isSensory = false
        
        super.init(rootLayout: rootLayout, node: vta)
        
    } // end init hippocampus
    
    
    
    
    open func createFeedbackProducerPaths() -> [FeedbackProducerPath] {
        var paths = [FeedbackProducerPath]()
        
        for layout in layouts {
            if let operantNeuron = layout as? OperantNeuronSymbol {
                let path = FeedbackProducerPath(feedbackNeuronSymbol: operantNeuron,
                                                appearance: nil)
                paths.append(path)
            }
        }
        
        return paths
    }
    
    
    
    
    
    
    // MARK: *Private* Data
    
    

    
        
} // end class FeedbackLayer

