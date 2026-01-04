//
//  Devices.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Device presets for preview sizing.
/// Mirrors the devices from devices.ts
import Foundation

/// All available device presets.
struct DevicePreset: Identifiable, Hashable {
    let id: String
    let name: String
    let width: CGFloat
    let height: CGFloat
    let scale: CGFloat
    let category: DeviceCategory

    var size: Size {
        Size(w: width, h: height)
    }

    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }

    var aspectRatio: CGFloat {
        width / height
    }
}
enum DeviceCategory: String, CaseIterable {
    case iphone = "iPhone"
    case ipad = "iPad"
    case watch = "Apple Watch"
    case mac = "Mac"
    case custom = "Custom"
}
struct DevicePresets {

    // MARK: - iPhones

    static let iPhone15ProMax = DevicePreset(
        id: "iphone-15-pro-max",
        name: "iPhone 15 Pro Max",
        width: 430,
        height: 932,
        scale: 3,
        category: .iphone
    )

    static let iPhone15Pro = DevicePreset(
        id: "iphone-15-pro",
        name: "iPhone 15 Pro",
        width: 393,
        height: 852,
        scale: 3,
        category: .iphone
    )

    static let iPhone15Plus = DevicePreset(
        id: "iphone-15-plus",
        name: "iPhone 15 Plus",
        width: 430,
        height: 932,
        scale: 3,
        category: .iphone
    )

    static let iPhone15 = DevicePreset(
        id: "iphone-15",
        name: "iPhone 15",
        width: 393,
        height: 852,
        scale: 3,
        category: .iphone
    )

    static let iPhone14ProMax = DevicePreset(
        id: "iphone-14-pro-max",
        name: "iPhone 14 Pro Max",
        width: 430,
        height: 932,
        scale: 3,
        category: .iphone
    )

    static let iPhone14Pro = DevicePreset(
        id: "iphone-14-pro",
        name: "iPhone 14 Pro",
        width: 393,
        height: 852,
        scale: 3,
        category: .iphone
    )

    static let iPhoneSE = DevicePreset(
        id: "iphone-se",
        name: "iPhone SE",
        width: 375,
        height: 667,
        scale: 2,
        category: .iphone
    )

    // MARK: - iPads

    static let iPadPro129 = DevicePreset(
        id: "ipad-pro-12-9",
        name: "iPad Pro 12.9\"",
        width: 1024,
        height: 1366,
        scale: 2,
        category: .ipad
    )

    static let iPadPro11 = DevicePreset(
        id: "ipad-pro-11",
        name: "iPad Pro 11\"",
        width: 834,
        height: 1194,
        scale: 2,
        category: .ipad
    )

    static let iPadAir = DevicePreset(
        id: "ipad-air",
        name: "iPad Air",
        width: 820,
        height: 1180,
        scale: 2,
        category: .ipad
    )

    static let iPadMini = DevicePreset(
        id: "ipad-mini",
        name: "iPad mini",
        width: 768,
        height: 1024,
        scale: 2,
        category: .ipad
    )

    // MARK: - Apple Watches

    static let appleWatchUltra = DevicePreset(
        id: "apple-watch-ultra",
        name: "Apple Watch Ultra",
        width: 198,
        height: 242,
        scale: 2,
        category: .watch
    )

    static let appleWatch45mm = DevicePreset(
        id: "apple-watch-45mm",
        name: "Apple Watch 45mm",
        width: 184,
        height: 224,
        scale: 2,
        category: .watch
    )

    static let appleWatch41mm = DevicePreset(
        id: "apple-watch-41mm",
        name: "Apple Watch 41mm",
        width: 176,
        height: 215,
        scale: 2,
        category: .watch
    )

    // MARK: - Collections

    static let allPhones: [DevicePreset] = [
        iPhone15ProMax, iPhone15Pro, iPhone15Plus, iPhone15,
        iPhone14ProMax, iPhone14Pro, iPhoneSE,
    ]

    static let allTablets: [DevicePreset] = [
        iPadPro129, iPadPro11, iPadAir, iPadMini,
    ]

    static let allWatches: [DevicePreset] = [
        appleWatchUltra, appleWatch45mm, appleWatch41mm,
    ]

    static let all: [DevicePreset] = allPhones + allTablets + allWatches

    static func preset(for id: String) -> DevicePreset? {
        all.first { $0.id == id }
    }

    static func presets(for category: DeviceCategory) -> [DevicePreset] {
        all.filter { $0.category == category }
    }

    /// Default preset for new projects.
    static let `default` = iPhone15Pro
}
