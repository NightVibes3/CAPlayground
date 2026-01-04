//
//  CGPoint+Extensions.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import CoreGraphics

import SwiftUI

extension CGPoint {
    /// Convert to Vec2 type.
    var toVec2: Vec2 {
        Vec2(x: x, y: y)
    }

    /// Distance to another point.
    func distance(to other: CGPoint) -> CGFloat {
        let dx = other.x - x
        let dy = other.y - y
        return sqrt(dx * dx + dy * dy)
    }

    /// Midpoint between this point and another.
    func midpoint(to other: CGPoint) -> CGPoint {
        CGPoint(x: (x + other.x) / 2, y: (y + other.y) / 2)
    }

    /// Add two points.
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Subtract two points.
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// Multiply point by scalar.
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    /// Divide point by scalar.
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    /// Apply a transform to this point.
    func applying(scale: CGFloat, offset: CGPoint = .zero) -> CGPoint {
        CGPoint(x: x * scale + offset.x, y: y * scale + offset.y)
    }

    /// Clamp point within a rectangle.
    func clamped(to rect: CGRect) -> CGPoint {
        CGPoint(
            x: min(max(x, rect.minX), rect.maxX),
            y: min(max(y, rect.minY), rect.maxY)
        )
    }

    /// Convert to unit point (0-1 range) within a size.
    func toUnitPoint(in size: CGSize) -> UnitPoint {
        guard size.width > 0, size.height > 0 else {
            return UnitPoint(x: 0.5, y: 0.5)
        }
        return UnitPoint(x: x / size.width, y: y / size.height)
    }

    /// Create from unit point and size.
    static func from(unitPoint: UnitPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: unitPoint.x * size.width, y: unitPoint.y * size.height)
    }
}
extension UnitPoint {
    /// Convert to Vec2.
    var toVec2: Vec2 {
        Vec2(x: x, y: y)
    }

    /// Create from Vec2.
    init(_ vec2: Vec2) {
        self.init(x: vec2.x, y: vec2.y)
    }
}
