//
//  LayerBase.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Foundation

/// Base protocol that all layer types must conform to.
/// Mirrors the TypeScript type: `LayerBase`
import SwiftUI

/// Base structure containing common properties for all layer types.

/// Filter type for layer effects.
/// Mirrors: `Filter` from filters.ts
protocol LayerProtocol: Identifiable, Codable {
    var id: String { get set }
    var name: String { get set }
    var children: [AnyLayer]? { get set }
    var position: Vec2 { get set }
    var zPosition: CGFloat? { get set }
    var size: Size { get set }
    var opacity: CGFloat? { get set }
    var rotation: CGFloat? { get set }
    var rotationX: CGFloat? { get set }
    var rotationY: CGFloat? { get set }
    var backgroundColor: String? { get set }
    var backgroundOpacity: CGFloat? { get set }
    var borderColor: String? { get set }
    var borderWidth: CGFloat? { get set }
    var cornerRadius: CGFloat? { get set }
    var visible: Bool? { get set }
    var anchorPoint: Vec2? { get set }
    var geometryFlipped: Int? { get set }
    var masksToBounds: Int? { get set }
    var animations: [CALayerAnimation]? { get set }
    var blendMode: String? { get set }
    var filters: [CAFilter]? { get set }
}
struct LayerBase: Codable, Hashable {
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

    init(
        id: String = UUID().uuidString,
        name: String = "Layer",
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
        anchorPoint: Vec2? = Vec2(x: 0.5, y: 0.5),
        geometryFlipped: Int? = nil,
        masksToBounds: Int? = nil,
        animations: [CALayerAnimation]? = nil,
        blendMode: String? = nil,
        filters: [CAFilter]? = nil
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
    }

    // MARK: - Computed Properties

    var isVisible: Bool {
        visible ?? true
    }

    var effectiveOpacity: CGFloat {
        opacity ?? 1.0
    }

    var frame: CGRect {
        CGRect(
            x: position.x - size.w / 2,
            y: position.y - size.h / 2,
            width: size.w,
            height: size.h
        )
    }

    var center: CGPoint {
        position.cgPoint
    }
}
struct CAFilter: Codable, Hashable, Identifiable {
    var id: String
    var type: String
    var inputRadius: CGFloat?
    var inputAmount: CGFloat?
    var inputScale: CGFloat?

    init(
        id: String = UUID().uuidString,
        type: String,
        inputRadius: CGFloat? = nil,
        inputAmount: CGFloat? = nil,
        inputScale: CGFloat? = nil
    ) {
        self.id = id
        self.type = type
        self.inputRadius = inputRadius
        self.inputAmount = inputAmount
        self.inputScale = inputScale
    }
}
