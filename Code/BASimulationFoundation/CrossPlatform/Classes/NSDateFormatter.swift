//
//  NSDateFormatter.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 5/11/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation


public extension DateFormatter {
    
    public class func RFC3339DateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    public func stringFromTimeInterval(_ timeIntervalSinceReferenceDate: TimeInterval) -> String {
        let date = Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
        return string(from: date)
    }
}
