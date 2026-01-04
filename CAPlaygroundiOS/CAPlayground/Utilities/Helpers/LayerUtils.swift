//
//  LayerUtils.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Utility functions for layer manipulation.
/// Mirrors the functions from layer-utils.ts
import Foundation

struct LayerUtils {

    /// Generate a unique ID.
    static func genId() -> String {
        UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "").prefix(12)
            .description
    }

    /// Find a layer by ID in a layer tree.
    static func findById(_ layers: [AnyLayer], _ id: String?) -> AnyLayer? {
        guard let id = id else { return nil }

        for layer in layers {
            if layer.id == id {
                return layer
            }
            if let children = layer.children, !children.isEmpty {
                if let found = findById(children, id) {
                    return found
                }
            }
        }
        return nil
    }

    /// Find the parent layer of a given layer ID.
    static func findParent(_ layers: [AnyLayer], _ childId: String) -> AnyLayer? {
        for layer in layers {
            if let children = layer.children {
                if children.contains(where: { $0.id == childId }) {
                    return layer
                }
                if let found = findParent(children, childId) {
                    return found
                }
            }
        }
        return nil
    }

    /// Check if a layer tree contains a specific ID.
    static func containsId(_ layers: [AnyLayer], _ id: String) -> Bool {
        findById(layers, id) != nil
    }

    /// Clone a layer deeply (including all children).
    static func cloneLayerDeep(_ layer: AnyLayer) -> AnyLayer {
        var cloned = layer
        cloned.id = genId()

        if let children = cloned.children {
            cloned.children = children.map { cloneLayerDeep($0) }
        }

        return cloned
    }

    /// Update a layer in the tree by ID.
    static func updateInTree(_ layers: [AnyLayer], id: String, update: (inout AnyLayer) -> Void)
        -> [AnyLayer]
    {
        return layers.map { layer in
            var mutableLayer = layer
            if layer.id == id {
                update(&mutableLayer)
                return mutableLayer
            }
            if let children = layer.children, !children.isEmpty {
                mutableLayer.children = updateInTree(children, id: id, update: update)
            }
            return mutableLayer
        }
    }

    /// Remove a layer from the tree by ID.
    static func removeFromTree(_ layers: [AnyLayer], id: String) -> [AnyLayer] {
        var result: [AnyLayer] = []

        for layer in layers {
            if layer.id == id {
                continue
            }
            var mutableLayer = layer
            if let children = layer.children, !children.isEmpty {
                mutableLayer.children = removeFromTree(children, id: id)
            }
            result.append(mutableLayer)
        }

        return result
    }

    /// Insert a layer into the tree.
    static func insertInTree(
        _ layers: [AnyLayer],
        layer: AnyLayer,
        parentId: String?,
        index: Int?
    ) -> [AnyLayer] {
        // If no parent, insert at root level
        if parentId == nil {
            var result = layers
            let insertIndex = min(index ?? result.count, result.count)
            result.insert(layer, at: insertIndex)
            return result
        }

        return layers.map { existingLayer in
            var mutableLayer = existingLayer
            if existingLayer.id == parentId {
                var children = mutableLayer.children ?? []
                let insertIndex = min(index ?? children.count, children.count)
                children.insert(layer, at: insertIndex)
                mutableLayer.children = children
            } else if let children = existingLayer.children, !children.isEmpty {
                mutableLayer.children = insertInTree(
                    children, layer: layer, parentId: parentId, index: index)
            }
            return mutableLayer
        }
    }

    /// Delete a layer from the tree (alias for removeFromTree).
    static func deleteInTree(_ layers: [AnyLayer], id: String) -> [AnyLayer] {
        removeFromTree(layers, id: id)
    }

    /// Insert a layer into the selected layer (as child) or at root level.
    static func insertIntoSelected(
        _ layers: [AnyLayer],
        selectedId: String?,
        layer: AnyLayer
    ) -> [AnyLayer] {
        guard let selectedId = selectedId else {
            // Insert at root level
            return layers + [layer]
        }

        // Check if selected layer exists
        guard let selectedLayer = findById(layers, selectedId) else {
            return layers + [layer]
        }

        // Can add children to basic, transform, or replicator layers
        let canHaveChildren: Bool
        switch selectedLayer {
        case .basic, .transform, .replicator:
            canHaveChildren = true
        default:
            canHaveChildren = false
        }

        if canHaveChildren {
            return insertInTree(layers, layer: layer, parentId: selectedId, index: nil)
        } else {
            // Insert as sibling after selected layer
            return insertAsSibling(layers, layer: layer, siblingId: selectedId, after: true)
        }
    }

    /// Insert a layer as a sibling of another layer.
    static func insertAsSibling(
        _ layers: [AnyLayer],
        layer: AnyLayer,
        siblingId: String,
        after: Bool
    ) -> [AnyLayer] {
        var result: [AnyLayer] = []

        for existingLayer in layers {
            if existingLayer.id == siblingId {
                if after {
                    result.append(existingLayer)
                    result.append(layer)
                } else {
                    result.append(layer)
                    result.append(existingLayer)
                }
            } else {
                var mutableLayer = existingLayer
                if let children = existingLayer.children, !children.isEmpty {
                    mutableLayer.children = insertAsSibling(
                        children, layer: layer, siblingId: siblingId, after: after)
                }
                result.append(mutableLayer)
            }
        }

        return result
    }

    /// Get the next layer name based on existing names.
    static func getNextLayerName(baseName: String, existingLayers: [AnyLayer]) -> String {
        let allNames = collectAllNames(existingLayers)

        if !allNames.contains(baseName) {
            return baseName
        }

        var counter = 1
        while allNames.contains("\(baseName) \(counter)") {
            counter += 1
        }

        return "\(baseName) \(counter)"
    }

    /// Collect all layer names in the tree.
    private static func collectAllNames(_ layers: [AnyLayer]) -> Set<String> {
        var names = Set<String>()

        for layer in layers {
            names.insert(layer.name)
            if let children = layer.children {
                names.formUnion(collectAllNames(children))
            }
        }

        return names
    }

    /// Flatten the layer tree into a single array.
    static func flattenLayers(_ layers: [AnyLayer]) -> [AnyLayer] {
        var result: [AnyLayer] = []

        for layer in layers {
            result.append(layer)
            if let children = layer.children {
                result.append(contentsOf: flattenLayers(children))
            }
        }

        return result
    }

    /// Get all layer IDs in the tree.
    static func getAllIds(_ layers: [AnyLayer]) -> Set<String> {
        Set(flattenLayers(layers).map { $0.id })
    }

    /// Move a layer within the tree.
    static func moveLayer(
        _ layers: [AnyLayer],
        sourceId: String,
        beforeId: String?,
        position: MovePosition
    ) -> [AnyLayer] {
        // First, remove the source layer
        guard let sourceLayer = findById(layers, sourceId) else {
            return layers
        }

        var result = removeFromTree(layers, id: sourceId)

        // Then insert at the new position
        switch position {
        case .before:
            if let beforeId = beforeId {
                result = insertAsSibling(
                    result, layer: sourceLayer, siblingId: beforeId, after: false)
            } else {
                result.insert(sourceLayer, at: 0)
            }
        case .after:
            if let beforeId = beforeId {
                result = insertAsSibling(
                    result, layer: sourceLayer, siblingId: beforeId, after: true)
            } else {
                result.append(sourceLayer)
            }
        case .into:
            if let beforeId = beforeId {
                result = insertInTree(result, layer: sourceLayer, parentId: beforeId, index: nil)
            } else {
                result.append(sourceLayer)
            }
        }

        return result
    }

    enum MovePosition {
        case before
        case after
        case into
    }
}
