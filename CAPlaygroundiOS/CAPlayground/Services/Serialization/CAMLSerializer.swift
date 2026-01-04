//
//  CAMLSerializer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Serializer for converting layer models to CAML (Core Animation Markup Language) format.
/// Mirrors the serialization logic from serializeCAML.ts

import Foundation

struct CAMLSerializer {

    /// Serialize a layer hierarchy to CAML XML string.
    func serialize(
        root: AnyLayer,
        project: CAProject,
        states: [String]?,
        stateOverrides: [String: [CAStateOverride]]?,
        transitions: [CAStateTransition]?,
        parallaxGroups: [GyroParallaxDictionary]?
    ) -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<caml xmlns=\"http://www.apple.com/CoreAnimation/1.0\">\n"

        // Serialize root layer
        xml += serializeLayer(root, indent: 2)

        // Serialize states
        if let states = states, !states.isEmpty {
            xml += "\n\n" + indent(2) + "<MicaStates type=\"NSArray\">\n"
            for state in states {
                xml += indent(4) + "<string>\(escapeXML(state))</string>\n"
            }
            xml += indent(2) + "</MicaStates>\n"
        }

        // Serialize state overrides
        if let overrides = stateOverrides, !overrides.isEmpty {
            xml += "\n" + serializeStateOverrides(overrides, indent: 2)
        }

        // Serialize transitions
        if let transitions = transitions, !transitions.isEmpty {
            xml += "\n" + serializeTransitions(transitions, indent: 2)
        }

        // Serialize parallax groups
        if let groups = parallaxGroups, !groups.isEmpty {
            xml += "\n" + serializeParallaxGroups(groups, indent: 2)
        }

        xml += "\n</caml>\n"

        return xml
    }

    // MARK: - Layer Serialization

    private func serializeLayer(_ layer: AnyLayer, indent indentLevel: Int) -> String {
        var xml = ""
        let ind = indent(indentLevel)

        // Determine element name and type
        let (elementName, layerClass) = layerElementInfo(layer)

        xml += ind + "<\(elementName)"
        if let layerClass = layerClass {
            xml += " class=\"\(layerClass)\""
        }
        xml += ">\n"

        // Common properties
        xml += serializeCommonProperties(layer, indent: indentLevel + 2)

        // Type-specific properties
        xml += serializeTypeSpecificProperties(layer, indent: indentLevel + 2)

        // Children
        if let children = layer.children, !children.isEmpty {
            xml += "\n" + indent(indentLevel + 2) + "<sublayers type=\"NSArray\">\n"
            for child in children {
                xml += serializeLayer(child, indent: indentLevel + 4)
            }
            xml += indent(indentLevel + 2) + "</sublayers>\n"
        }

        xml += ind + "</\(elementName)>\n"

        return xml
    }

    private func layerElementInfo(_ layer: AnyLayer) -> (String, String?) {
        switch layer {
        case .basic: return ("CALayer", nil)
        case .text: return ("CATextLayer", nil)
        case .image: return ("CALayer", nil)  // Images use contentsPath
        case .shape: return ("CAShapeLayer", nil)
        case .video: return ("CALayer", nil)
        case .gradient: return ("CAGradientLayer", nil)
        case .emitter: return ("CAEmitterLayer", nil)
        case .transform: return ("CATransformLayer", nil)
        case .replicator: return ("CAReplicatorLayer", nil)
        case .liquidGlass: return ("CALayer", "MicaLiquidGlassLayer")
        }
    }

    private func serializeCommonProperties(_ layer: AnyLayer, indent indentLevel: Int) -> String {
        var xml = ""
        let ind = indent(indentLevel)

        // Name
        xml += ind + "<key>name</key>\n"
        xml += ind + "<string>\(escapeXML(layer.name))</string>\n"

        // Position
        xml += ind + "<key>position</key>\n"
        xml +=
            ind
            + "<point>\(formatNumber(layer.position.x)) \(formatNumber(layer.position.y))</point>\n"

        // Bounds
        xml += ind + "<key>bounds</key>\n"
        xml +=
            ind + "<rect>0 0 \(formatNumber(layer.size.w)) \(formatNumber(layer.size.h))</rect>\n"

        // Opacity
        if let opacity = layer.opacity, opacity != 1 {
            xml += ind + "<key>opacity</key>\n"
            xml += ind + "<real>\(formatNumber(opacity))</real>\n"
        }

        // Rotation
        if let rotation = layer.rotation, rotation != 0 {
            xml += ind + "<key>transform.rotation.z</key>\n"
            xml += ind + "<real>\(formatNumber(rotation))</real>\n"
        }

        // Background color
        if let bgColor = layer.backgroundColor {
            xml += ind + "<key>backgroundColor</key>\n"
            xml += ind + "<color>\(bgColor)</color>\n"
        }

        // Corner radius
        if let radius = layer.cornerRadius, radius > 0 {
            xml += ind + "<key>cornerRadius</key>\n"
            xml += ind + "<real>\(formatNumber(radius))</real>\n"
        }

        // Visibility (hidden)
        if layer.visible == false {
            xml += ind + "<key>hidden</key>\n"
            xml += ind + "<true/>\n"
        }

        return xml
    }

    private func serializeTypeSpecificProperties(_ layer: AnyLayer, indent indentLevel: Int)
        -> String
    {
        let ind = indent(indentLevel)
        var xml = ""

        switch layer {
        case .text(let textLayer):
            xml += ind + "<key>string</key>\n"
            xml += ind + "<string>\(escapeXML(textLayer.text))</string>\n"

            if let fontSize = textLayer.fontSize {
                xml += ind + "<key>fontSize</key>\n"
                xml += ind + "<real>\(formatNumber(fontSize))</real>\n"
            }

            if let fontFamily = textLayer.fontFamily {
                xml += ind + "<key>fontName</key>\n"
                xml += ind + "<string>\(escapeXML(fontFamily))</string>\n"
            }

            if let color = textLayer.color {
                xml += ind + "<key>foregroundColor</key>\n"
                xml += ind + "<color>\(color)</color>\n"
            }

        case .image(let imageLayer):
            xml += ind + "<key>contentsPath</key>\n"
            xml += ind + "<string>\(escapeXML(imageLayer.src))</string>\n"

        case .shape(let shapeLayer):
            if let fill = shapeLayer.fill {
                xml += ind + "<key>fillColor</key>\n"
                xml += ind + "<color>\(fill)</color>\n"
            }
            if let stroke = shapeLayer.stroke {
                xml += ind + "<key>strokeColor</key>\n"
                xml += ind + "<color>\(stroke)</color>\n"
            }
            if let strokeWidth = shapeLayer.strokeWidth, strokeWidth > 0 {
                xml += ind + "<key>lineWidth</key>\n"
                xml += ind + "<real>\(formatNumber(strokeWidth))</real>\n"
            }

        case .gradient(let gradientLayer):
            xml += ind + "<key>type</key>\n"
            xml += ind + "<string>\(gradientLayer.gradientType.rawValue)</string>\n"

            xml += ind + "<key>startPoint</key>\n"
            xml +=
                ind
                + "<point>\(formatNumber(gradientLayer.startPoint.x)) \(formatNumber(gradientLayer.startPoint.y))</point>\n"

            xml += ind + "<key>endPoint</key>\n"
            xml +=
                ind
                + "<point>\(formatNumber(gradientLayer.endPoint.x)) \(formatNumber(gradientLayer.endPoint.y))</point>\n"

            xml += ind + "<key>colors</key>\n"
            xml += ind + "<array type=\"NSArray\">\n"
            for color in gradientLayer.colors {
                xml += ind + "  <color>\(color.color)</color>\n"
            }
            xml += ind + "</array>\n"

        case .emitter(let emitterLayer):
            xml += ind + "<key>emitterPosition</key>\n"
            xml +=
                ind
                + "<point>\(formatNumber(emitterLayer.emitterPosition.x)) \(formatNumber(emitterLayer.emitterPosition.y))</point>\n"

            xml += ind + "<key>emitterSize</key>\n"
            xml +=
                ind
                + "<size>\(formatNumber(emitterLayer.emitterSize.w)) \(formatNumber(emitterLayer.emitterSize.h))</size>\n"

            xml += ind + "<key>emitterShape</key>\n"
            xml += ind + "<string>\(emitterLayer.emitterShape.rawValue)</string>\n"

            xml += ind + "<key>emitterMode</key>\n"
            xml += ind + "<string>\(emitterLayer.emitterMode.rawValue)</string>\n"

            xml += ind + "<key>renderMode</key>\n"
            xml += ind + "<string>\(emitterLayer.renderMode.rawValue)</string>\n"

        case .replicator(let replicatorLayer):
            if let count = replicatorLayer.instanceCount {
                xml += ind + "<key>instanceCount</key>\n"
                xml += ind + "<integer>\(count)</integer>\n"
            }

            if let delay = replicatorLayer.instanceDelay {
                xml += ind + "<key>instanceDelay</key>\n"
                xml += ind + "<real>\(formatNumber(delay))</real>\n"
            }

        case .video(let videoLayer):
            xml += ind + "<key>frameCount</key>\n"
            xml += ind + "<integer>\(videoLayer.frameCount)</integer>\n"

            if let fps = videoLayer.fps {
                xml += ind + "<key>fps</key>\n"
                xml += ind + "<real>\(formatNumber(fps))</real>\n"
            }

        case .basic, .transform, .liquidGlass:
            break
        }

        return xml
    }

    // MARK: - State Override Serialization

    private func serializeStateOverrides(
        _ overrides: [String: [CAStateOverride]], indent indentLevel: Int
    ) -> String {
        var xml = indent(indentLevel) + "<MicaStateOverrides type=\"NSDictionary\">\n"

        for (stateName, stateOverrides) in overrides {
            xml += indent(indentLevel + 2) + "<key>\(escapeXML(stateName))</key>\n"
            xml += indent(indentLevel + 2) + "<array type=\"NSArray\">\n"

            for override in stateOverrides {
                xml += indent(indentLevel + 4) + "<dict>\n"
                xml += indent(indentLevel + 6) + "<key>targetId</key>\n"
                xml +=
                    indent(indentLevel + 6) + "<string>\(escapeXML(override.targetId))</string>\n"
                xml += indent(indentLevel + 6) + "<key>keyPath</key>\n"
                xml += indent(indentLevel + 6) + "<string>\(escapeXML(override.keyPath))</string>\n"
                xml += indent(indentLevel + 6) + "<key>value</key>\n"

                switch override.value {
                case .string(let str):
                    xml += indent(indentLevel + 6) + "<string>\(escapeXML(str))</string>\n"
                case .number(let num):
                    xml += indent(indentLevel + 6) + "<real>\(formatNumber(num))</real>\n"
                case .int(let num):
                    xml += indent(indentLevel + 6) + "<integer>\(num)</integer>\n"
                }

                xml += indent(indentLevel + 4) + "</dict>\n"
            }

            xml += indent(indentLevel + 2) + "</array>\n"
        }

        xml += indent(indentLevel) + "</MicaStateOverrides>\n"
        return xml
    }

    // MARK: - Transition Serialization

    private func serializeTransitions(_ transitions: [CAStateTransition], indent indentLevel: Int)
        -> String
    {
        var xml = indent(indentLevel) + "<MicaStateTransitions type=\"NSArray\">\n"

        for transition in transitions {
            xml += indent(indentLevel + 2) + "<dict>\n"
            xml += indent(indentLevel + 4) + "<key>fromState</key>\n"
            xml += indent(indentLevel + 4) + "<string>\(escapeXML(transition.fromState))</string>\n"
            xml += indent(indentLevel + 4) + "<key>toState</key>\n"
            xml += indent(indentLevel + 4) + "<string>\(escapeXML(transition.toState))</string>\n"
            xml += indent(indentLevel + 4) + "<key>elements</key>\n"
            xml += indent(indentLevel + 4) + "<array type=\"NSArray\">\n"

            for element in transition.elements {
                xml += indent(indentLevel + 6) + "<dict>\n"
                xml += indent(indentLevel + 8) + "<key>targetId</key>\n"
                xml += indent(indentLevel + 8) + "<string>\(escapeXML(element.targetId))</string>\n"
                xml += indent(indentLevel + 8) + "<key>keyPath</key>\n"
                xml += indent(indentLevel + 8) + "<string>\(escapeXML(element.keyPath))</string>\n"

                if let animation = element.animation {
                    xml += indent(indentLevel + 8) + "<key>animation</key>\n"
                    xml += indent(indentLevel + 8) + "<dict>\n"
                    xml += indent(indentLevel + 10) + "<key>type</key>\n"
                    xml += indent(indentLevel + 10) + "<string>\(animation.type)</string>\n"
                    if let duration = animation.duration {
                        xml += indent(indentLevel + 10) + "<key>duration</key>\n"
                        xml += indent(indentLevel + 10) + "<real>\(formatNumber(duration))</real>\n"
                    }
                    xml += indent(indentLevel + 8) + "</dict>\n"
                }

                xml += indent(indentLevel + 6) + "</dict>\n"
            }

            xml += indent(indentLevel + 4) + "</array>\n"
            xml += indent(indentLevel + 2) + "</dict>\n"
        }

        xml += indent(indentLevel) + "</MicaStateTransitions>\n"
        return xml
    }

    // MARK: - Parallax Serialization

    private func serializeParallaxGroups(
        _ groups: [GyroParallaxDictionary], indent indentLevel: Int
    ) -> String {
        var xml = indent(indentLevel) + "<wallpaperParallaxGroups type=\"NSArray\">\n"

        for group in groups {
            xml += indent(indentLevel + 2) + "<dict>\n"
            xml += indent(indentLevel + 4) + "<key>axis</key>\n"
            xml += indent(indentLevel + 4) + "<string>\(group.axis.rawValue)</string>\n"
            xml += indent(indentLevel + 4) + "<key>layerName</key>\n"
            xml += indent(indentLevel + 4) + "<string>\(escapeXML(group.layerName))</string>\n"
            xml += indent(indentLevel + 4) + "<key>keyPath</key>\n"
            xml += indent(indentLevel + 4) + "<string>\(group.keyPath.rawValue)</string>\n"
            xml += indent(indentLevel + 4) + "<key>mapMinTo</key>\n"
            xml += indent(indentLevel + 4) + "<real>\(formatNumber(group.mapMinTo))</real>\n"
            xml += indent(indentLevel + 4) + "<key>mapMaxTo</key>\n"
            xml += indent(indentLevel + 4) + "<real>\(formatNumber(group.mapMaxTo))</real>\n"
            xml += indent(indentLevel + 2) + "</dict>\n"
        }

        xml += indent(indentLevel) + "</wallpaperParallaxGroups>\n"
        return xml
    }

    // MARK: - Helpers

    private func indent(_ level: Int) -> String {
        String(repeating: "  ", count: level)
    }

    private func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    private func formatNumber(_ value: CGFloat) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%.4f", value).trimmingCharacters(in: CharacterSet(charactersIn: "0"))
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
    }
}
