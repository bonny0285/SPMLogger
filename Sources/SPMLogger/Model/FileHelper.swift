//
//  File.swift
//  
//
//  Created by Bonafede Massimiliano on 25/06/21.
//

import UIKit

public struct FileHelper {

    // MARK: Properties

    public static var documentsDirectory: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }

    private static var topController: UIViewController? {
        if var topController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    // MARK: Methods
    @discardableResult
    public static func addSkipBackupAttribute(to url: URL, isExcludedFromBackup excluded: Bool = true) -> Bool {
        var fileUrl = url

        guard FileManager.default.fileExists(atPath: fileUrl.path) else { return true }
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = excluded

        do {
            try fileUrl.setResourceValues(resourceValues)
            return true
        } catch {
            Log.e(error)
            return false
        }
    }

    @discardableResult
    public static func disableBackupForDocuments() -> Bool {
        return addSkipBackupAttribute(to: documentsDirectory)
    }

    public static func read(fromDirectory directory: String = ".", fileName: String, execute closure: ((String) -> Void)? = nil) {
        let file = FileHelper.documentsDirectory
            .appendingPathComponent(directory, isDirectory: true)
            .appendingPathComponent(fileName)

        do {
            let savedString = try String(contentsOfFile: file.path)
            closure?(savedString)
        } catch {
            Log.e("Impossible reading saved file: \(error as Any)")
        }
    }

    // Nota: Questo metodo è molto rozzo e va migliorato
    public static func saveAndShowAlert(text: String, onDirectory directory: String = ".", fileName: String, completion: (() -> Void)? = nil) {
        var contents: [URL]?
        do {
            // If the directory doesn't exists, create it before adding the file
            let directoryPath = documentsDirectory.appendingPathComponent(directory)
            if FileManager.default.fileExists(atPath: directoryPath.absoluteString) == false {
                try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
            }

            // Saves it locally
            try text.write(toFile: directoryPath.appendingPathComponent(fileName).path, atomically: true, encoding: .utf8)

            // Then picks all the logs to send to user to save
            let contentsOfDirectory = try FileManager.default.contentsOfDirectory(
                at: directoryPath,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            contents = []
            contents?.append(contentsOfDirectory.first { $0.lastPathComponent == fileName }!)

        } catch {
            Log.e("Impossible to save file: \(error as Any)")
            completion?()
            return
        }

        if let topController = topController, let contents = contents {
            let activityViewController = UIActivityViewController(activityItems: contents, applicationActivities: nil)
            topController.present(activityViewController, animated: true, completion: completion)
        } else {
            completion?()
        }
    }
}
