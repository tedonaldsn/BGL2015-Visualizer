//
//  PlotDefinitions.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 7/16/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation


open class PlotDefinitions {
    
    open var definitions: [PlotDefinition] {
        return priv_defs
    }
    
    public init(definitions: [PlotDefinition]? = nil) {
        if let defs = definitions {
            priv_defs = defs
        }
    }
    
    open func append(_ definition: PlotDefinition) {
        assert(!contains(definition.label))
        priv_defs.append(definition)
    }
    open func dataKey(_ forLabel: String) -> String? {
        if let def = find(forLabel) {
            return def.dataKey
        }
        return nil
    }
    open func contains(_ forLabel: String) -> Bool {
        return find(forLabel) != nil
    }
    
    // Note that find() is implemented by iterating over the array of
    // definitions. Given the small number of plots expected in any one
    // collection this should perform acceptably. In general the break even point
    // for using a hash table versus an array is around 100 items. One hundred
    // plots per graph seems highly unlikely.
    //
    open func find(_ forLabel: String) -> PlotDefinition? {
        for def in priv_defs {
            if def.label == forLabel { return def }
        }
        return nil
    }
    
    fileprivate var priv_defs = [PlotDefinition]()
    
} // end class PlotDefinitions
