//
//  SessionCreationViewController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 1/12/17.
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

import Cocoa

import BASimulationFoundation
import BASelectionistNeuralNetwork



class SessionCreationViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    typealias OnCompletionCallback = () -> Void
    
    
    @IBOutlet weak var sessionCountField: NSTextField!
    
    @IBOutlet weak var sessionsTableView: NSTableView!
    
    @IBOutlet weak var addSessionButton: NSButton!
    
    @IBAction func addSessionAction(_ sender: Any) {
        priv_runTrialLooper()
    }
    
    // MARK: Data

    var onCompletion: OnCompletionCallback!
    
    var logger = AppDelegate.sharedInstance().logger
    
    
    var privateManagedObjectContext: NSManagedObjectContext {
        return AppDelegate.sharedInstance().coreDataEnvironment.privateManagedObjectContext
    }
    
    
    
    
    // MARK: NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionsTableView.delegate = self
        sessionsTableView.dataSource = self
        
        
    } // end viewDidLoad
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        assert(onCompletion != nil)
        
        startSession()
    }
    
    
    
    // MARK: NSTableViewDelegate
    
    
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        
        assert(tableColumn != nil)
        assert(row < priv_runList.count)
        
        var indicator: NSProgressIndicator!
        
        indicator = tableView.make(withIdentifier: tableColumn!.identifier,
                              owner: self) as? NSProgressIndicator
        
        if indicator == nil {
            indicator = NSProgressIndicator()
            indicator.isIndeterminate = false
        }
        
        let sessionRunner = priv_runList[row]
        let maxTrials: Double = Double(sessionRunner.totalTrials)
        let currentTrial: Double = Double(sessionRunner.trialNumber)
        
        indicator.minValue = 0.0
        indicator.maxValue = maxTrials
        indicator.doubleValue = currentTrial

        return indicator
        
    } // end view for table column and row
    
    
    
    
    
    
    // MARK: NSTableViewDataSource
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return priv_runList.count
    }
    
    
    
    // MARK: Session Creation
    
    
    func startSession() -> Void {
        
        priv_runTrialLooper()
        
    } // end startSession
    
    
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_runList = [TrialsLooper]()
    
    
    
    // MARK: *Private* Methods
    
    
    fileprivate func priv_runTrialLooper() -> Void {
        
        let organism = Organism(identifier: Identifier(idString: "WhiteCarneaux_3151"))
        let sessionRunner = TrialsLooper(organism: organism, logger: logger.clone())
        
        priv_runList.append(sessionRunner)
        sessionCountField.intValue = Int32(priv_runList.count)
        
        
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        
        let userInterfaceQueue = DispatchQueue.main
        
        queue.async {
            sessionRunner.runTrials() {
                (sessionRunner: TrialsLooper) -> Void in
                userInterfaceQueue.async {
                    self.priv_sessionProgress(sessionRunner: sessionRunner)
                }
            }
            
            // Perform the data collection and save on Core Data's private
            // queue in the background. Note that upon completion of the
            // save(), Core Data will issue a NSManagedObjectContextDidSaveNotification,
            // which we use to force synch of the public context used by
            // the table view.
            //
            let context = self.privateManagedObjectContext
            context.perform {
                do {
                    try sessionRunner.saveSessionData(context)
                    
                } catch {
                    fatalError("Failure to save session data: \(error)")
                }
            }
            
            userInterfaceQueue.async {
                self.priv_sessionProgress(sessionRunner: sessionRunner)
            }
        }
        
        sessionsTableView.reloadData()
        
    } // end priv_runTrialLooper
    
    
    
    fileprivate func priv_sessionProgress(sessionRunner: TrialsLooper) -> Void {
        
        var rowIndex: Int = NSNotFound
        for ix in 0..<priv_runList.count {
            let candidate = priv_runList[ix]
            if candidate === sessionRunner {
                rowIndex = ix
                break
            }
        }
        
        // May get called more than once after the session finishes running.
        // The first time removes it from the run list and the table.
        //
        guard rowIndex != NSNotFound else { return }
        
        let rowIndexes = IndexSet([rowIndex])
        let columnIndexes = IndexSet([0])
        
        
        if sessionRunner.isRunComplete {
            priv_runList.remove(at: rowIndex)
            sessionCountField.intValue = Int32(priv_runList.count)
            sessionsTableView.removeRows(at: rowIndexes,
                                         withAnimation: NSTableViewAnimationOptions.effectFade)
            if priv_runList.isEmpty {
                onCompletion()
            }
            return

        } else {
            sessionsTableView.reloadData(forRowIndexes: rowIndexes,
                                         columnIndexes: columnIndexes)
        }
        
    } // end priv_sessionProgress
    
    
    
    
    
} // end SessionCreationViewController
