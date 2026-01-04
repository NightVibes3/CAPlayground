//
//  FileStorageService.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Service for managing file storage (offline-first approach).
/// Mirrors the file storage functionality from storage.ts and idb.ts
import Foundation

/// Represents a stored file.
actor FileStorageService {

    static let shared = FileStorageService()

    private let fileManager = FileManager.default

    /// Base directory for all projects.
    private var projectsDirectory: URL {
        FileUtils.documentsDirectory.appendingPathComponent("Projects")
    }

    // MARK: - Initialization

    init() {
        Task {
            await ensureDirectoriesExist()
        }
    }

    private func ensureDirectoriesExist() {
        try? FileUtils.createDirectoryIfNeeded(at: projectsDirectory)
    }

    // MARK: - Project Operations

    /// Get the directory URL for a project.
    func projectDirectory(for projectId: String) -> URL {
        projectsDirectory.appendingPathComponent(projectId)
    }

    /// List all project IDs.
    func listProjectIds() throws -> [String] {
        let contents = try fileManager.contentsOfDirectory(
            at: projectsDirectory, includingPropertiesForKeys: [.isDirectoryKey])
        return contents.compactMap { url in
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory),
                isDirectory.boolValue
            {
                return url.lastPathComponent
            }
            return nil
        }
    }

    /// Create a new project directory.
    func createProject(id: String) throws -> URL {
        let dir = projectDirectory(for: id)
        try FileUtils.createDirectoryIfNeeded(at: dir)
        return dir
    }

    /// Delete a project.
    func deleteProject(id: String) throws {
        let dir = projectDirectory(for: id)
        try FileUtils.delete(at: dir)
    }

    // MARK: - File Operations

    /// Get the URL for a file within a project.
    func fileURL(projectId: String, path: String) -> URL {
        projectDirectory(for: projectId).appendingPathComponent(path)
    }

    /// List all files in a project directory (optionally filtered by prefix).
    func listFiles(projectId: String, prefix: String? = nil) throws -> [StoredFile] {
        let projectDir = projectDirectory(for: projectId)
        guard fileManager.fileExists(atPath: projectDir.path) else {
            return []
        }

        var files: [StoredFile] = []
        let enumerator = fileManager.enumerator(
            at: projectDir, includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey])

        while let url = enumerator?.nextObject() as? URL {
            guard
                let resourceValues = try? url.resourceValues(forKeys: [
                    .isRegularFileKey, .fileSizeKey,
                ]),
                resourceValues.isRegularFile == true
            else {
                continue
            }

            let relativePath = url.path.replacingOccurrences(of: projectDir.path + "/", with: "")

            if let prefix = prefix, !relativePath.hasPrefix(prefix) {
                continue
            }

            files.append(
                StoredFile(
                    path: relativePath,
                    url: url,
                    size: resourceValues.fileSize ?? 0
                ))
        }

        return files
    }

    /// Read a text file.
    func readTextFile(projectId: String, path: String) throws -> String {
        let url = fileURL(projectId: projectId, path: path)
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// Read a binary file.
    func readBinaryFile(projectId: String, path: String) throws -> Data {
        let url = fileURL(projectId: projectId, path: path)
        return try Data(contentsOf: url)
    }

    /// Write a text file.
    func writeTextFile(projectId: String, path: String, content: String) throws {
        let url = fileURL(projectId: projectId, path: path)
        try FileUtils.createDirectoryIfNeeded(at: url.deletingLastPathComponent())
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Write a binary file.
    func writeBinaryFile(projectId: String, path: String, data: Data) throws {
        let url = fileURL(projectId: projectId, path: path)
        try FileUtils.createDirectoryIfNeeded(at: url.deletingLastPathComponent())
        try data.write(to: url)
    }

    /// Delete a file.
    func deleteFile(projectId: String, path: String) throws {
        let url = fileURL(projectId: projectId, path: path)
        try FileUtils.delete(at: url)
    }

    /// Check if a file exists.
    func fileExists(projectId: String, path: String) -> Bool {
        let url = fileURL(projectId: projectId, path: path)
        return FileUtils.fileExists(at: url)
    }

    // MARK: - CA Bundle Operations

    /// Get the .ca folder path for a project.
    func caFolderPath(projectName: String) -> String {
        "\(projectName).ca"
    }

    /// Get path to a specific CA type folder (Floating.ca, Background.ca, Wallpaper.ca).
    func caTypeFolderPath(projectName: String, caType: CAType) -> String {
        "\(caFolderPath(projectName: projectName))/\(caType.folderName)"
    }

    /// Get path to assets folder for a CA type.
    func assetsFolderPath(projectName: String, caType: CAType) -> String {
        "\(caTypeFolderPath(projectName: projectName, caType: caType))/assets"
    }

    /// Read the main.caml file for a CA type.
    func readMainCAML(projectId: String, projectName: String, caType: CAType) throws -> String {
        let path = "\(caTypeFolderPath(projectName: projectName, caType: caType))/main.caml"
        return try readTextFile(projectId: projectId, path: path)
    }

    /// Write the main.caml file for a CA type.
    func writeMainCAML(projectId: String, projectName: String, caType: CAType, content: String)
        throws
    {
        let path = "\(caTypeFolderPath(projectName: projectName, caType: caType))/main.caml"
        try writeTextFile(projectId: projectId, path: path, content: content)
    }

    /// Read an asset file.
    func readAsset(projectId: String, projectName: String, caType: CAType, assetName: String) throws
        -> Data
    {
        let path = "\(assetsFolderPath(projectName: projectName, caType: caType))/\(assetName)"
        return try readBinaryFile(projectId: projectId, path: path)
    }

    /// Write an asset file.
    func writeAsset(
        projectId: String, projectName: String, caType: CAType, assetName: String, data: Data
    ) throws {
        let path = "\(assetsFolderPath(projectName: projectName, caType: caType))/\(assetName)"
        try writeBinaryFile(projectId: projectId, path: path, data: data)
    }

    /// Delete an asset file.
    func deleteAsset(projectId: String, projectName: String, caType: CAType, assetName: String)
        throws
    {
        let path = "\(assetsFolderPath(projectName: projectName, caType: caType))/\(assetName)"
        try deleteFile(projectId: projectId, path: path)
    }

    /// List all assets for a CA type.
    func listAssets(projectId: String, projectName: String, caType: CAType) throws -> [StoredFile] {
        let prefix = assetsFolderPath(projectName: projectName, caType: caType)
        return try listFiles(projectId: projectId, prefix: prefix)
    }
}
struct StoredFile {
    let path: String
    let url: URL
    let size: Int

    var filename: String {
        url.lastPathComponent
    }

    var fileExtension: String? {
        url.pathExtension.isEmpty ? nil : url.pathExtension
    }

    var isImage: Bool {
        guard let ext = fileExtension else { return false }
        return FileUtils.isImageExtension(ext)
    }

    var isVideo: Bool {
        guard let ext = fileExtension else { return false }
        return FileUtils.isVideoExtension(ext)
    }
}
