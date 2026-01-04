//
//  GradientLayer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Foundation

/// Gradient types available for gradient layers.
/// Mirrors the TypeScript type: `'axial' | 'radial' | 'conic'`
import SwiftUI

/// A layer that displays a gradient.
/// Mirrors the TypeScript type: `GradientLayer`
enum GradientType: String, Codable {
    case axial
    case radial
    case conic
}
struct GradientLayer: Codable, Hashable, Identifiable {
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
    let type: String = "gradient"

    // Gradient-specific properties
    var gradientType: GradientType
    var startPoint: Vec2
    var endPoint: Vec2
    var colors: [GradientColor]

    init(
        id: String = UUID().uuidString,
        name: String = "Gradient Layer",
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
        gradientType: GradientType = .axial,
        startPoint: Vec2 = Vec2(x: 0.5, y: 0),
        endPoint: Vec2 = Vec2(x: 0.5, y: 1),
        colors: [GradientColor] = [
            GradientColor(color: "#3b82f6", opacity: 1),
            GradientColor(color: "#8b5cf6", opacity: 1),
        ]
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
        self.gradientType = gradientType
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.colors = colors
    }

    // MARK: - Computed Properties

    var swiftUIGradient: LinearGradient {
        LinearGradient(
            colors: colors.map { $0.swiftUIColor },
            startPoint: UnitPoint(x: startPoint.x, y: startPoint.y),
            endPoint: UnitPoint(x: endPoint.x, y: endPoint.y)
        )
    }

    var radialGradient: RadialGradient {
        RadialGradient(
            colors: colors.map { $0.swiftUIColor },
            center: UnitPoint(x: startPoint.x, y: startPoint.y),
            startRadius: 0,
            endRadius: max(size.w, size.h) / 2
        )
    }

    var angularGradient: AngularGradient {
        AngularGradient(
            colors: colors.map { $0.swiftUIColor },
            center: UnitPoint(x: startPoint.x, y: startPoint.y)
        )
    }
}
