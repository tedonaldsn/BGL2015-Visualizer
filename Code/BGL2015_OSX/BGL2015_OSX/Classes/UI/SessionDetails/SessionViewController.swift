//
//  SessionViewController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 6/4/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation



class SessionViewController: NSViewController, NSWindowDelegate, NSTableViewDelegate, NSTextFieldDelegate, DetailsCoordinator {
    
    class DummyDisplay: DetailsDisplay {
        let coordinator: DetailsCoordinator
        init(coordinator: DetailsCoordinator) {
            self.coordinator = coordinator
        }
        func willClose() {}
        func reloadData() {}
        func synchronizeScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) {}
        func synchronizeZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) {}
        func synchronizeZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {}
        func synchronizeSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) {}
    }
    
    
    var dummyDisplay: DummyDisplay {
        if priv_dummyDisplay == nil {
            priv_dummyDisplay = DummyDisplay(coordinator: self)
        }
        return priv_dummyDisplay!
    }
    
    
    // MARK: Outlets and Actions
    
    @IBOutlet weak var sessionGraphView: NSView!
    
    @IBOutlet weak var timeStepTableView: NSView!
    
    @IBOutlet weak var figure1View: NSView!
    
    @IBOutlet weak var timeStepPlayerControlsView: NSView!
    
    @IBOutlet var timeStepsArrayController: NSArrayController!
    
    @IBOutlet weak var s1m1weight: NSTextField!
    @IBOutlet weak var s2m2weight: NSTextField!
    @IBOutlet weak var m1activation: NSTextField!
    @IBOutlet weak var m2activation: NSTextField!
    @IBOutlet weak var r1count: NSTextField!
    @IBOutlet weak var r2count: NSTextField!
    
        
    
    // MARK: DetailsCoordinator
    

    var timeSteps: NSArrayController {
        assert(timeStepsArrayController != nil)
        return timeStepsArrayController!
    }
    

    var displays: [DetailsDisplay] { return priv_displays }
    
    
    var timeStepPlayerController: TimeStepPlayerController!
    
    
    // MARK: Time Step Predicates
    
    let trainingTrialsPredicate = NSPredicate(format: "trialNumber <= %d",
                                              TrialsLooper.totalTrainingTrials)
    
    let choiceTrialsPredicate = NSPredicate(format: "trialNumber > %d",
                                            TrialsLooper.totalTrainingTrials)
    
    let intertrialStepsPredicate = NSPredicate(format: "trialStepNumber >= %d && trialStepNumber < %d",
                                               TrialsLooper.firstIntertrialStepIndex,
                                               TrialsLooper.firstIntertrialStepIndex + TrialsLooper.intertrialStepsPerTrial)
    
    let nonSrStepsPredicate = NSPredicate(format: "trialStepNumber >= %d && trialStepNumber < %d",
                                          TrialsLooper.firstNonSrTimeStepIndex,
                                          TrialsLooper.firstNonSrTimeStepIndex + TrialsLooper.nonSrTimeStepsPerTrial)
    
    let srStepsPredicate = NSPredicate(format: "trialStepNumber >= %d && trialStepNumber < %d",
                                       TrialsLooper.firstSrTimeStepIndex,
                                       TrialsLooper.firstSrTimeStepIndex + TrialsLooper.srTimeStepsPerTrial)
    
    
    // MARK: Data
    
    var logger = AppDelegate.sharedInstance().logger
    
    var coreDataEnvironment: DataEnvironment {
        if priv_coreDataEnvironment == nil {
            priv_coreDataEnvironment = AppDelegate.sharedInstance().coreDataEnvironment
        }
        return priv_coreDataEnvironment!
    }
    
    var managedObjectContext: NSManagedObjectContext {
        return coreDataEnvironment.managedObjectContext
    }
    
    var session: Session!
    
    var sessionFetchPredicate: NSPredicate!
    
    

    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    
    // MARK: NSViewController Overrides
    
    override func loadView() {
        super.loadView()
        
        assert(sessionGraphView != nil)
        assert(s1m1weight != nil)
        assert(s2m2weight != nil)
        assert(m1activation != nil)
        assert(m2activation != nil)
        
        // Set programmatically after loading.
        // assert(session != nil)
    }
    
    
    override func viewDidLoad() {
        
    } // end loadView
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        assert(session != nil)
        
        self.view.window!.delegate = self
        
        self.view.window!.title = "Session @ \(session.startedAtDate)"
        
        s1m1weight.doubleValue = session.smPrimePrime1Weight
        s2m2weight.doubleValue = session.smPrimePrime2Weight
        m1activation.doubleValue = session.mPrime1Activation
        m2activation.doubleValue = session.mPrime2Activation
        r1count.integerValue = Int(session.r1Count)
        r2count.integerValue = Int(session.r2Count)
        
        if sessionFetchPredicate == nil {
            sessionFetchPredicate = NSPredicate(format: "session = %@", session)
            timeStepsArrayController.fetchPredicate = sessionFetchPredicate
            do {
                try timeStepsArrayController.fetch(with: nil, merge: false)
                
            } catch let error as NSError {
                AppDelegate.sharedInstance().handleError(error)
            }
        }
        
        let sortOnTrial = NSSortDescriptor(key: "trialNumber", ascending: true)
        let sortOnStep = NSSortDescriptor(key: "trialStepNumber", ascending: true)
        timeStepsArrayController.sortDescriptors = [ sortOnTrial, sortOnStep ]
        
        let prefs = UserDefaults.standard
        let settingsArchive = prefs.data(forKey: PreferenceKey.stepFilter)!
        priv_timeStepDisplayFilter =
            (NSKeyedUnarchiver.unarchiveObject(with: settingsArchive) as? StepDisplayFilterSettings)!
        
        // Replace table view placeholder with custom view
        //
        let timeStepTableViewController = (TimeStepTableViewController(nibName: nil, bundle: nil))!
        priv_displays.append(timeStepTableViewController)
        timeStepTableViewController.coordinator = self
        timeStepTableViewController.view.frame = timeStepTableView.frame
        view.replaceSubview(timeStepTableView, with: timeStepTableViewController.view)
        
        // Replace graph view placeholder with custom view
        //
        let timeStepGraphController = (TimeStepGraphController(nibName: nil, bundle: nil))!
        timeStepGraphController.coordinator = self
        priv_displays.append(timeStepGraphController)
        timeStepGraphController.view.frame = sessionGraphView.frame
        view.replaceSubview(sessionGraphView, with: timeStepGraphController.view)

        
        // Replace network figure section placeholder with custom view
        //
        let figureController = NetworkViewController(nibName: nil, bundle: nil)!
        figureController.coordinator = self
        priv_displays.append(figureController)
        figureController.view.frame = figure1View.frame
        view.replaceSubview(figure1View, with: figureController.view)
        
        
        timeStepPlayerController = TimeStepPlayerController(nibName: nil, bundle: nil)!
        timeStepPlayerController.coordinator = self
        priv_displays.append(timeStepPlayerController)
        timeStepPlayerController.view.frame = timeStepPlayerControlsView.frame
        view.replaceSubview(timeStepPlayerControlsView,
                            with: timeStepPlayerController.view)
        
        
        // Set timestep selection
        //
        installNewDetailFilteringSettings(priv_timeStepDisplayFilter)
        
                
        let notifier = NotificationCenter.default
        
        notifier.addObserver(self,
                             selector: #selector(stepFilterChanged),
                             name: NotificationKey.stepFilterChanged,
                             object: nil)
        
    } // end viewWillAppear
    
    
    
    
    
    
    override func viewDidAppear() {
        super.viewDidAppear()

        didSelect(dummyDisplay, selectedTimeStepIndex: 0)
        didScroll(dummyDisplay, toTimeStepRange: NSMakeRange(0, 1))
    }
    
    override func finalize() {
        let notifier = NotificationCenter.default
        notifier.removeObserver(self)
    }
    
    
    
    // MARK: NSWindowDelegate
    
    func windowShouldClose(_ sender: Any) -> Bool {
        self.willClose()
        return true
    }
    
    
    
    // MARK: NSTextFieldDelegate
    
    
    
    
    // MARK: Step Filtering
    
    func stepFilterChanged(_ filterChangeNotification: NSNotification) -> Void {
        assert(filterChangeNotification.name == NotificationKey.stepFilterChanged)
        
        let settings = (filterChangeNotification.object as? StepDisplayFilterSettings)!
        
        if settings != priv_timeStepDisplayFilter {
            
            installNewDetailFilteringSettings(settings)
            
            priv_timeStepDisplayFilter = settings.clone()
            
            for display in priv_displays {
                display.reloadData()
            }
            
            didZoom(dummyDisplay, percentOfRangeToDisplay: 1.0)
            didSelect(dummyDisplay, selectedTimeStepIndex: 0)
        }
    } // end stepFilterChanged
    
    
    
    func installNewDetailFilteringSettings(_ settings: StepDisplayFilterSettings) {
        
        if settings.isDefault {
            installNewFilterPredicates(nil, stepsPredicate: nil)
            
        } else {
            var phasesPredicate: NSPredicate? = nil
            var stepsPredicate: NSPredicate? = nil
            
            if !settings.isPhasesDefault {
                if settings.isTrainingPhase {
                    phasesPredicate = trainingTrialsPredicate
                } else {
                    phasesPredicate = choiceTrialsPredicate
                }
            }
            if !settings.isStepsDefault {
                var predicatesToOr = [NSPredicate]()
                if settings.isNonSrTimeSteps {
                    predicatesToOr.append(nonSrStepsPredicate)
                }
                if settings.isSrTimeStep {
                    predicatesToOr.append(srStepsPredicate)
                }
                if settings.isIntertrialTimeStep {
                    predicatesToOr.append(intertrialStepsPredicate)
                }
                
                if predicatesToOr.count == 1 {
                    stepsPredicate = predicatesToOr[0]
                } else {
                    stepsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicatesToOr)
                }
            }
            installNewFilterPredicates(phasesPredicate, stepsPredicate: stepsPredicate)
        }
        
        priv_timeStepDisplayFilter = settings
        
    } // end stepFilterChanged
    
    
    
    func installNewFilterPredicates(_ phasesPredicate: NSPredicate?, stepsPredicate: NSPredicate?) -> Void {
        
        var finalPredicate: NSPredicate!
        
        var predicatesToAnd = [NSPredicate]()
        
        if let phasesPredicate = phasesPredicate {
            predicatesToAnd.append(phasesPredicate)
        }
        if let stepsPredicate = stepsPredicate {
            predicatesToAnd.append(stepsPredicate)
        }
        
        
        if !predicatesToAnd.isEmpty {
            //
            // And phases, steps, and session specifier ...
            //
            predicatesToAnd.append(sessionFetchPredicate)
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicatesToAnd)
            
        } else {
            finalPredicate = sessionFetchPredicate
        }
        
  
        timeStepsArrayController.fetchPredicate = finalPredicate
        do {
            logger.logDebug("Time steps fetch predicate: \"\(timeStepsArrayController.fetchPredicate?.predicateFormat)\"")
            
            try timeStepsArrayController.fetch(with: nil, merge: false)
            
        } catch let error as NSError {
            AppDelegate.sharedInstance().handleError(error)
        }
        
        
    } // end installNewFilterPredicate
    
    
    
    
    // MARK: Playback
    

    func setPlaybackRange(beginIndex: UInt,
                          cursorIndex: UInt,
                          endIndex: UInt) -> Void {

        timeStepPlayerController.setPlaybackRange(beginIndex: beginIndex,
                                                  cursorIndex: cursorIndex,
                                                  endIndex: endIndex)
    }
    
    
    // MARK: Select
    
    func selectTimeStep(_ trialNumber: Int, stepIndex: Int) -> Void {
        
        let selectedTimeStepIndex = indexOfClosestStep(trialNumber, stepIndex: stepIndex)
        
        if selectedTimeStepIndex >= 0 {
            didSelect(dummyDisplay, selectedTimeStepIndex: selectedTimeStepIndex)
        }
    }
    
    
    
    
    // MARK: Coordinate

    // Shut down all displays, and remove all of them.
    //
    func willClose() {
        for display in priv_displays {
            display.willClose()
        }
        priv_displays.removeAll()
    }

    func didScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        for display in priv_displays {
            if display !== scrollInitiator {
                display.synchronizeScroll(scrollInitiator, toTimeStepRange: toTimeStepRange)
            }
        }
    }
    
    func didZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void {
        for display in priv_displays {
            if display !== zoomInitiator {
                display.synchronizeZoom(zoomInitiator, percentOfRangeToDisplay: percentOfRangeToDisplay)
            }
        }
    }
    
    func didZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        for display in priv_displays {
            if display !== zoomInitiator {
                display.synchronizeZoom(zoomInitiator, toTimeStepRange: toTimeStepRange)
            }
        }
    }
    
    func didSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void {        
        for display in priv_displays {
            if display !== selectionInitiator {
                display.synchronizeSelect(selectionInitiator, selectedTimeStepIndex: selectedTimeStepIndex)
            }
        }
    }

    
    
    // MARK: *Private*
    

    fileprivate var priv_coreDataEnvironment: DataEnvironment? = nil
    
    fileprivate var priv_displays = [DetailsDisplay]()
    fileprivate var priv_timeStepDisplayFilter: StepDisplayFilterSettings = StepDisplayFilterSettings()
    
    fileprivate var priv_dummyDisplay: DummyDisplay? = nil
    
    
    

    
    
} // end class SessionViewController


