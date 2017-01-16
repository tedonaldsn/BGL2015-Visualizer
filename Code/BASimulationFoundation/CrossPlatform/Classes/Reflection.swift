//
//  Reflection.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 2/4/15.
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


import Foundation


// MARK: Application

public func applicationName() -> String {
    let bundlePath = Bundle.main.bundlePath
    let appName = FileManager.default.displayName(atPath: bundlePath)
    return appName
}





public func objectIdentifierValue(_ obj: AnyObject) -> UInt {
    let id = ObjectIdentifier(obj)
    
    return UInt(bitPattern: id)
}

public func isObjectIdentity(_ obj1: AnyObject, obj2: AnyObject) -> Bool {
    return objectIdentifierValue(obj1) == objectIdentifierValue(obj2)
}


//  There is also reflection info used by Xcode IDE: MirrorType.
//
//  var myMirror: MirrorType = reflect(myObject)
//
//  Cannot find any official documentation, but see:
//  http://swiftdoc.org/protocol/MirrorType/





