//
//  VideoLayer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Sync state frame mode for video layers.
/// Mirrors the TypeScript enum: `SyncStateFrameMode`
import Foundation

/// Frame modes for each state.

/// Calculation mode for frame interpolation.

/// A layer that displays animated video frames.
/// Mirrors the TypeScript type: `VideoLayer`
enum SyncStateFrameMode: String, Codable {
    case beginning
    case end
}
struct SyncStateFrameModes: Codable, Hashable {
    var locked: SyncStateFrameMode?
    var unlock: SyncStateFrameMode?
    var sleep: SyncStateFrameMode?

    enum CodingKeys: String, CodingKey {
        case locked = "Locked"
        case unlock = "Unlock"
        case sleep = "Sleep"
    }
}
enum CalculationMode: String, Codable {
    case linear
    case discrete
}
struct VideoLayer: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var children: [AnyLayer]?
    var position: Vec2
    var zPosition: CGFloat?
    var size: Size
    var opacity: CGFloat?
    var rotation: CGFloat?
    var rotationX: CGFloat?
    var rotationY: CGFloat?
    var backgroundColor: String?
    var backgroundOpacity: CGFloat?
    var borderColor: String?
    var borderWidth: CGFloat?
    var cornerRadius: CGFloat?
    var visible: Bool?
    var anchorPoint: Vec2?
    var geometryFlipped: Int?
    var masksToBounds: Int?
    var animations: [CALayerAnimation]?
    var blendMode: String?
    var filters: [CAFilter]?

    // Type discriminator
    let type: String = "video"

    // Video-specific properties
    var frameCount: Int
    var fps: CGFloat?
    var duration: CGFloat?
    var autoReverses: Bool?
    var framePrefix: String?
    var frameExtension: String?
    var calculationMode: CalculationMode?
    var currentFrameIndex: Int?
    var syncWWithState: Bool?
    var syncStateFrameMode: SyncStateFrameModes?

    init(
        id: String = UUID().uuidString,
        name: String = "Video Layer",
        children: [AnyLayer]? = nil,
        position: Vec2 = Vec2(x: 50, y: 50),
        zPosition: CGFloat? = 0,
        size: Size = Size(w: 200, h: 200),
        opacity: CGFloat? = 1,
        rotation: CGFloat? = 0,
        rotationX: CGFloat? = 0,
        rotationY: CGFloat? = 0,
        backgroundColor: String? = nil,
        backgroundOpacity: CGFloat? = nil,
        borderColor: String? = nil,
        borderWidth: CGFloat? = nil,
        cornerRadius: CGFloat? = 0,
        visible: Bool? = true,
        anchorPoint: Vec2? = nil,
        geometryFlipped: Int? = nil,
        masksToBounds: Int? = nil,
        animations: [CALayerAnimation]? = nil,
        blendMode: String? = nil,
        filters: [CAFilter]? = nil,
        frameCount: Int = 0,
        fps: CGFloat? = 30,
        duration: CGFloat? = nil,
        autoReverses: Bool? = false,
        framePrefix: String? = nil,
        frameExtension: String? = ".jpg",
        calculationMode: CalculationMode? = .linear,
        currentFrameIndex: Int? = 0,
        syncWWithState: Bool? = false,
        syncStateFrameMode: SyncStateFrameModes? = nil
    ) {
        self.id = id
        self.name = name
        self.children = children
        self.position = position
        self.zPosition = zPosition
        self.size = size
        self.opacity = opacity
        self.rotation = rotation
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.backgroundColor = backgroundColor
        self.backgroundOpacity = backgroundOpacity
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.visible = visible
        self.anchorPoint = anchorPoint
        self.geometryFlipped = geometryFlipped
        self.masksToBounds = masksToBounds
        self.animations = animations
        self.blendMode = blendMode
        self.filters = filters
        self.frameCount = frameCount
        self.fps = fps
        self.duration = duration
        self.autoReverses = autoReverses
        self.framePrefix = framePrefix
        self.frameExtension = frameExtension
        self.calculationMode = calculationMode
        self.currentFrameIndex = currentFrameIndex
        self.syncWWithState = syncWWithState
        self.syncStateFrameMode = syncStateFrameMode
    }

    // MARK: - Computed Properties

    var effectiveFps: CGFloat {
        fps ?? 30
    }

    var effectiveDuration: CGFloat {
        if let duration = duration {
            return duration
        }
        guard effectiveFps > 0 else { return 0 }
        return CGFloat(frameCount) / effectiveFps
    }

    var effectiveFramePrefix: String {
        framePrefix ?? "\(id)_frame_"
    }

    var effectiveFrameExtension: String {
        var ext = frameExtension ?? ".jpg"
        if !ext.hasPrefix(".") {
            ext = ".\(ext)"
        }
        return ext
    }

    /// Generate the filename for a specific frame index
    func frameFilename(at index: Int) -> String {
        "\(effectiveFramePrefix)\(index)\(effectiveFrameExtension)"
    }

    /// Generate all frame filenames
    var allFrameFilenames: [String] {
        (0..<frameCount).map { frameFilename(at: $0) }
    }
}
