//
//  NSMutableAttributedString+AttrConvenience.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 8/31/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa


public extension NSMutableAttributedString {
    
    public var fullRange: NSRange {
        return NSMakeRange(0, length)
    }
    
    public func scaleFonts(_ scalingFactor: CGFloat) -> Void {
        
        let fullRange: NSRange = NSMakeRange(0, Int(length))
        
        beginEditing()
        enumerateAttribute(NSFontAttributeName,
                           in: fullRange,
                           options: NSAttributedString.EnumerationOptions(rawValue: 0),
                           using: {
                            (attribute: Any?,
                            range: NSRange,
                            stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                            
                            if let oldFont = attribute as? NSFont {
                                let newFont = oldFont.scale(scalingFactor)
                                self.removeAttribute(NSFontAttributeName, range: range)
                                self.addAttribute(NSFontAttributeName, value: newFont, range: range)
                            }
        })
        endEditing()
        
    } // end scaleFonts
    
    
    
} // end extension NSMutableAttributedString

