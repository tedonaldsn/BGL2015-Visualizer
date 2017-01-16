//
//  SessionsViewController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 4/17/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa

import BASimulationFoundation
import BASelectionistNeuralNetwork



class SessionsViewController: NSViewController, NSTableViewDelegate {
    
    struct SegueKey {
        static let NewSessionWindowSegue = "NewSessionWindowSegue"
    }

    
    var windowController: SessionsWindowController!
    
    
    var loggerViewController: LoggerViewController!
    
    
    // MARK: Outlets and Actions
    
    @IBOutlet var sessionArrayController: NSArrayController!
    
    @IBOutlet weak var sessionTableView: NSTableView!
    
    
    @IBAction func selectRowAction(_ sender: AnyObject) {
        logger.logTrace("selectRowAction - does nothing")
    }
    
    
    @IBAction func sessionRowAction(_ sender: AnyObject) {
        showDetailsForSelectedSessions()
    }

    
    
    
    
    // MARK: Parent Window Toolbar
    //
    // Cannot seem to reliably connect toolbar items to actions/outlets in
    // the window's content view, but can in the window controller. At least
    // that is the case within Interface Builder.
    //
    var toolbar: NSToolbar {
        return windowController.window!.toolbar!
    }
    
    
    var createSessionButton: NSToolbarItem {
        return windowController.createSessionButton
    }
    func createSessionAction(_ sender: Any) {
        createSession()
    }
    
    
    var deleteSessionsButton: NSToolbarItem {
        return windowController.deleteSessionsButton
    }
    func deleteSessionsAction(_ sender: AnyObject) {
        deleteSelectedSessions()
    }
    
    
    var sessionDetailsButton: NSToolbarItem {
        return windowController.sessionDetailsButton
    }
    func sessionDetailsAction(_ sender: AnyObject) {
        showDetailsForSelectedSessions()
    }
    
    
    // MARK: Data
    
    var logger = AppDelegate.sharedInstance().logger
    
    var coreDataEnvironment: DataEnvironment {
        return AppDelegate.sharedInstance().coreDataEnvironment
    }
    
    var managedObjectContext: NSManagedObjectContext {
        return coreDataEnvironment.managedObjectContext
    }
    
    
    
    
    // MARK: ViewController Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadSessionTableView()
        
        let notifier = NotificationCenter.default
        
        notifier.addObserver(self,
                             selector: #selector(otherContextDidSave),
                             name: NSNotification.Name.NSManagedObjectContextDidSave,
                             object: nil)
        
        notifier.addObserver(self,
                             selector: #selector(sessionDetailWindowWillClose),
                             name: NSNotification.Name.NSWindowWillClose,
                             object: nil)
        
    } // end viewDidLoad
    

    
    
    override func finalize() {
    
        let notifier = NotificationCenter.default
        notifier.removeObserver(self)
        
        super.viewWillDisappear()
    }
    
    
    // MARK: UI Refresh
    
    
    
    func reloadSessionTableView() {
        sessionTableView.reloadData()
    }
    
    
    
    func refreshToolbarItems() {
        
        // Only way I can find to disable a toolbar item is to invalidate it.
        // One way to invalidate it is to nil out its action. Then restore
        // the action to re-enable the button
        
        if priv_sessionDetailsButtonAction == nil {
            priv_sessionDetailsButtonAction = sessionDetailsButton.action
        }
        
        let selectedRowCount = sessionTableView.selectedRowIndexes.count

        if selectedRowCount > 0 {
            deleteSessionsButton.action = #selector(deleteSessionsAction)
            if let action = priv_sessionDetailsButtonAction {
                sessionDetailsButton.action = action
            }
            
        } else {
            deleteSessionsButton.action = nil
            sessionDetailsButton.action = nil
        }
        
        toolbar.validateVisibleItems()
        
    } // end refreshToolbarItems
    
    fileprivate var priv_sessionDetailsButtonAction: Selector? = nil
    
    
    
    // MARK: NSTableViewDelegate
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        logger.logTrace("tableViewSelectionDidChange")
        refreshToolbarItems()
    }
    
    
    /*
    func tableView(_ tableView: NSTableView,
                   shouldSelectRow row: Int) -> Bool{
        return true
    }
    */
    
    
    // MARK: Session Generation
    
    
    // Notification that the private managed object context has completed a
    // save (issued automatically by Core Data). We need to tell the public
    // managed object context that there is new data, or it will not be
    // displayed by the table view reload.
    //
    func otherContextDidSave(_ didSaveNotification: Notification) -> Void {
        assert(didSaveNotification.name == NSNotification.Name.NSManagedObjectContextDidSave)
        
        let context: NSManagedObjectContext = (didSaveNotification.object as? NSManagedObjectContext)!
        
        if context.persistentStoreCoordinator === managedObjectContext.persistentStoreCoordinator {
            
            // Notice that waitUntilDone is true. If false, the reload of the
            // table view causes CoreAnimation errors.
            //
            managedObjectContext.performSelector(
                onMainThread: #selector(NSManagedObjectContext.mergeChanges(fromContextDidSave:)),
                with:didSaveNotification,
                waitUntilDone: false
            )
        }

    } // end otherContextDidSave
    
    
    

    
    
    
    // MARK: Session Actions
    
    
    func selectedSessions() -> [Session] {
        let rawList: [Any] = sessionArrayController.selectedObjects!
        
        let sessionList = rawList.map() {
            (anObject: Any) -> Session in (anObject as? Session)!
        }
        
        return sessionList
    }

    
    func showDetailsForSelectedSessions() {
        assert(priv_inputQueue.isEmpty)
        assert(priv_outputQueue.isEmpty)
        
        logger.logTrace("showDetailsForSelectedSessions")
        
        let selections = selectedSessions()
        
        for selection in selections {
            let uuid = selection.uuid
            
            // Only open a window for the session if there is not already
            // one open for it. If the user is requesting details for a session
            // that is already displayed, then bring the window to the fore
            // so that the user can see it.
            //
            let sessionWindow = priv_detailWindows[uuid!]
            if sessionWindow == nil {
                priv_inputQueue.append(selection)
                
            } else {
                sessionWindow!.makeKeyAndOrderFront(self)
                sessionWindow!.orderedIndex = 0
            }
        }
        
        // Fire off a segue for each session for which we will open a window.
        // Note that additional processing is done in the prepareForSegue()
        // method, below, after the destination window and controllers have
        // been created.
        //
        for _ in 0..<priv_inputQueue.count {
            performSegue(withIdentifier: SegueKey.NewSessionWindowSegue, sender: self)
        }
        
    } // end showDetailsForSelectedSessions
    
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {

        if segue.identifier == SegueKey.NewSessionWindowSegue {
            assert(!priv_inputQueue.isEmpty)
            assert(priv_outputQueue.isEmpty)
            
            let session = priv_inputQueue.remove(at: 0)
            
            let destinationWindowController = (segue.destinationController as? NSWindowController)!
            
            let destination = (destinationWindowController.contentViewController as? SessionViewController)!
            destination.session = session
            
            let window = destinationWindowController.window
            priv_cascadeLocation = window!.cascadeTopLeft(from: priv_cascadeLocation)
            
            // Record the window to prevent opening additional windows for the
            // same session.
            //
            let uuid = session.uuid!
            priv_detailWindows[uuid] = window
        }
        
    } // end prepareForSegue
    
    
    
    
    // When a session detail window closes remove it from our list of
    // such windows. This will permit the user to open a new window form the
    // session.
    //
    // Note that we will get window close notifications for windows other
    // than the session detail windows, so we must check the window.
    //
    func sessionDetailWindowWillClose(_ willCloseNotification: Notification) -> Void {
        assert(willCloseNotification.name == NSNotification.Name.NSWindowWillClose)
        
        if let window = willCloseNotification.object as? NSWindow,
            let controller = window.contentViewController as? SessionViewController,
            let uuid = controller.session.uuid {
            
            priv_detailWindows[uuid] = nil
        }
        
    } // end sessionDetailWindowWillClose
    
    
    
    
    
    // MARK: Create Sessions
    
    
    func createSession() -> Void {
        
        let sessionCreationController = SessionCreationViewController(nibName: nil, bundle: nil)
        priv_creationSheet = NSWindow(contentViewController: sessionCreationController!)
        let parentWindow = self.windowController.window!
        
        sessionCreationController!.onCompletion = {
            () -> Void in
            self.priv_endCreationSheet()
        }
        
        // Completion handler gets called after endSheet() is called.
        //
        parentWindow.beginSheet(priv_creationSheet!, completionHandler: nil)
        
        // parentWindow.endSheet(sheetWindow)
        
    } // end createSession
    
    fileprivate var priv_creationSheet: NSWindow? = nil
    
    fileprivate func priv_endCreationSheet() -> Void {
        if let sheetWindow = priv_creationSheet {
            let parentWindow = self.windowController.window!
            parentWindow.endSheet(sheetWindow)
        }
        priv_creationSheet = nil
    }
    
    
    
    
    
    
    // MARK: Delete Sessions
    //
    // Delete sessions selected in the sessionTableView. Any detail window
    // for a selected session will be closed before deletion of the session.
    //
    func deleteSelectedSessions() {
        let sessionsToDelete: [Session] = selectedSessions()
        for session in sessionsToDelete {
            
            let uuid: String = session.uuid!
            if let sessionWindow = priv_detailWindows[uuid] {
                sessionWindow.performClose(self)
                priv_detailWindows[uuid] = nil
            }
        }

        let sessionDeletionController = SessionDeletionController(nibName: nil, bundle: nil)
        priv_deletionSheet = NSWindow(contentViewController: sessionDeletionController!)
        let parentWindow = self.windowController.window!

        sessionDeletionController!.managedObjectContext = managedObjectContext
        sessionDeletionController!.sessionsToDelete = sessionsToDelete
        sessionDeletionController!.onCompletion = {
            () -> Void in
            self.priv_endDeletionsheet()
        }
        
        // Completion handler gets called after endSheet() is called.
        //
        parentWindow.beginSheet(priv_deletionSheet!, completionHandler: nil)
        
        // parentWindow.endSheet(sheetWindow)
        
    } // end deleteSelectedSessions
    
    fileprivate var priv_deletionSheet: NSWindow? = nil
    
    fileprivate func priv_endDeletionsheet() -> Void {
        if let sheetWindow = priv_deletionSheet {
            let parentWindow = self.windowController.window!
            parentWindow.endSheet(sheetWindow)
        }
        priv_deletionSheet = nil
    }
    
    
    
    
    // MARK: *Private*

    
    
    // Session processing queues.
    //
    // Session processing functionality such as deletion or opening of detail
    // windows cannot readily be handled in single functions. Rather, multiple
    // functions must share information through these private vars.
    //
    //
    fileprivate var priv_inputQueue = [Session]()
    fileprivate var priv_outputQueue = [Session]()
    
    // Currently open session detail windows, keyed by session.uuid. Purpose
    // is to prevent opening multiple detail windows for the same session.
    //
    fileprivate var priv_detailWindows = [String: NSWindow]()
    
    // Used for displaying windows in cascading locations on open.
    //
    fileprivate var priv_cascadeLocation: NSPoint = NSMakePoint(0.0, 0.0)
    
    
    
} // end class SessionsViewController

