//
//  Diagnostics.swift
//  MPCGD
//

import Foundation

let MPCGDDiagnosticsLastErrorKey = "MPCGDDiagnosticsLastError"

func MPCGDUncaughtExceptionHandler(_ exception: NSException) {
    let reason = exception.reason ?? "no reason"
    let stack = exception.callStackSymbols.prefix(8).joined(separator: "\n")
    Diagnostics.recordFatal("Uncaught exception: \(exception.name.rawValue) \(reason)\n\(stack)")
}

class Diagnostics {
    static var onError: ((String) -> ())? = nil
    static var onClear: (() -> ())? = nil

    static func install() {
        NSSetUncaughtExceptionHandler(MPCGDUncaughtExceptionHandler)
    }

    static func report(_ message: String) {
        print("MPCGD ERROR: \(message)")
        DispatchQueue.main.async {
            onError?(message)
        }
    }

    static func clear() {
        DispatchQueue.main.async {
            onClear?()
        }
    }

    static func recordFatal(_ message: String) {
        UserDefaults.standard.set(message, forKey: MPCGDDiagnosticsLastErrorKey)
        UserDefaults.standard.synchronize()
    }

    static func consumeLastFatal() -> String? {
        let message = UserDefaults.standard.string(forKey: MPCGDDiagnosticsLastErrorKey)
        UserDefaults.standard.removeObject(forKey: MPCGDDiagnosticsLastErrorKey)
        return message
    }
}
