//
//  NSColor+fromRGB.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 1/1/17.
//  
//  Copyright © 2017 Tom Donaldson.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

//

import Cocoa



public extension NSColor {
    
    // Example chart of RGB values:
    //
    // http://cloford.com/resources/colours/500col.htm
    //
    public class func fromRGB(red: UInt8,
                              green: UInt8,
                              blue: UInt8,
                              alpha: UInt8 = 255) -> NSColor {
        
        let r: CGFloat = CGFloat(red) / 255.0
        let g: CGFloat = CGFloat(green) / 255.0
        let b: CGFloat = CGFloat(blue) / 255.0
        let a: CGFloat = CGFloat(alpha) / 255.0
        return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
    }
}
