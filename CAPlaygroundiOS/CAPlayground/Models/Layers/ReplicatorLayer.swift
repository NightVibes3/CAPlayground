//
//  ReplicatorLayer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// A layer that replicates its sublayers.
/// Mirrors the TypeScript type: `ReplicatorLayer`
import Foundation

/// 3D vector for instance translation.
struct ReplicatorLayer: Codable, Hashable, Identifiable {
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
    let type: String = "replicator"

    // Replicator-specific properties
    var instanceCount: Int?
    var instanceTranslation: Vec3?
    var instanceRotation: CGFloat?
    var instanceDelay: CGFloat?

    init(
        id: String = UUID().uuidString,
        name: String = "Replicator Layer",
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
        instanceCount: Int? = 1,
        instanceTranslation: Vec3? = nil,
        instanceRotation: CGFloat? = 0,
        instanceDelay: CGFloat? = 0
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
        self.instanceCount = instanceCount
        self.instanceTranslation = instanceTranslation
        self.instanceRotation = instanceRotation
        self.instanceDelay = instanceDelay
    }

    // MARK: - Computed Properties

    var effectiveInstanceCount: Int {
        instanceCount ?? 1
    }

    var effectiveInstanceRotation: CGFloat {
        instanceRotation ?? 0
    }

    var effectiveInstanceDelay: CGFloat {
        instanceDelay ?? 0
    }
}
struct Vec3: Codable, Hashable {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat

    init(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self.x = x
        self.y = y
        self.z = z
    }

    static let zero = Vec3(x: 0, y: 0, z: 0)
}
