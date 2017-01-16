//
//  Network.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 8/13/15.
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


final public class Network: NSObject, ComputationalNode, FindIdentifiedNode, NSCoding {
    
    
    // MARK: Node
    
    public var hasIdentifier: Bool { return priv_identifier == nil }
    public var identifier: Identifier? { return priv_identifier }
    public var environment: ComputationalNode { return self }
    public var network: Network { return self }
    public var logger: Logger {
        get { return priv_logger! }
        set { priv_logger = newValue }
    }
    
    // MARK: ComputationalNode Protocol
    
    public var activationSettings = ActivationSettings()
    public var learningSettings = LearningSettings()
    
    
    
    // MARK: NodeContainer Protocol
    
    // Note that the feedback areas are NOT included in the max depth and width.
    //
    public var maxLayerDepth: Int {
        let totalDepth = regions.reduce(0) {
            (currentDepth: Int, brainRegion: NeuralRegion) -> Int in
            let regionDepth = brainRegion.maxLayerDepth
            return regionDepth + currentDepth
        }
        return totalDepth
    }
    public var maxNodeWidth: Int {
        let width = regions.reduce(0) {
            (currentWidth: Int, brainRegion: NeuralRegion) -> Int in
            let regionWidth = brainRegion.maxNodeWidth
            return regionWidth > currentWidth ? regionWidth : currentWidth
        }
        return width
    }
    
    public var regionCount: Int { return regions.count }
    public var regions: [NeuralRegion] {
        return [sensorRegion,
                sensoryInputRegion, sensoryAssociationRegion,
                motorAssociationRegion, motorOutputRegion,
                effectorRegion]
    }
    
    public var feedbackAreas: [NeuralLayer] {
        return [hippocampus, vta]
    }
    
    public var maxFeedbackLayerDepth: Int {
        // Feedback areas are single layer each. If "stacked", that's two
        return feedbackAreas.count
    }
    
    public var maxFeedbackNodeWidth: Int {
        let width = max(hippocampus.nodeCount, vta.nodeCount)
        return width
    }
    
    
    // MARK: Network Specific Data
    
    
    public var isLearningEnabled: Bool = true {
        willSet { precondition(!isUpdating) }
    }
    
    // Structure of the network is not permitted to change during update,
    // or if an updater is installed. The updater may cache info for efficiency,
    // and structural changes would invalidate results (or crash the updater).
    //
    public var isStructureLocked: Bool { return hasUpdater || isUpdating }
    
    // If an updater object is supplied, it will be used for the actions
    // defined by the Network protocol. If no updater is provided, a default
    // update will be done (in-order activation, then in-order propogation,
    // then in-order learn).
    //
    public var isUpdating: Bool { return priv_isUpdating }
    
    // Want to compare results with a plugin updater versus the built-in
    // one without resorting to installing and deinstalling the updater?
    //
    // Set isUpdaterOnline to false to temporarily turn off the plugin updater.
    // Set to true to re-enable the plugin.
    //
    public var isUpdaterOnline: Bool {
        get { return hasUpdater && priv_isUpdaterOnline }
        set {
            precondition(!isUpdating)
            if hasUpdater {
                priv_isUpdaterOnline = newValue
            }
        }
    }
    
    public var hasUpdater: Bool { return priv_updater != nil }
    
    // Setting an updater automatically sets isUpdaterOnline
    //
    public var updater: NetworkUpdater? {
        get { return isUpdaterOnline ? priv_updater : nil }
        set {
            precondition(!isUpdating)
            priv_updater = newValue
            priv_updater?.network = self
            priv_isUpdaterOnline = priv_updater != nil
        }
    }
    
    // "Diffuse discrepancy signals" used throughout the network to compute
    // activation levels. The signals are themselves computed during the learn()
    // method. The signals are "latched" just before exit of learn() to provide
    // stable signals from exit of learn() to the exit of the next learn() invocation.
    //
    public var dopaminergicSignal: Double { return priv_latchedDopaminergicSignal }
    public var hippocampalSignal: Double { return priv_latchedHippocampalSignal }
    
    // Major components of the network.
    //
    public var sensorRegion: SensorRegion { return priv_sensors }
    
    public var hippocampus: Hippocampus { return priv_hippocampus }
    public var sensoryInputRegion : SensoryInputRegion { return priv_sensoryInput }
    public var sensoryAssociationRegion: SensoryAssociationRegion { return priv_sensoryAssociation }
    
    public var vta: VentralTegmentalArea { return priv_vta }
    public var motorAssociationRegion: MotorAssociationRegion { return priv_motorAssociation }
    public var motorOutputRegion: MotorOutputRegion { return priv_motorOutput }
    
    public var effectorRegion: EffectorRegion { return priv_effectors }
    
    
    
    // MARK: Initialization
    
    public init(identifier: Identifier? = nil, logger: Logger? = nil) {
        self.priv_identifier = identifier
        priv_logger = logger ?? Logger()
        
        super.init()
        
        priv_hippocampus
            = Hippocampus(environment: self,
                          identifier: Identifier(idString: "Hippocampus"))
        
        priv_sensors
            = SensorRegion(network: self,
                           identifier: Identifier(idString: "SensorRegion"))
        
        priv_sensoryInput
            = SensoryInputRegion(environment: self,
                                 identifier: Identifier(idString: "SensoryInputRegion"))
        priv_sensoryAssociation
            = SensoryAssociationRegion(environment: self,
                                       identifier: Identifier(idString: "SensoryAssociationRegion"))
        
        priv_motorAssociation
            = MotorAssociationRegion(environment: self,
                                     identifier: Identifier(idString: "MotorAssociationRegion"))
        priv_motorOutput
            = MotorOutputRegion(environment: self,
                                identifier: Identifier(idString: "MotorOutputRegion"))
        priv_vta
            = VentralTegmentalArea(environment: self,
                                   identifier: Identifier(idString: "VentralTegmentalArea"))
        
        priv_effectors
            = EffectorRegion(network: self,
                             identifier: Identifier(idString: "EffectorRegion"))
    }
    
    
    // MARK: FindIdentifiedNode
    
    public func registerNode(_ node: Node) -> Void {
        precondition(!isStructureLocked)
        precondition(node.hasIdentifier)
        precondition(!isRegisteredNode(node))
        priv_namedNodes[node.identifier!] = node
    }
    
    public func findNode(_ identifier: Identifier?) -> Node? {
        if let identifier = identifier {
            return priv_namedNodes[identifier]
        }
        return nil
    }
    
    public func unregisterNode(_ identifier: Identifier) -> Void {
        // clearInfoForNode(identifier)
        priv_namedNodes[identifier] = nil
    }

    public func registeredNodeIdentifiers() -> LazyMapCollection<Dictionary<Identifier,Node>,Identifier> {
        return priv_namedNodes.keys
    }
    public func registeredNodes() -> LazyMapCollection<Dictionary<Identifier,Node>,Node> {
        return priv_namedNodes.values
    }
    
    
    
    // MARK: Append Sensors
    //
    // Unlike neurons, of which we support a limited variety, an unlimited
    // variety of sensors will be permitted. For that reason the network
    // does not provide "creators", but rather a means of appending sensors
    // that you provide.
    //
    public func appendSensor(_ sensor: Sensor, areaIndex: Int = 0) -> Sensor {
        precondition(!isStructureLocked)
        return priv_sensors.append(sensor, areaIndex: areaIndex)
    }
    
    
    
    // MARK: Create Neurons
    //
    // The versions that take a string id are mostly for convenience when hand
    // coding networks, as in XCTest cases.
    //
    // TO BE DONE: when the need arises, also permit append()
    //
    public func createSensoryInputNeuron(_ idString: String,
                                         areaIndex: Int = 0) -> SensoryInputNeuron {
        precondition(!isStructureLocked)
        let identifier = Identifier(idString: idString)
        return createSensoryInputNeuron(identifier, areaIndex: areaIndex)
    }
    public func createSensoryInputNeuron(_ identifier: Identifier? = nil,
                                         areaIndex: Int = 0) -> SensoryInputNeuron {
        precondition(!isStructureLocked)
        return priv_sensoryInput.create(identifier, areaIndex: areaIndex)
    }
    
    
    
    public func createRespondentSensoryInputNeuron(_ idString: String,
                                                  areaIndex: Int = 0) -> SensoryInputNeuron {
        precondition(!isStructureLocked)
        let identifier = Identifier(idString: idString)
        return createRespondentSensoryInputNeuron(identifier, areaIndex: areaIndex)
    }
    public func createRespondentSensoryInputNeuron(_ identifier: Identifier? = nil,
                                                  areaIndex: Int = 0) -> SensoryInputNeuron {
        precondition(!isStructureLocked)
        return priv_sensoryInput.createRespondent(identifier, areaIndex: areaIndex)
    }
    
    
    
    // Creates sensory interneuron. If specified containers do not exist,
    // also creates them with default identifiers.
    //
    // If interneuron identifier is empty, creates the interneuron
    // unconditionally. But if a non-empty identifier is specified and
    // an interneuron already exists with the given non-empty identifier
    // in the specified containers, throws an exception.
    //
    // If necessary, additional containers are created to fill a container
    // array with containers between the beginning of the array and the
    // specified index.
    //
    // TO BE DONE: when the need arises, also permit append()
    //
    public func createSensoryInterneuron(_ idString: String,
                                         areaIndex: Int = 0,
                                         layerIndex: Int = 0) -> SensoryInterneuron {
        precondition(!isStructureLocked)
        let identifier = Identifier(idString: idString)
        return createSensoryInterneuron(identifier, areaIndex: areaIndex, layerIndex: layerIndex)
    }
    
    public func createSensoryInterneuron(_ identifier: Identifier? = nil,
                                         areaIndex: Int = 0,
                                         layerIndex: Int = 0) -> SensoryInterneuron {
        precondition(!isStructureLocked)
        
        let neuron = priv_sensoryAssociation.create(identifier,
                                                    areaIndex: areaIndex,
                                                    layerIndex: layerIndex)
        
        return neuron
    }
    
    
    
    
    public func createMotorInterneuron(_ idString: String,
                                       areaIndex: Int = 0,
                                       layerIndex: Int = 0) -> MotorInterneuron {
        precondition(!isStructureLocked)
        let identifier = Identifier(idString: idString)
        return createMotorInterneuron(identifier, areaIndex: areaIndex, layerIndex: layerIndex)
    }
    
    public func createMotorInterneuron(_ identifier: Identifier? = nil,
                                       areaIndex: Int = 0,
                                       layerIndex: Int = 0) -> MotorInterneuron {
        precondition(!isStructureLocked)
        
        let neuron = priv_motorAssociation.create(identifier,
                                                  areaIndex: areaIndex,
                                                  layerIndex: layerIndex)
        
        return neuron
    }
    
    
    
    
    public func createMotorOutputNeuron(_ idString: String,
                                        areaIndex: Int = 0,
                                        layerIndex: Int = 0) -> MotorOutputNeuron {
        precondition(!isStructureLocked)
        let identifier = Identifier(idString: idString)
        return createMotorOutputNeuron(identifier, areaIndex: areaIndex, layerIndex: layerIndex)
    }
    
    public func createMotorOutputNeuron(_ identifier: Identifier? = nil,
                                        areaIndex: Int = 0,
                                        layerIndex: Int = 0) -> MotorOutputNeuron {
        precondition(!isStructureLocked)
        
        let neuron = priv_motorOutput.create(identifier,
                                             areaIndex: areaIndex)
        
        return neuron
    }
    
    
    
    
    public func createDopaminergicNeuron(_ idString: String, areaIndex: Int = 0) -> DopaminergicNeuron {
        precondition(!isStructureLocked)
        let identifier = Identifier(idString: idString)
        return createDopaminergicNeuron(identifier)
    }
    
    public func createDopaminergicNeuron(_ identifier: Identifier? = nil) -> DopaminergicNeuron {
        precondition(!isStructureLocked)
        let neuron = priv_vta.create(identifier)
        return neuron
    }
    
    
    
    
    public func createHippocampalNeuron(_ idString: String, areaIndex: Int = 0) -> HippocampalNeuron {
        precondition(!isStructureLocked)
        let identifier = Identifier(idString: idString)
        return createHippocampalNeuron(identifier)
    }
    
    public func createHippocampalNeuron(_ identifier: Identifier? = nil) -> HippocampalNeuron {
        precondition(!isStructureLocked)
        let neuron = priv_hippocampus.create(identifier)
        return neuron
    }
    
    
    
    
    // MARK: Append Effectors
    //
    // Unlike neurons, of which we support a limited variety, an unlimited
    // variety of effectors will be permitted. For that reason the network
    // does not provide "creators", but rather a means of appending effectors
    // that you provide.
    //
    public func appendEffector(_ effector: Effector, areaIndex: Int = 0) -> Effector {
        precondition(!isStructureLocked)
        return priv_effectors.append(effector, areaIndex: areaIndex)
    }
    
    
    // MARK: Update
    
    
    
    // interTrialInterval()
    //
    // Simulates an intertrial interval long enough to reduce activation levels
    // to the default value as generated by the logistic function when passed
    // a value of 0.0.
    //
    // Always resets the discrepancy units (hippocampus and vta) with immediate
    // propogation.
    //
    // If hasUpdater, will call updater.operantNeuronIntertrialInterval()
    //
    // If !hasUpdater, will do a simple reset of operant neuron activations
    // with immediate propogation.
    //
    // DO NOT CALL THIS METHOD FROM AN UPDATER
    //
    public func interTrialInterval() -> Void {
        precondition(!isUpdating)
        
        priv_isUpdating = true
        
        // Always:
        //
        priv_discrepancyUnitsResetActivation()
        
        sensorsResetActivation(true)
        operantNeuronsResetActivation(true)
        effectorsResetActivation(true)
        
        priv_isUpdating = false
        
        precondition(!isUpdating)
        
    } // end interTrialInterval
    
    
    
    // update()
    //
    // Requests then propogates sensor inputs.
    //
    // Updates discrepancy units (vta and hippocampus) and propogates
    // the new signals.
    //
    // Updates "operant neurons" using either the default built-in process,
    // or if there is an updater delegate, using the updater. The neurons
    // that are update are those in the sensory associative region, the
    // motor associative region, and the motor output region.
    //
    // The default update process is a two-stage "simultaneious" activation
    // followed by learning. The two stages of activation are (a) the actual
    // activation of ALL neurons with NO propogation of the activation output,
    // then (b) propogation. This causes all recomputed activation levels from
    // preSynaptic units to show up at all postSynaptic units simultaneously.
    // It is one way to remove order bias from the computation.
    //
    // The original Donahoe, Palmer, Burgos algorithm uses continuous immediate
    // propogation as activations are recomputed neuron by neuron. This means
    // that the computation of activations of neurons earlier in the process
    // will affect activation levels of neurons later in the process. That
    // algorithm overcomes order bias by randomizing the neuron order on each
    // update. See network updater RandomizedContinuousPropogationUpdater.
    //
    // DO NOT CALL THIS METHOD FROM AN UPDATER
    //
    public func update() -> Void {
        precondition(!isUpdating)
        
        priv_isUpdating = true
        
        priv_update()
        
        priv_isUpdating = false
        
        precondition(!isUpdating)
        
    }
    
    public func getOperantNeurons(_ neurons: inout [OperantNeuron]) -> Void {
        priv_sensoryAssociation.getOperantNeurons(&neurons)
        priv_motorAssociation.getOperantNeurons(&neurons)
        priv_motorOutput.getOperantNeurons(&neurons)
        
        // -----
        // Do not include discrepancy signal producing areas. They are handled
        // specially at the beginning of activations.
        //
        // priv_hippocampus.getOperantNeurons(&neurons)
        // neurons.append(priv_dopaminergicUnit)
        // -----
    }
    
    
    
    // MARK: Activation
    
    
    
    // operantNeuronsActivate()
    //
    // Recomputes the activation levels of "learning" neurons. If the
    // autoPropogate argument is true the new activation levels are immediately
    // made available to postSynaptic neurons. If false, propogation may be
    // performed using operantNeuronPropogateActivation() or your own updater
    // method by the same name.
    //
    // Typically used with a false autoPropogate argument as part of a two stage
    // activation in which activation levels are computed for all neurons in the
    // first stage. Then in the second stage the new levels are "published".
    //
    public func operantNeuronsActivate(_ autoPropogate: Bool) -> Void {
        precondition(isUpdating)
        priv_sensoryAssociation.activate(autoPropogate)
        priv_motorAssociation.activate(autoPropogate)
        priv_motorOutput.activate(autoPropogate)
    }
    
    // operantNeuronPropogateActivation
    //
    // Copies the activation level of neurons from internal cache to the axon
    // of the neuron, at which point postSynaptic neurons can see the new value.
    //
    // Typically used as part of a two stage activation in which activation levels
    // are computed for all neurons in the first stage. Then in the second stage
    // the new levels are "published".
    //
    public func operantNeuronPropogateActivation() -> Void {
        precondition(isUpdating)
        priv_sensoryAssociation.commitActivation()
        priv_motorAssociation.commitActivation()
        priv_motorOutput.commitActivation()
    }
    
    
    
    // MARK: Learning
    
    
    // operantNeuronsLearn()
    //
    // Recomputes connection weights for operant neurons (i.e., those that
    // can learn operantly via discrepancy signals).
    //
    // Note that unlike activation levels, connection weights are not visible
    // to other neurons. Thus there is no concern with order effects in updating
    // connection weights.
    //
    public func operantNeuronsLearn() -> Void {
        precondition(isUpdating)
        priv_sensoryAssociation.learn()
        priv_motorAssociation.learn()
        priv_motorOutput.learn()
    }

    
    
    // operantNeuronsResetActivation()
    //
    // Resets activation of sensory associative, motor associative, and motor
    // output neurons. Activations are set to logisticSimoid(0.0) and immediately
    // propogated.
    //
    // Processing is in order of sensory motor associative, to motor output.
    //
    // Deactivation is generally used to fake an intertrial interval, or some other
    // quiesent period in which activations would decrease to logisticSimoid(0.0).
    // This is done in lieu of actually running enough time steps without reinforcers
    // to permit "natural" deactivation.
    //
    public func operantNeuronsResetActivation(_ autoPropogate: Bool) -> Void {
        precondition(isUpdating)
        priv_sensoryInput.resetActivation(autoPropogate)
        priv_sensoryAssociation.resetActivation(autoPropogate)
        priv_motorAssociation.resetActivation(autoPropogate)
        priv_motorOutput.resetActivation(autoPropogate)
    }
    
    
    
    public func sensorsResetActivation(_ autoPropogate: Bool) -> Void {
        precondition(isUpdating)
        priv_sensors.resetActivation()
        if autoPropogate {
            priv_sensors.commitActivation()
        }
    }
    
    public func effectorsResetActivation(_ autoPropogate: Bool) -> Void {
        precondition(isUpdating)
        priv_effectors.resetActivation()
        if autoPropogate {
            priv_effectors.commitActivation()
        }
    }
    
    
    
    
    public func setConnectionWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try setExcitatoryWeights(newValue)
        try setInhibitoryWeights(newValue)
    }
    public func setExcitatoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_sensoryAssociation.setExcitatoryWeights(newValue)
        try priv_motorAssociation.setExcitatoryWeights(newValue)
        try priv_motorOutput.setExcitatoryWeights(newValue)
        try priv_hippocampus.setExcitatoryWeights(newValue)
        try priv_vta.setExcitatoryWeights(newValue)
    }
    public func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_sensoryAssociation.setInhibitoryWeights(newValue)
        try priv_motorAssociation.setInhibitoryWeights(newValue)
        try priv_motorOutput.setInhibitoryWeights(newValue)
        try priv_hippocampus.setInhibitoryWeights(newValue)
        try priv_vta.setInhibitoryWeights(newValue)
    }
    
    
    
    
    
    
    // MARK: Testing/Debugging
    
    public func isForwardConnectionFrom(_ preSynapticNeuron: Identifier,
                                        toPostSynapticNeuron: Identifier) -> Bool {
        
        return isBackConnectionFrom(toPostSynapticNeuron,
                                    toPresynapticNeuron: preSynapticNeuron)
    }
    
    public func isBackConnectionFrom(_ postSynapticNeuron: Identifier,
                                     toPresynapticNeuron: Identifier) -> Bool {
        
        var hasConnection = false
        if let neuron = findNeuron(postSynapticNeuron) {
            hasConnection = neuron.containsPresynapticConnection(toPresynapticNeuron)
        }
        return hasConnection
    }
    
    
    // Set dopaminergic signal for testing purposes. Once forced, changes in the
    // output of the dopaminergic unit are ignored and the forced value used
    // instead. The unforce call will cause the dopaminergic units output to be
    // used again.
    //
    public func isDopaminergicSignalForced() -> Bool {
        return priv_isDopaminergicSignalForced
    }
    public func forceDopaminergicSignal(_ signalLevel: Double) -> Void {
        priv_latchedDopaminergicSignal = signalLevel
        priv_isDopaminergicSignalForced = true
    }
    public func unforceDopaminergicSignal() -> Void {
        priv_isDopaminergicSignalForced = false
    }
    
    // Set hippocampal signal for testing purposes, until unforce is called.
    //
    public func isHippocampalSignalForced() -> Bool {
        return priv_isHippocampalSignalForced
    }
    public func forceHippocampalSignal(_ signalLevel: Double) -> Void {
        priv_latchedHippocampalSignal = signalLevel
        priv_isHippocampalSignalForced = true
    }
    public func unforceHippocampalSignal() -> Void {
        priv_isHippocampalSignalForced = false
    }
    
    
    
    public func createOperantTestInputNeuron(_ identifier: Identifier? = nil,
                                             areaIndex: Int = 0) -> OperantTestInput {
        precondition(!isStructureLocked)
        return priv_sensoryInput.createOperantTestInputNeuron(identifier, areaIndex: areaIndex)
    }
    
    public func createRespondentTestInputNeuron(_ identifier: Identifier? = nil,
                                               areaIndex: Int = 0) -> RespondentTestInput {
        precondition(!isStructureLocked)
        return priv_sensoryInput.createRespondentTestInputNeuron(identifier, areaIndex: areaIndex)
    }
    
    
    
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_identifier = "identifier"
    public static var key_logger = "logger"
    
    public static var key_isDopaminergicSignalForced = "isDopaSignalForced"
    public static var key_latchedDopaminergicSignal = "latchedDopaSignal"
    
    public static var key_isHippocampalSignalForced = "isHippoSignalForced"
    public static var key_latchedHippocampalSignal = "latchedHippoSignal"
    
    public static var key_sensors = "sensors"
    
    public static var key_hippocampus = "hippocampus"
    public static var key_sensoryInput = "sensoryInput"
    public static var key_sensoryAssociation = "sensoryAssociation"
    
    public static var key_motorAssociation = "motorAssociation"
    public static var key_motorOutput = "motorOutput"
    public static var key_ventralTegmentalArea = "vta"
    
    public static var key_effectors = "effectors"
    
    public static var key_namedNodes_names = "namedNodes_names"
    public static var key_namedNodes_nodes = "namedNodes_nodes"
    
    public static var key_infoForNamedNodes_names = "infoForNamedNodes_names"
    
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init()
        
        priv_identifier = aDecoder.decodeObject(forKey: Network.key_identifier) as? Identifier
        priv_logger = (aDecoder.decodeObject(forKey: Network.key_logger) as? Logger)!
        
        priv_isDopaminergicSignalForced =
            aDecoder.decodeBool(forKey: Network.key_isDopaminergicSignalForced)
        priv_latchedDopaminergicSignal =
            aDecoder.decodeDouble(forKey: Network.key_latchedDopaminergicSignal)
        
        priv_isHippocampalSignalForced =
            aDecoder.decodeBool(forKey: Network.key_isHippocampalSignalForced)
        priv_latchedHippocampalSignal =
            aDecoder.decodeDouble(forKey: Network.key_latchedHippocampalSignal)
        
        priv_sensors =
            aDecoder.decodeObject(forKey: Network.key_sensors) as! SensorRegion
        
        priv_hippocampus =
            aDecoder.decodeObject(forKey: Network.key_hippocampus) as! Hippocampus
        priv_sensoryInput =
            aDecoder.decodeObject(forKey: Network.key_sensoryInput) as! SensoryInputRegion
        priv_sensoryAssociation =
            aDecoder.decodeObject(forKey: Network.key_sensoryAssociation) as! SensoryAssociationRegion
        
        priv_motorAssociation =
            aDecoder.decodeObject(forKey: Network.key_motorAssociation) as! MotorAssociationRegion
        priv_motorOutput =
            aDecoder.decodeObject(forKey: Network.key_motorOutput) as! MotorOutputRegion
        priv_vta =
            aDecoder.decodeObject(forKey: Network.key_ventralTegmentalArea) as! VentralTegmentalArea
        
        priv_effectors =
            aDecoder.decodeObject(forKey: Network.key_effectors) as! EffectorRegion
        
        // Swift dictionary cannot be coded/decoded directly. Convert and encode
        // as parallel NSArray's of keys and values. Read back as such and 
        // convert to dictionaries.
        
        let nsArrayNames: NSArray =
            aDecoder.decodeObject(forKey: Network.key_namedNodes_names) as! NSArray
        
        let nsArrayNodes: NSArray =
            aDecoder.decodeObject(forKey: Network.key_namedNodes_nodes) as! NSArray
        
        precondition(nsArrayNames.count == nsArrayNodes.count)
        for ix in 0..<nsArrayNames.count {
            let name: Identifier = nsArrayNames[ix] as! Identifier
            let node: Node = nsArrayNodes[ix] as! Node
            priv_namedNodes[name] = node
        }
        
    } // end init?
    
    
    
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(priv_identifier, forKey: Network.key_identifier)
        aCoder.encode(priv_logger, forKey: Network.key_logger)
        
        aCoder.encode(priv_isDopaminergicSignalForced,
                      forKey: Network.key_isDopaminergicSignalForced)
        aCoder.encode(priv_latchedDopaminergicSignal,
                      forKey: Network.key_latchedDopaminergicSignal)
        
        aCoder.encode(priv_isHippocampalSignalForced,
                      forKey: Network.key_isHippocampalSignalForced)
        aCoder.encode(priv_latchedHippocampalSignal,
                      forKey: Network.key_latchedHippocampalSignal)
        
        aCoder.encode(priv_sensors, forKey: Network.key_sensors)
        
        aCoder.encode(priv_hippocampus, forKey: Network.key_hippocampus)
        aCoder.encode(priv_sensoryInput, forKey: Network.key_sensoryInput)
        aCoder.encode(priv_sensoryAssociation, forKey: Network.key_sensoryAssociation)
        
        aCoder.encode(priv_motorAssociation, forKey: Network.key_motorAssociation)
        aCoder.encode(priv_motorOutput, forKey: Network.key_motorOutput)
        aCoder.encode(priv_vta, forKey: Network.key_ventralTegmentalArea)
        
        aCoder.encode(priv_effectors, forKey: Network.key_effectors)
        
        // Swift dictionary cannot be coded/decoded directly. Convert and encode
        // as parallel NSArray's of keys and values. Read back as such and
        // convert to dictionaries.
        
        let nodeNames = priv_namedNode_namesAsNSArray
        let nodes = priv_namedNode_nodesAsNSArray
        precondition(nodeNames.count == nodes.count)
        aCoder.encode(nodeNames, forKey: Network.key_namedNodes_names)
        aCoder.encode(nodes, forKey: Network.key_namedNodes_nodes)
        
        /*
        let nodeInfoNames = priv_infoForNamedNode_namesAsNSArray
        let infos = priv_inforForNamedNode_infoAsNSArray
        precondition(nodeInfoNames.count == infos.count)
        aCoder.encodeObject(nodeInfoNames, forKey: Network.key_infoForNamedNodes_names)
        aCoder.encodeObject(infos, forKey: Network.key_infoForNamedNodes_info)
        */
    } // end encodeWithCoder
    
    
    fileprivate var priv_namedNode_namesAsNSArray: NSArray {
        let array = NSMutableArray(capacity: priv_namedNodes.count)
        for name in priv_namedNodes.keys {
            array.add(name)
        }
        return array
    }
    fileprivate var priv_namedNode_nodesAsNSArray: NSArray {
        let array = NSMutableArray(capacity: priv_namedNodes.count)
        for node in priv_namedNodes.values {
            array.add(node)
        }
        return array
    }
    
    /*
    private var priv_infoForNamedNode_namesAsNSArray: NSArray {
        let array = NSMutableArray(capacity: priv_namedNodes.count)
        for name in priv_infoForNamedNodes.keys {
            array.addObject(name)
        }
        return array
    }
    private var priv_inforForNamedNode_infoAsNSArray: NSArray {
        let array = NSMutableArray(capacity: priv_namedNodes.count)
        for node in priv_infoForNamedNodes.values {
            array.addObject(node)
        }
        return array
    }
    */
    

    
    
    // MARK: *Private* Methods
    
    fileprivate func priv_update() -> Void {
        
        // Get sensor and propogate sensor input,
        // recompute discrepancy signals and propogate them.
        //
        priv_beginActivation()
        
        if hasUpdater {
            priv_updater!.operantNeuronsActivate()
            
        } else {
            operantNeuronsActivate(false)
            operantNeuronPropogateActivation()
        }
        
        if isLearningEnabled {
                operantNeuronsLearn()
        }
        
        // Discrepancy units learn. Trigger effectors.
        //
        priv_endActivation()

        priv_effectors.prepareActivation()
        priv_effectors.commitActivation()
        
    } // end priv_update
    

    
    
    fileprivate func priv_beginActivation() -> Void {
        precondition(isUpdating)
        
        // Make current sensor readings available to downstream neurons
        //
        priv_sensors.prepareActivation()
        priv_sensors.commitActivation()
        
        priv_sensoryInput.commitActivation()
        priv_sensoryInput.prepareActivation()
        
        // Compute new discrepancy signals based on inputs so that all other
        // neurons are responding to current conditions rather than conditions
        // on the previous activation.
        //
        // Important: The hippocampal neurons need the current signal from
        // the dopaminergic unit to be able to correctly apply reinforcement
        // feedback.
        //
        // Thus: Changes to activation of discrepancy units are immediately propogated.
        //
        priv_vta.prepareActivation()
        priv_vta.commitActivation()
        if !priv_isDopaminergicSignalForced {
            priv_latchedDopaminergicSignal = priv_vta.dopaminergicSignal
        }

        priv_hippocampus.prepareActivation()
        priv_hippocampus.commitActivation()
        if !priv_isHippocampalSignalForced {
            priv_latchedHippocampalSignal = hippocampus.hippocampalSignal
        }
        
    } // end priv_beginActivation
    
    
    
    
    
    // Deactivation is generally used to fake an intertrial interval, or some other
    // quiesent period in which activations would decrease to logisticSimoid(0.0).
    //
    // This is done in lieu of actually running enough time steps without reinforcers
    // to permit "natural" deactivation.
    //
    // NOTE: Changes to activation of discrepancy units are immediately propogated.
    //
    fileprivate func priv_discrepancyUnitsResetActivation() -> Void {
        precondition(isUpdating)
        
        priv_vta.resetActivation()
        priv_vta.commitActivation()
        if !priv_isDopaminergicSignalForced {
            priv_latchedDopaminergicSignal = priv_vta.dopaminergicSignal
        }

        priv_hippocampus.resetActivation()
        priv_hippocampus.commitActivation()
        if !priv_isHippocampalSignalForced {
            priv_latchedHippocampalSignal = hippocampus.hippocampalSignal
        }
    }
    
    
    
    
    
    fileprivate func priv_endActivation() -> Void {
        precondition(isUpdating)
        if isLearningEnabled {
            priv_vta.learn()
            priv_hippocampus.learn()
        }
    }
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_identifier: Identifier? = nil
    fileprivate var priv_logger: Logger? = nil
    
    
    fileprivate var priv_isUpdating: Bool = false
    fileprivate var priv_isUpdaterOnline: Bool = false
    fileprivate var priv_updater: NetworkUpdater? = nil
    
    
    
    fileprivate var priv_isDopaminergicSignalForced = false
    fileprivate var priv_latchedDopaminergicSignal: Double = 0.0
    
    fileprivate var priv_isHippocampalSignalForced = false
    fileprivate var priv_latchedHippocampalSignal: Double = 0.0
    
    fileprivate var priv_sensors: SensorRegion!
    
    fileprivate var priv_hippocampus: Hippocampus!
    fileprivate var priv_sensoryInput: SensoryInputRegion!
    fileprivate var priv_sensoryAssociation: SensoryAssociationRegion!
    
    fileprivate var priv_motorAssociation: MotorAssociationRegion!
    fileprivate var priv_motorOutput: MotorOutputRegion!
    fileprivate var priv_vta: VentralTegmentalArea!
    
    fileprivate var priv_effectors: EffectorRegion!
    
    fileprivate var priv_namedNodes = [Identifier: Node]()
    
    // NO: This should be in a database, or some separate store. NOT
    // part of the state of the neural network.
    //
    // private var priv_infoForNamedNodes = [Identifier: NodeInfo]()
    
} // end class Network

