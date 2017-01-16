//
//  MutabilityProtocol.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 8/16/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation


// For objects that are mutable upon creation, but which can be permanently
// made immutable. Obviously, if it is not mutable then the object cannot be
// mutated to become mutable.
//
public protocol MutabilityProtocol {
    
    var isMutable: Bool { get }
    func makeImmutable() -> Void
}


public extension MutabilityProtocol {

    var isImmutable: Bool { return !isMutable }
    
}
