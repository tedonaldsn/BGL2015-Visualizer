//
//  BGL2015Experiment.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 10/13/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//
//  Tests based on Burgos, José E., García-Leal, Óscar (2015). Autoshaped
//  choice in artificial neural networks: Implications for behavioral
//  economics and neuroeconomics. Behavioural Processes, 114, 63-71




import BASimulationFoundation
import GameplayKit



final public class BGL2015Experiment {
    
    public struct SummaryStatistics {
        
        public var subjectCount: Int = 0
        
        public var totalR1: Int = 0
        public var totalR1percent: Double = 0.0
        
        public var totalR2: Int = 0
        public var totalR2percent: Double = 0.0
        
        public var totalChoiceTrials: Int = 0
        
        public var totalR1activation: Double = 0.0
        public var totalR1activationPercent: Double = 0.0
        
        public var totalR1weight: Double = 0.0
        
        public var totalR2activation: Double = 0.0
        public var totalR2activationPercent: Double = 0.0
        
        public var totalR2weight: Double = 0.0
        
        public var avgR1activation: Double = 0.0
        public var avgR1weight: Double = 0.0
        public var avgR2activation: Double = 0.0
        public var avgR2weight: Double = 0.0
        
        public var activationR2greaterR1: Int = 0
        public var activationR2greaterR1percent: Double = 0.0
        
        public var weightR2greaterR1: Int = 0
        public var weightR2greaterR1percent: Double = 0.0
        
        public init() {}
        public init(initFrom: SummaryStatistics) {
            self.init()
            
            self.subjectCount = initFrom.subjectCount
            
            self.totalR1 = initFrom.totalR1
            self.totalR1percent = initFrom.totalR1percent
            self.totalR2 = initFrom.totalR2
            self.totalR2percent = initFrom.totalR2percent
            self.totalChoiceTrials = initFrom.totalChoiceTrials
            self.totalR1activation = initFrom.totalR1activation
            self.totalR1activationPercent = initFrom.totalR1activationPercent
            self.totalR1weight = initFrom.totalR1weight
            self.totalR2activation = initFrom.totalR2activation
            self.totalR2activationPercent = initFrom.totalR2activationPercent
            self.totalR2weight = initFrom.totalR2weight
            
            self.avgR1activation = initFrom.avgR1activation
            self.avgR1weight = initFrom.avgR1weight
            self.avgR2activation = initFrom.avgR2activation
            self.avgR2weight = initFrom.avgR2weight

            self.activationR2greaterR1 = initFrom.activationR2greaterR1
            self.activationR2greaterR1percent = initFrom.activationR2greaterR1percent
            
            self.weightR2greaterR1 = initFrom.weightR2greaterR1
            self.weightR2greaterR1percent = initFrom.weightR2greaterR1percent
        }

        
        public mutating func update(currentSubjectNumber: Int, session: BGL2015Session) {
            
            subjectCount = currentSubjectNumber
            
            totalChoiceTrials += session.choiceTrialsCompleted
            
            totalR1activation += session.avgR1activation
            totalR1weight += session.avgR1weight
            
            totalR1 += session.countR1
            totalR1percent
                = (Double(totalR1) / Double(totalChoiceTrials)) * 100
            
            totalR2activation += session.avgR2activation
            totalR2weight += session.avgR2weight
            
            totalR2 += session.countR2
            totalR2percent
                = (Double(totalR2) / Double(totalChoiceTrials)) * 100
            
            if session.avgR2activation > session.avgR1activation {
                activationR2greaterR1 += 1
                activationR2greaterR1percent = (Double(activationR2greaterR1) / Double(subjectCount)) * 100
            }
            if session.avgR2weight > session.avgR1weight {
                weightR2greaterR1 += 1
                weightR2greaterR1percent = (Double(weightR2greaterR1) / Double(subjectCount)) * 100
            }
            
            avgR1activation = totalR1activation/Double(subjectCount)
            avgR1weight = totalR1weight/Double(subjectCount)
            avgR2activation = totalR2activation/Double(subjectCount)
            avgR2weight = totalR2weight/Double(subjectCount)
            
        } // end update
        
    } // end struct SummaryStatistics
    
    
    
    public var isDebugPrintingDetail: Bool = false
    public var isDebugPrintingSummary: Bool = false
    
    public var numberOfSubjects:Int = 9
    
    public var currentSubjectNumber: Int { return subjectSessions.count }
    public var currentSubjectIndex: Int { return currentSubjectNumber - 1 }
    public var currentSubject: BGL2015Session? {
        return currentSubjectIndex >= 0
        ? subjectSessions[currentSubjectIndex]
        : nil
    }
    public var subjectSessions = [BGL2015Session]()
    
    public var criterionNumberPreferredR2:Int = 7 // Usual, but not always: 8
    
    public init(){}
    
    public func newSession() -> BGL2015Session {
        let subjectNumber = subjectSessions.count + 1
        let titleString = "TestBurgosGarciaLeal2015.Subject_\(subjectNumber)"
        let session = BGL2015Session(subjectIdentifier: Identifier(idString: titleString))
        
        session.subject.network.activationSettings.reactivationThresholdGenerator.isRandom = true
        
        session.isDebugPrintingDetail = isDebugPrintingDetail
        session.isDebugPrintingSummary = isDebugPrintingSummary
        
        subjectSessions.append(session)
        return session
    }
    
    public func initializeSummaryStats() {
        
        priv_summaryStats = SummaryStatistics()
        
        subjectSessions.removeAll()

    } // end initializeSummaryStats
    
    
    public var summaryStatistics: SummaryStatistics {
        return SummaryStatistics(initFrom: priv_summaryStats)
    }
    
    public func updateSummaryStats() -> Void {
        priv_summaryStats.update(currentSubjectNumber, session: currentSubject!)
    }
    
    
    public func debugPrintSummary() {
        if isDebugPrintingSummary {
            print("\n ------------------------------ Start Overall Summary ------------------------------\n")
            print("Responses (activation > 0.5) out of a total of \(priv_summaryStats.totalChoiceTrials) choice trials:")
            print("\tTotal R1 responses: \(priv_summaryStats.totalR1) (\(priv_summaryStats.totalR1percent)%)")
            print("\tTotal R2 responses: \(priv_summaryStats.totalR2) (\(priv_summaryStats.totalR2percent)%)")
            print("\n")
            
            print("Subjects with activations R2 > R1: \(priv_summaryStats.activationR2greaterR1)")
            print("Subjects with weights R2 > R1: \(priv_summaryStats.weightR2greaterR1)")
            print("\n")
            print("Overall activation averages: R1: \(priv_summaryStats.avgR1activation), R2: \(priv_summaryStats.avgR2activation)")
            print("Overall weight averages: R1: \(priv_summaryStats.avgR1weight), R2: \(priv_summaryStats.avgR2weight)")
            print("\n ------------------------------ End Overall Summary ------------------------------\n")
        }
    }
    
    
    public func startRunningSessions() {
        precondition(!isRunningSessions)
        
        if priv_endState == nil {
            priv_endState = BLG2015ExperimentStop(experiment: self)
            
            priv_stateMachine = GKStateMachine(states: [
                BGL2015ExperimentStart(experiment: self),
                BLG2015ExperimentSubjectSession(experiment: self),
                priv_endState,
                ])
        }
        priv_stateMachine.enterState(BGL2015ExperimentStart)
    }
    
    public var isRunningSessions: Bool {
        return priv_stateMachine != nil
            && priv_stateMachine.currentState != nil
            && priv_stateMachine.currentState !== priv_endState
    }
    
    public func runSessionTimeStep() {
        if isRunningSessions {
            priv_stateMachine.updateWithDeltaTime(0)
        }
    }
    
    
    
    public func runSessions() {
        startRunningSessions()
        
        while isRunningSessions {
            runSessionTimeStep()
        }
        
    } // end runSessions
    
    
    // MARK: *Private*
    
    private var priv_endState: BLG2015ExperimentStop!
    private var priv_stateMachine: GKStateMachine!
    
    
    private var priv_summaryStats = SummaryStatistics()

} // end class BGL2015Experiment




