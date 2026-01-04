//
//  AnyLayer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Type-erased wrapper for polymorphic layer handling.
/// Mirrors the TypeScript union type: `AnyLayer`
import Foundation

enum AnyLayer: Codable, Hashable, Identifiable {
    case basic(BasicLayer)
    case image(ImageLayer)
    case text(TextLayer)
    case shape(ShapeLayer)
    case video(VideoLayer)
    case gradient(GradientLayer)
    case emitter(EmitterLayer)
    case transform(TransformLayer)
    case replicator(ReplicatorLayer)
    case liquidGlass(LiquidGlassLayer)

    // MARK: - Identifiable

    var id: String {
        get {
            switch self {
            case .basic(let layer): return layer.id
            case .image(let layer): return layer.id
            case .text(let layer): return layer.id
            case .shape(let layer): return layer.id
            case .video(let layer): return layer.id
            case .gradient(let layer): return layer.id
            case .emitter(let layer): return layer.id
            case .transform(let layer): return layer.id
            case .replicator(let layer): return layer.id
            case .liquidGlass(let layer): return layer.id
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.id = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.id = newValue
                self = .image(layer)
            case .text(var layer):
                layer.id = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.id = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.id = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.id = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.id = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.id = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.id = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.id = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    // MARK: - Common Properties

    var name: String {
        get {
            switch self {
            case .basic(let layer): return layer.name
            case .image(let layer): return layer.name
            case .text(let layer): return layer.name
            case .shape(let layer): return layer.name
            case .video(let layer): return layer.name
            case .gradient(let layer): return layer.name
            case .emitter(let layer): return layer.name
            case .transform(let layer): return layer.name
            case .replicator(let layer): return layer.name
            case .liquidGlass(let layer): return layer.name
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.name = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.name = newValue
                self = .image(layer)
            case .text(var layer):
                layer.name = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.name = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.name = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.name = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.name = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.name = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.name = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.name = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    var position: Vec2 {
        get {
            switch self {
            case .basic(let layer): return layer.position
            case .image(let layer): return layer.position
            case .text(let layer): return layer.position
            case .shape(let layer): return layer.position
            case .video(let layer): return layer.position
            case .gradient(let layer): return layer.position
            case .emitter(let layer): return layer.position
            case .transform(let layer): return layer.position
            case .replicator(let layer): return layer.position
            case .liquidGlass(let layer): return layer.position
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.position = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.position = newValue
                self = .image(layer)
            case .text(var layer):
                layer.position = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.position = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.position = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.position = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.position = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.position = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.position = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.position = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    var size: Size {
        get {
            switch self {
            case .basic(let layer): return layer.size
            case .image(let layer): return layer.size
            case .text(let layer): return layer.size
            case .shape(let layer): return layer.size
            case .video(let layer): return layer.size
            case .gradient(let layer): return layer.size
            case .emitter(let layer): return layer.size
            case .transform(let layer): return layer.size
            case .replicator(let layer): return layer.size
            case .liquidGlass(let layer): return layer.size
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.size = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.size = newValue
                self = .image(layer)
            case .text(var layer):
                layer.size = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.size = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.size = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.size = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.size = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.size = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.size = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.size = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    var opacity: CGFloat? {
        get {
            switch self {
            case .basic(let layer): return layer.opacity
            case .image(let layer): return layer.opacity
            case .text(let layer): return layer.opacity
            case .shape(let layer): return layer.opacity
            case .video(let layer): return layer.opacity
            case .gradient(let layer): return layer.opacity
            case .emitter(let layer): return layer.opacity
            case .transform(let layer): return layer.opacity
            case .replicator(let layer): return layer.opacity
            case .liquidGlass(let layer): return layer.opacity
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.opacity = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.opacity = newValue
                self = .image(layer)
            case .text(var layer):
                layer.opacity = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.opacity = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.opacity = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.opacity = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.opacity = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.opacity = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.opacity = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.opacity = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    var rotation: CGFloat? {
        get {
            switch self {
            case .basic(let layer): return layer.rotation
            case .image(let layer): return layer.rotation
            case .text(let layer): return layer.rotation
            case .shape(let layer): return layer.rotation
            case .video(let layer): return layer.rotation
            case .gradient(let layer): return layer.rotation
            case .emitter(let layer): return layer.rotation
            case .transform(let layer): return layer.rotation
            case .replicator(let layer): return layer.rotation
            case .liquidGlass(let layer): return layer.rotation
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.rotation = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.rotation = newValue
                self = .image(layer)
            case .text(var layer):
                layer.rotation = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.rotation = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.rotation = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.rotation = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.rotation = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.rotation = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.rotation = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.rotation = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    var visible: Bool? {
        get {
            switch self {
            case .basic(let layer): return layer.visible
            case .image(let layer): return layer.visible
            case .text(let layer): return layer.visible
            case .shape(let layer): return layer.visible
            case .video(let layer): return layer.visible
            case .gradient(let layer): return layer.visible
            case .emitter(let layer): return layer.visible
            case .transform(let layer): return layer.visible
            case .replicator(let layer): return layer.visible
            case .liquidGlass(let layer): return layer.visible
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.visible = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.visible = newValue
                self = .image(layer)
            case .text(var layer):
                layer.visible = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.visible = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.visible = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.visible = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.visible = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.visible = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.visible = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.visible = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    var children: [AnyLayer]? {
        get {
            switch self {
            case .basic(let layer): return layer.children
            case .image(let layer): return layer.children
            case .text(let layer): return layer.children
            case .shape(let layer): return layer.children
            case .video(let layer): return layer.children
            case .gradient(let layer): return layer.children
            case .emitter(let layer): return layer.children
            case .transform(let layer): return layer.children
            case .replicator(let layer): return layer.children
            case .liquidGlass(let layer): return layer.children
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.children = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.children = newValue
                self = .image(layer)
            case .text(var layer):
                layer.children = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.children = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.children = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.children = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.children = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.children = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.children = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.children = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    var cornerRadius: CGFloat? {
        get {
            switch self {
            case .basic(let layer): return layer.cornerRadius
            case .image(let layer): return layer.cornerRadius
            case .text(let layer): return layer.cornerRadius
            case .shape(let layer): return layer.cornerRadius
            case .video(let layer): return layer.cornerRadius
            case .gradient(let layer): return layer.cornerRadius
            case .emitter(let layer): return layer.cornerRadius
            case .transform(let layer): return layer.cornerRadius
            case .replicator(let layer): return layer.cornerRadius
            case .liquidGlass(let layer): return layer.cornerRadius
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.cornerRadius = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.cornerRadius = newValue
                self = .image(layer)
            case .text(var layer):
                layer.cornerRadius = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.cornerRadius = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.cornerRadius = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.cornerRadius = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.cornerRadius = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.cornerRadius = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.cornerRadius = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.cornerRadius = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    var backgroundColor: String? {
        get {
            switch self {
            case .basic(let layer): return layer.backgroundColor
            case .image(let layer): return layer.backgroundColor
            case .text(let layer): return layer.backgroundColor
            case .shape(let layer): return layer.backgroundColor
            case .video(let layer): return layer.backgroundColor
            case .gradient(let layer): return layer.backgroundColor
            case .emitter(let layer): return layer.backgroundColor
            case .transform(let layer): return layer.backgroundColor
            case .replicator(let layer): return layer.backgroundColor
            case .liquidGlass(let layer): return layer.backgroundColor
            }
        }
        set {
            switch self {
            case .basic(var layer):
                layer.backgroundColor = newValue
                self = .basic(layer)
            case .image(var layer):
                layer.backgroundColor = newValue
                self = .image(layer)
            case .text(var layer):
                layer.backgroundColor = newValue
                self = .text(layer)
            case .shape(var layer):
                layer.backgroundColor = newValue
                self = .shape(layer)
            case .video(var layer):
                layer.backgroundColor = newValue
                self = .video(layer)
            case .gradient(var layer):
                layer.backgroundColor = newValue
                self = .gradient(layer)
            case .emitter(var layer):
                layer.backgroundColor = newValue
                self = .emitter(layer)
            case .transform(var layer):
                layer.backgroundColor = newValue
                self = .transform(layer)
            case .replicator(var layer):
                layer.backgroundColor = newValue
                self = .replicator(layer)
            case .liquidGlass(var layer):
                layer.backgroundColor = newValue
                self = .liquidGlass(layer)
            }
        }
    }

    // MARK: - Type Info

    var layerType: String {
        switch self {
        case .basic: return "basic"
        case .image: return "image"
        case .text: return "text"
        case .shape: return "shape"
        case .video: return "video"
        case .gradient: return "gradient"
        case .emitter: return "emitter"
        case .transform: return "transform"
        case .replicator: return "replicator"
        case .liquidGlass: return "liquidGlass"
        }
    }

    var displayTypeName: String {
        switch self {
        case .basic: return "Basic"
        case .image: return "Image"
        case .text: return "Text"
        case .shape: return "Shape"
        case .video: return "Video"
        case .gradient: return "Gradient"
        case .emitter: return "Emitter"
        case .transform: return "Transform"
        case .replicator: return "Replicator"
        case .liquidGlass: return "Liquid Glass"
        }
    }

    var iconName: String {
        switch self {
        case .basic: return "square.stack.3d.up"
        case .image: return "photo"
        case .text: return "textformat"
        case .shape: return "square.on.circle"
        case .video: return "video"
        case .gradient: return "paintbrush"
        case .emitter: return "sparkles"
        case .transform: return "arrow.up.left.and.arrow.down.right"
        case .replicator: return "square.on.square"
        case .liquidGlass: return "drop"
        }
    }

    // MARK: - Computed Properties

    var hasChildren: Bool {
        guard let children = children else { return false }
        return !children.isEmpty
    }

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

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "basic":
            self = .basic(try BasicLayer(from: decoder))
        case "image":
            self = .image(try ImageLayer(from: decoder))
        case "text":
            self = .text(try TextLayer(from: decoder))
        case "shape":
            self = .shape(try ShapeLayer(from: decoder))
        case "video":
            self = .video(try VideoLayer(from: decoder))
        case "gradient":
            self = .gradient(try GradientLayer(from: decoder))
        case "emitter":
            self = .emitter(try EmitterLayer(from: decoder))
        case "transform":
            self = .transform(try TransformLayer(from: decoder))
        case "replicator":
            self = .replicator(try ReplicatorLayer(from: decoder))
        case "liquidGlass":
            self = .liquidGlass(try LiquidGlassLayer(from: decoder))
        default:
            // Default to basic layer for unknown types
            self = .basic(try BasicLayer(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .basic(let layer):
            try layer.encode(to: encoder)
        case .image(let layer):
            try layer.encode(to: encoder)
        case .text(let layer):
            try layer.encode(to: encoder)
        case .shape(let layer):
            try layer.encode(to: encoder)
        case .video(let layer):
            try layer.encode(to: encoder)
        case .gradient(let layer):
            try layer.encode(to: encoder)
        case .emitter(let layer):
            try layer.encode(to: encoder)
        case .transform(let layer):
            try layer.encode(to: encoder)
        case .replicator(let layer):
            try layer.encode(to: encoder)
        case .liquidGlass(let layer):
            try layer.encode(to: encoder)
        }
    }
}
