//
//  BlendModes.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Foundation

/// Available blend modes for layers.
/// Mirrors the blend modes from blending.ts
import SwiftUI

enum LayerBlendMode: String, CaseIterable, Codable {
    case normal
    case multiply
    case screen
    case overlay
    case darken
    case lighten
    case colorDodge = "color-dodge"
    case colorBurn = "color-burn"
    case hardLight = "hard-light"
    case softLight = "soft-light"
    case difference
    case exclusion
    case hue
    case saturation
    case color
    case luminosity
    case plusDarker = "plus-darker"
    case plusLighter = "plus-lighter"

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .multiply: return "Multiply"
        case .screen: return "Screen"
        case .overlay: return "Overlay"
        case .darken: return "Darken"
        case .lighten: return "Lighten"
        case .colorDodge: return "Color Dodge"
        case .colorBurn: return "Color Burn"
        case .hardLight: return "Hard Light"
        case .softLight: return "Soft Light"
        case .difference: return "Difference"
        case .exclusion: return "Exclusion"
        case .hue: return "Hue"
        case .saturation: return "Saturation"
        case .color: return "Color"
        case .luminosity: return "Luminosity"
        case .plusDarker: return "Plus Darker"
        case .plusLighter: return "Plus Lighter"
        }
    }

    var swiftUIBlendMode: BlendMode {
        switch self {
        case .normal: return .normal
        case .multiply: return .multiply
        case .screen: return .screen
        case .overlay: return .overlay
        case .darken: return .darken
        case .lighten: return .lighten
        case .colorDodge: return .colorDodge
        case .colorBurn: return .colorBurn
        case .hardLight: return .hardLight
        case .softLight: return .softLight
        case .difference: return .difference
        case .exclusion: return .exclusion
        case .hue: return .hue
        case .saturation: return .saturation
        case .color: return .color
        case .luminosity: return .luminosity
        case .plusDarker: return .plusDarker
        case .plusLighter: return .plusLighter
        }
    }

    static func from(string: String?) -> LayerBlendMode {
        guard let string = string else { return .normal }
        return LayerBlendMode(rawValue: string) ?? .normal
    }
}
