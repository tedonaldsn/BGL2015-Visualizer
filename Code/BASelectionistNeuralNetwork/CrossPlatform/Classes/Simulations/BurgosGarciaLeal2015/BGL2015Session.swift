//
//  BGL2015Session.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 10/19/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//



import BASimulationFoundation
import GameplayKit




final public class BGL2015Session {
    
    public struct TimeStepData {
        var trial: Int = 0
        var timeStep: Int = 0
        var isLearning: Bool = false
        var isX: Bool = false
        var isY: Bool = false
        var isSr: Bool = false
        var isR1: Bool = false
        var isR2: Bool = false
        var r1Activation: Double = 0.0
        var r1Weight: Double = 0.0
        var r2Activation: Double = 0.0
        var r2Weight: Double = 0.0
        
        var isChoiceTrial: Bool { return isX && isY }
        var isXTrial: Bool { return isX && !isY }
        var isYTrial: Bool { return isY && !isX }
        
        var trialTypeName: String {
            if isXTrial {
                if isSr { return "X Trial w/S*" }
                return "X Trial"
            }
            if isYTrial { return "Y Trial" }
            if isChoiceTrial { return "Choice Trial" }
            return "Unknown Trial Type"
        }
        
    } // end struct TimeStepData
    
    
    
    // MARK: Free Settings
    
    public var isDebugPrintingSummary = false
    public var isDebugPrintingDetail = false
    
    // MARK: Pre-Run Settings
    
    public var timeStepsPerTrial = 5 {
        willSet { precondition(!priv_isRunning) }
    }
    public var srTimeStepsPerTrial = 1 {
        willSet { precondition(!priv_isRunning) }
    }
    
    public var srStartsAtTimeStepIndex: Int {
        precondition(srTimeStepsPerTrial <= timeStepsPerTrial)
        return timeStepsPerTrial - srTimeStepsPerTrial
    }
    
    public var maxXtrials = 200 {
        willSet { precondition(!priv_isRunning) }
    }
    public var maxYtrials = 200 {
        willSet { precondition(!priv_isRunning) }
    }
    public var maxChoiceTrials = 20 {
        willSet { precondition(!priv_isRunning) }
    }
    
    
    
    // MARK: In-Progress Read Only Data
    
    public var isRunning: Bool { return priv_isRunning }
    
    public var xTrialsCompleted: Int { return priv_xTrialsCompleted }
    public var yTrialsCompleted: Int { return priv_yTrialsCompleted }
    public var choiceTrialsCompleted: Int { return priv_choiceTrialsCompleted }
    
    public var timeStepData: [TimeStepData] { return priv_timeStepData }
    
    public var countR1: Int { return priv_countR1 }
    public var countR2: Int { return priv_countR2 }
    
    public var r1activationTotal: Double { return priv_r1activationTotal }
    public var r1weightTotal: Double { return priv_r1weightTotal }
    public var r2activationTotal: Double { return priv_r2activationTotal }
    public var r2weightTotal: Double { return priv_r2weightTotal }
    
    
    public var avgR1activation: Double { return priv_avgR1activation }
    public var avgR1weight: Double { return priv_avgR1weight }
    public var avgR2activation: Double { return priv_avgR2activation }
    public var avgR2weight: Double { return priv_avgR2weight }
    
    
    
    
    
    // MARK: Operanda
    
    public let subject: BGL2015Subject
    public let rand50 =
    GKRandomDistribution(randomSource: GKMersenneTwisterRandomSource(),
        lowestValue: 0,
        highestValue: 1)
    
    
    
    
    // MARK: Initialization
    
    
    public init(subjectIdentifier: Identifier) {
        let subject = BGL2015Subject(subjectIdentifier: subjectIdentifier)
        self.subject = subject
    }
    
    
    
    public func start() -> Void {
        
        if !priv_isRunning {
            
            priv_reset()
            priv_isRunning = true
            
            if isDebugPrintingSummary {
                
                print("\n\n======================================= Start of Session \(subject.network.identifier!) =======================================")
                
                print(subject.network.activationSettings)
                print(subject.network.learningSettings)
                print("Will run:")
                print("\tTime steps per trial: \(timeStepsPerTrial)")
                print("\tTraining trials:")
                print("\t\tX trials: \(maxXtrials)")
                print("\t\tY trials: \(maxYtrials)")
                print("\t\tSr time steps at end of trial: \(srTimeStepsPerTrial)")
                print("\tChoice trials: \(maxChoiceTrials)")
                print("\n")
            }
        }
        
    } // end start
    
    
    
    public func stop() -> Void {
        
        if priv_isRunning {
            if isDebugPrintingSummary {
                print("Completed trials: \(priv_overallTrialIndex) (\(priv_overallTrialIndex * timeStepsPerTrial) time steps)")
                print("\tX trials: \(priv_xTrialsCompleted) (\(priv_xTrialsCompleted * timeStepsPerTrial) time steps)")
                print("\tY trials: \(priv_yTrialsCompleted) (\(priv_yTrialsCompleted * timeStepsPerTrial) time steps)")
                print("\tChoice trials: \(priv_choiceTrialsCompleted) (\(priv_choiceTrialsCompleted * timeStepsPerTrial) time steps)")
            }
            
            var choiceTrialsInAverages = 0
            for rec in priv_timeStepData {
                if rec.isChoiceTrial && rec.timeStep >= srStartsAtTimeStepIndex {
                    priv_r1activationTotal += rec.r1Activation
                    if priv_r1activationTotal > 0.5 {
                        priv_countR1 += 1
                    }
                    priv_r1weightTotal += rec.r1Weight
                    
                    priv_r2activationTotal += rec.r2Activation
                    if priv_r2activationTotal > 0.5 {
                        priv_countR2 += 1
                    }
                    priv_r2weightTotal += rec.r2Weight
                    
                    choiceTrialsInAverages += 1
                }
            }
            assert(choiceTrialsInAverages == priv_choiceTrialsCompleted)
            
            priv_avgR1activation = priv_r1activationTotal / Double(priv_choiceTrialsCompleted)
            priv_avgR1weight = priv_r1weightTotal / Double(priv_choiceTrialsCompleted)
            priv_avgR2activation = priv_r2activationTotal / Double(priv_choiceTrialsCompleted)
            priv_avgR2weight = priv_r2weightTotal / Double(priv_choiceTrialsCompleted)
            
            if isDebugPrintingSummary {
                print("\nChoice Trial Averages (\(choiceTrialsCompleted) trials, final time step)\n\tR1: Activation: \(avgR1activation), Weight: \(avgR1weight)\n\tR2: Activation: \(avgR2activation), Weight: \(avgR2weight)")
                print("======================================= End of Session \(subject.network.identifier!) =======================================\n\n")
            }
            
            priv_isRunning = false
        }
        
    } // end stop
    
    
    func timeStep() -> Bool {
        
        if priv_isRunning {
            
            let isTrainingTrial = priv_xTrialsCompleted < maxXtrials || priv_yTrialsCompleted < maxYtrials
            
            if isTrainingTrial {
                
                let isXTrial = priv_xTrialsCompleted < maxXtrials && rand50.nextBool()
                
                if isXTrial {
                    xTrial(priv_overallTrialIndex)
                    priv_xTrialsCompleted += 1
                    priv_overallTrialIndex += 1
                    
                } else if priv_yTrialsCompleted < maxYtrials {
                    yTrial(priv_overallTrialIndex)
                    priv_yTrialsCompleted += 1
                    priv_overallTrialIndex += 1
                }
                
            } else {
                
                let isChoiceTrial = priv_choiceTrialsCompleted < maxChoiceTrials
                
                if isChoiceTrial {
                    choiceTrial(priv_overallTrialIndex)
                    priv_choiceTrialsCompleted += 1
                    priv_overallTrialIndex += 1
                    
                } else {
                    stop()
                }
            }
        }
        
        return priv_isRunning
        
    } // end timeStep
    
    
    
    
    func xTrial(trialIndex: Int) -> Void {
        let maybe = rand50.nextBool()
        trial(trialIndex, xIsOn: true, yIsOn: false, isSrTrial: maybe, learningIsOn: true)
    }
    
    func yTrial(trialIndex: Int) -> Void {
        trial(trialIndex, xIsOn: false, yIsOn: true, isSrTrial: true, learningIsOn: true)
    }
    
    func choiceTrial(trialIndex: Int) -> Void {
        trial(trialIndex, xIsOn: true, yIsOn: true, isSrTrial: false, learningIsOn: false)
    }
    
    
    
    
    func trial(trialIndex: Int,
        xIsOn: Bool,
        yIsOn: Bool,
        isSrTrial: Bool,
        learningIsOn: Bool) -> Void {
            
            subject.x = xIsOn
            subject.y = yIsOn
            subject.sr = false
            
            subject.network.isLearningEnabled = learningIsOn
            
            for timeStepIndex in 0..<timeStepsPerTrial {
                
                if isSrTrial && timeStepIndex == srStartsAtTimeStepIndex {
                    subject.sr = true
                }
                
                let isNewTrial = timeStepIndex == 0
                if isNewTrial {
                    subject.network.interTrialInterval()
                }
                subject.network.update()
                
                let r1Activation = subject.mPrime1.activationLevel.rawValue
                let r1Weight = subject.mPrimePrime1.excitatoryWeights[0]
                let r2Activation = subject.mPrime2.activationLevel.rawValue
                let r2Weight = subject.mPrimePrime2.excitatoryWeights[0]
                
                let stepData =
                TimeStepData(trial: trialIndex,
                    timeStep: timeStepIndex,
                    isLearning: learningIsOn,
                    isX: xIsOn,
                    isY: yIsOn,
                    isSr: subject.sr,
                    isR1: subject.r1,
                    isR2: subject.r2,
                    r1Activation: r1Activation,
                    r1Weight: r1Weight,
                    r2Activation: r2Activation,
                    r2Weight: r2Weight)
                
                priv_timeStepData.append(stepData)

                if isDebugPrintingDetail {
                    
                    print("\(stepData.trialTypeName), Trial[\(trialIndex)], Step[\(timeStepIndex)]")
                    
                    print("Network:")
                    print("\tDopaminergic signal: \(subject.network.dopaminergicSignal)")
                    print("\tHippocampal signal: \(subject.network.hippocampalSignal)")
                    
                    print("\tD:")
                    print("\t\tPresynaptic Activation:")
                    print("\t\t\tPavlovian: \(subject.d.pavlovianPresynapticExcitatoryActivation)")
                    print("\t\t\tOperant: \(subject.d.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.d.excitatoryWeights)")
                    print("\t\tActivation: \(subject.d.activationLevel)")
                    
                    // ---

                    print("S1-R1:")
                    
                    print("\tS'1: \(subject.sPrime1.activationLevel)")
                    
                    print("\tS''1:")
                    print("\t\tPresynaptic Activation: \(subject.sPrimePrime1.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.sPrimePrime1.excitatoryWeights)")
                    print("\t\tActivation: \(subject.sPrimePrime1.activationLevel)")
                    
                    print("\tH1:")
                    print("\t\tPresynaptic Activation: \(subject.h1.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.h1.excitatoryWeights)")
                    print("\t\tHippocampal Signal: \(subject.h1.discrepancySignal)")
                    print("\t\tActivation: \(subject.h1.activationLevel)")
                    
                    print("\tM''1:")
                    print("\t\tPresynaptic Activation: \(subject.mPrimePrime1.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.mPrimePrime1.excitatoryWeights)")
                    print("\t\tActivation: \(subject.mPrimePrime1.activationLevel)")
                    
                    print("\tM'1:")
                    print("\t\tPresynaptic Activation: \(subject.mPrime1.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.mPrime1.excitatoryWeights)")
                    print("\t\tActivation: \(subject.mPrime1.activationLevel)")

                    // ---
                    
                    print("S*, S2-R2:")
                    
                    print("\tS*: \(subject.sStar.activationLevel)")
                    print("\tS'2: \(subject.sPrime2.activationLevel)")
                    
                    print("\tS''2:")
                    print("\t\tPresynaptic Activation: \(subject.sPrimePrime2.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.sPrimePrime2.excitatoryWeights)")
                    print("\t\tActivation: \(subject.sPrimePrime2.activationLevel)")
                    
                    print("\tH2:")
                    print("\t\tPresynaptic Activation: \(subject.h2.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.h2.excitatoryWeights)")
                    print("\t\tHippocampal Signal: \(subject.h2.discrepancySignal)")
                    print("\t\tActivation: \(subject.h2.activationLevel)")
                    
                    print("\tM''2:")
                    print("\t\tPresynaptic Activation: \(subject.mPrimePrime2.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.mPrimePrime2.excitatoryWeights)")
                    print("\t\tActivation: \(subject.mPrimePrime2.activationLevel)")
                    
                    print("\tM'2:")
                    print("\t\tPresynaptic Activation: \(subject.mPrime2.operantPresynapticExcitatoryActivation)")
                    print("\t\tWeights: \(subject.mPrime2.excitatoryWeights)")
                    print("\t\tActivation: \(subject.mPrime2.activationLevel)")
                    
                    print(stepData)
                    print("\n")
                }

                
            } // end for timeStepIndex
            
    } // end trial
    
    
    
    // MARK: *Private*
    
    private func priv_reset() -> Void {
        
        // Run state
        
        priv_isRunning = false
        
        // Tallies
        
        priv_overallTrialIndex = 0
        
        priv_xTrialsCompleted = 0
        priv_yTrialsCompleted = 0
        priv_choiceTrialsCompleted = 0
        
        priv_timeStepData = [TimeStepData]()
        
        priv_countR1 = 0
        priv_countR2 = 0
        
        priv_r1activationTotal = 0.0
        priv_r1weightTotal = 0.0
        priv_r2activationTotal = 0.0
        priv_r2weightTotal = 0.0
        
        priv_avgR1activation = 0.0
        priv_avgR1weight = 0.0
        priv_avgR2activation = 0.0
        priv_avgR2weight = 0.0
        
    } // end priv_reset
    
    
    private var priv_isRunning = false
    
    
    private var priv_overallTrialIndex = 0
    
    private var priv_xTrialsCompleted = 0
    private var priv_yTrialsCompleted = 0
    private var priv_choiceTrialsCompleted = 0
    
    private var priv_timeStepData = [TimeStepData]()
    
    private var priv_countR1 = 0
    private var priv_countR2 = 0
    
    private var priv_r1activationTotal: Double = 0.0
    private var priv_r1weightTotal: Double = 0.0
    private var priv_r2activationTotal: Double = 0.0
    private var priv_r2weightTotal: Double = 0.0
    
    private var priv_avgR1activation: Double = 0.0
    private var priv_avgR1weight: Double = 0.0
    private var priv_avgR2activation: Double = 0.0
    private var priv_avgR2weight: Double = 0.0
    
} // end class BGL2015Session

