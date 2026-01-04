//
//  CAState.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Represents the available device states for wallpapers.
/// Mirrors the TypeScript state types from editor-context.tsx
import Foundation

/// A state override that modifies a layer property in a specific state.
/// Mirrors: `CAStateOverride`

/// Type-erased value for state overrides (supports String and Number).

/// Animation configuration for state transitions.
/// Mirrors: `CAStateTransitionAnim`

/// An element within a state transition.
/// Mirrors: `CAStateTransitionElement`

/// A state transition definition.
/// Mirrors: `CAStateTransition`

/// Gyro parallax configuration for wallpapers.
/// Mirrors: `GyroParallaxDictionary`
enum CAState: String, Codable, CaseIterable, Hashable {
    case baseState = "Base State"
    case locked = "Locked"
    case unlock = "Unlock"
    case sleep = "Sleep"
    case lockedLight = "Locked Light"
    case unlockLight = "Unlock Light"
    case sleepLight = "Sleep Light"
    case lockedDark = "Locked Dark"
    case unlockDark = "Unlock Dark"
    case sleepDark = "Sleep Dark"

    // MARK: - Computed Properties

    var isBaseState: Bool {
        self == .baseState
    }

    var isLightVariant: Bool {
        switch self {
        case .lockedLight, .unlockLight, .sleepLight:
            return true
        default:
            return false
        }
    }

    var isDarkVariant: Bool {
        switch self {
        case .lockedDark, .unlockDark, .sleepDark:
            return true
        default:
            return false
        }
    }

    var baseStateName: String {
        switch self {
        case .baseState: return "Base State"
        case .locked, .lockedLight, .lockedDark: return "Locked"
        case .unlock, .unlockLight, .unlockDark: return "Unlock"
        case .sleep, .sleepLight, .sleepDark: return "Sleep"
        }
    }

    // MARK: - Static Properties

    static let defaultStates: [CAState] = [.locked, .unlock, .sleep]

    static let lightStates: [CAState] = [.lockedLight, .unlockLight, .sleepLight]

    static let darkStates: [CAState] = [.lockedDark, .unlockDark, .sleepDark]

    static let allAppearanceStates: [CAState] = lightStates + darkStates
}
struct CAStateOverride: Codable, Hashable, Identifiable {
    var id: String { "\(targetId)_\(keyPath)" }
    var targetId: String
    var keyPath: String
    var value: AnyCodableValue

    init(targetId: String, keyPath: String, value: AnyCodableValue) {
        self.targetId = targetId
        self.keyPath = keyPath
        self.value = value
    }
}
enum AnyCodableValue: Codable, Hashable {
    case string(String)
    case number(CGFloat)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .number(CGFloat(doubleValue))
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(
                AnyCodableValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath, debugDescription: "Expected String or Number")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(Double(value))
        case .int(let value):
            try container.encode(value)
        }
    }

    var numberValue: CGFloat? {
        switch self {
        case .number(let value): return value
        case .int(let value): return CGFloat(value)
        case .string: return nil
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let value): return value
        default: return nil
        }
    }
}
struct CAStateTransitionAnim: Codable, Hashable {
    var type: String  // e.g., "CASpringAnimation"
    var damping: CGFloat?
    var mass: CGFloat?
    var stiffness: CGFloat?
    var velocity: CGFloat?
    var duration: CGFloat?
    var fillMode: String?
    var keyPath: String?

    init(
        type: String = "CASpringAnimation",
        damping: CGFloat? = 50,
        mass: CGFloat? = 2,
        stiffness: CGFloat? = 300,
        velocity: CGFloat? = 0,
        duration: CGFloat? = 0.8,
        fillMode: String? = "backwards",
        keyPath: String? = nil
    ) {
        self.type = type
        self.damping = damping
        self.mass = mass
        self.stiffness = stiffness
        self.velocity = velocity
        self.duration = duration
        self.fillMode = fillMode
        self.keyPath = keyPath
    }
}
struct CAStateTransitionElement: Codable, Hashable {
    var targetId: String
    var keyPath: String
    var animation: CAStateTransitionAnim?
}
struct CAStateTransition: Codable, Hashable {
    var fromState: String
    var toState: String
    var elements: [CAStateTransitionElement]
}
struct GyroParallaxDictionary: Codable, Hashable, Identifiable {
    var id: String { "\(layerName)_\(axis)" }
    var axis: Axis
    var image: String?  // always null in the original
    var keyPath: KeyPath
    var layerName: String
    var mapMaxTo: CGFloat
    var mapMinTo: CGFloat
    var title: String
    var view: String

    enum Axis: String, Codable {
        case x
        case y
    }
}
