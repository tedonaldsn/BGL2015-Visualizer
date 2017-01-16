//
//  NSFont+AttrConvenience.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/24/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa



public extension NSFont {
    
    public func scale(_ scalingFactor: CGFloat) -> NSFont {
        let descriptor: NSFontDescriptor = fontDescriptor
        let currentSize: CGFloat = pointSize
        let newSize: CGFloat = currentSize * scalingFactor
        let newFont: NSFont = NSFont(descriptor: descriptor, size: newSize)!
        return newFont
    }
}
