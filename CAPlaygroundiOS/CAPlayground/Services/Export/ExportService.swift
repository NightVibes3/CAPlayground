//
//  ExportService.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Service handling the export of projects to `.ca` bundles or `.tendies` files.
/// Requires a Zip library (like ZIPFoundation) to be fully functional for .tendies.

// MARK: - Zip Utility Wrapper

import Foundation

enum ExportFormat {
    case caBundle
    case tendies
}
enum ExportError: Error {
    case projectNotFound
    case templateNotFound
    case zipFailed
    case fileSystemError(Error)
}
class ExportService {
    static let shared = ExportService()

    private let fileManager = FileManager.default
    private let fileStorage = FileStorageService.shared

    // MARK: - Public API

    func exportProject(
        _ project: ProjectMeta, format: ExportFormat,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        Task {
            do {
                let url = try await performExport(project: project, format: format)
                await MainActor.run {
                    completion(.success(url))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Internal Logic

    private func performExport(project: ProjectMeta, format: ExportFormat) async throws -> URL {
        // 1. Flush any pending saves (handled by ViewModel usually, but good to be safe)
        // In a real app, we'd ensure persistence is up to date here.

        // 2. Prepare temporary directory
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)

        switch format {
        case .caBundle:
            return try await exportCABundle(project: project, to: tempDir)
        case .tendies:
            return try await exportTendies(project: project, to: tempDir)
        }
    }

    private func exportCABundle(project: ProjectMeta, to tempDir: URL) async throws -> URL {
        let projectName = project.name.sanitizeFilename()
        let sourcePath = "\(projectName).ca"  // This is where FileStorage keeps it normally

        // We need to reconstruct the full folder structure in temp
        let exportDir = tempDir.appendingPathComponent("\(projectName).ca")
        try fileManager.createDirectory(at: exportDir, withIntermediateDirectories: true)

        // Copy files from FileStorage to temp exportDir
        // Note: FileStorage might store things flat or in a structure.
        // Based on previous FileStorageService, it mirrors the structure.

        let files = try await fileStorage.listFiles(projectId: project.id, path: sourcePath)

        for file in files {
            // file.path is relative to project root, e.g. "MyProject.ca/Background.ca/main.caml"
            // We want to preserve the structure inside the export folder

            // Remove the project root folder name from the path if present to map correctly
            let cleanPath: String
            if file.path.hasPrefix("\(sourcePath)/") {
                cleanPath = String(file.path.dropFirst("\(sourcePath)/".count))
            } else {
                continue
            }

            let destUrl = exportDir.appendingPathComponent(cleanPath)
            let destFolder = destUrl.deletingLastPathComponent()

            try fileManager.createDirectory(at: destFolder, withIntermediateDirectories: true)

            if let data = await fileStorage.readFile(projectId: project.id, path: file.path) {
                try data.write(to: destUrl)
            }
        }

        // Zip the folder
        let zipUrl = tempDir.appendingPathComponent("\(projectName).zip")
        try ZipUtils.zip(directory: exportDir, to: zipUrl)

        return zipUrl
    }

    private func exportTendies(project: ProjectMeta, to tempDir: URL) async throws -> URL {
        let isGyro = project.gyroEnabled ?? false
        let templateName = isGyro ? "gyro-tendies" : "tendies"

        // 1. Load Template
        guard let templatePath = Bundle.main.path(forResource: templateName, ofType: "zip") else {
            throw ExportError.templateNotFound
        }

        let workDir = tempDir.appendingPathComponent("working")
        try fileManager.createDirectory(at: workDir, withIntermediateDirectories: true)

        // 2. Unzip template to workDir
        try ZipUtils.unzip(source: URL(fileURLWithPath: templatePath), destination: workDir)

        // 3. Inject CA files
        let projectName = project.name.sanitizeFilename()
        let sourcePath = "\(projectName).ca"
        let files = try await fileStorage.listFiles(projectId: project.id, path: sourcePath)

        if isGyro {
            // Gyro Path Mapping
            let targetBase = workDir.appendingPathComponent(
                "descriptors/99990000-0000-0000-0000-000000000000/versions/0/contents/7400.WWDC_2022-390w-844h@3x~iphone.wallpaper/wallpaper.ca"
            )
            try fileManager.createDirectory(at: targetBase, withIntermediateDirectories: true)

            let sourcePrefix = "\(sourcePath)/Wallpaper.ca/"

            for file in files where file.path.hasPrefix(sourcePrefix) {
                let relativePath = String(file.path.dropFirst(sourcePrefix.count))
                let destUrl = targetBase.appendingPathComponent(relativePath)
                try Utils.ensureDir(for: destUrl)

                if let data = await fileStorage.readFile(projectId: project.id, path: file.path) {
                    try data.write(to: destUrl)
                }
            }
        } else {
            // Non-Gyro Path Mapping
            let uuid = "09E9B685-7456-4856-9C10-47DF26B76C33"
            let contentBase = workDir.appendingPathComponent(
                "descriptors/\(uuid)/versions/1/contents/7400.WWDC_2022-390w-844h@3x~iphone.wallpaper"
            )

            let bgTarget = contentBase.appendingPathComponent(
                "7400.WWDC_2022_Background-390w-844h@3x~iphone.ca")
            let floatTarget = contentBase.appendingPathComponent(
                "7400.WWDC_2022_Floating-390w-844h@3x~iphone.ca")

            let bgPrefix = "\(sourcePath)/Background.ca/"
            let floatPrefix = "\(sourcePath)/Floating.ca/"

            for file in files {
                var destUrl: URL?

                if file.path.hasPrefix(bgPrefix) {
                    let rel = String(file.path.dropFirst(bgPrefix.count))
                    destUrl = bgTarget.appendingPathComponent(rel)
                } else if file.path.hasPrefix(floatPrefix) {
                    let rel = String(file.path.dropFirst(floatPrefix.count))
                    destUrl = floatTarget.appendingPathComponent(rel)
                }

                if let dest = destUrl {
                    try Utils.ensureDir(for: dest)
                    if let data = await fileStorage.readFile(projectId: project.id, path: file.path)
                    {
                        try data.write(to: dest)
                    }
                }
            }
        }

        // 4. Zip up the result
        let finalParams = tempDir.appendingPathComponent("\(projectName).tendies")

        // Important: We must zip the CONTENTS of workDir, not workDir itself
        try ZipUtils.zip(directory: workDir, to: finalParams)

        return finalParams
    }
}
class ZipUtils {
    static func zip(directory: URL, to dest: URL) throws {
        // Placeholder: Requires ZIPFoundation or similar
        // Example: try FileManager.default.zipItem(at: directory, to: dest)
        print("Zipping \(directory) to \(dest)")

        // For now, since we can't add dependencies, we'll implement a simplistic
        // file coordinator approach OR warn the user.
        // In a real conversion, this would use ZIPFoundation.

        // This is a stub implementation that just creates an empty file to prevent crashes
        // The user MUST implement real zipping here.
        try "Placeholder Zip".write(to: dest, atomically: true, encoding: .utf8)
    }

    static func unzip(source: URL, destination: URL) throws {
        // Placeholder: Requires ZIPFoundation or similar
        // Example: try FileManager.default.unzipItem(at: source, to: destination)
        print("Unzipping \(source) to \(destination)")
    }
}
private class Utils {
    static func ensureDir(for fileUrl: URL) throws {
        let folder = fileUrl.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }
}
