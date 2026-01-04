//
//  InspectorView.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Inspector panel for editing layer properties.
/// Mirrors inspector/index.tsx from the web app.
import SwiftUI

// MARK: - Geometry Tab

// MARK: - Content Tab (Generic)

// MARK: - Text Tab

// MARK: - Image Tab

// MARK: - Shape Tab

// MARK: - Gradient Tab

// MARK: - Emitter Tab

// MARK: - Video Tab

// MARK: - Replicator Tab

// MARK: - Animations Tab

// MARK: - Helper Components

struct InspectorView: View {
    @EnvironmentObject var viewModel: EditorViewModel
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            if let layer = viewModel.selectedLayer {
                // Tab picker
                Picker("Tab", selection: $selectedTab) {
                    Text("Geometry").tag(0)
                    Text("Content").tag(1)
                    if hasAnimationsTab(for: layer) {
                        Text("Animate").tag(2)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Divider()

                // Tab content
                ScrollView {
                    VStack(spacing: 0) {
                        switch selectedTab {
                        case 0:
                            GeometryTab(layer: layer)
                        case 1:
                            contentTab(for: layer)
                        case 2:
                            AnimationsTab(layer: layer)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            } else {
                noSelectionView
            }
        }
    }

    private var noSelectionView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cursorarrow.click.2")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No Selection")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Select a layer to edit its properties")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }

    private func hasAnimationsTab(for layer: AnyLayer) -> Bool {
        // Most layers support animations
        true
    }

    @ViewBuilder
    private func contentTab(for layer: AnyLayer) -> some View {
        switch layer {
        case .text(let textLayer):
            TextTab(layer: textLayer)
        case .image(let imageLayer):
            ImageTab(layer: imageLayer)
        case .shape(let shapeLayer):
            ShapeTab(layer: shapeLayer)
        case .gradient(let gradientLayer):
            GradientTab(layer: gradientLayer)
        case .emitter(let emitterLayer):
            EmitterTab(layer: emitterLayer)
        case .video(let videoLayer):
            VideoTab(layer: videoLayer)
        case .replicator(let replicatorLayer):
            ReplicatorTab(layer: replicatorLayer)
        default:
            ContentTab(layer: layer)
        }
    }
}
struct GeometryTab: View {
    let layer: AnyLayer
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Position
            PropertySection(title: "Position") {
                HStack {
                    NumberField(label: "X", value: layer.position.x) { newValue in
                        viewModel.updateLayer(id: layer.id) { layer in
                            layer.position = Vec2(x: newValue, y: layer.position.y)
                        }
                    }
                    NumberField(label: "Y", value: layer.position.y) { newValue in
                        viewModel.updateLayer(id: layer.id) { layer in
                            layer.position = Vec2(x: layer.position.x, y: newValue)
                        }
                    }
                }
            }

            // Size
            PropertySection(title: "Size") {
                HStack {
                    NumberField(label: "W", value: layer.size.w) { newValue in
                        viewModel.updateLayer(id: layer.id) { layer in
                            layer.size = Size(w: newValue, h: layer.size.h)
                        }
                    }
                    NumberField(label: "H", value: layer.size.h) { newValue in
                        viewModel.updateLayer(id: layer.id) { layer in
                            layer.size = Size(w: layer.size.w, h: newValue)
                        }
                    }
                }
            }

            // Rotation
            PropertySection(title: "Rotation") {
                SliderRow(
                    label: "Z",
                    value: layer.rotation ?? 0,
                    range: -Double.pi...Double.pi,
                    unit: "rad"
                ) { newValue in
                    viewModel.updateLayer(id: layer.id) { layer in
                        layer.rotation = newValue
                    }
                }
            }

            // Opacity
            PropertySection(title: "Opacity") {
                SliderRow(
                    label: "",
                    value: layer.effectiveOpacity,
                    range: 0...1,
                    unit: ""
                ) { newValue in
                    viewModel.updateLayer(id: layer.id) { layer in
                        layer.opacity = newValue
                    }
                }
            }

            // Corner Radius
            PropertySection(title: "Corner Radius") {
                NumberField(label: "", value: layer.cornerRadius ?? 0) { newValue in
                    viewModel.updateLayer(id: layer.id) { layer in
                        layer.cornerRadius = newValue
                    }
                }
            }
        }
    }
}
struct ContentTab: View {
    let layer: AnyLayer
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 20) {
            PropertySection(title: "Name") {
                TextField(
                    "Layer Name",
                    text: Binding(
                        get: { layer.name },
                        set: { newValue in
                            viewModel.updateLayer(id: layer.id) { layer in
                                layer.name = newValue
                            }
                        }
                    )
                )
                .textFieldStyle(.roundedBorder)
            }

            if let bgColor = layer.backgroundColor {
                PropertySection(title: "Background Color") {
                    Text(bgColor)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
struct TextTab: View {
    let layer: TextLayer
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 20) {
            PropertySection(title: "Text") {
                TextEditor(
                    text: Binding(
                        get: { layer.text },
                        set: { newValue in
                            viewModel.updateLayer(id: layer.id) { l in
                                if case .text(var textLayer) = l {
                                    textLayer.text = newValue
                                    l = .text(textLayer)
                                }
                            }
                        }
                    )
                )
                .frame(height: 80)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            }

            PropertySection(title: "Font Size") {
                NumberField(label: "", value: layer.effectiveFontSize) { newValue in
                    viewModel.updateLayer(id: layer.id) { l in
                        if case .text(var textLayer) = l {
                            textLayer.fontSize = newValue
                            l = .text(textLayer)
                        }
                    }
                }
            }

            PropertySection(title: "Color") {
                Text(layer.effectiveColor)
                    .foregroundColor(.secondary)
            }
        }
    }
}
struct ImageTab: View {
    let layer: ImageLayer
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 20) {
            PropertySection(title: "Source") {
                Text(layer.src.isEmpty ? "No image" : layer.src)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            PropertySection(title: "Fit Mode") {
                Picker(
                    "Fit",
                    selection: Binding(
                        get: { layer.effectiveFit },
                        set: { newValue in
                            viewModel.updateLayer(id: layer.id) { l in
                                if case .image(var imageLayer) = l {
                                    imageLayer.fit = newValue
                                    l = .image(imageLayer)
                                }
                            }
                        }
                    )
                ) {
                    Text("Cover").tag(ImageFit.cover)
                    Text("Contain").tag(ImageFit.contain)
                    Text("Fill").tag(ImageFit.fill)
                    Text("None").tag(ImageFit.none)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
struct ShapeTab: View {
    let layer: ShapeLayer
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 20) {
            PropertySection(title: "Shape Type") {
                Picker(
                    "Shape",
                    selection: Binding(
                        get: { layer.shape },
                        set: { newValue in
                            viewModel.updateLayer(id: layer.id) { l in
                                if case .shape(var shapeLayer) = l {
                                    shapeLayer.shape = newValue
                                    l = .shape(shapeLayer)
                                }
                            }
                        }
                    )
                ) {
                    Text("Rectangle").tag(ShapeKind.rect)
                    Text("Circle").tag(ShapeKind.circle)
                    Text("Rounded").tag(ShapeKind.roundedRect)
                }
                .pickerStyle(.segmented)
            }

            if let fill = layer.fill {
                PropertySection(title: "Fill Color") {
                    Text(fill)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
struct GradientTab: View {
    let layer: GradientLayer
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 20) {
            PropertySection(title: "Gradient Type") {
                Picker(
                    "Type",
                    selection: Binding(
                        get: { layer.gradientType },
                        set: { newValue in
                            viewModel.updateLayer(id: layer.id) { l in
                                if case .gradient(var gradientLayer) = l {
                                    gradientLayer.gradientType = newValue
                                    l = .gradient(gradientLayer)
                                }
                            }
                        }
                    )
                ) {
                    Text("Linear").tag(GradientType.axial)
                    Text("Radial").tag(GradientType.radial)
                    Text("Conic").tag(GradientType.conic)
                }
                .pickerStyle(.segmented)
            }

            PropertySection(title: "Colors") {
                ForEach(layer.colors) { color in
                    HStack {
                        Circle()
                            .fill(Color(hex: color.color))
                            .frame(width: 24, height: 24)
                        Text(color.color)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
struct EmitterTab: View {
    let layer: EmitterLayer

    var body: some View {
        VStack(spacing: 20) {
            PropertySection(title: "Emitter Shape") {
                Text(layer.emitterShape.rawValue.capitalized)
                    .foregroundColor(.secondary)
            }

            PropertySection(title: "Emitter Mode") {
                Text(layer.emitterMode.rawValue.capitalized)
                    .foregroundColor(.secondary)
            }

            PropertySection(title: "Cells") {
                Text("\(layer.emitterCells.count) cell(s)")
                    .foregroundColor(.secondary)
            }
        }
    }
}
struct VideoTab: View {
    let layer: VideoLayer

    var body: some View {
        VStack(spacing: 20) {
            PropertySection(title: "Frames") {
                Text("\(layer.frameCount) frames")
                    .foregroundColor(.secondary)
            }

            PropertySection(title: "FPS") {
                Text("\(Int(layer.effectiveFps)) fps")
                    .foregroundColor(.secondary)
            }

            PropertySection(title: "Duration") {
                Text(String(format: "%.2f seconds", layer.effectiveDuration))
                    .foregroundColor(.secondary)
            }
        }
    }
}
struct ReplicatorTab: View {
    let layer: ReplicatorLayer
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 20) {
            PropertySection(title: "Instance Count") {
                NumberField(label: "", value: CGFloat(layer.effectiveInstanceCount)) { newValue in
                    viewModel.updateLayer(id: layer.id) { l in
                        if case .replicator(var replicatorLayer) = l {
                            replicatorLayer.instanceCount = Int(newValue)
                            l = .replicator(replicatorLayer)
                        }
                    }
                }
            }

            PropertySection(title: "Instance Delay") {
                NumberField(label: "", value: layer.effectiveInstanceDelay) { newValue in
                    viewModel.updateLayer(id: layer.id) { l in
                        if case .replicator(var replicatorLayer) = l {
                            replicatorLayer.instanceDelay = newValue
                            l = .replicator(replicatorLayer)
                        }
                    }
                }
            }
        }
    }
}
struct AnimationsTab: View {
    let layer: AnyLayer

    var body: some View {
        VStack(spacing: 20) {
            Text("Animations")
                .font(.headline)

            Text("Animation editing coming soon")
                .foregroundColor(.secondary)
        }
    }
}
struct PropertySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            content
        }
    }
}
struct NumberField: View {
    let label: String
    let value: CGFloat
    let onChange: (CGFloat) -> Void

    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            }
            TextField("", text: $textValue)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .onAppear {
                    textValue = formatValue(value)
                }
                .onChange(of: value) { newValue in
                    if !isFocused {
                        textValue = formatValue(newValue)
                    }
                }
                .onChange(of: isFocused) { focused in
                    if !focused, let newValue = Double(textValue) {
                        onChange(CGFloat(newValue))
                    }
                }
        }
    }

    private func formatValue(_ v: CGFloat) -> String {
        if v == v.rounded() {
            return String(format: "%.0f", v)
        }
        return String(format: "%.2f", v)
    }
}
struct SliderRow: View {
    let label: String
    let value: CGFloat
    let range: ClosedRange<Double>
    let unit: String
    let onChange: (CGFloat) -> Void

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                if !label.isEmpty {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(String(format: "%.2f", value) + (unit.isEmpty ? "" : " \(unit)"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { onChange(CGFloat($0)) }
                ), in: range)
        }
    }
}
#Preview {
    InspectorView()
        .frame(width: 300)
        .environmentObject(
            EditorViewModel(
                projectId: "test",
                initialMeta: ProjectMeta(id: "test", name: "Test", width: 390, height: 844)
            ))
}
