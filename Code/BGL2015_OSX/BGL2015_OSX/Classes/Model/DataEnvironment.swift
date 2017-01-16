//
//  DataEnvironment.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 5/9/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import CoreData

import BASimulationFoundation



// Class DataEnvironment
//
// Application-wide directories, repositories, etc.
//
// Some (but not all) of this was adapted from an empty app created with
// the "core data" checkoff.
//
final public class DataEnvironment {
    
    public var logger: Logger
    
    
    public lazy var applicationName: String = {
        let bundlePath = Bundle.main.bundlePath
        let appName = FileManager.default.displayName(atPath: bundlePath)
        return appName
    }()
    
    public lazy var bundleIdentifier: String = {
        return Bundle.main.bundleIdentifier!
    }()
    
    // Return URL of where the application documents directory is expected to
    // be. To ensure that it actually exists, call makeApplicationDocumentDirectory()
    // instead.
    //
    public lazy var applicationDocumentsDirectory: URL = {
        let urls =
            FileManager.default.urls(for: .applicationSupportDirectory,
                                                            in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent(self.bundleIdentifier)
    }()
    
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not
        // optional. It is a fatal error for the application not to be able to
        // find and load its model.
        //
        let bundle = Bundle.main
        let appName = "BGL2015_OSX"
        if let modelURL: URL = bundle.url(forResource: appName, withExtension: "momd") {
            if let model = NSManagedObjectModel(contentsOf: modelURL) {
                return model
            }
        }
        preconditionFailure()
    }()
    
    
    // The deletePersistentStores() will cause the coordinator to be recreated
    // next time the coordinator is requested.
    //
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if priv_persistentStoreCoordinator == nil {
            do {
                priv_persistentStoreCoordinator = try self.createPersistenStoreCoordinator()
                
            } catch let error as NSError {
                AppDelegate.sharedInstance().handleError(error)
            }
        }
        return priv_persistentStoreCoordinator!
    }
    fileprivate var priv_persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil
    
    
    public lazy var managedObjectContext: NSManagedObjectContext = {
        //
        // Returns the managed object context for the application (which is
        // already bound to the persistent store coordinator for the application).
        //
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    

    
    public lazy var privateManagedObjectContext: NSManagedObjectContext = {
        //
        // Returns the managed object context for the application (which is
        // already bound to the persistent store coordinator for the application).
        //
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    
    
    
    // MARK: Initialization
    
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    
    // Ensures that the application document directory specific to this
    // application exists and returns the URL.
    //
    // Throws an error if a the directory is missing and cannot be created, or
    // if a non-directory item already exists at the URL path.
    //
    public func makeApplicationDocumentDirectory() throws -> URL {
        let url: URL = applicationDocumentsDirectory
        
        do {
            let properties = try (url as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            
            // If the url points to something that is not a directory, throw
            // an error 'cause we cannot deal with this.
            //
            if !(properties[URLResourceKey.isDirectoryKey]! as AnyObject).boolValue {
                throw ModelError.applicationDocumentDirectoryIsFile(url)
            }
            
        } catch let error as NSError {
            //
            // If the error was just a missing directory, then create the directory.
            // Else, it is an error we cannot handle so just throw it on up
            // the call stack.
            //
            if error.code == NSFileReadNoSuchFileError {
                let fileManager = FileManager.default
                //
                // If we cannot create the directory then something is wrong that
                // we cannot handle. Let any new error propogate on up the call
                // stack
                //
                try fileManager.createDirectory(atPath: url.path,
                                                      withIntermediateDirectories: true,
                                                      attributes: nil)
            } else {
                throw error
            }
        }
        return url
        
    } // end makeApplicationDocumentDirectory
    
    
    
    public func persistentStoreURL() throws -> URL {
        let appDocDir = try makeApplicationDocumentDirectory()
        let url = appDocDir.appendingPathComponent("CocoaAppCD.storedata")
        return url
    }
    
    
    public func createPersistenStoreCoordinator() throws -> NSPersistentStoreCoordinator {
        let url = try persistentStoreURL()
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        //
        // XML store for debug only. NSSQLiteStoreType for normal use.
        //
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                   configurationName: nil,
                                                   at: url,
                                                   options: nil)
        return coordinator
    }

    
    
    // MARK: Convenience Methods
    
    
    public func deletePersistentStores() throws {
        for store in persistentStoreCoordinator.persistentStores {
            try persistentStoreCoordinator.remove(store)
        }
        // This will force creation of a new coordinator and store(s).
        //
        priv_persistentStoreCoordinator = nil
        
        /*
        let url = try persistentStoreURL()
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(url.path!) {
            try fileManager.removeItemAtURL(url)
        }
        */
    }
    
    public func deleteAll(_ entityName: String) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let context = managedObjectContext
        let coordinator = managedObjectContext.persistentStoreCoordinator
        assert(coordinator != nil)
        
        let deleteRequest =  NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try coordinator!.execute(deleteRequest, with: context)

        /*
        let items = try context.fetch(fetchRequest)
        for item in items {
            context.delete(item as! NSManagedObject)
        }
        */
        try context.save()
        
    } // end deleteAll
    
} // end class DataEnvironment

