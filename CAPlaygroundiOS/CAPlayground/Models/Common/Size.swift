/// A size structure representing width and height dimensions.
/// Mirrors the TypeScript type: `type Size = { w: number; h: number }`
import CoreGraphics
//
//  Size.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Foundation

struct Size: Codable, Hashable, Equatable {
    var w: CGFloat
    var h: CGFloat

    init(w: CGFloat = 0, h: CGFloat = 0) {
        self.w = w
        self.h = h
    }

    // MARK: - Convenience Initializers

    init(cgSize: CGSize) {
        self.w = cgSize.width
        self.h = cgSize.height
    }

    init(width: CGFloat, height: CGFloat) {
        self.w = width
        self.h = height
    }

    // MARK: - Computed Properties

    var cgSize: CGSize {
        CGSize(width: w, height: h)
    }

    var width: CGFloat { w }
    var height: CGFloat { h }

    var aspectRatio: CGFloat {
        guard h > 0 else { return 1 }
        return w / h
    }

    // MARK: - Methods

    func scaled(by factor: CGFloat) -> Size {
        Size(w: w * factor, h: h * factor)
    }

    func fitted(into container: Size, mode: FitMode = .contain) -> Size {
        switch mode {
        case .contain:
            let scale = min(container.w / w, container.h / h)
            return scaled(by: scale)
        case .cover:
            let scale = max(container.w / w, container.h / h)
            return scaled(by: scale)
        case .fill:
            return container
        case .none:
            return self
        }
    }

    // MARK: - Static Constants

    static let zero = Size(w: 0, h: 0)

    // MARK: - Nested Types

    enum FitMode: String, Codable {
        case cover
        case contain
        case fill
        case none
    }
}
