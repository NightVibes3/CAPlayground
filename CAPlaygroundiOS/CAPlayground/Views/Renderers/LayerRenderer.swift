//
//  LayerRenderer.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Renders a layer and its children recursively.
import SwiftUI

// MARK: - Layer Type Views

struct LayerRenderer: View {
    let layer: AnyLayer
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        Group {
            if layer.isVisible && !viewModel.hiddenLayerIds.contains(layer.id) {
                layerContent
                    .opacity(layer.effectiveOpacity)
                    .rotationEffect(.radians(layer.rotation ?? 0))
                    .position(x: layer.position.x, y: layer.position.y)
                    .onTapGesture {
                        viewModel.selectLayer(layer.id)
                    }
            }
        }
    }

    @ViewBuilder
    private var layerContent: some View {
        switch layer {
        case .basic(let basicLayer):
            BasicLayerView(layer: basicLayer)

        case .text(let textLayer):
            TextLayerView(layer: textLayer)

        case .image(let imageLayer):
            ImageLayerView(layer: imageLayer)

        case .shape(let shapeLayer):
            ShapeLayerView(layer: shapeLayer)

        case .gradient(let gradientLayer):
            GradientLayerView(layer: gradientLayer)

        case .video(let videoLayer):
            VideoLayerView(layer: videoLayer)

        case .emitter(let emitterLayer):
            EmitterLayerView(layer: emitterLayer)

        case .transform(let transformLayer):
            TransformLayerView(layer: transformLayer)

        case .replicator(let replicatorLayer):
            ReplicatorLayerView(layer: replicatorLayer)

        case .liquidGlass(let glassLayer):
            LiquidGlassLayerView(layer: glassLayer)
        }
    }
}
struct BasicLayerView: View {
    let layer: BasicLayer

    var body: some View {
        ZStack {
            if let bgColor = layer.backgroundColor {
                RoundedRectangle(cornerRadius: layer.cornerRadius ?? 0)
                    .fill(Color(hex: bgColor))
            }

            // Render children
            if let children = layer.children {
                ForEach(children) { child in
                    LayerRenderer(layer: child)
                }
            }
        }
        .frame(width: layer.size.w, height: layer.size.h)
    }
}
struct TextLayerView: View {
    let layer: TextLayer

    var body: some View {
        Text(layer.text)
            .font(.system(size: layer.effectiveFontSize))
            .foregroundColor(Color(hex: layer.effectiveColor))
            .multilineTextAlignment(swiftUIAlignment)
            .frame(width: layer.size.w, height: layer.size.h, alignment: frameAlignment)
    }

    private var swiftUIAlignment: SwiftUI.TextAlignment {
        switch layer.effectiveAlignment {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        case .justified: return .leading
        }
    }

    private var frameAlignment: Alignment {
        switch layer.effectiveAlignment {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        case .justified: return .leading
        }
    }
}
struct ImageLayerView: View {
    let layer: ImageLayer
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .frame(width: layer.size.w, height: layer.size.h)
        .clipShape(RoundedRectangle(cornerRadius: layer.cornerRadius ?? 0))
    }

    private var contentMode: ContentMode {
        switch layer.effectiveFit {
        case .cover: return .fill
        case .contain: return .fit
        case .fill: return .fill
        case .none: return .fit
        }
    }
}
struct ShapeLayerView: View {
    let layer: ShapeLayer

    var body: some View {
        Group {
            switch layer.shape {
            case .rect:
                Rectangle()
                    .fill(fillColor)
                    .overlay(Rectangle().stroke(strokeColor, lineWidth: layer.effectiveStrokeWidth))

            case .circle:
                Circle()
                    .fill(fillColor)
                    .overlay(Circle().stroke(strokeColor, lineWidth: layer.effectiveStrokeWidth))

            case .roundedRect:
                RoundedRectangle(cornerRadius: layer.effectiveRadius)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: layer.effectiveRadius).stroke(
                            strokeColor, lineWidth: layer.effectiveStrokeWidth))
            }
        }
        .frame(width: layer.size.w, height: layer.size.h)
    }

    private var fillColor: Color {
        if let fill = layer.fill {
            return Color(hex: fill)
        }
        return Color.clear
    }

    private var strokeColor: Color {
        if let stroke = layer.stroke {
            return Color(hex: stroke)
        }
        return Color.clear
    }
}
struct GradientLayerView: View {
    let layer: GradientLayer

    var body: some View {
        Group {
            switch layer.gradientType {
            case .axial:
                layer.swiftUIGradient
            case .radial:
                layer.radialGradient
            case .conic:
                layer.angularGradient
            }
        }
        .frame(width: layer.size.w, height: layer.size.h)
        .clipShape(RoundedRectangle(cornerRadius: layer.cornerRadius ?? 0))
    }
}
struct VideoLayerView: View {
    let layer: VideoLayer
    @State private var currentFrame: UIImage?

    var body: some View {
        Group {
            if let frame = currentFrame {
                Image(uiImage: frame)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        VStack {
                            Image(systemName: "video")
                            Text("\(layer.frameCount) frames")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    )
            }
        }
        .frame(width: layer.size.w, height: layer.size.h)
        .clipShape(RoundedRectangle(cornerRadius: layer.cornerRadius ?? 0))
    }
}
struct EmitterLayerView: View {
    let layer: EmitterLayer

    var body: some View {
        Rectangle()
            .fill(Color.purple.opacity(0.1))
            .overlay(
                VStack {
                    Image(systemName: "sparkles")
                    Text("Emitter")
                        .font(.caption)
                }
                .foregroundColor(.purple)
            )
            .frame(width: layer.size.w, height: layer.size.h)
    }
}
struct TransformLayerView: View {
    let layer: TransformLayer

    var body: some View {
        ZStack {
            if let bgColor = layer.backgroundColor {
                Rectangle()
                    .fill(Color(hex: bgColor))
            }

            if let children = layer.children {
                ForEach(children) { child in
                    LayerRenderer(layer: child)
                }
            }
        }
        .frame(width: layer.size.w, height: layer.size.h)
    }
}
struct ReplicatorLayerView: View {
    let layer: ReplicatorLayer

    var body: some View {
        ZStack {
            if let children = layer.children, let first = children.first {
                ForEach(0..<layer.effectiveInstanceCount, id: \.self) { index in
                    LayerRenderer(layer: first)
                        .offset(
                            x: CGFloat(index) * (layer.instanceTranslation?.x ?? 0),
                            y: CGFloat(index) * (layer.instanceTranslation?.y ?? 0)
                        )
                        .rotationEffect(.radians(CGFloat(index) * layer.effectiveInstanceRotation))
                }
            }
        }
        .frame(width: layer.size.w, height: layer.size.h)
    }
}
struct LiquidGlassLayerView: View {
    let layer: LiquidGlassLayer

    var body: some View {
        ZStack {
            // Blur background effect
            Rectangle()
                .fill(.ultraThinMaterial)

            // Children
            if let children = layer.children {
                ForEach(children) { child in
                    LayerRenderer(layer: child)
                }
            }
        }
        .frame(width: layer.size.w, height: layer.size.h)
        .clipShape(RoundedRectangle(cornerRadius: layer.cornerRadius ?? 20))
    }
}
