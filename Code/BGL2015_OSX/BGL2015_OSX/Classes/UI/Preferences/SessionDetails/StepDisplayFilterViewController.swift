//
//  StepDisplayFilterViewController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 6/22/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa



// Class StepDisplayFilterViewController
//
// Allow user to select which phases of the experiment for which to display 
// trials in session details: training and/or choice phase.
//
// Allow user to select which time steps within trials to display: the non-Sr
// time steps leading up to the final Sr step; the Sr step; and/or the
// intertrial interval time step.
//
// This controller will not permit empty selections. If both phases are turned
// off, then both phases are turned back on. If all steps are turned off, then
// all steps are turned back on.
//
// On every change NSUserDefaults are updated and a notification is posted
// so that observers can update their displays. Key: PreferenceKey.stepFilter
//
class StepDisplayFilterViewController: NSViewController {
    
    // MARK: Phases Outlets/Actions
    
    @IBOutlet weak var trainingPhaseButton: NSButton!
    @IBAction func trainingPhaseAction(_ sender: AnyObject) {
        updateAndSave()
    }
    
    @IBOutlet weak var choicePhaseButton: NSButton!
    @IBAction func choicePhaseAction(_ sender: AnyObject) {
        updateAndSave()
    }
    
    // MARK: Time Steps Outlets/Actions
    
    @IBOutlet weak var nonSrStepsButton: NSButton!
    @IBAction func nonSrStepsAction(_ sender: AnyObject) {
        updateAndSave()
    }
    
    @IBOutlet weak var srStepButton: NSButton!
    @IBAction func srStepAction(_ sender: AnyObject) {
        updateAndSave()
    }
    
    @IBOutlet weak var intertrialIntervalButton: NSButton!
    @IBAction func intertrialIntervalAction(_ sender: AnyObject) {
        updateAndSave()
    }
    
    
    // MARK: General Outlets/Actions
    
    @IBOutlet weak var resetButton: NSButton!
    @IBAction func resetAction(_ sender: AnyObject) {
        settings = StepDisplayFilterSettings.defaultSettings()
        updateButtons()
        saveDefaults()
    }
    
    
    // MARK: Data
    
    var settings: StepDisplayFilterSettings!
    
    
    
    // MARK: Initialization
    
    
    // MARK: NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer!.borderWidth = 1.0
        view.layer!.cornerRadius = 5.0
        
        let prefs = UserDefaults.standard
        let settingsArchive = prefs.data(forKey: PreferenceKey.stepFilter)!
        settings = (NSKeyedUnarchiver.unarchiveObject(with: settingsArchive) as? StepDisplayFilterSettings)!

        updateButtons()
    }
    
    
    // MARK: Update
    
    func updateAndSave() -> Void {
        updateSettings()
        updateButtons()
        saveDefaults()
    }
    
    func updateSettings() -> Void {
        settings.isTrainingPhase = trainingPhaseButton.state == NSOnState
        settings.isChoicePhase = choicePhaseButton.state == NSOnState
        
        settings.isNonSrTimeSteps = nonSrStepsButton.state == NSOnState
        settings.isSrTimeStep = srStepButton.state == NSOnState
        settings.isIntertrialTimeStep = intertrialIntervalButton.state == NSOnState
        
        if !settings.isTrainingPhase && !settings.isChoicePhase {
            settings.setDefaultPhases()
        }
        
        if !settings.isNonSrTimeSteps && !settings.isSrTimeStep && !settings.isIntertrialTimeStep {
            settings.setDefaultSteps()
        }

    } // end update
    
    
    func updateButtons() -> Void {
        trainingPhaseButton.state = settings.isTrainingPhase ? NSOnState : NSOffState
        choicePhaseButton.state = settings.isChoicePhase ? NSOnState : NSOffState
        
        nonSrStepsButton.state = settings.isNonSrTimeSteps ? NSOnState : NSOffState
        srStepButton.state = settings.isSrTimeStep ? NSOnState : NSOffState
        intertrialIntervalButton.state = settings.isIntertrialTimeStep ? NSOnState : NSOffState
        
        resetButton.isEnabled = !settings.isDefault
    }
    
    
    // MARK: User Defaults
    
    func saveDefaults() {
        
        let archive = NSKeyedArchiver.archivedData(withRootObject: self.settings)
        let prefs = UserDefaults.standard
        prefs.set(archive, forKey: PreferenceKey.stepFilter)
        
        let notifier = NotificationCenter.default
        
        notifier.post(name: NotificationKey.stepFilterChanged, object: settings)
        
    } // end saveDefaults
    
    // MARK: *Private* 
    
    
    
} // end class StepDisplayFilterViewController




