//
//  ImageLayer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Image fit modes.
/// Mirrors the TypeScript type: `'cover' | 'contain' | 'fill' | 'none'`
import Foundation

/// A layer that displays an image.
/// Mirrors the TypeScript type: `ImageLayer`
enum ImageFit: String, Codable {
    case cover
    case contain
    case fill
    case none
}
struct ImageLayer: Codable, Hashable, Identifiable {
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
    let type: String = "image"

    // Image-specific properties
    var src: String
    var fit: ImageFit?

    init(
        id: String = UUID().uuidString,
        name: String = "Image Layer",
        children: [AnyLayer]? = nil,
        position: Vec2 = Vec2(x: 50, y: 50),
        zPosition: CGFloat? = 0,
        size: Size = Size(w: 120, h: 120),
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
        src: String = "",
        fit: ImageFit? = .fill
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
        self.src = src
        self.fit = fit
    }

    // MARK: - Computed Properties

    var effectiveFit: ImageFit {
        fit ?? .fill
    }

    /// Returns the asset path without the leading "assets/" if present
    var assetPath: String {
        if src.hasPrefix("assets/") {
            return String(src.dropFirst(7))
        }
        return src
    }

    /// Returns true if the source is a relative asset path
    var isAssetPath: Bool {
        src.hasPrefix("assets/") || !src.contains("://")
    }
}
