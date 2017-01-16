//
//  LearningDendriteSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/12/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


// Class LearningDendriteSymbol
//
// The receiving end of a connection between a presynaptic unit and a
// postsynaptic unit that "learns". Note that the dendrite does not learn;
// rather, its display "strength" is affected by the efficacy/weight of the
// connection it represents.
//
open class LearningDendriteSymbol: DendriteSymbol {
    
    
    open class LearningDendriteAppearance: DendriteSymbol.DendriteAppearance {
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        return LearningDendriteAppearance(
            shapeType: defaultShape(),
            fillColor: StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                     colorAtStrongest: NSColor.white.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.lightGray.cgColor,
                                         colorAtStrongest: NSColor.black.cgColor,
                                         widthAtWeakest: 1.0,
                                         widthAtStrongest: 5.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: defaultPadding(),
            label: nil
        )
    }
    
    
    
    // MARK: Data
    
    
    open var neuronSymbol: NeuronSymbol {
        return parentSymbol as! NeuronSymbol
    }
    
    
    // MARK: Connection Attributes
    
    open let stimulation: Stimulation
    
    open var isExcitatoryConnection: Bool {
        return stimulation == Stimulation.Excitatory
    }
    open var isInhibitoryConnection: Bool {
        return stimulation == Stimulation.Inhibitory
    }
    
    
    open let learning: Learning
    
    open var isOperantConnection: Bool {
        return learning == Learning.Operant
    }
    open var isRespondentConnection: Bool {
        return learning == Learning.Respondent
    }
    
    open let connectionIndex: Int
    
    
    
    // MARK: Connection Efficacy
    
    // Efficacy is represented as weight of the connection scaled from 0 - 1
    //
    open var connectionWeight: Scaled0to1Value {
        if isOperantConnection {
            let neuron = neuronSymbol.neuron as! OperantNeuron
            let weight = neuron.operantConnectionWeightAt(stimulation, index: connectionIndex)
            return Scaled0to1Value(rawValue: weight)
        }
        let neuron = neuronSymbol.neuron as! RespondentNeuron
        let weight = neuron.respondentConnectionWeightAt(stimulation, index: connectionIndex)
        return Scaled0to1Value(rawValue: weight)
    }
    
    
    open var connectionWeightString: String {
        return BaseSymbol.format(scaledValue: connectionWeight)
    }
    
    // Strength of the graphical representation for a receptor is the current
    // efficacy of the connection between the presynaptic unit and the neuron
    // of which the receptor is a part.
    //
    open override var presentationStrength: Scaled0to1Value {
        return connectionWeight
    }
    
    
    
    
    open override var statusSummary: NSAttributedString? {
        let info = NSMutableAttributedString(attributedString: super.statusSummary!)
        let learningtype = isOperantConnection ? "operant" : "respondent"
        let stimtype = isExcitatoryConnection ? "excitatory" : "inhibitory"
        info.append(NSAttributedString(string: "\nLearning: \(learningtype)"))
        info.append(NSAttributedString(string: "\nStimulation: \(stimtype)"))
        info.append(NSAttributedString(string: "\nConnection weight: \(connectionWeightString)"))
        
        return info
    }
    
    
    // MARK: Initialization
    
    public init(parentNeuronSymbol: NeuronSymbol,
                connectionAttributes: ConnectionAttributes,
                appearance: BaseLayout.BaseAppearance? = nil) {
        
        self.stimulation = connectionAttributes.stimulation
        self.learning = connectionAttributes.learning
        self.connectionIndex = connectionAttributes.index
        
        assert(parentNeuronSymbol.neuron === connectionAttributes.postSynapticUnit)
        assert(connectionAttributes.preSynapticUnit != nil)
        
        let presynapticUnit = connectionAttributes.preSynapticUnit!
        let presynapticSymbol = parentNeuronSymbol.updatableNodeLayouts.find(presynapticUnit)
        
        assert(presynapticSymbol != nil)
        assert(presynapticSymbol is NeuronSymbol)
        
        let myAppearance = appearance != nil
            ? appearance!
            : LearningDendriteSymbol.defaultAppearance()
        
        super.init(parentSymbol: parentNeuronSymbol,
                   presynapticSymbol: presynapticSymbol as! PresynapticSymbolProtocol,
                   appearance: myAppearance)
        
    } // end init
    
    
    
} // end class LearningDendriteSymbol

