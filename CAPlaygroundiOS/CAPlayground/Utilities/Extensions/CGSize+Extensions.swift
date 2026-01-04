//
//  CGSize+Extensions.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import CoreGraphics

extension CGSize {
    /// Convert to Size type.
    var toSize: Size {
        Size(w: width, h: height)
    }

    /// Aspect ratio (width / height).
    var aspectRatio: CGFloat {
        guard height > 0 else { return 1 }
        return width / height
    }

    /// Scale the size by a factor.
    func scaled(by factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
    }

    /// Fit this size into a container.
    func fitted(into container: CGSize, mode: Size.FitMode = .contain) -> CGSize {
        switch mode {
        case .contain:
            let scale = min(container.width / width, container.height / height)
            return scaled(by: scale)
        case .cover:
            let scale = max(container.width / width, container.height / height)
            return scaled(by: scale)
        case .fill:
            return container
        case .none:
            return self
        }
    }

    /// Center point of a rectangle with this size at origin.
    var center: CGPoint {
        CGPoint(x: width / 2, y: height / 2)
    }

    /// Area (width * height).
    var area: CGFloat {
        width * height
    }

    /// Check if this size is larger than another.
    func isLarger(than other: CGSize) -> Bool {
        area > other.area
    }

    /// Maximum dimension.
    var maxDimension: CGFloat {
        max(width, height)
    }

    /// Minimum dimension.
    var minDimension: CGFloat {
        min(width, height)
    }
}
