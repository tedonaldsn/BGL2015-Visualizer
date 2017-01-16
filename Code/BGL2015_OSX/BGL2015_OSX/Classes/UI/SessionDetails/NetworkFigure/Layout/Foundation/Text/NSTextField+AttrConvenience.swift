//
//  NSTextField+AttrConvenience.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/24/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa



public extension NSTextField {
    
    // Scale up/down by the specified factor. Currently only modifies
    // font size to accommodate attributed strings that are being separately
    // scaled.
    //
    // Note that preferred width must also grow to avoid truncating text
    // when scaled up.
    //
    public func scale(_ scalingFactor: CGFloat) -> Void {
        
        if let currentFont = self.font {
            font = currentFont.scale(scalingFactor)
            preferredMaxLayoutWidth = preferredMaxLayoutWidth * scalingFactor
        }

    } // end scale

} // end extension NSTextField
