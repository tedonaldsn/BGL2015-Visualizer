//
//  BGL2015Tests.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 7/18/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import XCTest
import BASimulationFoundation

class BGL2015Tests: XCTestCase {
    
    var experiment: TrialsLooper!

    override func setUp() {
        super.setUp()
        experiment = TrialsLooper(
            organism: Organism(identifier: Identifier(idString: "BGL2015Tests")),
            logger: Logger())
    }
    
    override func tearDown() {
        experiment = nil
        super.tearDown()
    }

    func testTrialCounts() {
        
        experiment.runTrials()
        let steps = experiment.stepData
        
        XCTAssertTrue(steps.count == TrialsLooper.totalSteps,
                      "Expected \(TrialsLooper.totalSteps) step records. Got \(steps.count)")
        
        var trainingTrialCount = 0
        var choiceTrialCount = 0
        var unexpectedTrailTypeCount = 0
        
        var xTrainingTrialCount = 0
        var yTrainingTrialCount = 0
        var unexpectedTrainingTrialCount = 0
        
        var xSrTrainingTrialCount = 0
        var ySrTrainingTrialCount = 0
        
        for step in steps {
            if step.isFirstStepOfTrialProper {
                if step.isTrainingTrial {
                    trainingTrialCount = trainingTrialCount + 1
                    if step.isXTrainingTrial {
                        xTrainingTrialCount = xTrainingTrialCount + 1
                    } else if step.isYTrainingTrail {
                        yTrainingTrialCount = yTrainingTrialCount + 1
                    } else {
                        unexpectedTrainingTrialCount = unexpectedTrainingTrialCount + 1
                    }
                    
                } else if step.isChoiceTrial {
                    choiceTrialCount = choiceTrialCount + 1
                    
                } else {
                    unexpectedTrailTypeCount = unexpectedTrailTypeCount + 1
                }
                
            } else if step.isFinalSrStepOfTrial {
                if step.isXTrainingTrial {
                    if step.isSrOn {
                        xSrTrainingTrialCount = xSrTrainingTrialCount + 1
                    }
                } else if step.isYTrainingTrail {
                    if step.isSrOn {
                        ySrTrainingTrialCount = ySrTrainingTrialCount + 1
                    }
                }
            }
        }
        
        XCTAssertTrue(trainingTrialCount == TrialsLooper.totalTrainingTrials,
                      "Expected \(TrialsLooper.totalTrainingTrials) training trials. Got \(trainingTrialCount)")
        XCTAssertTrue(choiceTrialCount == TrialsLooper.totalChoiceTrials,
                      "Expected \(TrialsLooper.totalChoiceTrials) choice trials. Got \(choiceTrialCount)")
        XCTAssertTrue(unexpectedTrailTypeCount == 0,
                      "Expected \(TrialsLooper.totalChoiceTrials) trials of unexpected type. Got \(choiceTrialCount)")
        let totalTrialCount = trainingTrialCount + choiceTrialCount
        XCTAssertTrue(totalTrialCount == TrialsLooper.totalTrials,
                      "Expected \(TrialsLooper.totalTrials) total trials. Got \(totalTrialCount)")
        
        XCTAssertTrue(xTrainingTrialCount == yTrainingTrialCount)
        XCTAssertTrue(xTrainingTrialCount == TrialsLooper.totalXTrials)
        XCTAssertTrue(yTrainingTrialCount == TrialsLooper.totalYTrials)
        XCTAssertTrue(unexpectedTrainingTrialCount == 0)
        
        // Will have approximately 50% of X trials with Sr. Give it a range of 
        // plus or minus 5% around 50%.
        //
        let xSrPad: Int = Int(Double(TrialsLooper.totalXTrials) * 0.1)
        let xSrMin = TrialsLooper.totalXTrials/2 - xSrPad
        let xSrMax = TrialsLooper.totalXTrials/2 + xSrPad
        
        XCTAssertTrue(xSrTrainingTrialCount >= xSrMin,
                      "Expected at least \(xSrMin) X trials with Sr. Got \(xSrTrainingTrialCount)")
        XCTAssertTrue(xSrTrainingTrialCount <= xSrMax,
                      "Expected no more than \(xSrMax) X trials with Sr. Got \(xSrTrainingTrialCount)")
        XCTAssertTrue(ySrTrainingTrialCount == TrialsLooper.totalYTrials,
                      "Expected \(TrialsLooper.totalYTrials) Y trials with Sr. Got \(ySrTrainingTrialCount)")
        
        
    } // end testTrialCounts
    
    
    
    
    
    func testSummarizedResults() {
        
        // experiment.logger.isInfoEnabled = true
        
        let expectedDepth = 6
        let maxDepth = experiment.organism.brain.maxLayerDepth
        let expectedWidth = 3
        let maxWidth = experiment.organism.brain.maxNodeWidth
        
        XCTAssertTrue(maxDepth == expectedDepth,
                      "Expected depth: \(expectedDepth). Actual: \(maxDepth)")
        XCTAssertTrue(maxWidth == expectedWidth,
                      "Expected width: \(expectedWidth). Actual: \(maxWidth)")
        
        // Minimum values determined pragmatically. They are lower than any
        // values actually observed.
        //
        let min_smPrimePrime1Weight = 0.4
        let min_smPrimePrime2Weight = 0.5
        let min_mPrime1Activation = 0.004
        let min_mPrime2Activation = 0.4
        
        experiment.runTrials()
        let summary = experiment.choiceSummaryData
        
        XCTAssertTrue(summary.r1Count <= summary.r2Count,
                      "Expected R1 count to be no more than R2, but got \(summary.r1Count) R1's and \(summary.r2Count) R2's")
        
        XCTAssertTrue(summary.smPrimePrime1Weight > min_smPrimePrime1Weight,
                      "Expected average S\"1-M\"1 weight to be greater than \(min_smPrimePrime1Weight), but is \(summary.smPrimePrime1Weight).")
        XCTAssertTrue(summary.smPrimePrime2Weight > min_smPrimePrime2Weight,
                      "Expected average S\"2-M\"2 weight to be greater than \(min_smPrimePrime2Weight), but is \(summary.smPrimePrime2Weight).")
        
        XCTAssertTrue(summary.smPrimePrime1Weight < summary.smPrimePrime2Weight,
                      "Expected average S\"1-M\"1 weight to be less than S\"2-M\"2 weight, but got \(summary.smPrimePrime1Weight) and \(summary.smPrimePrime2Weight), respectively")
        
        XCTAssertTrue(summary.mPrime1Activation > min_mPrime1Activation,
                      "Expected average M'1 activation to be greater than \(min_mPrime1Activation), but got \(summary.mPrime1Activation).")
        XCTAssertTrue(summary.mPrime2Activation > min_mPrime2Activation,
                      "Expected average M'2 activation to be greater than \(min_mPrime2Activation), but got \(summary.mPrime2Activation).")
        
        XCTAssertTrue(summary.mPrime1Activation < summary.mPrime2Activation,
                      "Expected average M'1 activation to be less than M'2 activation, but got \(summary.smPrimePrime1Weight) and \(summary.smPrimePrime2Weight), respectively")
        
    } // end  testSummarizedResults
    
    

    
    func testPerformance() {

        self.measure {
            self.experiment.runTrials()
        }
    }
    
    
} // end class BGL2015Tests


