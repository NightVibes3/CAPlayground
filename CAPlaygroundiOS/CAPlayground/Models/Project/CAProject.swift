//
//  CAProject.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// The main project metadata structure.
/// Mirrors the TypeScript type: `CAProject`
import Foundation

struct CAProject: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var width: CGFloat
    var height: CGFloat
    var background: String?
    /// Flip Geometry for the root layer (0 = bottom-left origin, 1 = top-left origin)
    var geometryFlipped: Int?

    init(
        id: String = UUID().uuidString,
        name: String = "Untitled",
        width: CGFloat = 390,
        height: CGFloat = 844,
        background: String? = "#e5e7eb",
        geometryFlipped: Int? = 0
    ) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
        self.background = background
        self.geometryFlipped = geometryFlipped
    }

    // MARK: - Computed Properties

    var size: Size {
        Size(w: width, h: height)
    }

    var center: Vec2 {
        Vec2(x: width / 2, y: height / 2)
    }

    // MARK: - Presets

    static let defaultiPhone = CAProject(
        name: "iPhone Wallpaper",
        width: 390,
        height: 844
    )

    static let defaultiPad = CAProject(
        name: "iPad Wallpaper",
        width: 1024,
        height: 1366
    )
}
