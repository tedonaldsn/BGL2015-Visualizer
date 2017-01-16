//
//  Step+CoreDataProperties.swift
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

extension Step {

    @NSManaged var isLearning: Bool
    @NSManaged var isSrOn: Bool
    @NSManaged var isXOn: Bool
    @NSManaged var isYOn: Bool
    @NSManaged var m1outActivation: Double
    @NSManaged var m2outActivation: Double
    @NSManaged var s1m1Weight: Double
    @NSManaged var s2m2Weight: Double
    @NSManaged var trialNumber: Int64
    @NSManaged var trialStepNumber: Int64
    @NSManaged var networkState: Data?
    @NSManaged var session: Session?

}
