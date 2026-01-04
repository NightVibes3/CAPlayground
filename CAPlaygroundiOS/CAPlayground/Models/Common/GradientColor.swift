//
//  GradientColor.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Foundation

/// A gradient color stop with color and opacity.
/// Mirrors the TypeScript type: `type GradientColor = { color: string; opacity: number }`
import SwiftUI

struct GradientColor: Codable, Hashable, Identifiable {
    let id: String
    var color: String
    var opacity: CGFloat

    init(id: String = UUID().uuidString, color: String, opacity: CGFloat = 1.0) {
        self.id = id
        self.color = color
        self.opacity = opacity
    }

    // MARK: - Computed Properties

    var swiftUIColor: Color {
        Color(hex: color).opacity(opacity)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case color
        case opacity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.color = try container.decode(String.self, forKey: .color)
        self.opacity = try container.decodeIfPresent(CGFloat.self, forKey: .opacity) ?? 1.0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(opacity, forKey: .opacity)
    }
}
