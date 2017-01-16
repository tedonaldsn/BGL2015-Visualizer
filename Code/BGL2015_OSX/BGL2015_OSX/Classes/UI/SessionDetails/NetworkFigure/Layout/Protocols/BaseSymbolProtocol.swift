//
//  BaseSymbolProtocol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 1/7/17.
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
import BASimulationFoundation



public protocol BaseSymbolProtocol {
    
    var fillColor: StrengthColor { get set }
    var lineStyle: StrengthLineStyle { get set }
    var label: StrengthText? { get set }
    
    var presentationStrength: Scaled0to1Value { get }
    
} // end protocol BaseSymbolProtocol



public extension BaseSymbolProtocol {
    
    public var rawPresentationStrength: CGFloat {
        return CGFloat(presentationStrength.rawValue)
    }
    
    public var strengthAdjustedFillColor: CGColor {
        return fillColor.color(rawPresentationStrength)
    }
    public var strengthAdjustedLineWidth: CGFloat {
        return lineStyle.lineWidth(rawPresentationStrength)
    }
    public var strengthAdjustedLineColor: CGColor {
        return lineStyle.color(rawPresentationStrength)
    }
    
} // end extension BaseSymbolProtocol


