//
//  ConnectionAttributes.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 10/20/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation



// ConnectionAttributes
//
// Tuple describing a "synapse" between a preSynaptic neural group and a 
// postSynaptic neural group. The aggregate activation level of the preSynaptic
// unit is an input to the postSynaptic unit, and is used to affect the 
// current activation of the postSynaptic unit as well as its learning.
//
// Learning: Type of learning process, either Learning.Operant or
// Learning.Respondent. Instances of OperantNeuron will only ever return 
// Operant. Instances of RespondentNeuron may return either, depending upon how
// the connection is handled internal to the neuron.
//
// Stimulation: Indicates whether higher levels of activation of the preSynaptic
// unit will promote (i.e., Stimulation.Excitatory) or suppress 
// (i.e., Stimulation.Inhibitory) activation of the postSynaptic unit.
//
// Index: Location of the "synapse" within the collection appropriate 
// collection of connections within the postSynaptic unit. The appropriate
// connection is defined by the values of the learning and the stimualation
// attributes.
//
// Note that the connection attributes, as such, are not used within the neural
// network. They are provided as a service to clients of the neural network
// library (e.g., to select appropriate graphical representations of a "synapse").
//
public typealias ConnectionAttributes = (
    preSynapticUnit: Neuron?,
    postSynapticUnit: Neuron?,
    
    learning: Learning,
    stimulation: Stimulation,
    
    index: Int

) // end ConnectionAttributes

