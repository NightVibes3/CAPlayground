//
//  ShapeLayer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Shape types available for shape layers.
/// Mirrors the TypeScript type: `ShapeKind = 'rect' | 'circle' | 'rounded-rect'`
import Foundation

/// A layer that displays a shape (rectangle, circle, or rounded rectangle).
/// Mirrors the TypeScript type: `ShapeLayer`
enum ShapeKind: String, Codable {
    case rect
    case circle
    case roundedRect = "rounded-rect"
}
struct ShapeLayer: Codable, Hashable, Identifiable {
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
    let type: String = "shape"

    // Shape-specific properties
    var shape: ShapeKind
    var fill: String?
    var stroke: String?
    var strokeWidth: CGFloat?
    var radius: CGFloat?

    init(
        id: String = UUID().uuidString,
        name: String = "Shape Layer",
        children: [AnyLayer]? = nil,
        position: Vec2 = Vec2(x: 50, y: 50),
        zPosition: CGFloat? = 0,
        size: Size = Size(w: 100, h: 100),
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
        shape: ShapeKind = .rect,
        fill: String? = "#3b82f6",
        stroke: String? = nil,
        strokeWidth: CGFloat? = nil,
        radius: CGFloat? = nil
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
        self.shape = shape
        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.radius = radius
    }

    // MARK: - Computed Properties

    var effectiveFill: String? {
        fill
    }

    var effectiveStrokeWidth: CGFloat {
        strokeWidth ?? 0
    }

    var effectiveRadius: CGFloat {
        radius ?? cornerRadius ?? 0
    }
}
