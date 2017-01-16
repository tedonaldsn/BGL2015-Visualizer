//
//  CGRect+LargestSquare.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 8/10/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import CoreGraphics


// Returns largest square containable by rect, centered in rect.
//
public func CGRectCenteredSquare(_ rect: CGRect) -> CGRect {
    let minDim = min(rect.size.width, rect.size.height)
    let xPad = (rect.size.width - minDim)/2.0
    let yPad = (rect.size.height - minDim)/2.0
    let x = rect.origin.x + xPad
    let y = rect.origin.y + yPad
    let centeredSquare = CGRect(x: x, y: y, width: minDim, height: minDim)
    return centeredSquare
}
