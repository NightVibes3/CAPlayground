//
//  CAPlaygroundTests.swift
//  CAPlayground
//

import XCTest

@testable import CAPlaygroundCore

final class CAPlaygroundTests: XCTestCase {

    func testVec2Creation() {
        let vec = Vec2(x: 10, y: 20)
        XCTAssertEqual(vec.x, 10)
        XCTAssertEqual(vec.y, 20)
    }

    func testSizeCreation() {
        let size = Size(w: 100, h: 200)
        XCTAssertEqual(size.w, 100)
        XCTAssertEqual(size.h, 200)
    }

    func testIDGeneration() {
        let id1 = IDGenerator.generate()
        let id2 = IDGenerator.generate()
        XCTAssertNotEqual(id1, id2)
        XCTAssertFalse(id1.isEmpty)
    }

    func testStringSanitization() {
        let dangerous = "My/Project:Name*Test"
        let safe = dangerous.sanitizeFilename()
        XCTAssertFalse(safe.contains("/"))
        XCTAssertFalse(safe.contains(":"))
        XCTAssertFalse(safe.contains("*"))
    }

    func testBasicLayerCreation() {
        let layer = BasicLayer(
            id: "test-id",
            name: "Test Layer",
            position: Vec2(x: 50, y: 100),
            size: Size(w: 200, h: 150)
        )

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.name, "Test Layer")
        XCTAssertEqual(layer.position.x, 50)
        XCTAssertEqual(layer.size.w, 200)
    }

    func testTextLayerDefaults() {
        let layer = TextLayer(
            id: "text-1",
            name: "Text",
            position: Vec2(x: 0, y: 0),
            size: Size(w: 100, h: 40),
            text: "Hello"
        )

        XCTAssertEqual(layer.text, "Hello")
        XCTAssertEqual(layer.effectiveFontSize, 16)  // default
        XCTAssertEqual(layer.effectiveColor, "#000000")  // default
    }

    func testAnyLayerEncoding() throws {
        let basic = BasicLayer(
            id: "basic-1",
            name: "Basic",
            position: Vec2(x: 0, y: 0),
            size: Size(w: 100, h: 100)
        )
        let anyLayer = AnyLayer.basic(basic)

        let encoder = JSONEncoder()
        let data = try encoder.encode(anyLayer)
        XCTAssertNotNil(data)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyLayer.self, from: data)
        XCTAssertEqual(decoded.id, "basic-1")
        XCTAssertEqual(decoded.name, "Basic")
    }

    func testCAMLSerializer() {
        let serializer = CAMLSerializer()
        let layer = BasicLayer(
            id: "root",
            name: "Root",
            position: Vec2(x: 195, y: 422),
            size: Size(w: 390, h: 844)
        )

        let project = CAProject(
            id: "proj-1",
            name: "Test Project",
            width: 390,
            height: 844
        )

        let caml = serializer.serialize(
            root: .basic(layer),
            project: project,
            states: ["Locked", "Unlock"],
            stateOverrides: nil,
            transitions: nil,
            parallaxGroups: nil
        )

        XCTAssertTrue(caml.contains("<?xml"))
        XCTAssertTrue(caml.contains("Root"))
        XCTAssertTrue(caml.contains("MicaStates"))
    }
}
