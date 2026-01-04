//
//  ProjectStorage.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Manages project metadata storage.
import Foundation

actor ProjectStorage {

    static let shared = ProjectStorage()

    private let fileStorage = FileStorageService.shared
    private let metadataFilename = "project.json"

    // MARK: - Project Metadata

    /// Load project metadata.
    func loadProjectMeta(projectId: String) async throws -> ProjectMeta? {
        guard await fileStorage.fileExists(projectId: projectId, path: metadataFilename) else {
            return nil
        }

        let data = try await fileStorage.readBinaryFile(
            projectId: projectId, path: metadataFilename)
        return try JSONDecoder().decode(ProjectMeta.self, from: data)
    }

    /// Save project metadata.
    func saveProjectMeta(projectId: String, meta: ProjectMeta) async throws {
        let data = try JSONEncoder().encode(meta)
        try await fileStorage.writeBinaryFile(
            projectId: projectId, path: metadataFilename, data: data)
    }

    /// List all projects with their metadata.
    func listProjects() async throws -> [ProjectMeta] {
        let projectIds = try await fileStorage.listProjectIds()
        var projects: [ProjectMeta] = []

        for id in projectIds {
            if let meta = try await loadProjectMeta(projectId: id) {
                projects.append(meta)
            }
        }

        return projects
    }

    /// Create a new project.
    func createProject(name: String, width: CGFloat, height: CGFloat, gyroEnabled: Bool = false)
        async throws -> ProjectMeta
    {
        let projectId = IDGenerator.projectId()

        let meta = ProjectMeta(
            id: projectId,
            name: name,
            width: width,
            height: height,
            background: "#e5e7eb",
            geometryFlipped: 0,
            gyroEnabled: gyroEnabled
        )

        // Create project directory
        _ = try await fileStorage.createProject(id: projectId)

        // Save metadata
        try await saveProjectMeta(projectId: projectId, meta: meta)

        return meta
    }

    /// Delete a project.
    func deleteProject(projectId: String) async throws {
        try await fileStorage.deleteProject(id: projectId)
    }

    /// Duplicate a project.
    func duplicateProject(projectId: String, newName: String) async throws -> ProjectMeta {
        guard let originalMeta = try await loadProjectMeta(projectId: projectId) else {
            throw ProjectStorageError.projectNotFound
        }

        // Create new project
        let newMeta = try await createProject(
            name: newName,
            width: originalMeta.width,
            height: originalMeta.height,
            gyroEnabled: originalMeta.gyroEnabled ?? false
        )

        // Copy all files
        let files = try await fileStorage.listFiles(projectId: projectId)
        for file in files {
            if file.path != metadataFilename {
                let data = try await fileStorage.readBinaryFile(
                    projectId: projectId, path: file.path)
                try await fileStorage.writeBinaryFile(
                    projectId: newMeta.id, path: file.path, data: data)
            }
        }

        return newMeta
    }
}
enum ProjectStorageError: Error {
    case projectNotFound
    case invalidProjectData
    case fileOperationFailed
}
