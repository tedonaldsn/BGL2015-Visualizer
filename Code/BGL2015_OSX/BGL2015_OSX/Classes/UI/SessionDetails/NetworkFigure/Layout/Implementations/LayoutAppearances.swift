//
//  LayoutAppearances.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/17/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import BASimulationFoundation


final public class LayoutAppearances {
    
    public typealias BaseAppearance = BaseLayout.BaseAppearance
    
    public static let sharedInstance = LayoutAppearances()
    
    
    // MARK: Initialization
    
    public init() {
        priv_appearances = [Identifier: BaseAppearance]()
    }
    
    
    public func append(identifier: Identifier, appearance: BaseAppearance) -> Void {
        assert(!contains(identifier: identifier))
        priv_appearances[identifier] = appearance
    }
    
    
    // MARK: Access
    
    public func contains(identifier: Identifier) -> Bool {
        return priv_appearances[identifier] != nil
    }
    
    public func find(identifier: Identifier) -> BaseAppearance? {
        return priv_appearances[identifier]
    }
    
    public func findSensor(identifier: Identifier) -> SensorSymbol.SensorAppearance? {
        return find(identifier: identifier) as? SensorSymbol.SensorAppearance
    }
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_appearances: [Identifier: BaseAppearance]
    
} // end class LayoutAppearances

