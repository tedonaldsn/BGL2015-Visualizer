//
//  SessionDeletionController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 1/4/17.
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

class SessionDeletionController: NSViewController {
    
    typealias OnCompletionCallback = () -> Void

    @IBOutlet weak var progressTextField: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        cancelRequested = true
        cancel()
    }
    
    var managedObjectContext: NSManagedObjectContext!
    var sessionsToDelete: [Session]!
    
    var cancelRequested: Bool = false
    var onCompletion: OnCompletionCallback!
    
    let slowCommitWarningThreshold: Int = 8
    var sessionCount: Int = 0
    var warnAboutSlowCommit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        assert(progressTextField != nil)
        assert(progressIndicator != nil)
        
        progressIndicator.minValue = 0
        progressIndicator.maxValue = Double(sessionsToDelete.count + 1)
        progressIndicator.doubleValue = 0
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        assert(sessionsToDelete != nil)
        assert(!sessionsToDelete.isEmpty)
        assert(managedObjectContext != nil)
        assert(onCompletion != nil)
        
        sessionCount = sessionsToDelete.count
        warnAboutSlowCommit = sessionCount >= slowCommitWarningThreshold
        
        delete()
    }
    
    
    func delete() -> Void {
        assert(!sessionsToDelete.isEmpty)
        
        guard !cancelRequested else { return }
        
        let session = sessionsToDelete.remove(at: 0)
        progressTextField.stringValue = session.startedAtDate
        progressIndicator.increment(by: 1)
        
        delete(session: session)
    }
    
    func delete(session: Session) -> Void {
        guard !cancelRequested else { return }
        
        managedObjectContext.delete(session)
        
        if !sessionsToDelete.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.delete()
            }
        } else {
            if !warnAboutSlowCommit {
                progressTextField.stringValue = "committing deletions ..."
                
            } else {
                progressTextField.stringValue = "committing \(sessionCount) deletions (please wait) ..."
            }
            
            
            progressIndicator.increment(by: 1)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.save()
            }
        }
    }
    
    func save() -> Void {
        guard !cancelRequested else { return }
        
        do {
            try managedObjectContext.save()
            
        } catch let error as NSError {
            AppDelegate.sharedInstance().handleError(error)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.completed()
        }
    }
    
    func cancel() -> Void {
        assert(cancelRequested)
        
        progressTextField.stringValue = "rolling back deletions ..."
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.rollback()
        }
    }
    
    func rollback() -> Void {
        assert(cancelRequested)
        managedObjectContext.rollback()
        onCompletion()
    }
    
    
    func completed() -> Void {
        guard !cancelRequested else { return }
        
        onCompletion()
    }
    
} // end class SessionDeletionController


