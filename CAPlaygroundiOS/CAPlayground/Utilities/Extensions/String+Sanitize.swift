//
//  String+Sanitize.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Foundation

extension String {
    /// Sanitize a filename to remove unsafe characters.
    /// Mirrors the `sanitizeFilename` function from file-utils.ts
    func sanitizedFilename() -> String {
        // Replace unsafe characters with underscores
        var sanitized =
            self
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "*", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "\"", with: "_")
            .replacingOccurrences(of: "<", with: "_")
            .replacingOccurrences(of: ">", with: "_")
            .replacingOccurrences(of: "|", with: "_")

        // Remove leading/trailing whitespace
        sanitized = sanitized.trimmingCharacters(in: .whitespaces)

        // Replace multiple underscores with single underscore
        while sanitized.contains("__") {
            sanitized = sanitized.replacingOccurrences(of: "__", with: "_")
        }

        // Ensure filename isn't empty
        if sanitized.isEmpty {
            sanitized = "untitled"
        }

        return sanitized
    }

    /// Normalize a string for comparison.
    /// Mirrors the `normalize` function from file-utils.ts
    func normalized() -> String {
        self.lowercased().trimmingCharacters(in: .whitespaces)
    }

    /// Get the file extension from a path.
    var fileExtension: String? {
        guard let lastDot = self.lastIndex(of: ".") else { return nil }
        return String(self[self.index(after: lastDot)...])
    }

    /// Get the filename without extension.
    var filenameWithoutExtension: String {
        guard let lastDot = self.lastIndex(of: ".") else { return self }
        return String(self[..<lastDot])
    }

    /// Get just the filename from a path.
    var filename: String {
        (self as NSString).lastPathComponent
    }

    /// Get the directory path (without filename).
    var directoryPath: String {
        (self as NSString).deletingLastPathComponent
    }

    /// Check if this string is a valid hex color.
    var isValidHexColor: Bool {
        let pattern = "^#?([A-Fa-f0-9]{3}|[A-Fa-f0-9]{4}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$"
        return self.range(of: pattern, options: .regularExpression) != nil
    }

    /// Ensure hex color has # prefix.
    var withHexPrefix: String {
        if self.hasPrefix("#") {
            return self
        }
        return "#\(self)"
    }

    /// Remove # prefix from hex color.
    var withoutHexPrefix: String {
        if self.hasPrefix("#") {
            return String(self.dropFirst())
        }
        return self
    }
}
