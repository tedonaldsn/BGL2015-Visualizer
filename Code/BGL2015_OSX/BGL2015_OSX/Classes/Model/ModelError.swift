//
//  ModelError.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 5/9/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation


final public class ModelError {
    
    public class func errorDomain() -> String {
        return "BASimulation.BGL2015_OSX.Model"
    }
    
    // MARK: Error Codes
    
    enum ErrorCodes: Int {
        
        case
        
        applicationDocumentDirectoryIsFile,
        incorrectSessionRecordFetch,
        incorrectChoiceFinalStepFetch
        
    } // end ErrorCodes
    
    
    
    
    fileprivate class func priv_error(_ errorCode: ModelError.ErrorCodes, message: String) -> NSError {
        return NSError(
            domain: ModelError.errorDomain(),
            code: errorCode.rawValue,
            userInfo: [ NSLocalizedDescriptionKey : message ]
        )
    }
    
    
    // MARK: Virtual Constructors
    
    public class func applicationDocumentDirectoryIsFile(_ url: URL) -> NSError {
        let message = "Expected a folder to store application data, found a file \(url.path)."
        return priv_error(ErrorCodes.applicationDocumentDirectoryIsFile, message: message)
    }
    
    public class func incorrectSessionRecordFetch(_ startingTimeStamp: TimeInterval, recordCount: Int) -> NSError {
        let message = "Data store should have returned one and only one session record for time stamp \(startingTimeStamp), but returned \(recordCount)"
        return priv_error(ErrorCodes.incorrectSessionRecordFetch, message: message)
    }
    
    public class func incorrectChoiceFinalStepFetch(_ expected: Int, recordCount: Int) -> NSError {
        let message = "Data store should have returned \(expected) final choice steps, but returned \(recordCount)"
        return priv_error(ErrorCodes.incorrectSessionRecordFetch, message: message)
    }
    
    
} // end class Error

