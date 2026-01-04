//
//  CAAnimation.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// A layer animation configuration.
/// Mirrors the TypeScript type: `Animation`
import Foundation

/// Animation value that can be a number, Vec2, or Size.
struct CALayerAnimation: Codable, Hashable, Identifiable {
    var id: String
    var enabled: Bool?
    var keyPath: KeyPath
    var autoreverses: Int?
    var values: [AnimationValue]?
    var durationSeconds: CGFloat?
    var infinite: Int?
    var repeatDurationSeconds: CGFloat?
    var speed: CGFloat?

    init(
        id: String = UUID().uuidString,
        enabled: Bool? = true,
        keyPath: KeyPath = .opacity,
        autoreverses: Int? = 0,
        values: [AnimationValue]? = nil,
        durationSeconds: CGFloat? = 1.0,
        infinite: Int? = 0,
        repeatDurationSeconds: CGFloat? = nil,
        speed: CGFloat? = 1.0
    ) {
        self.id = id
        self.enabled = enabled
        self.keyPath = keyPath
        self.autoreverses = autoreverses
        self.values = values
        self.durationSeconds = durationSeconds
        self.infinite = infinite
        self.repeatDurationSeconds = repeatDurationSeconds
        self.speed = speed
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case enabled, keyPath, autoreverses, values, durationSeconds
        case infinite, repeatDurationSeconds, speed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled)
        self.keyPath = try container.decode(KeyPath.self, forKey: .keyPath)
        self.autoreverses = try container.decodeIfPresent(Int.self, forKey: .autoreverses)
        self.values = try container.decodeIfPresent([AnimationValue].self, forKey: .values)
        self.durationSeconds = try container.decodeIfPresent(CGFloat.self, forKey: .durationSeconds)
        self.infinite = try container.decodeIfPresent(Int.self, forKey: .infinite)
        self.repeatDurationSeconds = try container.decodeIfPresent(
            CGFloat.self, forKey: .repeatDurationSeconds)
        self.speed = try container.decodeIfPresent(CGFloat.self, forKey: .speed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(enabled, forKey: .enabled)
        try container.encode(keyPath, forKey: .keyPath)
        try container.encodeIfPresent(autoreverses, forKey: .autoreverses)
        try container.encodeIfPresent(values, forKey: .values)
        try container.encodeIfPresent(durationSeconds, forKey: .durationSeconds)
        try container.encodeIfPresent(infinite, forKey: .infinite)
        try container.encodeIfPresent(repeatDurationSeconds, forKey: .repeatDurationSeconds)
        try container.encodeIfPresent(speed, forKey: .speed)
    }

    // MARK: - Computed Properties

    var isEnabled: Bool {
        enabled ?? true
    }

    var shouldAutoReverse: Bool {
        autoreverses == 1
    }

    var isInfinite: Bool {
        infinite == 1
    }

    var effectiveDuration: CGFloat {
        durationSeconds ?? 1.0
    }

    var effectiveSpeed: CGFloat {
        speed ?? 1.0
    }
}
enum AnimationValue: Codable, Hashable {
    case number(CGFloat)
    case vec2(Vec2)
    case size(Size)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Try to decode as number first
        if let number = try? container.decode(CGFloat.self) {
            self = .number(number)
            return
        }

        // Try to decode as Vec2
        if let vec2 = try? container.decode(Vec2.self) {
            self = .vec2(vec2)
            return
        }

        // Try to decode as Size
        if let size = try? container.decode(Size.self) {
            self = .size(size)
            return
        }

        throw DecodingError.typeMismatch(
            AnimationValue.self,
            DecodingError.Context(
                codingPath: decoder.codingPath, debugDescription: "Expected number, Vec2, or Size")
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .number(let value):
            try container.encode(value)
        case .vec2(let value):
            try container.encode(value)
        case .size(let value):
            try container.encode(value)
        }
    }

    var numberValue: CGFloat? {
        if case .number(let value) = self {
            return value
        }
        return nil
    }

    var vec2Value: Vec2? {
        if case .vec2(let value) = self {
            return value
        }
        return nil
    }

    var sizeValue: Size? {
        if case .size(let value) = self {
            return value
        }
        return nil
    }
}
