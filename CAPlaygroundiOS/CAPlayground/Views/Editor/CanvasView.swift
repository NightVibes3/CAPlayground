//
//  CanvasView.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Canvas view for displaying and interacting with layers.
/// Mirrors canvas-preview.tsx from the web app.
import SwiftUI

/// Overlay showing selection handles for a layer.

struct CanvasView: View {
    @Binding var zoom: CGFloat
    @Binding var offset: CGPoint

    @EnvironmentObject var viewModel: EditorViewModel

    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemGray6)
                    .ignoresSafeArea()

                // Canvas container
                canvasContent
                    .frame(
                        width: viewModel.doc?.meta.width ?? 390,
                        height: viewModel.doc?.meta.height ?? 844
                    )
                    .scaleEffect(effectiveZoom(for: geometry.size))
                    .offset(x: offset.x, y: offset.y)
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        zoom = value
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = CGPoint(
                            x: value.translation.width,
                            y: value.translation.height
                        )
                    }
            )
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation {
                            zoom = 1.0
                            offset = .zero
                        }
                    }
            )
        }
    }

    private var canvasContent: some View {
        ZStack {
            // Canvas background
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(hex: viewModel.doc?.meta.background ?? "#e5e7eb"))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

            // Layers
            ForEach(viewModel.layers) { layer in
                LayerRenderer(layer: layer)
            }

            // Selection overlay
            if let selectedId = viewModel.selectedId,
                let selectedLayer = viewModel.selectedLayer
            {
                SelectionOverlay(layer: selectedLayer)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    private func effectiveZoom(for containerSize: CGSize) -> CGFloat {
        let canvasWidth = viewModel.doc?.meta.width ?? 390
        let canvasHeight = viewModel.doc?.meta.height ?? 844

        let scaleX = (containerSize.width - 40) / canvasWidth
        let scaleY = (containerSize.height - 40) / canvasHeight

        let fitScale = min(scaleX, scaleY, 1.0)
        return fitScale * zoom
    }
}
struct SelectionOverlay: View {
    let layer: AnyLayer
    @EnvironmentObject var viewModel: EditorViewModel

    @State private var isDragging = false
    @State private var dragStart: CGPoint = .zero
    @State private var initialPosition: Vec2 = .zero

    var body: some View {
        let frame = layer.frame

        ZStack {
            // Selection border
            Rectangle()
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: frame.width, height: frame.height)

            // Corner handles
            ForEach(HandlePosition.allCases, id: \.self) { position in
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .position(handlePosition(for: position, in: frame))
            }
        }
        .position(x: layer.position.x, y: layer.position.y)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        dragStart = value.startLocation
                        initialPosition = layer.position
                    }

                    let newX = initialPosition.x + value.translation.width
                    let newY = initialPosition.y + value.translation.height

                    viewModel.updateLayerTransient(id: layer.id) { layer in
                        layer.position = Vec2(x: newX, y: newY)
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    // Push to history on drag end
                    viewModel.updateLayer(id: layer.id) { _ in }
                }
        )
    }

    private func handlePosition(for position: HandlePosition, in frame: CGRect) -> CGPoint {
        let halfWidth = frame.width / 2
        let halfHeight = frame.height / 2

        switch position {
        case .topLeft:
            return CGPoint(x: -halfWidth, y: -halfHeight)
        case .topRight:
            return CGPoint(x: halfWidth, y: -halfHeight)
        case .bottomLeft:
            return CGPoint(x: -halfWidth, y: halfHeight)
        case .bottomRight:
            return CGPoint(x: halfWidth, y: halfHeight)
        case .topCenter:
            return CGPoint(x: 0, y: -halfHeight)
        case .bottomCenter:
            return CGPoint(x: 0, y: halfHeight)
        case .leftCenter:
            return CGPoint(x: -halfWidth, y: 0)
        case .rightCenter:
            return CGPoint(x: halfWidth, y: 0)
        }
    }
}
enum HandlePosition: CaseIterable {
    case topLeft, topCenter, topRight
    case leftCenter, rightCenter
    case bottomLeft, bottomCenter, bottomRight
}
#Preview {
    CanvasView(zoom: .constant(1.0), offset: .constant(.zero))
        .environmentObject(
            EditorViewModel(
                projectId: "test",
                initialMeta: ProjectMeta(id: "test", name: "Test", width: 390, height: 844)
            ))
}
