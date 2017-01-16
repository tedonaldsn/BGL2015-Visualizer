//
//  AppDelegate.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 4/17/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import GameplayKit

import BASimulationFoundation
import BASelectionistNeuralNetwork

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    class func sharedInstance() -> AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    struct SegueKey {
        static let showPreferencesSegue = "ShowPreferencesSegue"
    }
    
    
    // MARK: Data

    var preferencesWindow: NSWindow? = nil
    
    var logger = Logger()
    

    
    // MARK: Core Data
    //
    // Moved all the non-UI stuff normally placed in the app delegate by the
    // project creation template to its own class: CoreDataEnvironment. This
    // allows unit testing without the UI/application, and still supports access
    // by the rest of the app via the delegate.
    //
    var applicationName: String {
        return self.coreDataEnvironment.applicationName
    }
    
    var bundleIdentifier: String {
        return self.coreDataEnvironment.bundleIdentifier
    }
    
    var applicationDocumentsDirectory: URL {
        return self.coreDataEnvironment.applicationDocumentsDirectory as URL
    }
    
    var managedObjectModel: NSManagedObjectModel {
        return self.coreDataEnvironment.managedObjectModel
    }
    

    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return self.coreDataEnvironment.persistentStoreCoordinator
    }
    

    var managedObjectContext: NSManagedObjectContext {
        return self.coreDataEnvironment.managedObjectContext
    }
    
    
    var coreDataEnvironment: DataEnvironment {
        if priv_coreDataEnvironment == nil {
            priv_coreDataEnvironment = DataEnvironment(logger: self.logger)
        }
        return priv_coreDataEnvironment!
    }
    
    
    
    // MARK: - Core Data Saving and Undo support
    
    @IBAction func saveAction(_ sender: AnyObject!) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if !managedObjectContext.commitEditing() {
            self.logger.logErrorMessage("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                
            } catch let error as NSError {
                self.handleError(error)
            }
        }
    }
    
    
    
    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if !managedObjectContext.commitEditing() {
            self.logger.logErrorMessage("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !managedObjectContext.hasChanges {
            return .terminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    



    // MARK: NSApplicationDelegate
    
    func applicationWillFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupPreferences()

        
        let notifier = NotificationCenter.default
        notifier.addObserver(self,
                             selector: #selector(AppDelegate.windowNotifications),
                             name: NSNotification.Name.NSWindowWillClose,
                             object: nil)
        
        notifier.addObserver(self,
                             selector: #selector(AppDelegate.windowNotifications),
                             name: NSNotification.Name.NSWindowDidBecomeMain,
                             object: nil)
        
        priv_sessionListWindowAction = sessionListWindowMenuItem.action
        priv_preferencesMenuItemAction = preferencesMenuItem.action
    }
    
    fileprivate var priv_sessionListWindowAction: Selector!
    fileprivate var priv_preferencesMenuItemAction: Selector!
    

    func applicationWillTerminate(_ aNotification: Notification) {
        
        let notifier = NotificationCenter.default
        notifier.removeObserver(self)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // MARK: Menu Manipulation
    
    var preferencesMenuItem: NSMenuItem {
        let menu = NSApplication.shared().menu
        assert(menu != nil)
        let windowSubmenu = menu!.item(withTitle: applicationName)
        assert(windowSubmenu != nil)
        assert(windowSubmenu!.hasSubmenu)
        let item = windowSubmenu!.submenu!.item(withTitle: "Preferences…")
        assert(item != nil)
        return item!
    }
    
    var sessionListWindowMenuItem: NSMenuItem {
        let menu = NSApplication.shared().menu
        assert(menu != nil)
        let windowSubmenu = menu!.item(withTitle: "Window")
        assert(windowSubmenu != nil)
        assert(windowSubmenu!.hasSubmenu)
        let item = windowSubmenu!.submenu!.item(withTitle: "Session List")
        assert(item != nil)
        return item!
    }
    
    func windowNotifications(_ notification: Notification) -> Void {
        assert(notification.name == NSNotification.Name.NSWindowWillClose
            || notification.name == NSNotification.Name.NSWindowDidBecomeMain)
        
        if let window = notification.object as? NSWindow {
            
            if let _ = window.contentViewController as? SessionsViewController {
                if notification.name == NSNotification.Name.NSWindowWillClose {
                    sessionListWindowMenuItem.action = priv_sessionListWindowAction
                } else if notification.name == NSNotification.Name.NSWindowDidBecomeMain {
                    sessionListWindowMenuItem.action = nil
                }
            } else if let _ = window.contentViewController as? PreferencesViewController {
                if notification.name == NSNotification.Name.NSWindowWillClose {
                    preferencesMenuItem.action = priv_preferencesMenuItemAction
                } else if notification.name == NSNotification.Name.NSWindowDidBecomeMain {
                    preferencesMenuItem.action = nil
                }
            }
        }

    } // end windowNotifications
    

    
    // MARK: Setup
    
    func setupPreferences() {
        
        // Note that because default factory settings are provided to NSUserDefaults
        // there are NO checks for nil on values it returns. That is, it is a
        // fatal programmer error if a nil value is returned.
        //
        // These factory settings must be re-established on each run of the 
        // application (i.e., they are not persistent).
        //
        let factorySettings = [
            PreferenceKey.logger
                : NSKeyedArchiver.archivedData(withRootObject: Logger.defaultSettings),
            PreferenceKey.stepFilter
                : NSKeyedArchiver.archivedData(withRootObject: StepDisplayFilterSettings.defaultSettings())
        ]
        
        let prefs = UserDefaults.standard
        prefs.register(defaults: factorySettings)

        // Get logger preferences.
        //
        let loggerSettingsArchive = prefs.data(forKey: PreferenceKey.logger)!
        let loggerSettings =
            (NSKeyedUnarchiver.unarchiveObject(with: loggerSettingsArchive) as? Logger.Settings)!
        logger.settings = loggerSettings
        
    } // end setupPreferences
    
    
    
    // MARK: Error Handling
    
    func handleError(_ error: NSError) -> Void {
        logger.logError(error)
        NSApplication.shared().presentError(error)
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_coreDataEnvironment: DataEnvironment? = nil


} // end AppDelegate

