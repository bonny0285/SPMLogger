//
//  File.swift
//  
//
//  Created by Bonafede Massimiliano on 25/06/21.
//

import Foundation


/// This class provides multiple methods to print messages and retrieve them, also thread safe
public class Log {
    // MARK: - Singleton
    public static let shared = Log()
    private init() {}

    // MARK: - Properties

    public static var isLoggingEnabled = true

    // Date in the Log message
    public static var dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
    public static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    private class var now: String {
        return Log.dateFormatter.string(from: Date())
    }

    // The logHistory is an ordered list without duplicates, logSet is used to avoid doubles
    // This works like a SortedSet, if it is not in the set then is inserted in both
    // The semaphore makes the operations thread-safe
    private(set) var logHistory = [String]() {
        didSet {
            onCallBack?(logHistory)
        }
    }
    public var onCallBack: (([String]) -> Void)?
    private var logSet = Set<String>()
    private var logsSemaphore = DispatchSemaphore(value: 1)

    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }

    /// Logs a message
    /// - Parameters:
    ///   - object: This will be the debug object which is to be printed on the debug console, required.
    ///   - filename: The file name from where the log will appear. Defaults will simply copy the path of the file from where log() is getting called.
    ///   - line: The line number of the log message. Default value will simply be the line number from where log() is executed.
    ///   - funcName: The default value of this parameter is the signature of the function from where the log function is getting called.
    private class func log(event: LogEvent, _ object: Any, filename: String, line: Int, funcName: String) {
        if isLoggingEnabled {
            let text = "\(now) \(event.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(funcName) ->\n\(object)\n"
            print(text)
            saveLog(text)
        }
    }

    private class func saveLog(_ text: String) {
        Log.shared.logsSemaphore.wait() // Begin thread safe block

        // If the insert was successful, it is a new item and must be inserted also in the list
        if Log.shared.logSet.insert(text).inserted {
            Log.shared.logHistory.append(text)
        }

        Log.shared.logsSemaphore.signal() // End of block
    }

    public class func e(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        log(event: LogEvent.error, object, filename: filename, line: line, funcName: funcName)
    }

    public class func i(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        log(event: LogEvent.info, object, filename: filename, line: line, funcName: funcName)
    }

    public class func d(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        log(event: LogEvent.debug, object, filename: filename, line: line, funcName: funcName)
    }

    public class func v(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        log(event: LogEvent.verbose, object, filename: filename, line: line, funcName: funcName)
    }

    public class func w(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        log(event: LogEvent.warning, object, filename: filename, line: line, funcName: funcName)
    }

    public class func s(_ object: Any, filename: String = #file, line: Int = #line, funcName: String = #function) {
        log(event: LogEvent.severe, object, filename: filename, line: line, funcName: funcName)
    }

    public class func cleanHistory() {
        Log.shared.logsSemaphore.wait() // Begin thread safe block

        Log.shared.logHistory.removeAll()
        Log.shared.logSet.removeAll()

        Log.shared.logsSemaphore.signal() // End of block
    }
}

// MARK: - Log Builder
extension Log {
    internal class Builder {
        private var logEvent: LogEvent?
        private var logSymbol: String = ""
        private var object: Any = ""
        private var filename: String
        private var line: Int = #line
        private var column: Int = #column
        private var funcName: String = #function
        private var items = [String: Any?]()

        internal init(
            for logEvent: LogEvent? = nil,
            text object: Any = "",
            filename: String = #file,
            line: Int = #line,
            column: Int = #column,
            funcName: String = #function,
            items: [String: Any?] = [String: Any?]()
        ) {
            self.logEvent = logEvent
            self.object = object
            self.filename = filename
            self.line = line
            self.column = column
            self.funcName = funcName
            self.items = items
        }

        func log() {
            if isLoggingEnabled {
                // swiftlint:disable:next line_length
                var text = "\(now) \(logEvent?.rawValue ?? logSymbol)[\(sourceFileName(filePath: filename))]:\(line)-\(column) \(funcName) ->\n\(object)\n"
                items.forEach { text.append("\($0): \($1 ?? "nil")\n") }

                print(text)
                Log.saveLog(text)
            }
        }

        func logSymbol(_ logSymbol: String) -> Builder {
            self.logSymbol = logSymbol
            return self
        }

        func object(_ object: Any) -> Builder {
            self.object = "\(object)\n"
            return self
        }

        func filename(_ filename: String) -> Builder {
            self.filename = filename
            return self
        }

        func line(_ line: Int) -> Builder {
            self.line = line
            return self
        }

        func column(_ column: Int) -> Builder {
            self.column = column
            return self
        }

        func funcName(_ funcName: String) -> Builder {
            self.funcName = funcName
            return self
        }

        func infoAbout(_ items: [String: Any?]) -> Builder {
            self.items = items
            return self
        }
    }
}

// MARK: - LogEvent
internal enum LogEvent: String {
    case error = "[‼️]"
    case info = "[ℹ️]"
    case debug = "[💬]"
    case verbose = "[🔬]"
    case warning = "[⚠️]"
    case severe = "[🔥]"
}
