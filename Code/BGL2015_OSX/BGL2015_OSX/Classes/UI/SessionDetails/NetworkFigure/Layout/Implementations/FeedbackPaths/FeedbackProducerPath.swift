//
//  FeedbackProducerPath.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/31/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//





import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


// The feedback producer path connects the output of a feedback producing
// hippocampal or dopaminergic neuron to the feedback consumer path that
// distributes it. Or rather, does so for the graphical representations of each.
//
// Unlike Fig 1 in BGL2015, these paths will always wrap up and over the
// neurons in this automatic layout. They will show output coming from 
// 0 radians (due east), turning up the figure, then left over the neuron
// to connect to the consumer path at a known point: directly over the top
// dendrite and even with the top of the neuron symbol.
//
// Note that a feedback layer may have more than one feedback producing 
// neuron. Each gets an independent producer path. This means that the 
// producer path and consumer path may differ in appearance, since in multi-
// neuron feedback layers the total output of the layer is an average of 
// the feedback signals.
//
open class FeedbackProducerPath: FeedbackPathBase {
    
    // MARK: Data
    
    open let producerSymbol: OperantNeuronSymbol
    open var operantNeuron: OperantNeuron {
        return producerSymbol.operantNeuron
    }
    
    open override var presentationStrength: Scaled0to1Value {
        return discrepancySignal
    }
    
    
    open var discrepancySignal: Scaled0to1Value {
        var signal: Double = 0.0
        
        let neuron = operantNeuron
        
        if let hippocampalNeuron = neuron as? HippocampalNeuron {
            signal = hippocampalNeuron.discrepancySignal
        } else {
            let dopaminergicNeuron = neuron as! DopaminergicNeuron
            signal = dopaminergicNeuron.discrepancySignal
        }
        
        if signal < Scaled0to1Value.minimum.rawValue {
            return Scaled0to1Value.minimum
        }
        if signal > Scaled0to1Value.maximum.rawValue {
            return Scaled0to1Value.maximum
        }
        return Scaled0to1Value(rawValue: signal)
    }
    
    
    
    open override var statusSummary: NSAttributedString? {
        let info = NSMutableAttributedString(attributedString: label!.text)
        
        let strength = BaseSymbol.format(scaledValue: presentationStrength)
        info.append(NSAttributedString(string: "\nSignal strength: \(strength)"))
        
        return info
    }
    
    
    // MARK: Initialization
    
    
    public init(feedbackNeuronSymbol: OperantNeuronSymbol,
                appearance: FeedbackPathBase.FeedbackPathAppearance?) {
        
        self.producerSymbol = feedbackNeuronSymbol
        
        let operantNeuron = feedbackNeuronSymbol.operantNeuron
        
        assert(operantNeuron is HippocampalNeuron || operantNeuron is DopaminergicNeuron)
        
        let isSensory = (operantNeuron is HippocampalNeuron)
        let rootLayout = feedbackNeuronSymbol.rootLayout
        
        super.init(rootLayout: rootLayout,
                   isSensory: isSensory,
                   appearance: appearance)
        
        priv_initializePath()
        
        let _ = label!.appendString("d")
        if let producerLabel = producerSymbol.label {
            let _ = label!.appendSubscript(producerLabel.text)
        }
        let _ = label!.appendSubscript(",t")
        
    } // end init
    
    
    
    // MARK: *Private* Methods
    
    
    fileprivate func priv_initializePath() {
        
        // If there are no dendrites, then there is no consumer path to which
        // we can connect, so we will only procede if there are dendrites on
        // the producer symbol. Missing dendrite symbols only means that the
        // figure is incomplete, as during development.
        //
        let dendrites = producerSymbol.dendriteSymbols
        
        guard dendrites.count > 0 else { return }
        
        // Sort the dendrites on the producer symbol by vertical position
        // in the figure. We want the top one in order to establish the
        // x position of the consumer path to which we will connect the
        // producer path.
        //
        // Note that the coordinate system is flipped in the neural network
        // figure view. Thus, the dendrite with the lowest y value is closest
        // to the top of the figure.
        //
        let sortedDendrites = dendrites.sorted(by: {
            (dendrite1: DendriteSymbol, dendrite2: DendriteSymbol) -> Bool in
            return dendrite1.center.y < dendrite2.center.y
        })
        
        let consumerPointOffset: CGFloat = 0.0 // lineStyle.strengthLineWidth.maximum / 3.0
        
        let consumerPoint = CGPoint(x: sortedDendrites.first!.center.x + consumerPointOffset,
                                    y: producerSymbol.frame.origin.y)
        
        let producerPoint = producerSymbol.pointAtOffsetFromPath(0.0,
                                                                 offset: 0.0)
        
        let upTurnPointOffset = producerSymbol.padding / 2.0
        let upTurnPoint = CGPoint(x: producerPoint.x + upTurnPointOffset,
                                  y: producerPoint.y)
        let leftTurnPoint = CGPoint(x: upTurnPoint.x,
                                    y: consumerPoint.y)
        
        path.move(to: producerPoint)
        path.line(to: upTurnPoint)
        path.line(to: leftTurnPoint)
        path.line(to: consumerPoint)
        
        setFrameTo(rect: path.bounds)
        
    } // end priv_initializePath
    
    
    
} // end class FeedbackProducerPath

