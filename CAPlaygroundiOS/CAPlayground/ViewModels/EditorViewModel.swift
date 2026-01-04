/// Main ViewModel for the editor, managing document state and layer operations.
/// Mirrors the EditorContext from editor-context.tsx

//
//  EditorViewModel.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Combine

import Foundation

// MARK: - Supporting Types

import SwiftUI

@MainActor
class EditorViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var doc: ProjectDocument?
    @Published var savingStatus: SavingStatus = .idle
    @Published var lastSavedAt: Date?
    @Published var animatedLayers: [AnyLayer] = []
    @Published var hiddenLayerIds: Set<String> = []

    // MARK: - Private Properties

    private let projectId: String
    private let fileStorage = FileStorageService.shared
    private var pastStates: [ProjectDocument] = []
    private var futureStates: [ProjectDocument] = []
    private var clipboard: ClipboardData?
    private var saveTask: Task<Void, Never>?
    private var skipPersist = false

    private let maxHistorySize = 50

    // MARK: - Computed Properties

    var activeCA: CAType {
        doc?.activeCA ?? .floating
    }

    var currentDocument: CADocument? {
        doc?.currentDocument
    }

    var layers: [AnyLayer] {
        currentDocument?.layers ?? []
    }

    var selectedId: String? {
        currentDocument?.selectedId
    }

    var selectedLayer: AnyLayer? {
        guard let id = selectedId else { return nil }
        return LayerUtils.findById(layers, id)
    }

    var states: [String] {
        currentDocument?.states ?? ["Locked", "Unlock", "Sleep"]
    }

    var activeState: CAState {
        currentDocument?.activeState ?? .baseState
    }

    var stateOverrides: [String: [CAStateOverride]] {
        currentDocument?.stateOverrides ?? [:]
    }

    var canUndo: Bool {
        !pastStates.isEmpty
    }

    var canRedo: Bool {
        !futureStates.isEmpty
    }

    // MARK: - Initialization

    init(projectId: String, initialMeta: ProjectMeta) {
        self.projectId = projectId

        // Initialize with empty document
        Task {
            await loadProject(initialMeta: initialMeta)
        }
    }

    // MARK: - Project Loading

    private func loadProject(initialMeta: ProjectMeta) async {
        let isGyro = initialMeta.gyroEnabled ?? false

        let emptyDoc = CADocument(
            layers: [],
            selectedId: nil,
            states: ["Locked", "Unlock", "Sleep"],
            activeState: .baseState
        )

        let meta = ProjectMeta(
            id: initialMeta.id,
            name: initialMeta.name,
            width: initialMeta.width,
            height: initialMeta.height,
            background: initialMeta.background ?? "#e5e7eb",
            geometryFlipped: 0,
            gyroEnabled: isGyro
        )

        // Try to load existing CAML files
        var floatingDoc = emptyDoc
        var backgroundDoc = emptyDoc
        var wallpaperDoc = emptyDoc

        let caFolder = "\(meta.name).ca"

        if isGyro {
            // Load Wallpaper.ca
            if let caml = try? await fileStorage.readTextFile(
                projectId: projectId,
                path: "\(caFolder)/Wallpaper.ca/main.caml"
            ) {
                let parser = CAMLParser()
                if let root = try? parser.parseCAML(caml) {
                    let rootLayers: [AnyLayer]
                    if root.name == "Root Layer", let children = root.children {
                        rootLayers = children
                    } else {
                        rootLayers = [root]
                    }

                    wallpaperDoc = CADocument(
                        layers: rootLayers,
                        states: parser.parseStates(caml),
                        stateOverrides: parser.parseStateOverrides(caml),
                        wallpaperParallaxGroups: parser.parseWallpaperParallaxGroups(caml)
                    )
                }
            }
        } else {
            // Load Floating.ca and Background.ca
            for (caType, docVar) in [
                (CAType.floating, \EditorViewModel.floatingDoc),
                (CAType.background, \EditorViewModel.backgroundDoc),
            ] as [(CAType, WritableKeyPath<EditorViewModel, CADocument>)] {
                if let caml = try? await fileStorage.readTextFile(
                    projectId: projectId,
                    path: "\(caFolder)/\(caType.folderName)/main.caml"
                ) {
                    let parser = CAMLParser()
                    if let root = try? parser.parseCAML(caml) {
                        let rootLayers: [AnyLayer]
                        if root.name == "Root Layer", let children = root.children {
                            rootLayers = children
                        } else {
                            rootLayers = [root]
                        }

                        if caType == .floating {
                            floatingDoc = CADocument(
                                layers: rootLayers,
                                states: parser.parseStates(caml),
                                stateOverrides: parser.parseStateOverrides(caml)
                            )
                        } else {
                            backgroundDoc = CADocument(
                                layers: rootLayers,
                                states: parser.parseStates(caml),
                                stateOverrides: parser.parseStateOverrides(caml)
                            )
                        }
                    }
                }
            }
        }

        skipPersist = true
        doc = ProjectDocument(
            meta: meta,
            activeCA: isGyro ? .wallpaper : .floating,
            docs: ProjectDocs(
                background: backgroundDoc,
                floating: floatingDoc,
                wallpaper: wallpaperDoc
            )
        )
    }

    // Placeholder for loading
    private var floatingDoc: CADocument = CADocument()
    private var backgroundDoc: CADocument = CADocument()

    // MARK: - Layer Selection

    func selectLayer(_ id: String?) {
        updateCurrentDocument { doc in
            doc.selectedId = id
        }
    }

    // MARK: - Layer Creation

    func addTextLayer() {
        pushHistory()

        let canvasW = doc?.meta.width ?? 390
        let canvasH = doc?.meta.height ?? 844
        let parentLayer = selectedLayer

        let layer = TextLayer(
            id: IDGenerator.generate(),
            name: LayerUtils.getNextLayerName(baseName: "Text Layer", existingLayers: layers),
            position: Vec2(
                x: (parentLayer?.size.w ?? canvasW) / 2,
                y: (parentLayer?.size.h ?? canvasH) / 2
            ),
            size: Size(w: 120, h: 40),
            text: "Text Layer",
            fontFamily: "SFProText-Regular",
            fontSize: 16,
            color: "#111827",
            align: .center,
            wrapped: 1
        )

        insertLayer(.text(layer))
    }

    func addImageLayer(src: String = "") {
        pushHistory()

        let canvasW = doc?.meta.width ?? 390
        let canvasH = doc?.meta.height ?? 844
        let parentLayer = selectedLayer

        let layer = ImageLayer(
            id: IDGenerator.generate(),
            name: LayerUtils.getNextLayerName(baseName: "Image Layer", existingLayers: layers),
            position: Vec2(
                x: (parentLayer?.size.w ?? canvasW) / 2,
                y: (parentLayer?.size.h ?? canvasH) / 2
            ),
            size: Size(w: 120, h: 120),
            src: src
        )

        insertLayer(.image(layer))
    }

    func addShapeLayer(shape: ShapeKind = .rect) {
        pushHistory()

        let canvasW = doc?.meta.width ?? 390
        let canvasH = doc?.meta.height ?? 844
        let parentLayer = selectedLayer

        let layer = ShapeLayer(
            id: IDGenerator.generate(),
            name: LayerUtils.getNextLayerName(baseName: "Shape Layer", existingLayers: layers),
            position: Vec2(
                x: (parentLayer?.size.w ?? canvasW) / 2,
                y: (parentLayer?.size.h ?? canvasH) / 2
            ),
            size: Size(w: 100, h: 100),
            shape: shape,
            fill: "#3b82f6"
        )

        insertLayer(.shape(layer))
    }

    func addGradientLayer() {
        pushHistory()

        let canvasW = doc?.meta.width ?? 390
        let canvasH = doc?.meta.height ?? 844
        let parentLayer = selectedLayer

        let layer = GradientLayer(
            id: IDGenerator.generate(),
            name: LayerUtils.getNextLayerName(baseName: "Gradient Layer", existingLayers: layers),
            position: Vec2(
                x: (parentLayer?.size.w ?? canvasW) / 2,
                y: (parentLayer?.size.h ?? canvasH) / 2
            ),
            size: Size(w: 200, h: 200)
        )

        insertLayer(.gradient(layer))
    }

    func addEmitterLayer() {
        pushHistory()

        let canvasW = doc?.meta.width ?? 390
        let canvasH = doc?.meta.height ?? 844
        let parentLayer = selectedLayer

        let layer = EmitterLayer(
            id: IDGenerator.generate(),
            name: LayerUtils.getNextLayerName(baseName: "Emitter Layer", existingLayers: layers),
            position: Vec2(
                x: (parentLayer?.size.w ?? canvasW) / 2,
                y: (parentLayer?.size.h ?? canvasH) / 2
            ),
            size: Size(w: 200, h: 200),
            emitterPosition: Vec2(x: 100, y: 100),
            emitterSize: Size(w: 1, h: 1),
            emitterShape: .point,
            emitterMode: .volume,
            emitterCells: [],
            renderMode: .unordered
        )

        insertLayer(.emitter(layer))
    }

    func addTransformLayer() {
        pushHistory()

        let canvasW = doc?.meta.width ?? 390
        let canvasH = doc?.meta.height ?? 844

        let layer = TransformLayer(
            id: IDGenerator.generate(),
            name: LayerUtils.getNextLayerName(baseName: "Transform Layer", existingLayers: layers),
            position: Vec2(x: canvasW / 2, y: canvasH / 2),
            size: Size(w: 200, h: 200)
        )

        insertLayer(.transform(layer))
    }

    func addReplicatorLayer() {
        pushHistory()

        let canvasW = doc?.meta.width ?? 390
        let canvasH = doc?.meta.height ?? 844

        let layer = ReplicatorLayer(
            id: IDGenerator.generate(),
            name: LayerUtils.getNextLayerName(baseName: "Replicator Layer", existingLayers: layers),
            position: Vec2(x: canvasW / 2, y: canvasH / 2),
            size: Size(w: 200, h: 200),
            instanceCount: 5
        )

        insertLayer(.replicator(layer))
    }

    func addLiquidGlassLayer() {
        pushHistory()

        let canvasW = doc?.meta.width ?? 390
        let canvasH = doc?.meta.height ?? 844

        let layer = LiquidGlassLayer(
            id: IDGenerator.generate(),
            name: LayerUtils.getNextLayerName(baseName: "Liquid Glass", existingLayers: layers),
            position: Vec2(x: canvasW / 2, y: canvasH / 2),
            size: Size(w: 200, h: 200),
            cornerRadius: 20,
            masksToBounds: 1
        )

        insertLayer(.liquidGlass(layer))
    }

    private func insertLayer(_ layer: AnyLayer) {
        updateCurrentDocument { doc in
            let newLayers = LayerUtils.insertIntoSelected(
                doc.layers, selectedId: doc.selectedId, layer: layer)
            doc.layers = newLayers
            doc.selectedId = layer.id
        }
    }

    // MARK: - Layer Updates

    func updateLayer(id: String, update: (inout AnyLayer) -> Void) {
        pushHistory()
        updateLayerWithoutHistory(id: id, update: update)
    }

    func updateLayerTransient(id: String, update: (inout AnyLayer) -> Void) {
        // Update without pushing history (for dragging, etc.)
        updateLayerWithoutHistory(id: id, update: update)
    }

    private func updateLayerWithoutHistory(id: String, update: (inout AnyLayer) -> Void) {
        updateCurrentDocument { doc in
            doc.layers = LayerUtils.updateInTree(doc.layers, id: id, update: update)
        }
    }

    // MARK: - Layer Deletion

    func deleteLayer(id: String) {
        pushHistory()

        updateCurrentDocument { doc in
            doc.layers = LayerUtils.removeFromTree(doc.layers, id: id)
            if doc.selectedId == id {
                doc.selectedId = nil
            }
        }
    }

    // MARK: - Layer Duplication

    func duplicateLayer(id: String? = nil) {
        let targetId = id ?? selectedId
        guard let targetId = targetId,
            let layer = LayerUtils.findById(layers, targetId)
        else { return }

        pushHistory()

        let cloned = LayerUtils.cloneLayerDeep(layer)

        updateCurrentDocument { doc in
            doc.layers = LayerUtils.insertAsSibling(
                doc.layers, layer: cloned, siblingId: targetId, after: true)
            doc.selectedId = cloned.id
        }
    }

    // MARK: - Layer Movement

    func moveLayer(sourceId: String, beforeId: String?, position: LayerUtils.MovePosition = .before)
    {
        pushHistory()

        updateCurrentDocument { doc in
            doc.layers = LayerUtils.moveLayer(
                doc.layers, sourceId: sourceId, beforeId: beforeId, position: position)
        }
    }

    // MARK: - Clipboard Operations

    func copySelectedLayer() {
        guard let selected = selectedLayer else { return }
        clipboard = ClipboardData(layers: [selected])
    }

    func pasteFromClipboard() {
        guard let clipboard = clipboard, !clipboard.layers.isEmpty else { return }

        pushHistory()

        for layer in clipboard.layers {
            let cloned = LayerUtils.cloneLayerDeep(layer)
            insertLayer(cloned)
        }
    }

    // MARK: - State Management

    func setActiveState(_ state: CAState) {
        updateCurrentDocument { doc in
            doc.activeState = state
        }
    }

    func setActiveCA(_ caType: CAType) {
        doc?.activeCA = caType
        objectWillChange.send()
    }

    func updateStateOverride(targetId: String, keyPath: String, value: CGFloat) {
        guard activeState != .baseState else { return }

        pushHistory()

        updateCurrentDocument { doc in
            let stateName = activeState.rawValue
            var overrides = doc.stateOverrides ?? [:]
            var stateOverrides = overrides[stateName] ?? []

            // Find existing override or create new
            if let index = stateOverrides.firstIndex(where: {
                $0.targetId == targetId && $0.keyPath == keyPath
            }) {
                stateOverrides[index] = CAStateOverride(
                    targetId: targetId, keyPath: keyPath, value: .number(value))
            } else {
                stateOverrides.append(
                    CAStateOverride(targetId: targetId, keyPath: keyPath, value: .number(value)))
            }

            overrides[stateName] = stateOverrides
            doc.stateOverrides = overrides
        }
    }

    // MARK: - Visibility

    func toggleLayerVisibility(id: String) {
        if hiddenLayerIds.contains(id) {
            hiddenLayerIds.remove(id)
        } else {
            hiddenLayerIds.insert(id)
        }
    }

    // MARK: - Undo/Redo

    func undo() {
        guard let lastState = pastStates.popLast() else { return }

        if let currentDoc = doc {
            futureStates.append(currentDoc)
            if futureStates.count > maxHistorySize {
                futureStates.removeFirst()
            }
        }

        skipPersist = true
        doc = lastState
    }

    func redo() {
        guard let nextState = futureStates.popLast() else { return }

        if let currentDoc = doc {
            pastStates.append(currentDoc)
            if pastStates.count > maxHistorySize {
                pastStates.removeFirst()
            }
        }

        skipPersist = true
        doc = nextState
    }

    private func pushHistory() {
        guard let currentDoc = doc else { return }
        pastStates.append(currentDoc)
        if pastStates.count > maxHistorySize {
            pastStates.removeFirst()
        }
        futureStates.removeAll()
    }

    // MARK: - Persistence

    func persist() {
        guard let doc = doc else { return }
        if skipPersist {
            skipPersist = false
            return
        }

        savingStatus = .saving

        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)  // 500ms debounce

            if Task.isCancelled { return }

            await saveToStorage(doc)

            await MainActor.run {
                self.savingStatus = .saved
                self.lastSavedAt = Date()
            }
        }
    }

    func flushPersist() async {
        guard let doc = doc else { return }
        saveTask?.cancel()
        await saveToStorage(doc)
        savingStatus = .saved
        lastSavedAt = Date()
    }

    private func saveToStorage(_ snapshot: ProjectDocument) async {
        let serializer = CAMLSerializer()
        let projectName = snapshot.meta.name
        let isGyro = snapshot.meta.gyroEnabled ?? false

        let caTypes: [CAType] = isGyro ? [.wallpaper] : [.background, .floating]

        for caType in caTypes {
            let caDoc = getDocument(for: caType, from: snapshot)

            // Create root layer
            let rootLayer: AnyLayer = .basic(
                BasicLayer(
                    id: snapshot.meta.id,
                    name: "Root Layer",
                    children: caDoc.layers,
                    position: Vec2(
                        x: CGFloat(Int(snapshot.meta.width / 2)),
                        y: CGFloat(Int(snapshot.meta.height / 2))
                    ),
                    size: Size(w: snapshot.meta.width, h: snapshot.meta.height),
                    backgroundColor: caType == .floating ? nil : snapshot.meta.background,
                    geometryFlipped: snapshot.meta.geometryFlipped
                ))

            let transitions = StateTransitionManager.buildTransitions(
                stateNames: caDoc.states,
                overrides: caDoc.stateOverrides
            )

            let caml = serializer.serialize(
                root: rootLayer,
                project: CAProject(
                    id: snapshot.meta.id,
                    name: snapshot.meta.name,
                    width: snapshot.meta.width,
                    height: snapshot.meta.height,
                    background: snapshot.meta.background,
                    geometryFlipped: snapshot.meta.geometryFlipped
                ),
                states: caDoc.states,
                stateOverrides: caDoc.stateOverrides,
                transitions: transitions,
                parallaxGroups: caDoc.wallpaperParallaxGroups
            )

            do {
                try await fileStorage.writeMainCAML(
                    projectId: projectId,
                    projectName: projectName,
                    caType: caType,
                    content: caml
                )
            } catch {
                print("Failed to save CAML: \(error)")
            }
        }
    }

    private func getDocument(for caType: CAType, from snapshot: ProjectDocument) -> CADocument {
        switch caType {
        case .background: return snapshot.docs.background
        case .floating: return snapshot.docs.floating
        case .wallpaper: return snapshot.docs.wallpaper
        }
    }

    // MARK: - Helper Methods

    private func updateCurrentDocument(_ update: (inout CADocument) -> Void) {
        guard var document = doc else { return }

        switch document.activeCA {
        case .background:
            update(&document.docs.background)
        case .floating:
            update(&document.docs.floating)
        case .wallpaper:
            update(&document.docs.wallpaper)
        }

        doc = document
        persist()
    }
}
enum SavingStatus {
    case idle
    case saving
    case saved
}
struct ClipboardData {
    let layers: [AnyLayer]
    var assets: [String: Data]?
}
