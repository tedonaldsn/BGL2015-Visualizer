//
//  SpacerLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/28/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation


// SpacerLayout
//
// Maintains blank area in displayed layout.
//
// Default size is square of SpacerLayout.initialDimension per side.
//
// Alternately a major axis can be specified, and the spacer scaled along
// that axis (e.g., to create a 0.5 sized spacer, or a 2.0 sized spacer). The
// minor axis will still be SpacerLayout.initialDimension long.
//
open class SpacerLayout: BaseLayout {
    
    open static let initialDimension: CGFloat = 50.0
    open static let initialSize = CGSize(width: initialDimension,
                                           height: initialDimension)
    
    open var collectionAxis: CollectionAxis

    public init(collectionAxis: CollectionAxis = .Undefined,
                scalingFactor: CGFloat = 1.0) {
        
        assert(scalingFactor > 0.0)
        
        self.collectionAxis = collectionAxis
        super.init()
        
        var size = SpacerLayout.initialSize
        
        switch collectionAxis {
            
        case .Undefined:
            break
            
        case .XMajor:
            size = CGSize(width: SpacerLayout.initialDimension,
                          height: SpacerLayout.initialDimension * scalingFactor)
            
        case .YMajor:
            size = CGSize(width: SpacerLayout.initialDimension * scalingFactor,
                          height: SpacerLayout.initialDimension)
        }
        
        extendFrameToInclude(rect: CGRect(origin: frame.origin,
                                          size: size))
    }
    
} // end class SpacerLayout

