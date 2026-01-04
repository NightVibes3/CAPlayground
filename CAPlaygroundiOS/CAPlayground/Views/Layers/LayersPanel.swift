//
//  LayersPanel.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Panel displaying the layer hierarchy with drag-and-drop reordering.
/// Mirrors layers-panel.tsx from the web app.
import SwiftUI

/// A single row in the layers panel.

struct LayersPanel: View {
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Layers")
                    .font(.headline)
                Spacer()
                Menu {
                    Button {
                        viewModel.addTextLayer()
                    } label: {
                        Label("Text", systemImage: "textformat")
                    }
                    Button {
                        viewModel.addImageLayer()
                    } label: {
                        Label("Image", systemImage: "photo")
                    }
                    Button {
                        viewModel.addShapeLayer()
                    } label: {
                        Label("Shape", systemImage: "square")
                    }
                    Button {
                        viewModel.addGradientLayer()
                    } label: {
                        Label("Gradient", systemImage: "paintbrush")
                    }
                    Divider()
                    Button {
                        viewModel.addEmitterLayer()
                    } label: {
                        Label("Emitter", systemImage: "sparkles")
                    }
                    Button {
                        viewModel.addReplicatorLayer()
                    } label: {
                        Label("Replicator", systemImage: "square.on.square")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))

            Divider()

            // Layer list
            if viewModel.layers.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.layers) { layer in
                            LayerRow(layer: layer, depth: 0)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "square.3.layers.3d")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No Layers")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Add a layer to get started")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
struct LayerRow: View {
    let layer: AnyLayer
    let depth: Int

    @EnvironmentObject var viewModel: EditorViewModel
    @State private var isExpanded = true

    private var isSelected: Bool {
        viewModel.selectedId == layer.id
    }

    private var isHidden: Bool {
        viewModel.hiddenLayerIds.contains(layer.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: 8) {
                // Expand/collapse button for layers with children
                if layer.hasChildren {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 16)
                } else {
                    Spacer()
                        .frame(width: 16)
                }

                // Layer icon
                Image(systemName: layer.iconName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(width: 20)

                // Layer name
                Text(layer.name)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)

                Spacer()

                // Visibility toggle
                Button {
                    viewModel.toggleLayerVisibility(id: layer.id)
                } label: {
                    Image(systemName: isHidden ? "eye.slash" : "eye")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, CGFloat(depth) * 16 + 12)
            .padding(.trailing, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectLayer(layer.id)
            }
            .contextMenu {
                contextMenuItems
            }

            Divider()
                .padding(.leading, CGFloat(depth) * 16 + 12)

            // Children
            if isExpanded, let children = layer.children {
                ForEach(children) { child in
                    LayerRow(layer: child, depth: depth + 1)
                }
            }
        }
    }

    @ViewBuilder
    private var contextMenuItems: some View {
        Button {
            viewModel.selectLayer(layer.id)
        } label: {
            Label("Select", systemImage: "hand.point.up.left")
        }

        Button {
            viewModel.duplicateLayer(id: layer.id)
        } label: {
            Label("Duplicate", systemImage: "plus.square.on.square")
        }

        Button {
            viewModel.copySelectedLayer()
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }

        Divider()

        Button {
            viewModel.toggleLayerVisibility(id: layer.id)
        } label: {
            Label(isHidden ? "Show" : "Hide", systemImage: isHidden ? "eye" : "eye.slash")
        }

        Divider()

        Button(role: .destructive) {
            viewModel.deleteLayer(id: layer.id)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
#Preview {
    LayersPanel()
        .frame(width: 250)
        .environmentObject(
            EditorViewModel(
                projectId: "test",
                initialMeta: ProjectMeta(id: "test", name: "Test", width: 390, height: 844)
            ))
}
