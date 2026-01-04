//
//  FileUtils.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Utility functions for file operations.
/// Mirrors functions from file-utils.ts
import Foundation

struct FileUtils {

    /// Sanitize a filename to remove unsafe characters.
    static func sanitizeFilename(_ filename: String) -> String {
        filename.sanitizedFilename()
    }

    /// Normalize a string for comparison (lowercase, trimmed).
    static func normalize(_ str: String) -> String {
        str.normalized()
    }

    /// Convert a data URL to Data.
    static func dataURLToData(_ dataURL: String) -> Data? {
        guard let commaIndex = dataURL.firstIndex(of: ",") else { return nil }
        let base64String = String(dataURL[dataURL.index(after: commaIndex)...])
        return Data(base64Encoded: base64String)
    }

    /// Convert Data to a data URL with MIME type.
    static func dataToDataURL(_ data: Data, mimeType: String) -> String {
        let base64 = data.base64EncodedString()
        return "data:\(mimeType);base64,\(base64)"
    }

    /// Get MIME type from file extension.
    static func mimeType(for extension: String) -> String {
        let ext = `extension`.lowercased()
        switch ext {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "webp":
            return "image/webp"
        case "svg":
            return "image/svg+xml"
        case "mp4":
            return "video/mp4"
        case "mov":
            return "video/quicktime"
        case "caml":
            return "application/xml"
        case "xml":
            return "application/xml"
        case "json":
            return "application/json"
        default:
            return "application/octet-stream"
        }
    }

    /// Get file extension from MIME type.
    static func fileExtension(for mimeType: String) -> String {
        switch mimeType.lowercased() {
        case "image/jpeg":
            return "jpg"
        case "image/png":
            return "png"
        case "image/gif":
            return "gif"
        case "image/webp":
            return "webp"
        case "image/svg+xml":
            return "svg"
        case "video/mp4":
            return "mp4"
        case "video/quicktime":
            return "mov"
        default:
            return "bin"
        }
    }

    /// Check if a file extension is an image type.
    static func isImageExtension(_ ext: String) -> Bool {
        let imageExtensions: Set<String> = [
            "jpg", "jpeg", "png", "gif", "webp", "svg", "heic", "heif",
        ]
        return imageExtensions.contains(ext.lowercased())
    }

    /// Check if a file extension is a video type.
    static func isVideoExtension(_ ext: String) -> Bool {
        let videoExtensions: Set<String> = ["mp4", "mov", "m4v", "gif"]
        return videoExtensions.contains(ext.lowercased())
    }

    /// Create a unique filename if file already exists.
    static func uniqueFilename(_ filename: String, existingNames: Set<String>) -> String {
        if !existingNames.contains(filename) {
            return filename
        }

        let name = filename.filenameWithoutExtension
        let ext = filename.fileExtension ?? ""

        var counter = 1
        var newName = "\(name)_\(counter)"
        if !ext.isEmpty {
            newName += ".\(ext)"
        }

        while existingNames.contains(newName) {
            counter += 1
            newName = "\(name)_\(counter)"
            if !ext.isEmpty {
                newName += ".\(ext)"
            }
        }

        return newName
    }

    /// Get the documents directory URL.
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Get the caches directory URL.
    static var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    /// Create a directory if it doesn't exist.
    static func createDirectoryIfNeeded(at url: URL) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    /// List files in a directory.
    static func listFiles(in directory: URL) throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    }

    /// Delete a file or directory.
    static func delete(at url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    /// Copy a file.
    static func copy(from source: URL, to destination: URL) throws {
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: source, to: destination)
    }

    /// Move a file.
    static func move(from source: URL, to destination: URL) throws {
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: source, to: destination)
    }

    /// Check if a file exists.
    static func fileExists(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    /// Get file size.
    static func fileSize(at url: URL) -> Int64? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
            let size = attributes[.size] as? Int64
        else {
            return nil
        }
        return size
    }
}
