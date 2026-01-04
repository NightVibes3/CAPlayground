//
//  ContentView.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

import SwiftUI

/// Container view that loads project metadata and creates the editor.

/// Project list view for selecting or creating projects.

/// Sheet for creating a new project.

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isShowingProjectList {
                ProjectListView()
            } else if let projectId = appState.currentProjectId {
                EditorContainerView(projectId: projectId)
            }
        }
    }
}
struct EditorContainerView: View {
    let projectId: String

    @EnvironmentObject var appState: AppState
    @State private var projectMeta: ProjectMeta?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading project...")
            } else if let error = error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.secondary)
                    Button("Go Back") {
                        appState.closeProject()
                    }
                }
            } else if let meta = projectMeta {
                EditorView(projectId: projectId, initialMeta: meta)
            }
        }
        .task {
            await loadProject()
        }
    }

    private func loadProject() async {
        do {
            if let meta = try await ProjectStorage.shared.loadProjectMeta(projectId: projectId) {
                projectMeta = meta
            } else {
                // Create a default meta for now
                projectMeta = ProjectMeta(
                    id: projectId,
                    name: "Untitled",
                    width: 390,
                    height: 844
                )
            }
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
}
struct ProjectListView: View {
    @EnvironmentObject var appState: AppState
    @State private var projects: [ProjectMeta] = []
    @State private var isLoading = true
    @State private var showingNewProjectSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading projects...")
                } else if projects.isEmpty {
                    emptyStateView
                } else {
                    projectList
                }
            }
            .navigationTitle("CAPlayground")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewProjectSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewProjectSheet) {
                NewProjectSheet()
            }
        }
        .task {
            await loadProjects()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Projects")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create your first project to get started")
                .foregroundColor(.secondary)

            Button {
                showingNewProjectSheet = true
            } label: {
                Label("New Project", systemImage: "plus")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var projectList: some View {
        List {
            ForEach(projects, id: \.id) { project in
                Button {
                    appState.openProject(id: project.id)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(project.name)
                                .font(.headline)
                            Text("\(Int(project.width)) × \(Int(project.height))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            .onDelete(perform: deleteProjects)
        }
    }

    private func loadProjects() async {
        do {
            projects = try await ProjectStorage.shared.listProjects()
        } catch {
            print("Failed to load projects: \(error)")
        }
        isLoading = false
    }

    private func deleteProjects(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let project = projects[index]
                try? await ProjectStorage.shared.deleteProject(projectId: project.id)
            }
            await loadProjects()
        }
    }
}
struct NewProjectSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var projectName = ""
    @State private var selectedDevice = DevicePresets.default
    @State private var isGyroEnabled = false
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Name") {
                    TextField("My Wallpaper", text: $projectName)
                }

                Section("Canvas Size") {
                    Picker("Device", selection: $selectedDevice) {
                        ForEach(DevicePresets.allPhones) { device in
                            Text(device.name).tag(device)
                        }
                    }

                    HStack {
                        Text("Width")
                        Spacer()
                        Text("\(Int(selectedDevice.width))")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Height")
                        Spacer()
                        Text("\(Int(selectedDevice.height))")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Type") {
                    Toggle("Gyro Wallpaper", isOn: $isGyroEnabled)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createProject()
                    }
                    .disabled(projectName.isEmpty || isCreating)
                }
            }
        }
    }

    private func createProject() {
        isCreating = true

        Task {
            do {
                _ = try await appState.createNewProject(
                    name: projectName.isEmpty ? "Untitled" : projectName,
                    width: selectedDevice.width,
                    height: selectedDevice.height,
                    gyroEnabled: isGyroEnabled
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to create project: \(error)")
                isCreating = false
            }
        }
    }
}
#Preview {
    ContentView()
        .environmentObject(AppState())
}
