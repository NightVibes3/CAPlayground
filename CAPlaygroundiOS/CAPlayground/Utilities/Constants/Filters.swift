//
//  Filters.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Available filter types for layers.
/// Mirrors the filters from filters.ts
import Foundation

/// Create a default filter with the given type.
enum FilterType: String, CaseIterable, Codable {
    case gaussianBlur = "CIGaussianBlur"
    case motionBlur = "CIMotionBlur"
    case zoomBlur = "CIZoomBlur"
    case boxBlur = "CIBoxBlur"
    case discBlur = "CIDiscBlur"
    case colorControls = "CIColorControls"
    case exposureAdjust = "CIExposureAdjust"
    case gammaAdjust = "CIGammaAdjust"
    case hueAdjust = "CIHueAdjust"
    case vibrance = "CIVibrance"
    case whitePointAdjust = "CIWhitePointAdjust"
    case sharpenLuminance = "CISharpenLuminance"
    case unsharpMask = "CIUnsharpMask"

    var displayName: String {
        switch self {
        case .gaussianBlur: return "Gaussian Blur"
        case .motionBlur: return "Motion Blur"
        case .zoomBlur: return "Zoom Blur"
        case .boxBlur: return "Box Blur"
        case .discBlur: return "Disc Blur"
        case .colorControls: return "Color Controls"
        case .exposureAdjust: return "Exposure"
        case .gammaAdjust: return "Gamma"
        case .hueAdjust: return "Hue"
        case .vibrance: return "Vibrance"
        case .whitePointAdjust: return "White Point"
        case .sharpenLuminance: return "Sharpen"
        case .unsharpMask: return "Unsharp Mask"
        }
    }

    var category: FilterCategory {
        switch self {
        case .gaussianBlur, .motionBlur, .zoomBlur, .boxBlur, .discBlur:
            return .blur
        case .colorControls, .exposureAdjust, .gammaAdjust, .hueAdjust, .vibrance,
            .whitePointAdjust:
            return .colorAdjustment
        case .sharpenLuminance, .unsharpMask:
            return .sharpen
        }
    }

    var defaultParameters: [String: CGFloat] {
        switch self {
        case .gaussianBlur:
            return ["inputRadius": 10]
        case .motionBlur:
            return ["inputRadius": 10, "inputAngle": 0]
        case .zoomBlur:
            return ["inputAmount": 10]
        case .boxBlur:
            return ["inputRadius": 10]
        case .discBlur:
            return ["inputRadius": 10]
        case .colorControls:
            return ["inputSaturation": 1, "inputBrightness": 0, "inputContrast": 1]
        case .exposureAdjust:
            return ["inputEV": 0]
        case .gammaAdjust:
            return ["inputPower": 1]
        case .hueAdjust:
            return ["inputAngle": 0]
        case .vibrance:
            return ["inputAmount": 0]
        case .whitePointAdjust:
            return [:]
        case .sharpenLuminance:
            return ["inputSharpness": 0.4]
        case .unsharpMask:
            return ["inputRadius": 2.5, "inputIntensity": 0.5]
        }
    }
}
enum FilterCategory: String, CaseIterable {
    case blur = "Blur"
    case colorAdjustment = "Color Adjustment"
    case sharpen = "Sharpen"

    var filters: [FilterType] {
        FilterType.allCases.filter { $0.category == self }
    }
}
func createDefaultFilter(type: FilterType) -> CAFilter {
    let params = type.defaultParameters
    return CAFilter(
        id: IDGenerator.generate(),
        type: type.rawValue,
        inputRadius: params["inputRadius"],
        inputAmount: params["inputAmount"],
        inputScale: params["inputScale"]
    )
}
