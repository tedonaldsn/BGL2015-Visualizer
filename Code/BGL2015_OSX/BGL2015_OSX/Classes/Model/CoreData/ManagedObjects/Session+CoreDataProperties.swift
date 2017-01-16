//
//  Session+CoreDataProperties.swift
//  
//
//  Created by Tom Donaldson on 7/21/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Session {

    @NSManaged var duration: TimeInterval
    @NSManaged var mPrime1Activation: Double
    @NSManaged var mPrime2Activation: Double
    @NSManaged var r1Count: Int64
    @NSManaged var r2Count: Int64
    @NSManaged var smPrimePrime1Weight: Double
    @NSManaged var smPrimePrime2Weight: Double
    @NSManaged var startedAt: TimeInterval
    @NSManaged var uuid: String?
    @NSManaged var steps: NSOrderedSet?

}
