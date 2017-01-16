//
//  Logger.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 12/2/15.
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
//  



import Foundation


//  Logger
//
//  General purpose application logger. It is a convenience wrapper around
//  NSLog() which provides:
//
//      1) Cheap calls to logging. The logging calls all use @autoclosure
//          to pass the logging messages. Therefore, if logging is not
//          enabled, or the particular class of logging is not enabled, then
//          the call has essentially no cost.
//
//      2) Standard NSLog() formatting of output including the Zulu time,
//          application name, and process id.
//
//      3) "The Foundation framework's NSLog function is available in every 
//          version of iOS and OS X that ever shipped."
//
//      4) "NSLog outputs messages to the Apple System Log facility or to the
//          Console app ..."
//
//  For more information on NSLog() see:
//
//      https://developer.apple.com/library/ios/technotes/tn2347/_index.html
//
//  In addition to NSLog()'s features, Logger provides:
//
//      1) Selective enabling/disabling of logging classes.
//
//      2) Enabling/disabling of all logging for the instance without affecting
//          settings for the logging classes.
//
//      3) Logging class labels on each line.
//
//
final public class Logger: NSObject, NSCoding {
    
    public static var defaultSettings = Settings()
    
    // Note that the rawValue of each enum value is used as the class tag
    // in the log output. The class tag will appear just after the NSLog()
    // standard prefix, followed by a colon (":"), then followed by the message
    // passed to the log method.
    //
    // Class Info: General messages.
    //
    // Class Warn: Something may be wrong, but is not serious at this time.
    //
    //              Should probably always be turned on. Low volume of output,
    //              and may be useful in preventing future problems.
    //
    // Class Error: Serious problem that may be causing the application to
    //              abort. Whatever caused the error probably generated a
    //              NSError or threw an exception (or should have).
    //
    //              Should probably always be turned on. Low volume of output,
    //              but important output.
    //
    // Class Trace: Logs execution path through the application. Generally
    //              only useful during development or debugging.
    //
    //              Should probably be turned off except during debugging. Can
    //              generate large volumes of output.
    //
    // Class Debug: Besides logging the supplied message, also logs information
    //              about where it was called: source file, function name, line.
    //
    //              Should probably be turned off except during debugging. Can
    //              generate large volumes of output.
    //
    //
    public enum LogEntryClass: String {
        case Info = "_INFO_"            // General messages
        case Warn = "_WARN_"            // Something is wrong, but not serious.
        case Error = "_ERROR_"          // Serious problem, maybe abortive

        case Trace = "_TRACE_"          // Program flow tracing (development)
        case Debug = "_DEBUG_"          // Development info including calling file, function, line.
    }
    
    
    // Settings: controls what kinds of logging, if any, are enabled. Convenience
    // tests for logging.
    //
    // Besides being used to control logging, enables wholesale setting and
    // restoring of settings.
    //
    open class Settings: NSObject, NSCoding {
        
        // isLoggingEnabled is the master switch for logging in this instance of
        // Logger. None of the logging works unless this "master switch" is on.
        // When isLoggingEnabled is on, logging still may not occur none of the
        // logging class specific switches are on.
        //
        // When isLoggingEnabled is on, logging will only be done for logging classes
        // whose switches are also on.
        //
        // DEFAULT SETTINGS: Logging is enabled for errors only.
        //
        open var isLoggingEnabled = true
        
        // Logging class specific switches.
        //
        open var isErrorEnabled = true
        
        open var isInfoEnabled = false
        open var isWarnEnabled = false
        
        open var isTraceEnabled = false
        open var isDebugEnabled = false
        
        open var isAnyLoggingEnabled: Bool {
            return
                isLoggingEnabled
                    
                    && ( isInfoEnabled || isWarnEnabled
                        || isErrorEnabled || isTraceEnabled
                        || isDebugEnabled
            )
        }
        
        
        open var isAllLoggingEnabled: Bool {
            get { return
                isLoggingEnabled
                    && isInfoEnabled && isWarnEnabled
                    && isErrorEnabled && isTraceEnabled
                    && isDebugEnabled
            }
            set {
                isLoggingEnabled = newValue
                isInfoEnabled = newValue
                isWarnEnabled = newValue
                isErrorEnabled = newValue
                isTraceEnabled = newValue
                isDebugEnabled = newValue
            }
        }
        
        public override init() {
        }
        
        public convenience init(settingsToCopy: Settings) {
            self.init()
            self.copyFrom(settingsToCopy)
        }
        
        open func copyFrom(_ other: Settings) -> Void {
            if self !== other {
                self.isLoggingEnabled = other.isLoggingEnabled
                self.isInfoEnabled = other.isInfoEnabled
                self.isWarnEnabled = other.isWarnEnabled
                self.isErrorEnabled = other.isErrorEnabled
                self.isTraceEnabled = other.isTraceEnabled
                self.isDebugEnabled = other.isDebugEnabled
            }
        }
        
        open func isLoggingClassEnabled(_ entryClass: LogEntryClass) -> Bool {
            if !isLoggingEnabled { return false }
            switch entryClass {
            case .Info: return isInfoEnabled
            case .Warn: return isWarnEnabled
            case .Error: return isErrorEnabled
            case .Trace: return isTraceEnabled
            case .Debug: return isDebugEnabled
            }
        }
        open override func isEqual(_ object: Any?) -> Bool {
            if let other = object as? Settings {
                
                return isLoggingEnabled == other.isLoggingEnabled
                    && isErrorEnabled == other.isErrorEnabled
                    && isInfoEnabled == other.isInfoEnabled
                    && isWarnEnabled == other.isWarnEnabled
                    && isTraceEnabled == other.isTraceEnabled
                    && isDebugEnabled == other.isDebugEnabled
            }
            return false
        }
        
        
        // MARK: NSCoding
        
        open static let key_isLoggingEnabled = "isLoggingEnabled"
        open static let key_isErrorEnabled = "isErrorEnabled"
        open static let key_isInfoEnabled = "isInfoEnabled"
        open static let key_isWarnEnabled = "isWarnEnabled"
        open static let key_isTraceEnabled = "isTraceEnabled"
        open static let key_isDebugEnabled = "isDebugEnabled"
        
        public required init?(coder aDecoder: NSCoder) {
            isLoggingEnabled = aDecoder.decodeBool(forKey: Settings.key_isLoggingEnabled)
            isErrorEnabled = aDecoder.decodeBool(forKey: Settings.key_isErrorEnabled)
            isInfoEnabled = aDecoder.decodeBool(forKey: Settings.key_isInfoEnabled)
            isWarnEnabled = aDecoder.decodeBool(forKey: Settings.key_isWarnEnabled)
            isTraceEnabled = aDecoder.decodeBool(forKey: Settings.key_isTraceEnabled)
            isDebugEnabled = aDecoder.decodeBool(forKey: Settings.key_isDebugEnabled)
        }
        
        open func encode(with aCoder: NSCoder) {
            aCoder.encode(isLoggingEnabled, forKey: Settings.key_isLoggingEnabled)
            aCoder.encode(isErrorEnabled, forKey: Settings.key_isErrorEnabled)
            aCoder.encode(isInfoEnabled, forKey: Settings.key_isInfoEnabled)
            aCoder.encode(isWarnEnabled, forKey: Settings.key_isWarnEnabled)
            aCoder.encode(isTraceEnabled, forKey: Settings.key_isTraceEnabled)
            aCoder.encode(isDebugEnabled, forKey: Settings.key_isDebugEnabled)
        }
        
    } // end class Settings
    
    
    // MARK: Data
    
    // Bulk getting/setting of flags controlling logging. Note that because
    // Value semantics.
    //
    public var settings: Settings {
        get { return priv_settings }
        set { priv_settings = newValue }
    }
    

    public var isLoggingEnabled: Bool {
        get { return priv_settings.isLoggingEnabled }
        set { priv_settings.isLoggingEnabled = newValue }
    }
    public var isErrorEnabled: Bool {
        get { return priv_settings.isErrorEnabled }
        set { priv_settings.isErrorEnabled = newValue }
    }
    public var isInfoEnabled: Bool {
        get { return priv_settings.isInfoEnabled }
        set { priv_settings.isInfoEnabled = newValue }
    }
    public var isWarnEnabled: Bool {
        get { return priv_settings.isWarnEnabled }
        set { priv_settings.isWarnEnabled = newValue }
    }
    public var isTraceEnabled: Bool {
        get { return priv_settings.isTraceEnabled }
        set { priv_settings.isTraceEnabled = newValue }
    }
    public var isDebugEnabled: Bool {
        get { return priv_settings.isDebugEnabled }
        set { priv_settings.isDebugEnabled = newValue }
    }
    public var isAnyLoggingEnabled: Bool {
        return priv_settings.isAnyLoggingEnabled
    }
    public var isAllLoggingEnabled: Bool {
        return priv_settings.isAllLoggingEnabled
    }
    
    public var isDefaultSettings: Bool {
        return priv_settings == Logger.defaultSettings
    }
    
    // MARK: Initialization
    
    public override init() {
    }
    
    public convenience init(from: Logger) {
        self.init()
        priv_settings.copyFrom(from.settings)
    }
    
    public func clone() -> Logger {
        return Logger(from: self)
    }
    
    public func reset() -> Void {
        priv_settings.copyFrom(Logger.defaultSettings)
    }
    
    // MARK: Logging Class Specific
    
    public func isLoggingClassEnabled(_ entryClass: LogEntryClass) -> Bool {
        return priv_settings.isLoggingClassEnabled(entryClass)
    }
    
    public func logInfo(_ message: @autoclosure () -> String) {
        log(.Info, message: message)
    }
    
    public func logWarn(_ message: @autoclosure () -> String) {
        log(.Warn, message: message)
    }
    
    public func logError(_ error: NSError) {
        logErrorMessage(error.localizedDescription)
    }
    public func logErrorMessage(_ message: @autoclosure () -> String) {
        log(.Error, message: message)
    }
    
    public func logTrace(_ message: @autoclosure () -> String) {
        log(.Trace, message: message)
    }
    
    public func logDebug(_ message: @autoclosure () -> String,
        file: String = #file,
        line: Int = #line,
        function: String = #function) {
            
            if isLoggingEnabled && isDebugEnabled {
                let message = "File: \(file), Line: \(line), Function: \(function): \(message())"
                log(.Debug, message: message)
            }
    }
    
    // MARK: Base Methods
    
    public func log(_ entryClass: LogEntryClass, message: @autoclosure () -> String) {
        if isLoggingClassEnabled(entryClass) {
            let line = "\(entryClass.rawValue): \(message())"
            NSLog("%@", line)
        }
    }
    
    // MARK: NSCoding
    
    public static let key_settings = "settings"
    
    public init?(coder aDecoder: NSCoder) {
        let obj = aDecoder.decodeObject(forKey: Logger.key_settings)
        if let settings = obj as? Settings {
            priv_settings = settings
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(priv_settings, forKey: Logger.key_settings)
    }
    
    
    // MARK: *Private*
    
    
    fileprivate var priv_settings = Logger.Settings()
    
} // end class Logger


public func ==(lhs: Logger, rhs: Logger) -> Bool {
    return lhs.settings == rhs.settings
}
public func ==(lhs: Logger.Settings, rhs: Logger.Settings) -> Bool {
    return lhs.isEqual(rhs)
}

