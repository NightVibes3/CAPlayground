//
//  AssetStorage.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import Foundation

/// Manages asset storage and caching.
import UIKit

actor AssetStorage {

    static let shared = AssetStorage()

    private let fileStorage = FileStorageService.shared
    private var imageCache: [String: UIImage] = [:]
    private let maxCacheSize = 50

    // MARK: - Image Operations

    /// Load an image from storage.
    func loadImage(projectId: String, projectName: String, caType: CAType, assetPath: String)
        async throws -> UIImage
    {
        let cacheKey = "\(projectId)/\(caType.rawValue)/\(assetPath)"

        // Check cache first
        if let cached = imageCache[cacheKey] {
            return cached
        }

        // Load from storage
        let assetName = assetPath.hasPrefix("assets/") ? String(assetPath.dropFirst(7)) : assetPath
        let data = try await fileStorage.readAsset(
            projectId: projectId,
            projectName: projectName,
            caType: caType,
            assetName: assetName
        )

        guard let image = UIImage(data: data) else {
            throw AssetStorageError.invalidImageData
        }

        // Cache the image
        addToCache(key: cacheKey, image: image)

        return image
    }

    /// Save an image to storage.
    func saveImage(
        projectId: String,
        projectName: String,
        caType: CAType,
        assetName: String,
        image: UIImage,
        quality: CGFloat = 0.9
    ) async throws {
        let filename = assetName.sanitizedFilename()
        let ext = filename.fileExtension?.lowercased() ?? "jpg"

        let data: Data
        if ext == "png" {
            guard let pngData = image.pngData() else {
                throw AssetStorageError.imageEncodingFailed
            }
            data = pngData
        } else {
            guard let jpegData = image.jpegData(compressionQuality: quality) else {
                throw AssetStorageError.imageEncodingFailed
            }
            data = jpegData
        }

        try await fileStorage.writeAsset(
            projectId: projectId,
            projectName: projectName,
            caType: caType,
            assetName: filename,
            data: data
        )

        // Update cache
        let cacheKey = "\(projectId)/\(caType.rawValue)/assets/\(filename)"
        addToCache(key: cacheKey, image: image)
    }

    /// Save raw data as an asset.
    func saveData(
        projectId: String,
        projectName: String,
        caType: CAType,
        assetName: String,
        data: Data
    ) async throws {
        let filename = assetName.sanitizedFilename()
        try await fileStorage.writeAsset(
            projectId: projectId,
            projectName: projectName,
            caType: caType,
            assetName: filename,
            data: data
        )
    }

    /// Delete an asset.
    func deleteAsset(
        projectId: String,
        projectName: String,
        caType: CAType,
        assetName: String
    ) async throws {
        try await fileStorage.deleteAsset(
            projectId: projectId,
            projectName: projectName,
            caType: caType,
            assetName: assetName
        )

        // Remove from cache
        let cacheKey = "\(projectId)/\(caType.rawValue)/assets/\(assetName)"
        imageCache.removeValue(forKey: cacheKey)
    }

    /// List all assets for a CA type.
    func listAssets(
        projectId: String,
        projectName: String,
        caType: CAType
    ) async throws -> [StoredFile] {
        try await fileStorage.listAssets(
            projectId: projectId,
            projectName: projectName,
            caType: caType
        )
    }

    // MARK: - Video Frame Operations

    /// Save video frames to storage.
    func saveVideoFrames(
        projectId: String,
        projectName: String,
        caType: CAType,
        framePrefix: String,
        frames: [(index: Int, image: UIImage)],
        extension: String = "jpg",
        quality: CGFloat = 0.85
    ) async throws {
        for (index, image) in frames {
            let filename = "\(framePrefix)\(index).\(`extension`)"
            try await saveImage(
                projectId: projectId,
                projectName: projectName,
                caType: caType,
                assetName: filename,
                image: image,
                quality: quality
            )
        }
    }

    /// Load a video frame from storage.
    func loadVideoFrame(
        projectId: String,
        projectName: String,
        caType: CAType,
        framePrefix: String,
        frameIndex: Int,
        extension: String = "jpg"
    ) async throws -> UIImage {
        let filename = "\(framePrefix)\(frameIndex).\(`extension`)"
        return try await loadImage(
            projectId: projectId,
            projectName: projectName,
            caType: caType,
            assetPath: "assets/\(filename)"
        )
    }

    // MARK: - Cache Management

    private func addToCache(key: String, image: UIImage) {
        // Simple LRU-like eviction
        if imageCache.count >= maxCacheSize {
            // Remove first item (oldest)
            if let firstKey = imageCache.keys.first {
                imageCache.removeValue(forKey: firstKey)
            }
        }
        imageCache[key] = image
    }

    /// Clear the image cache.
    func clearCache() {
        imageCache.removeAll()
    }

    /// Remove a specific item from cache.
    func removeFromCache(projectId: String, caType: CAType, assetPath: String) {
        let cacheKey = "\(projectId)/\(caType.rawValue)/\(assetPath)"
        imageCache.removeValue(forKey: cacheKey)
    }
}
enum AssetStorageError: Error {
    case invalidImageData
    case imageEncodingFailed
    case assetNotFound
}
