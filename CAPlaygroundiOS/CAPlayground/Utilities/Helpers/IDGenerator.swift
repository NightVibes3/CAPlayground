//
//  IDGenerator.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// ID generation utilities.
import Foundation

struct IDGenerator {

    /// Generate a short unique ID (12 characters).
    static func generate() -> String {
        LayerUtils.genId()
    }

    /// Generate a UUID string.
    static func uuid() -> String {
        UUID().uuidString
    }

    /// Generate a timestamp-based ID.
    static func timestampId() -> String {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let random = Int.random(in: 0..<10000)
        return "\(timestamp)_\(random)"
    }

    /// Generate a layer ID with a prefix.
    static func layerId(prefix: String = "layer") -> String {
        "\(prefix)_\(generate())"
    }

    /// Generate a project ID.
    static func projectId() -> String {
        "proj_\(generate())"
    }
}
