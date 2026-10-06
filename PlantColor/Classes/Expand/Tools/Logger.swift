//
//  Logger.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//  Copyright © 2024 PlantColor. All rights reserved.
//

import Foundation
import os.log

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case fatal = "FATAL"
}

class AppLogger {
    static let shared = AppLogger()
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "PlantColor", category: "App")
    
    private init() {}
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"
        
        switch level {
        case .debug:
            os_log(.debug, log: log, "%{public}@", logMessage)
        case .info:
            os_log(.info, log: log, "%{public}@", logMessage)
        case .warning:
            os_log(.default, log: log, "%{public}@", logMessage)
        case .error:
            os_log(.error, log: log, "%{public}@", logMessage)
        case .fatal:
            os_log(.fault, log: log, "%{public}@", logMessage)
        }
        
        #if DEBUG
        print(logMessage)
        #endif
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    func fatal(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .fatal, file: file, function: function, line: line)
    }
} 