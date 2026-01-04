//
//  Vec2.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Foundation
import CoreGraphics

/// A 2D vector representing position or offset coordinates.
/// Mirrors the TypeScript type: `type Vec2 = { x: number; y: number }`
struct Vec2: Codable, Hashable, Equatable {
    var x: CGFloat
    var y: CGFloat
    
    init(x: CGFloat = 0, y: CGFloat = 0) {
        self.x = x
        self.y = y
    }
    
    // MARK: - Convenience Initializers
    
    init(cgPoint: CGPoint) {
        self.x = cgPoint.x
        self.y = cgPoint.y
    }
    
    // MARK: - Computed Properties
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    // MARK: - Operators
    
    static func + (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: Vec2, rhs: CGFloat) -> Vec2 {
        Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func / (lhs: Vec2, rhs: CGFloat) -> Vec2 {
        Vec2(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    // MARK: - Static Constants
    
    static let zero = Vec2(x: 0, y: 0)
    static let center = Vec2(x: 0.5, y: 0.5)
}
