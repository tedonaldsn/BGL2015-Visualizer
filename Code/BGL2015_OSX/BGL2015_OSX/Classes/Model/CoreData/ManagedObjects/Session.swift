//
//  Session.swift
//  
//
//  Created by Tom Donaldson on 5/9/16.
//
//

import Foundation
import CoreData


open class Session: NSManagedObject {
    open static let entityName = "Session"
    open static let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        return formatter
    }()
    open static var timeStamp: TimeInterval {
        return Date().timeIntervalSinceReferenceDate
    }
    // Valid UUID string is 128 bits of character data as hex. The final length
    // will be longer because the formatting includes a number of hypens.
    // This minimum length is just a fairly quick sanity check.
    //
    open static let minimumUUIDlength = (128/8) * 2
    
    
    open var isValidInvariants: Bool { return isValidUUID && isValidTimes }

    open var isValidUUID: Bool {
        guard uuid != nil && !uuid!.isEmpty else { return false }
        let charCount = uuid!.characters.count
        return charCount > Session.minimumUUIDlength
    }
    open var isValidTimes: Bool {
        return (!isStarted && !isStopped) || isStarted
    }
    
    
    open var startedAtDate: String {
        let dateString = Session.dateFormatter.stringFromTimeInterval(startedAt)
        return dateString
    }
    
    open var isStarted: Bool {
        return value(forKey: "startedAt") != nil
    }
    
    open var isStopped: Bool {
        return value(forKey: "duration") != nil
    }

    open func recordStart(_ startTime: TimeInterval = 0.0) {
        if !isStarted {
            
            if uuid == nil {
                uuid = UUID().uuidString
            }
            
            if startTime == 0.0 {
                startedAt = Session.timeStamp
            } else {
                startedAt = startTime
            }
        }
    }
    
    open func recordStop() {
        if isStarted && !isStopped {
            duration = Session.timeStamp - startedAt
        }
    }
    

} // end Session

