//
//  TextLayer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Text alignment options.
/// Mirrors the TypeScript type: `'left' | 'center' | 'right' | 'justified'`
import Foundation

/// A layer that displays text content.
/// Mirrors the TypeScript type: `TextLayer`
enum TextAlignment: String, Codable {
    case left
    case center
    case right
    case justified
}
struct TextLayer: Codable, Hashable, Identifiable {
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
    let type: String = "text"

    // Text-specific properties
    var text: String
    var fontFamily: String?
    var fontSize: CGFloat?
    var color: String?
    var align: TextAlignment?
    /// When 1, text is wrapped within the bounds width. When 0, no wrapping.
    var wrapped: Int?

    init(
        id: String = UUID().uuidString,
        name: String = "Text Layer",
        children: [AnyLayer]? = nil,
        position: Vec2 = Vec2(x: 50, y: 50),
        zPosition: CGFloat? = 0,
        size: Size = Size(w: 120, h: 40),
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
        text: String = "Text Layer",
        fontFamily: String? = "SFProText-Regular",
        fontSize: CGFloat? = 16,
        color: String? = "#111827",
        align: TextAlignment? = .center,
        wrapped: Int? = 1
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
        self.text = text
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.color = color
        self.align = align
        self.wrapped = wrapped
    }

    // MARK: - Computed Properties

    var isWrapped: Bool {
        wrapped == 1
    }

    var effectiveFontSize: CGFloat {
        fontSize ?? 16
    }

    var effectiveFontFamily: String {
        fontFamily ?? "SFProText-Regular"
    }

    var effectiveColor: String {
        color ?? "#111827"
    }

    var effectiveAlignment: TextAlignment {
        align ?? .center
    }
}
