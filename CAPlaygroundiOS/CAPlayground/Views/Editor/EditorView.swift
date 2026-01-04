//
//  EditorView.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Main editor view containing the canvas, layers panel, and inspector.
/// Mirrors the editor layout from the web app.

/// Mobile bottom bar for compact layouts.

import SwiftUI

struct EditorView: View {
    let projectId: String
    let initialMeta: ProjectMeta

    @StateObject private var viewModel: EditorViewModel
    @EnvironmentObject private var appState: AppState

    @State private var showingLayers = true
    @State private var showingInspector = true
    @State private var zoom: CGFloat = 1.0
    @State private var offset: CGPoint = .zero
    @State private var showingExportSheet = false
    @State private var exportedFile: ExportedFile?

    init(projectId: String, initialMeta: ProjectMeta) {
        self.projectId = projectId
        self.initialMeta = initialMeta
        _viewModel = StateObject(
            wrappedValue: EditorViewModel(projectId: projectId, initialMeta: initialMeta))
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 700 {
                // iPad / Large screen layout
                HStack(spacing: 0) {
                    // Layers Panel
                    if showingLayers {
                        LayersPanel()
                            .frame(width: 250)
                            .background(Color(.systemGroupedBackground))
                    }

                    Divider()

                    // Canvas
                    CanvasView(zoom: $zoom, offset: $offset)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Divider()

                    // Inspector
                    if showingInspector {
                        InspectorView()
                            .frame(width: 300)
                            .background(Color(.systemGroupedBackground))
                    }
                }
            } else {
                // iPhone / Compact layout
                ZStack {
                    CanvasView(zoom: $zoom, offset: $offset)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Spacer()
                        MobileBottomBar(
                            showingLayers: $showingLayers,
                            showingInspector: $showingInspector
                        )
                    }
                }
                .sheet(isPresented: $showingLayers) {
                    NavigationStack {
                        LayersPanel()
                            .navigationTitle("Layers")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        showingLayers = false
                                    }
                                }
                            }
                    }
                    .presentationDetents([.medium, .large])
                }
                .sheet(isPresented: $showingInspector) {
                    NavigationStack {
                        InspectorView()
                            .navigationTitle("Inspector")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        showingInspector = false
                                    }
                                }
                            }
                    }
                    .presentationDetents([.medium, .large])
                }
            }
        }
        .environmentObject(viewModel)
        .navigationTitle(initialMeta.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    appState.closeProject()
                } label: {
                    Image(systemName: "chevron.left")
                }

                // Undo/Redo
                Button {
                    viewModel.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!viewModel.canUndo)

                Button {
                    viewModel.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(!viewModel.canRedo)
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Saving status
                switch viewModel.savingStatus {
                case .idle:
                    EmptyView()
                case .saving:
                    ProgressView()
                        .scaleEffect(0.7)
                case .saved:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                // Toggle panels
                Button {
                    withAnimation {
                        showingLayers.toggle()
                    }
                } label: {
                    Image(systemName: "sidebar.left")
                }

                Button {
                    withAnimation {
                        showingInspector.toggle()
                    }
                } label: {
                    Image(systemName: "sidebar.right")
                }

                Menu {
                    addLayerMenuItems
                } label: {
                    Image(systemName: "plus")
                }

                Button {
                    showingExportSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .confirmationDialog("Export Project", isPresented: $showingExportSheet) {
            Button("Export as .ca bundle") {
                exportProject(format: .caBundle)
            }
            Button("Export as .tendies") {
                exportProject(format: .tendies)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose an export format")
        }
        .sheet(item: $exportedFile) { file in
            ShareSheet(activityItems: [file.url])
        }
    }

    private func exportProject(format: ExportFormat) {
        guard let doc = viewModel.doc else { return }

        viewModel.savingStatus = .saving

        ExportService.shared.exportProject(doc.meta, format: format) { result in
            viewModel.savingStatus = .saved
            switch result {
            case .success(let url):
                exportedFile = ExportedFile(url: url)
            case .failure(let error):
                print("Export failed: \(error)")
            // In a real app, show an alert
            }
        }
    }

    @ViewBuilder
    private var addLayerMenuItems: some View {
        Button {
            viewModel.addTextLayer()
        } label: {
            Label("Text Layer", systemImage: "textformat")
        }

        Button {
            viewModel.addImageLayer()
        } label: {
            Label("Image Layer", systemImage: "photo")
        }

        Button {
            viewModel.addShapeLayer()
        } label: {
            Label("Shape Layer", systemImage: "square.on.circle")
        }

        Button {
            viewModel.addGradientLayer()
        } label: {
            Label("Gradient Layer", systemImage: "paintbrush")
        }

        Divider()

        Button {
            viewModel.addEmitterLayer()
        } label: {
            Label("Emitter Layer", systemImage: "sparkles")
        }

        Button {
            viewModel.addReplicatorLayer()
        } label: {
            Label("Replicator Layer", systemImage: "square.on.square")
        }

        Button {
            viewModel.addTransformLayer()
        } label: {
            Label("Transform Layer", systemImage: "arrow.up.left.and.arrow.down.right")
        }

        Button {
            viewModel.addLiquidGlassLayer()
        } label: {
            Label("Liquid Glass", systemImage: "drop")
        }
    }
}
struct MobileBottomBar: View {
    @Binding var showingLayers: Bool
    @Binding var showingInspector: Bool
    @EnvironmentObject var viewModel: EditorViewModel

    var body: some View {
        HStack(spacing: 20) {
            Button {
                showingLayers = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "square.3.layers.3d")
                    Text("Layers")
                        .font(.caption2)
                }
            }

            Spacer()

            // Add layer button
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
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }

            Spacer()

            Button {
                showingInspector = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Inspector")
                        .font(.caption2)
                }
            }
            .disabled(viewModel.selectedLayer == nil)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
#Preview {
    NavigationStack {
        EditorView(
            projectId: "test",
            initialMeta: ProjectMeta(
                id: "test",
                name: "Test Project",
                width: 390,
                height: 844
            )
        )
    }
    .environmentObject(AppState())
}
struct ExportedFile: Identifiable {
    let id = UUID()
    let url: URL
}
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
