//
//  TimeStepPlayerController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 8/8/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa

class TimeStepPlayerController: NSViewController, DetailsDisplay {
    
    static let oneSecondInNanoseconds = TimeInterval(1000000000)
    static let speedSteps: UInt = 3
    
    
    // MARK: Time Step Scrubber
    
    @IBOutlet weak var stepScrubber: NSSlider!
    @IBAction func stepScrubberAction(_ sender: AnyObject) {
        let currentIndex = stepScrubber.integerValue
        priv_select(currentIndex)
    }
    
    
    // MARK: Play Limit Fields & Buttons
    
    @IBOutlet weak var beginButton: NSButton!
    @IBAction func beginButtonAction(_ sender: AnyObject) {
        priv_beginIndex = priv_currentSelectionIndex
        priv_adjustAndUpdateControls()
    }
    @IBOutlet weak var beginTrialField: NSTextField!
    @IBAction func beginTrialFieldAction(_ sender: AnyObject) {
        setFromBeginFields()
    }
    @IBOutlet weak var beginStepField: NSTextField!
    @IBAction func beginStepFieldAction(_ sender: AnyObject) {
        setFromBeginFields()
    }
    func setFromBeginFields() {
        let trialNumber = beginTrialField.integerValue
        let stepNumber = beginStepField.integerValue
        let beginIndex = coordinator.indexOfClosestStep(trialNumber, stepIndex: stepNumber)
        
        assert(beginIndex >= 0)
        
        setPlaybackRange(beginIndex: UInt(beginIndex),
                         cursorIndex: UInt(priv_currentSelectionIndex),
                         endIndex: UInt(priv_endIndex))
    }
    
    @IBOutlet weak var currentButton: NSButton!
    @IBAction func currentButtonAction(_ sender: AnyObject) {
    }
    @IBOutlet weak var currentTrialField: NSTextField!
    @IBAction func currentTrialFieldAction(_ sender: AnyObject) {
        setFromCurrentFields()
    }
    @IBOutlet weak var currentStepField: NSTextField!
    @IBAction func currentStepFieldAction(_ sender: AnyObject) {
        setFromCurrentFields()
    }
    func setFromCurrentFields() {
        let trialNumber = currentTrialField.integerValue
        let stepNumber = currentStepField.integerValue
        let newCurrent = coordinator.indexOfClosestStep(trialNumber, stepIndex: stepNumber)
        
        assert(newCurrent >= 0)
        
        if newCurrent != priv_currentSelectionIndex {
            
            setPlaybackRange(beginIndex: UInt(priv_beginIndex),
                             cursorIndex: UInt(newCurrent),
                             endIndex: UInt(priv_endIndex))
            
            coordinator.didSelect(self, selectedTimeStepIndex: priv_currentSelectionIndex)
        }
    }
    
    @IBOutlet weak var endButton: NSButton!
    @IBAction func endButtonAction(_ sender: AnyObject) {
        priv_endIndex = priv_currentSelectionIndex
        priv_adjustAndUpdateControls()
    }
    @IBOutlet weak var endTrialField: NSTextField!
    @IBAction func endTrialFieldAction(_ sender: AnyObject) {
        setFromEndFields()
    }
    @IBOutlet weak var endStepField: NSTextField!
    @IBAction func endStepFieldAction(_ sender: AnyObject) {
        setFromEndFields()
    }
    
    func setFromEndFields() {
        let trialNumber = endTrialField.integerValue
        let stepNumber = endStepField.integerValue
        let endIndex = coordinator.indexOfClosestStep(trialNumber, stepIndex: stepNumber)
        
        assert(endIndex >= 0)
        
        setPlaybackRange(beginIndex: UInt(priv_beginIndex),
                         cursorIndex: UInt(priv_currentSelectionIndex),
                         endIndex: UInt(endIndex))
    }
    
    
    
    func setPlaybackRange(fromTrialNumber: Int, fromStepNumber: Int,
                          currentTrialNumber: Int, currentStepNumber: Int,
                          toTrialNumber: Int, toStepNumber: Int) -> Void {
        
        assert(fromTrialNumber >= 0)
        assert(fromTrialNumber <= currentTrialNumber)
        assert(currentTrialNumber <= toTrialNumber)
        
        assert(fromStepNumber >= 0)
        assert(currentStepNumber >= 0)
        assert(toStepNumber >= 0)
        
        let beginIndex = coordinator.indexOfClosestStep(fromTrialNumber,
                                                        stepIndex: fromStepNumber)
        let currentIndex = coordinator.indexOfClosestStep(currentTrialNumber,
                                                          stepIndex: currentStepNumber)
        let endIndex = coordinator.indexOfClosestStep(toTrialNumber,
                                                      stepIndex: toStepNumber)
        
        assert(beginIndex >= 0)
        assert(currentIndex >= 0)
        assert(endIndex >= 0)
        
        setPlaybackRange(beginIndex: UInt(beginIndex),
                         cursorIndex: UInt(currentIndex),
                         endIndex: UInt(endIndex))
        
    } // end setPlaybackRange
    
    
    
    
    func setPlaybackRange(beginIndex: UInt,
                          cursorIndex: UInt,
                          endIndex: UInt) -> Void {
        
        priv_beginIndex = Int(beginIndex)
        priv_currentSelectionIndex = Int(cursorIndex)
        priv_endIndex = Int(endIndex)
        
        priv_adjustAndUpdateControls()
        
    } // end setPlaybackRange
    
    
    
    
    
    
    // MARK: Reset
    
    @IBOutlet weak var resetButton: NSButton!
    
    // Stop play and reset controls to original start-up values.
    //
    @IBAction func resetButtonAction(_ sender: AnyObject) {
        resetControls()
        
        coordinator.didZoom(self, percentOfRangeToDisplay: 1.0)
        coordinator.didSelect(self, selectedTimeStepIndex: priv_currentSelectionIndex)

    } // end resetButtonAction
    
    
    // MARK: Auto Zoom
    
    @IBOutlet weak var autoZoomCheckBox: NSButton!
    
    @IBAction func autoZoomAction(_ sender: AnyObject) {
        
        if !priv_didClose && priv_isPlaying &&
            autoZoomCheckBox.state == NSOnState {
            
            let zoomRange = NSMakeRange(priv_beginIndex,
                                        (priv_endIndex - priv_beginIndex) + 1)
            coordinator.didZoom(self, toTimeStepRange: zoomRange)
        }
    }

    // MARK: Play/Pause Button
    
    @IBOutlet weak var playPauseButton: NSButton!
    
    @IBAction func playPauseAction(_ sender: AnyObject) {
        if priv_isPlaying {
            pausePlay()
        } else {
            resumePlay()
        }
    }
    
    // MARK: Repeat (Loop) Button
    
    @IBOutlet weak var repeatPlayButton: NSButton!
    
    
    // MARK: Play Speed Slider
    
    @IBOutlet weak var speedSlider: NSSlider!
    
    @IBAction func speedSliderAction(_ sender: AnyObject) {
        
        let minValue = speedSlider.minValue
        let currentValue = speedSlider.doubleValue
        let maxValue = speedSlider.maxValue

        // Convert the control's values to a speed in the range 0-1 where
        // 0 is slowest and 1 is fastest.
        //
        let requestedSpeed = (currentValue - minValue) / (maxValue - minValue)
        
        setPlaySpeed(requestedSpeed)

    } // end speedSliderAction
    
    
    // MARK: Data
    
    var isPlaying: Bool {
        get { return priv_isPlaying }
        set {
            if newValue {
                startPlay()
            } else {
                pausePlay()
            }
        }
    }
    
    
    
    
    // MARK: DetailsDisplay Data
    
    
    var coordinator: DetailsCoordinator {
        get {
            assert(priv_coordinator != nil)
            return priv_coordinator!
        }
        set {
            priv_coordinator = newValue
        }
    }
    
    
    // MARK: Data
    
    var stepDelaySeconds: TimeInterval = 0.5 {
        willSet { precondition(newValue >= 0.0) }
    }
    
    var stepDelayNanoseconds: TimeInterval {
        return TimeStepPlayerController.oneSecondInNanoseconds * stepDelaySeconds
    }
    
    
    // MARK: Initialization
    
    
    
    // MARK: NSViewController
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view.translatesAutoresizingMaskIntoConstraints = false
        
        view.autoresizingMask = [
            NSAutoresizingMaskOptions.viewWidthSizable
        ]
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        priv_beginIndex = 0
        priv_currentSelectionIndex = priv_beginIndex
        priv_endIndex = timeStepsArray.count - 1
        
        priv_adjustAndUpdateControls()
    }
    
    
    
    // MARK: DetailsDisplay Functions
    
    
    func reloadData() -> Void {
        assert(priv_coordinator != nil)
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        resetControls()
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end displayTimeSteps
    
    
    func synchronizeScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
    } // end synchronizeScroll
    
    
    
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void {
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    
    
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    
    
    func synchronizeSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void {
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        priv_currentSelectionIndex = selectedTimeStepIndex
        priv_adjustAndUpdateControls()
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    

    
    
    
    func willClose() {
        guard !priv_didClose else { return }
        priv_didClose = true
        priv_isPlaying = false
        priv_beginIndex = -1
        priv_currentSelectionIndex = priv_beginIndex
        priv_endIndex = priv_currentSelectionIndex
    }
    
    
    
    // MARK: Play
    
    func startPlay() -> Void { resumePlay() }
    
    func resumePlay() -> Void {
        guard !priv_didClose else { return }
        guard !priv_isPlaying else { return }
        
        priv_isPlaying = true
        
        playPauseButton.image = NSImage(named: "pause_play_filled")
        
        if autoZoomCheckBox.state == NSOnState {
            let zoomRange = NSMakeRange(priv_beginIndex,
                                        (priv_endIndex - priv_beginIndex) + 1)
            coordinator.didZoom(self, toTimeStepRange: zoomRange)
        }
        
        // Force update of speed calculations based on currently selected
        // play range.
        //
        speedSliderAction(speedSlider)
        
        playNextStep()
    
    } // end resumePlay
    
    
    
    func playNextStep() -> Void {
        guard isPlaying else { return }
        
        var nextStep = (priv_currentSelectionIndex + 1) + priv_speedSkip

        if nextStep > priv_endIndex {
            if repeatPlayButton.state == NSOnState {
                nextStep = priv_beginIndex
                
            } else {
                pausePlay()
                return
            }
        }
        
        priv_currentSelectionIndex = nextStep
        scheduleNextStep()
        priv_adjustAndUpdateControls()
        coordinator.didSelect(self, selectedTimeStepIndex: nextStep)
        
    } // end playNextStep
    
    
    
    func scheduleNextStep() -> Void {
        guard isPlaying else { return }
        
        let delay = DispatchTime.now() + Double(priv_delayNanoseconds) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delay) {
            if !self.priv_didClose {
                self.playNextStep()
            }
        }
        
    } // end schedulePlayNextStep
    
    
    
    func stopPlay() -> Void { pausePlay() }
    
    func pausePlay() -> Void {
        guard !priv_didClose else { return }
        guard priv_isPlaying else { return }
        
        priv_isPlaying = false
        
        playPauseButton.image = NSImage(named: "start_play_filled")

    } // end pausePlay
    
    
    
    func setPlaySpeed(_ requestedSpeed: Double) -> Void {
        
        // Slower speeds are handled by adjusting scheduling delays.
        // Higher speeds are handled by skipping steps.
        //
        if requestedSpeed <= 0.5 {
            priv_speedSkip = 0
            
            let delayProportion = 1.0 - (requestedSpeed * 2.0)
            priv_delayNanoseconds = Int64(Double(priv_maxDelayNanoseconds) * delayProportion)
            
        } else {
            priv_delayNanoseconds = 0
            
            let skipProportionRequested: Double = (requestedSpeed - 0.5) * 2.0
            let stepsInRange: Int = (priv_endIndex - priv_beginIndex) + 1
            
            let accelleration: Double = Double(timeStepsArray.count) / Double(stepsInRange) * 0.75
            let proportionOfSteps: Double = priv_maxSpeedSkipProportionOfSteps * accelleration
            
            let maxSkipSteps: Int = Int(Double(stepsInRange) * proportionOfSteps)
            
            priv_speedSkip = Int(Double(maxSkipSteps) * skipProportionRequested)
        }
        
    } // end setPlaySpeed
    
    
    
    
    func resetControls() -> Void {
        pausePlay()
        
        priv_beginIndex = 0
        priv_currentSelectionIndex = 0
        priv_endIndex = timeStepsArray.count - 1
        
        autoZoomCheckBox.state = NSOnState
        repeatPlayButton.state = NSOnState
        speedSlider.doubleValue
            = speedSlider.minValue + ((speedSlider.maxValue - speedSlider.minValue) / 2.0)
        
        priv_adjustAndUpdateControls()
    }
    
    
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_isPlaying = false
    
    fileprivate var priv_beginIndex = 0
    fileprivate var priv_currentSelectionIndex = 0
    fileprivate var priv_endIndex = 0
    
    
    fileprivate var priv_isBlockingRecursiveUpdate = false
    fileprivate var priv_coordinator: DetailsCoordinator? = nil
    fileprivate var priv_didClose = false
    
    // Max delay is 1/4 second
    fileprivate var priv_maxDelayNanoseconds: Int64 = 1000000000/4
    fileprivate var priv_delayNanoseconds: Int64 = 0
    
    // Time steps to skip to speed up play faster than no-delay will provide.
    //
    fileprivate var priv_speedSkip: Int = 0
    fileprivate var priv_maxSpeedSkipProportionOfSteps: Double = 0.005
    
    
    // MARK: *Private* Methods
    
    fileprivate func priv_select(_ currentIndex: Int) {
        assert(!priv_didClose)
        assert(currentIndex >= 0)
        assert(currentIndex < timeStepsArray.count)
        
        priv_currentSelectionIndex = currentIndex
        priv_adjustAndUpdateControls()
        
        priv_isBlockingRecursiveUpdate = true
        coordinator.didSelect(self, selectedTimeStepIndex: priv_currentSelectionIndex)
        priv_isBlockingRecursiveUpdate = false
        
    } // end priv_select
    
    
    
    
    fileprivate func priv_adjustAndUpdateControls() -> Void {
        assert(!priv_didClose)
        
        let steps = coordinator.timeStepsArray
        let maxStepIndex = steps.count - 1
        
        if priv_endIndex > maxStepIndex {
            priv_endIndex = maxStepIndex
        }
        if priv_currentSelectionIndex > priv_endIndex {
            priv_currentSelectionIndex = priv_endIndex
        }
        if priv_currentSelectionIndex < priv_beginIndex {
            priv_currentSelectionIndex = priv_beginIndex
        }
        
        stepScrubber.minValue = Double(priv_beginIndex)
        stepScrubber.maxValue = Double(priv_endIndex)
        stepScrubber.integerValue = priv_currentSelectionIndex
        
        let beginStep = steps[priv_beginIndex]
        let currentStep = steps[priv_currentSelectionIndex]
        let endStep = steps[priv_endIndex]
        
        beginTrialField.integerValue = Int(beginStep.trialNumber)
        beginStepField.integerValue = Int(beginStep.trialStepNumber)
        
        currentTrialField.integerValue = Int(currentStep.trialNumber)
        currentStepField.integerValue = Int(currentStep.trialStepNumber)
        
        endTrialField.integerValue = Int(endStep.trialNumber)
        endStepField.integerValue = Int(endStep.trialStepNumber)
        
    } // end priv_adjustAndUpdateControls
    
    
} // end class TimeStepPlayerController


