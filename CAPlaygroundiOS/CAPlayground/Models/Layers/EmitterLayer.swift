//
//  EmitterLayer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Emitter shape types.
/// Mirrors: `'point' | 'line' | 'rectangle' | 'cuboid' | 'circle' | 'sphere'`
import Foundation

/// Emitter mode types.
/// Mirrors: `'volume' | 'outline' | 'surface'`

/// Render mode for emitter layers.
/// Mirrors: `'unordered' | 'additive'`

/// A single emitter cell configuration.
/// Mirrors the TypeScript class: `CAEmitterCell`

/// A layer that displays particle effects.
/// Mirrors the TypeScript type: `EmitterLayer`
enum EmitterShape: String, Codable {
    case point
    case line
    case rectangle
    case cuboid
    case circle
    case sphere
}
enum EmitterMode: String, Codable {
    case volume
    case outline
    case surface
}
enum RenderMode: String, Codable {
    case unordered
    case additive
}
struct CAEmitterCell: Codable, Hashable, Identifiable {
    var id: String
    var src: String?
    var name: String?

    // Birth rate and lifetime
    var birthRate: CGFloat?
    var lifetime: CGFloat?
    var lifetimeRange: CGFloat?

    // Velocity
    var velocity: CGFloat?
    var velocityRange: CGFloat?

    // Acceleration
    var xAcceleration: CGFloat?
    var yAcceleration: CGFloat?
    var zAcceleration: CGFloat?

    // Scale
    var scale: CGFloat?
    var scaleRange: CGFloat?
    var scaleSpeed: CGFloat?

    // Spin
    var spin: CGFloat?
    var spinRange: CGFloat?

    // Emission
    var emissionLatitude: CGFloat?
    var emissionLongitude: CGFloat?
    var emissionRange: CGFloat?

    // Alpha
    var alphaSpeed: CGFloat?
    var alphaRange: CGFloat?

    // Color
    var redRange: CGFloat?
    var greenRange: CGFloat?
    var blueRange: CGFloat?
    var redSpeed: CGFloat?
    var greenSpeed: CGFloat?
    var blueSpeed: CGFloat?

    // Contents
    var contentsRect: CGRect?
    var contentsScale: CGFloat?

    init(
        id: String = UUID().uuidString,
        src: String? = nil,
        name: String? = nil,
        birthRate: CGFloat? = 1,
        lifetime: CGFloat? = 1,
        lifetimeRange: CGFloat? = 0,
        velocity: CGFloat? = 0,
        velocityRange: CGFloat? = 0,
        xAcceleration: CGFloat? = 0,
        yAcceleration: CGFloat? = 0,
        zAcceleration: CGFloat? = 0,
        scale: CGFloat? = 1,
        scaleRange: CGFloat? = 0,
        scaleSpeed: CGFloat? = 0,
        spin: CGFloat? = 0,
        spinRange: CGFloat? = 0,
        emissionLatitude: CGFloat? = 0,
        emissionLongitude: CGFloat? = 0,
        emissionRange: CGFloat? = 0,
        alphaSpeed: CGFloat? = 0,
        alphaRange: CGFloat? = 0,
        redRange: CGFloat? = 0,
        greenRange: CGFloat? = 0,
        blueRange: CGFloat? = 0,
        redSpeed: CGFloat? = 0,
        greenSpeed: CGFloat? = 0,
        blueSpeed: CGFloat? = 0,
        contentsRect: CGRect? = nil,
        contentsScale: CGFloat? = 1
    ) {
        self.id = id
        self.src = src
        self.name = name
        self.birthRate = birthRate
        self.lifetime = lifetime
        self.lifetimeRange = lifetimeRange
        self.velocity = velocity
        self.velocityRange = velocityRange
        self.xAcceleration = xAcceleration
        self.yAcceleration = yAcceleration
        self.zAcceleration = zAcceleration
        self.scale = scale
        self.scaleRange = scaleRange
        self.scaleSpeed = scaleSpeed
        self.spin = spin
        self.spinRange = spinRange
        self.emissionLatitude = emissionLatitude
        self.emissionLongitude = emissionLongitude
        self.emissionRange = emissionRange
        self.alphaSpeed = alphaSpeed
        self.alphaRange = alphaRange
        self.redRange = redRange
        self.greenRange = greenRange
        self.blueRange = blueRange
        self.redSpeed = redSpeed
        self.greenSpeed = greenSpeed
        self.blueSpeed = blueSpeed
        self.contentsRect = contentsRect
        self.contentsScale = contentsScale
    }
}
struct EmitterLayer: Codable, Hashable, Identifiable {
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
    let type: String = "emitter"

    // Emitter-specific properties
    var emitterPosition: Vec2
    var emitterSize: Size
    var emitterShape: EmitterShape
    var emitterMode: EmitterMode
    var emitterCells: [CAEmitterCell]
    var renderMode: RenderMode

    init(
        id: String = UUID().uuidString,
        name: String = "Emitter Layer",
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
        emitterPosition: Vec2 = Vec2(x: 100, y: 100),
        emitterSize: Size = Size(w: 1, h: 1),
        emitterShape: EmitterShape = .point,
        emitterMode: EmitterMode = .volume,
        emitterCells: [CAEmitterCell] = [],
        renderMode: RenderMode = .unordered
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
        self.emitterPosition = emitterPosition
        self.emitterSize = emitterSize
        self.emitterShape = emitterShape
        self.emitterMode = emitterMode
        self.emitterCells = emitterCells
        self.renderMode = renderMode
    }
}
