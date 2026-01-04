//
//  KeyPath.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Animatable property key paths.
/// Mirrors the TypeScript type: `KeyPath`
import Foundation

enum KeyPath: String, Codable, CaseIterable, Hashable {
    case position
    case positionX = "position.x"
    case positionY = "position.y"
    case transformTranslationX = "transform.translation.x"
    case transformTranslationY = "transform.translation.y"
    case transformRotationX = "transform.rotation.x"
    case transformRotationY = "transform.rotation.y"
    case transformRotationZ = "transform.rotation.z"
    case opacity
    case bounds
    case boundsWidth = "bounds.size.width"
    case boundsHeight = "bounds.size.height"
    case cornerRadius
    case zPosition

    // MARK: - Display Names

    var displayName: String {
        switch self {
        case .position: return "Position"
        case .positionX: return "Position X"
        case .positionY: return "Position Y"
        case .transformTranslationX: return "Translation X"
        case .transformTranslationY: return "Translation Y"
        case .transformRotationX: return "Rotation X"
        case .transformRotationY: return "Rotation Y"
        case .transformRotationZ: return "Rotation Z"
        case .opacity: return "Opacity"
        case .bounds: return "Bounds"
        case .boundsWidth: return "Width"
        case .boundsHeight: return "Height"
        case .cornerRadius: return "Corner Radius"
        case .zPosition: return "Z Position"
        }
    }

    // MARK: - Categories

    var isPositionKeyPath: Bool {
        switch self {
        case .position, .positionX, .positionY:
            return true
        default:
            return false
        }
    }

    var isTransformKeyPath: Bool {
        switch self {
        case .transformTranslationX, .transformTranslationY,
            .transformRotationX, .transformRotationY, .transformRotationZ:
            return true
        default:
            return false
        }
    }

    var isBoundsKeyPath: Bool {
        switch self {
        case .bounds, .boundsWidth, .boundsHeight:
            return true
        default:
            return false
        }
    }

    var isRotationKeyPath: Bool {
        switch self {
        case .transformRotationX, .transformRotationY, .transformRotationZ:
            return true
        default:
            return false
        }
    }

    // MARK: - Grouped Key Paths

    static let stateOverrideKeyPaths: [KeyPath] = [
        .positionX, .positionY,
        .boundsWidth, .boundsHeight,
        .transformRotationZ, .transformRotationX, .transformRotationY,
        .opacity, .cornerRadius,
    ]

    static let animatableKeyPaths: [KeyPath] = [
        .position, .positionX, .positionY,
        .transformTranslationX, .transformTranslationY,
        .transformRotationX, .transformRotationY, .transformRotationZ,
        .opacity, .bounds,
    ]
}
