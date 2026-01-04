//
//  CAPlaygroundApp.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import SwiftUI

/// Global application state.
@main
struct CAPlaygroundApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
class AppState: ObservableObject {
    @Published var currentProjectId: String?
    @Published var isShowingProjectList = true

    let projectStorage = ProjectStorage.shared

    func createNewProject(name: String, width: CGFloat, height: CGFloat, gyroEnabled: Bool = false)
        async throws -> ProjectMeta
    {
        let meta = try await projectStorage.createProject(
            name: name,
            width: width,
            height: height,
            gyroEnabled: gyroEnabled
        )
        await MainActor.run {
            currentProjectId = meta.id
            isShowingProjectList = false
        }
        return meta
    }

    func openProject(id: String) {
        currentProjectId = id
        isShowingProjectList = false
    }

    func closeProject() {
        currentProjectId = nil
        isShowingProjectList = true
    }
}
