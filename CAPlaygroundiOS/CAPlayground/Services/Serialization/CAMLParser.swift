//
//  CAMLParser.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Parser for CAML (Core Animation Markup Language) files.
/// Mirrors the parsing logic from caml.ts
import Foundation

// MARK: - Helper Types

class CAMLParser: NSObject, XMLParserDelegate {

    private var elementStack: [XMLElement] = []
    private var currentElement: XMLElement?
    private var rootElement: XMLElement?
    private var currentText: String = ""

    // MARK: - Public API

    /// Parse a CAML string into a layer hierarchy.
    func parseCAML(_ camlString: String) throws -> AnyLayer? {
        guard let data = camlString.data(using: .utf8) else {
            throw CAMLParserError.invalidData
        }

        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse() else {
            throw CAMLParserError.parseError(
                parser.parserError?.localizedDescription ?? "Unknown error")
        }

        guard let root = rootElement else {
            throw CAMLParserError.noRootElement
        }

        return try convertToLayer(root)
    }

    /// Parse states from a CAML string.
    func parseStates(_ camlString: String) -> [String] {
        // Extract state names from the CAML
        var states: [String] = []

        // Look for state definitions in the XML
        if let statesMatch = camlString.range(
            of: "<MicaStates.*?</MicaStates>", options: .regularExpression)
        {
            let statesBlock = String(camlString[statesMatch])

            // Extract individual state names
            let statePattern = "<string>([^<]+)</string>"
            if let regex = try? NSRegularExpression(pattern: statePattern) {
                let nsString = statesBlock as NSString
                let matches = regex.matches(
                    in: statesBlock, range: NSRange(location: 0, length: nsString.length))

                for match in matches {
                    if let range = Range(match.range(at: 1), in: statesBlock) {
                        let stateName = String(statesBlock[range])
                        if !stateName.isEmpty && stateName != "Base State" {
                            states.append(stateName)
                        }
                    }
                }
            }
        }

        // Default states if none found
        if states.isEmpty {
            states = ["Locked", "Unlock", "Sleep"]
        }

        return states
    }

    /// Parse state overrides from a CAML string.
    func parseStateOverrides(_ camlString: String) -> [String: [CAStateOverride]] {
        // This is a simplified implementation
        // A full implementation would parse the MicaStateOverrides section
        return [:]
    }

    /// Parse wallpaper parallax groups from a CAML string.
    func parseWallpaperParallaxGroups(_ camlString: String) -> [GyroParallaxDictionary] {
        // This is a simplified implementation
        // A full implementation would parse the wallpaperParallaxGroups section
        return []
    }

    // MARK: - XMLParserDelegate

    func parser(
        _ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
        qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]
    ) {
        let element = XMLElement(name: elementName, attributes: attributeDict)

        if let current = currentElement {
            current.children.append(element)
            elementStack.append(current)
        } else {
            rootElement = element
        }

        currentElement = element
        currentText = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(
        _ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            currentElement?.text = trimmedText
        }

        if !elementStack.isEmpty {
            currentElement = elementStack.removeLast()
        }
        currentText = ""
    }

    // MARK: - Conversion

    private func convertToLayer(_ element: XMLElement) throws -> AnyLayer? {
        // Check for layer type
        let typeName = element.attributes["type"] ?? element.name

        switch typeName.lowercased() {
        case "calayer", "layer", "basic":
            return try convertToBasicLayer(element)
        case "catextlayer", "text":
            return try convertToTextLayer(element)
        case "caimagelayer", "image":
            return try convertToImageLayer(element)
        case "cashapelayer", "shape":
            return try convertToShapeLayer(element)
        case "caemitterlayer", "emitter":
            return try convertToEmitterLayer(element)
        case "cagradientlayer", "gradient":
            return try convertToGradientLayer(element)
        case "careplicatorlayer", "replicator":
            return try convertToReplicatorLayer(element)
        case "catransformlayer", "transform":
            return try convertToTransformLayer(element)
        default:
            return try convertToBasicLayer(element)
        }
    }

    private func convertToBasicLayer(_ element: XMLElement) throws -> AnyLayer {
        let base = extractLayerBase(from: element)
        let layer = BasicLayer(
            id: base.id,
            name: base.name,
            children: try extractChildren(from: element),
            position: base.position,
            zPosition: base.zPosition,
            size: base.size,
            opacity: base.opacity,
            rotation: base.rotation,
            rotationX: base.rotationX,
            rotationY: base.rotationY,
            backgroundColor: base.backgroundColor,
            backgroundOpacity: base.backgroundOpacity,
            borderColor: base.borderColor,
            borderWidth: base.borderWidth,
            cornerRadius: base.cornerRadius,
            visible: base.visible,
            anchorPoint: base.anchorPoint,
            geometryFlipped: base.geometryFlipped,
            masksToBounds: base.masksToBounds,
            animations: base.animations,
            blendMode: base.blendMode,
            filters: base.filters
        )
        return .basic(layer)
    }

    private func convertToTextLayer(_ element: XMLElement) throws -> AnyLayer {
        let base = extractLayerBase(from: element)
        let layer = TextLayer(
            id: base.id,
            name: base.name,
            children: try extractChildren(from: element),
            position: base.position,
            zPosition: base.zPosition,
            size: base.size,
            opacity: base.opacity,
            rotation: base.rotation,
            backgroundColor: base.backgroundColor,
            cornerRadius: base.cornerRadius,
            visible: base.visible,
            text: element.stringValue(for: "string") ?? element.stringValue(for: "text") ?? "",
            fontFamily: element.stringValue(for: "fontName"),
            fontSize: element.cgFloatValue(for: "fontSize"),
            color: element.stringValue(for: "foregroundColor")
        )
        return .text(layer)
    }

    private func convertToImageLayer(_ element: XMLElement) throws -> AnyLayer {
        let base = extractLayerBase(from: element)
        let layer = ImageLayer(
            id: base.id,
            name: base.name,
            children: try extractChildren(from: element),
            position: base.position,
            zPosition: base.zPosition,
            size: base.size,
            opacity: base.opacity,
            rotation: base.rotation,
            backgroundColor: base.backgroundColor,
            cornerRadius: base.cornerRadius,
            visible: base.visible,
            src: element.stringValue(for: "contentsPath") ?? element.stringValue(for: "src") ?? ""
        )
        return .image(layer)
    }

    private func convertToShapeLayer(_ element: XMLElement) throws -> AnyLayer {
        let base = extractLayerBase(from: element)
        let shapeType = element.stringValue(for: "shape") ?? "rect"
        let layer = ShapeLayer(
            id: base.id,
            name: base.name,
            children: try extractChildren(from: element),
            position: base.position,
            zPosition: base.zPosition,
            size: base.size,
            opacity: base.opacity,
            rotation: base.rotation,
            backgroundColor: base.backgroundColor,
            cornerRadius: base.cornerRadius,
            visible: base.visible,
            shape: ShapeKind(rawValue: shapeType) ?? .rect,
            fill: element.stringValue(for: "fillColor"),
            stroke: element.stringValue(for: "strokeColor"),
            strokeWidth: element.cgFloatValue(for: "lineWidth")
        )
        return .shape(layer)
    }

    private func convertToEmitterLayer(_ element: XMLElement) throws -> AnyLayer {
        let base = extractLayerBase(from: element)
        let layer = EmitterLayer(
            id: base.id,
            name: base.name,
            children: try extractChildren(from: element),
            position: base.position,
            size: base.size,
            opacity: base.opacity,
            visible: base.visible,
            emitterPosition: Vec2(
                x: element.cgFloatValue(for: "emitterPosition.x") ?? base.size.w / 2,
                y: element.cgFloatValue(for: "emitterPosition.y") ?? base.size.h / 2
            ),
            emitterSize: Size(
                w: element.cgFloatValue(for: "emitterSize.width") ?? 1,
                h: element.cgFloatValue(for: "emitterSize.height") ?? 1
            ),
            emitterShape: EmitterShape(
                rawValue: element.stringValue(for: "emitterShape") ?? "point") ?? .point,
            emitterMode: EmitterMode(rawValue: element.stringValue(for: "emitterMode") ?? "volume")
                ?? .volume,
            emitterCells: [],
            renderMode: RenderMode(rawValue: element.stringValue(for: "renderMode") ?? "unordered")
                ?? .unordered
        )
        return .emitter(layer)
    }

    private func convertToGradientLayer(_ element: XMLElement) throws -> AnyLayer {
        let base = extractLayerBase(from: element)
        let layer = GradientLayer(
            id: base.id,
            name: base.name,
            children: try extractChildren(from: element),
            position: base.position,
            size: base.size,
            opacity: base.opacity,
            visible: base.visible,
            gradientType: GradientType(rawValue: element.stringValue(for: "type") ?? "axial")
                ?? .axial,
            startPoint: Vec2(
                x: element.cgFloatValue(for: "startPoint.x") ?? 0.5,
                y: element.cgFloatValue(for: "startPoint.y") ?? 0
            ),
            endPoint: Vec2(
                x: element.cgFloatValue(for: "endPoint.x") ?? 0.5,
                y: element.cgFloatValue(for: "endPoint.y") ?? 1
            ),
            colors: []
        )
        return .gradient(layer)
    }

    private func convertToReplicatorLayer(_ element: XMLElement) throws -> AnyLayer {
        let base = extractLayerBase(from: element)
        let layer = ReplicatorLayer(
            id: base.id,
            name: base.name,
            children: try extractChildren(from: element),
            position: base.position,
            size: base.size,
            opacity: base.opacity,
            visible: base.visible,
            instanceCount: element.intValue(for: "instanceCount"),
            instanceTranslation: Vec3(
                x: element.cgFloatValue(for: "instanceTransform.translation.x") ?? 0,
                y: element.cgFloatValue(for: "instanceTransform.translation.y") ?? 0,
                z: element.cgFloatValue(for: "instanceTransform.translation.z") ?? 0
            ),
            instanceRotation: element.cgFloatValue(for: "instanceTransform.rotation"),
            instanceDelay: element.cgFloatValue(for: "instanceDelay")
        )
        return .replicator(layer)
    }

    private func convertToTransformLayer(_ element: XMLElement) throws -> AnyLayer {
        let base = extractLayerBase(from: element)
        let layer = TransformLayer(
            id: base.id,
            name: base.name,
            children: try extractChildren(from: element),
            position: base.position,
            size: base.size,
            opacity: base.opacity,
            visible: base.visible
        )
        return .transform(layer)
    }

    private func extractLayerBase(from element: XMLElement) -> LayerBase {
        LayerBase(
            id: element.stringValue(for: "id") ?? element.stringValue(for: "name")
                ?? IDGenerator.generate(),
            name: element.stringValue(for: "name") ?? "Layer",
            position: Vec2(
                x: element.cgFloatValue(for: "position.x") ?? 0,
                y: element.cgFloatValue(for: "position.y") ?? 0
            ),
            zPosition: element.cgFloatValue(for: "zPosition"),
            size: Size(
                w: element.cgFloatValue(for: "bounds.size.width") ?? 100,
                h: element.cgFloatValue(for: "bounds.size.height") ?? 100
            ),
            opacity: element.cgFloatValue(for: "opacity"),
            rotation: element.cgFloatValue(for: "transform.rotation.z"),
            rotationX: element.cgFloatValue(for: "transform.rotation.x"),
            rotationY: element.cgFloatValue(for: "transform.rotation.y"),
            backgroundColor: element.stringValue(for: "backgroundColor"),
            cornerRadius: element.cgFloatValue(for: "cornerRadius"),
            visible: element.stringValue(for: "hidden") != "true",
            anchorPoint: Vec2(
                x: element.cgFloatValue(for: "anchorPoint.x") ?? 0.5,
                y: element.cgFloatValue(for: "anchorPoint.y") ?? 0.5
            ),
            geometryFlipped: element.intValue(for: "geometryFlipped"),
            masksToBounds: element.intValue(for: "masksToBounds")
        )
    }

    private func extractChildren(from element: XMLElement) throws -> [AnyLayer]? {
        let sublayersElement = element.children.first {
            $0.name == "sublayers" || $0.name == "children"
        }
        guard let sublayers = sublayersElement else { return nil }

        var children: [AnyLayer] = []
        for child in sublayers.children {
            if let layer = try convertToLayer(child) {
                children.append(layer)
            }
        }

        return children.isEmpty ? nil : children
    }
}
private class XMLElement {
    let name: String
    var attributes: [String: String]
    var children: [XMLElement] = []
    var text: String?

    init(name: String, attributes: [String: String] = [:]) {
        self.name = name
        self.attributes = attributes
    }

    func stringValue(for key: String) -> String? {
        // Check attributes first
        if let value = attributes[key] {
            return value
        }

        // Then check children
        for child in children {
            if child.name == "key" && child.text == key {
                // Next sibling should be the value
                if let index = children.firstIndex(where: { $0 === child }),
                    index + 1 < children.count
                {
                    return children[index + 1].text
                }
            }
            if child.name == key {
                return child.text
            }
        }

        return nil
    }

    func cgFloatValue(for key: String) -> CGFloat? {
        guard let str = stringValue(for: key), let value = Double(str) else {
            return nil
        }
        return CGFloat(value)
    }

    func intValue(for key: String) -> Int? {
        guard let str = stringValue(for: key), let value = Int(str) else {
            return nil
        }
        return value
    }
}
enum CAMLParserError: Error {
    case invalidData
    case parseError(String)
    case noRootElement
    case invalidLayerType
}
