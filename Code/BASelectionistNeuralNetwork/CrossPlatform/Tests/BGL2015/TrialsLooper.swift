//
//  TrialsLooper.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 5/28/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Foundation
import CoreData
import BASimulationFoundation


final public class TrialsLooper {
    
    // MARK: Session Control Settings
    
    public static let firstIntertrialStepIndex = 0
    public static let intertrialStepsPerTrial = 1
    
    public class var firstNonSrTimeStepIndex: Int {
        return firstIntertrialStepIndex + intertrialStepsPerTrial
    }
    public static let nonSrTimeStepsPerTrial = 4
    
    public class var firstSrTimeStepIndex: Int {
        return firstNonSrTimeStepIndex + nonSrTimeStepsPerTrial
    }
    public static let srTimeStepsPerTrial = 1
    
    public class var maxStepsPerTrial: Int {
        return intertrialStepsPerTrial + nonSrTimeStepsPerTrial + srTimeStepsPerTrial
    }
    
    public static let totalXTrials = 200
    public static let totalYTrials = 200
    public class var totalTrainingTrials: Int { return totalXTrials + totalYTrials }
    
    public static let totalChoiceTrials = 20
    
    public class var totalTrials: Int { return totalTrainingTrials + totalChoiceTrials }
    
    // Note that there is one fewer intertrial interval than there are trials
    // since the intertrial interval only occurs between trials.
    //
    public class var totalSteps: Int {
        return (totalTrials * maxStepsPerTrial) - intertrialStepsPerTrial
    }
    
    // MARK: Trial/step Predicates
    
    public class func isTrainingTrial(_ trialNumber: Int) -> Bool {
        assert(trialNumber > 0)
        return trialNumber <= totalTrainingTrials
    }
    public class func isChoiceTrial(_ trialNumber: Int) -> Bool {
        assert(trialNumber <= totalTrials)
        return trialNumber > totalTrainingTrials
    }
    public class func isIntertrialIntervalStep(_ stepNumber: Int) -> Bool {
        assert(stepNumber >= 0)
        assert(stepNumber <= maxStepsPerTrial)
        return stepNumber < firstNonSrTimeStepIndex
    }
    public class func isFirstStepOfTrialProper(_ stepNumber: Int) -> Bool {
        assert(stepNumber >= 0)
        assert(stepNumber <= maxStepsPerTrial)
        return stepNumber == firstNonSrTimeStepIndex
    }
    public class func isNonSrStep(_ stepNumber: Int) -> Bool {
        assert(stepNumber >= 0)
        assert(stepNumber <= maxStepsPerTrial)
        return stepNumber >= firstNonSrTimeStepIndex && stepNumber < firstSrTimeStepIndex
    }
    public class func isSrStep(_ stepNumber: Int) -> Bool {
        assert(stepNumber >= 0)
        assert(stepNumber <= maxStepsPerTrial)
        return stepNumber >= firstSrTimeStepIndex
    }
    public class func isFinalSrStepOfTrial(_ stepNumber: Int) -> Bool {
        assert(stepNumber >= 0)
        assert(stepNumber <= maxStepsPerTrial)
        return stepNumber == (firstSrTimeStepIndex + srTimeStepsPerTrial) - 1
    }
    public class func isFinalStepOfTrialProoper(_ stepNumber: Int) -> Bool {
        assert(stepNumber >= 0)
        assert(stepNumber <= maxStepsPerTrial)
        return stepNumber >= firstSrTimeStepIndex
            && stepNumber < firstSrTimeStepIndex + srTimeStepsPerTrial
    }
    
    // MARK: Data
    
    public let logger: Logger
    
    // The "organism" experienceing the procedure. This is an instance of
    // the neural network described in Burgos, José E., García-Leal, Óscar (2015).
    //
    public var organism: Organism!
    
    
    public var stepData: [SessionStepData] {
        return priv_stepData
    }
    public var choiceData: [SessionStepData] {
        return priv_finalChoiceSteps
    }
    public var choiceSummaryData: SessionSummaryData {
        return priv_choiceSummaryData
    }

    
    
    // MARK: Initialization

    public init(organism: Organism, logger: Logger) {
        self.organism = organism
        self.logger = logger
    }
    
    
    
    // MARK: Run
    
    public func runTrials() {
        priv_clearData()
        priv_beginOfSessionDataCollection()
        priv_runTrainingTrials()
        priv_runChoiceTrials()
        endOfSessionDataCollection()
    }
    
    
    
    // MARK: Data Collection
    
    public func endOfSessionDataCollection() -> Void {
        
        logger.logTrace("endOfSessionDataCollection")
        
        for stepData in priv_stepData {
            
            if stepData.isChoiceTrial && stepData.isSrStep {
                priv_finalChoiceSteps.append(stepData)
            }
        }
        
        priv_summarize(priv_finalChoiceSteps)
        priv_logSessionSummary()
        
    } // end endOfSessionDataCollection
    
    
    // MARK: *Private*
    
    fileprivate var priv_wp50 = RandomBoolean(withProbability: 0.50)
    
    fileprivate var priv_isLearningEnabled = false
    fileprivate var priv_turnXStimulusOn = false
    fileprivate var priv_turnYStimulusOn = false
    fileprivate var priv_turnSrStimulusOn = false
    
    fileprivate var priv_xTrialCount = 0
    fileprivate var priv_yTrialCount = 0
    fileprivate var priv_choiceTrialCount = 0
    
    fileprivate var priv_isXTrial = false
    fileprivate var priv_isYTrial = false
    fileprivate var priv_isChoiceTrial = false
    
    
    fileprivate var priv_trialNumber = 0
    fileprivate var priv_trialStepNumber = 0
    
    // The session Core Data record will not be created until the session is over,
    // so must record the session start time until then.
    //
    fileprivate var priv_sessionStartedAt: TimeInterval = 0
    
    // The data from a run is not saved to Core Data until after the session,
    // so accumulate data from each step here for dump to Core Data later.
    //
    fileprivate var priv_stepData = [SessionStepData]()
    fileprivate var priv_finalChoiceSteps = [SessionStepData]()
    fileprivate var priv_choiceSummaryData = SessionSummaryData()

    fileprivate func priv_clearData() {
        priv_stepData = [SessionStepData]()
        priv_finalChoiceSteps = [SessionStepData]()
        priv_choiceSummaryData = SessionSummaryData()
    }
    
    fileprivate func priv_runTrainingTrials() {
        
        logger.logTrace("Begin Training Trials")
        
        while priv_xTrialCount < TrialsLooper.totalXTrials || priv_yTrialCount < TrialsLooper.totalYTrials {
            
            priv_trialNumber = priv_trialNumber + 1
            
            if priv_trialNumber > 1 {
                priv_runIntertrialIntervalTimeStep()
            }
            
            priv_clearTrialConfiguration()
            
            // 50/50 chance of doing a X trial, unless Y trials are completed
            // in which case we keep doing X trials until we hit the max.
            //
            if priv_xTrialCount < TrialsLooper.totalXTrials
                && (priv_wp50.next || priv_yTrialCount == TrialsLooper.totalYTrials) {
                
                priv_isLearningEnabled = true
                priv_turnXStimulusOn = true
                priv_turnSrStimulusOn = priv_wp50.next
                
                priv_xTrialCount = priv_xTrialCount + 1
                
            } else {
                priv_isLearningEnabled = true
                priv_turnYStimulusOn = true
                priv_turnSrStimulusOn = true
                
                priv_yTrialCount = priv_yTrialCount + 1
            }
            
            priv_runTrial()
        }
        
        logger.logTrace("End Training Trials")

    } // end priv_runTrainingTrials
    
    
    
    fileprivate func priv_runChoiceTrials() {
        
        logger.logTrace("Begin Choice Trials")
        
        while priv_choiceTrialCount < TrialsLooper.totalChoiceTrials {
            
            priv_trialNumber = priv_trialNumber + 1
            
            priv_runIntertrialIntervalTimeStep()
            
            priv_clearTrialConfiguration()
            
            priv_turnXStimulusOn = true
            priv_turnYStimulusOn = true
            
            priv_choiceTrialCount = priv_choiceTrialCount + 1
            
            priv_runTrial()
        }
        
        logger.logTrace("End Choice Trials")
    
    } // end priv_runChoiceTrials
    
    
    
    fileprivate func priv_runTrial() {
        organism.isLearningEnabled = priv_isLearningEnabled
        organism.x = priv_turnXStimulusOn
        organism.y = priv_turnYStimulusOn
        
        priv_trialStepNumber = 1
        organism.sr = false
        
        while priv_trialStepNumber <= TrialsLooper.nonSrTimeStepsPerTrial {
            organism.brain.update()
            
            priv_endOfStepDataCollection()
            priv_trialStepNumber = priv_trialStepNumber + 1
        }
        
        organism.sr = priv_turnSrStimulusOn
        
        while priv_trialStepNumber < TrialsLooper.maxStepsPerTrial {
            organism.brain.update()
            
            priv_endOfStepDataCollection()
            priv_trialStepNumber = priv_trialStepNumber + 1
        }
        priv_endOfTrialDataCollection(logger)
    }
    
    fileprivate func priv_runIntertrialIntervalTimeStep() {
        organism.isLearningEnabled = false
        organism.x = false
        organism.y = false
        organism.sr = false
        
        priv_trialStepNumber = 0
        
        organism.brain.interTrialInterval()
        
        priv_endOfStepDataCollection()
    }
    
    fileprivate func priv_clearTrialConfiguration() {
        priv_isLearningEnabled = false
        priv_turnXStimulusOn = false
        priv_turnYStimulusOn = false
        priv_turnSrStimulusOn = false
    }
    
    public func priv_beginOfSessionDataCollection() -> Void {
        logger.logTrace("beginOfSessionDataCollection")
        
        // Save the session start time for later inclusion in Core Data Session record.
        //
        // priv_sessionStartedAt = Session.timeStamp
    }
    
    
    public func priv_endOfStepDataCollection() -> Void {
        
        // logger.logTrace("endOfStepDataCollection")
        
        let stepData = SessionStepData()
        
        stepData.trialNumber = priv_trialNumber
        stepData.trialStepNumber = priv_trialStepNumber
        
        stepData.isXOn = organism.x
        stepData.isYOn = organism.y
        stepData.isSrOn = organism.sr
        
        stepData.isLearning = organism.isLearningEnabled
        
        stepData.s1m1Weight = organism.mPrimePrime1.excitatoryWeights[0]
        stepData.s2m2Weight = organism.mPrimePrime2.excitatoryWeights[0]
        stepData.m1outActivation = organism.mPrime1.activationLevel.rawValue
        stepData.m2outActivation = organism.mPrime2.activationLevel.rawValue
        
        priv_stepData.append(stepData)
        
        if logger.isInfoEnabled {
            let line = "\(stepData.trialNumber), step: \(stepData.trialStepNumber), X: \(stepData.isXOn), Y: \(stepData.isYOn), Sr: \(stepData.isSrOn), learning: \(stepData.isLearning), S\"1-M\"1 w: \(stepData.s1m1Weight), S\"2-M\"2 w: \(stepData.s2m2Weight), M'1 a: \(stepData.m1outActivation), M'2 a: \(stepData.m2outActivation)"
            
            logger.logInfo(line)
        }
        
    } // end priv_endOfStepDataCollection
    
    
    public func priv_endOfTrialDataCollection(_ logger: Logger) -> Void {
        // logger.logTrace("endOfTrialDataCollection")
    }
    
    
    
    fileprivate func priv_summarize(_ finalChoiceSteps: [SessionStepData]) -> Void {
        
        priv_choiceSummaryData.r1Count = finalChoiceSteps.reduce(0) {
            (total: Int, step: SessionStepData) -> Int in return total + (step.m1outActivation >= 0.50 ? 1 : 0)
        }
        priv_choiceSummaryData.r2Count = finalChoiceSteps.reduce(0) {
            (total: Int, step: SessionStepData) -> Int in return total + (step.m2outActivation >= 0.50 ? 1 : 0)
        }
        
        let count: Double = Double(finalChoiceSteps.count)
        
        let mPrime1ActivationTotal = finalChoiceSteps.reduce(0.0) {
            (total: Double, step: SessionStepData) -> Double in return total + step.m1outActivation
        }
        priv_choiceSummaryData.mPrime1Activation = mPrime1ActivationTotal / count
        
        let mPrime2ActivationTotal = finalChoiceSteps.reduce(0.0) {
            (total: Double, step: SessionStepData) -> Double in return total + step.m2outActivation
        }
        priv_choiceSummaryData.mPrime2Activation = mPrime2ActivationTotal / count
        
        let smPrimePrime1WeightTotal = finalChoiceSteps.reduce(0.0) {
            (total: Double, step: SessionStepData) -> Double in return total + step.s1m1Weight
        }
        priv_choiceSummaryData.smPrimePrime1Weight = smPrimePrime1WeightTotal / count
        
        let smPrimePrime2WeightTotal = finalChoiceSteps.reduce(0.0) {
            (total: Double, step: SessionStepData) -> Double in return total + step.s2m2Weight
        }
        priv_choiceSummaryData.smPrimePrime2Weight = smPrimePrime2WeightTotal / count
        
    } // end priv_summarize
    
    
    fileprivate func priv_logSessionSummary() -> Void {
        if logger.isInfoEnabled {
            
            logger.logInfo("-- Begin Choices Summary -")
            logger.logInfo("Average weight: s\"1-m\"1: \(priv_choiceSummaryData.smPrimePrime1Weight), s\"2-m\"2: \(priv_choiceSummaryData.smPrimePrime2Weight)")
            logger.logInfo("Average activation: m'1: \(priv_choiceSummaryData.mPrime1Activation), m'2: \(priv_choiceSummaryData.mPrime2Activation)")
            logger.logInfo("Response counts: R1: \(priv_choiceSummaryData.r1Count), R2: \(priv_choiceSummaryData.r2Count)")
            logger.logInfo("-- End Choices Summary --")
        }
        
    } // end priv_logSessionSummary
    


    
    
} // end class TrialsLooper

