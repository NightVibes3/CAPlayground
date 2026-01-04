//
//  CAProjectBundle.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// The complete project bundle containing all project data.
/// Mirrors the TypeScript type: `CAProjectBundle`
import Foundation

/// An asset reference within the project.
/// Mirrors: `CAAsset`

/// Document structure for a single CA type (Background, Floating, or Wallpaper).
/// Mirrors: `CADoc` from editor-context.tsx

/// Appearance mode (light or dark).

/// The active CA type being edited.

/// The complete project document containing all three CA document types.
/// Mirrors: `ProjectDocument` from editor-context.tsx

/// Project metadata.

/// Container for all three CA documents.
struct CAProjectBundle: Codable {
    var project: CAProject
    var root: AnyLayer
    var assets: [String: CAAsset]?
    var states: [String]?
    var stateOverrides: [String: [CAStateOverride]]?
    var stateTransitions: [CAStateTransition]?
    var wallpaperParallaxGroups: [GyroParallaxDictionary]?

    init(
        project: CAProject,
        root: AnyLayer,
        assets: [String: CAAsset]? = nil,
        states: [String]? = nil,
        stateOverrides: [String: [CAStateOverride]]? = nil,
        stateTransitions: [CAStateTransition]? = nil,
        wallpaperParallaxGroups: [GyroParallaxDictionary]? = nil
    ) {
        self.project = project
        self.root = root
        self.assets = assets
        self.states = states
        self.stateOverrides = stateOverrides
        self.stateTransitions = stateTransitions
        self.wallpaperParallaxGroups = wallpaperParallaxGroups
    }
}
struct CAAsset: Codable {
    var path: String
    var data: Data?

    init(path: String, data: Data? = nil) {
        self.path = path
        self.data = data
    }
}
struct CADocument: Codable {
    var layers: [AnyLayer]
    var selectedId: String?
    var states: [String]
    var stateOverrides: [String: [CAStateOverride]]?
    var activeState: CAState?
    var appearanceSplit: Bool?
    var appearanceMode: AppearanceMode?
    var wallpaperParallaxGroups: [GyroParallaxDictionary]?
    var camlHeaderComments: String?

    init(
        layers: [AnyLayer] = [],
        selectedId: String? = nil,
        states: [String] = ["Locked", "Unlock", "Sleep"],
        stateOverrides: [String: [CAStateOverride]]? = nil,
        activeState: CAState? = .baseState,
        appearanceSplit: Bool? = false,
        appearanceMode: AppearanceMode? = .light,
        wallpaperParallaxGroups: [GyroParallaxDictionary]? = nil,
        camlHeaderComments: String? = nil
    ) {
        self.layers = layers
        self.selectedId = selectedId
        self.states = states
        self.stateOverrides = stateOverrides
        self.activeState = activeState
        self.appearanceSplit = appearanceSplit
        self.appearanceMode = appearanceMode
        self.wallpaperParallaxGroups = wallpaperParallaxGroups
        self.camlHeaderComments = camlHeaderComments
    }

    static let empty = CADocument()
}
enum AppearanceMode: String, Codable {
    case light
    case dark
}
enum CAType: String, Codable {
    case background
    case floating
    case wallpaper

    var folderName: String {
        switch self {
        case .background: return "Background.ca"
        case .floating: return "Floating.ca"
        case .wallpaper: return "Wallpaper.ca"
        }
    }
}
struct ProjectDocument: Codable {
    var meta: ProjectMeta
    var activeCA: CAType
    var docs: ProjectDocs

    init(
        meta: ProjectMeta,
        activeCA: CAType = .floating,
        docs: ProjectDocs = ProjectDocs()
    ) {
        self.meta = meta
        self.activeCA = activeCA
        self.docs = docs
    }

    /// Get the currently active document
    var currentDocument: CADocument {
        get {
            switch activeCA {
            case .background: return docs.background
            case .floating: return docs.floating
            case .wallpaper: return docs.wallpaper
            }
        }
        set {
            switch activeCA {
            case .background: docs.background = newValue
            case .floating: docs.floating = newValue
            case .wallpaper: docs.wallpaper = newValue
            }
        }
    }
}
struct ProjectMeta: Codable {
    var id: String
    var name: String
    var width: CGFloat
    var height: CGFloat
    var background: String?
    var geometryFlipped: Int?
    var gyroEnabled: Bool?

    init(
        id: String = UUID().uuidString,
        name: String = "Untitled",
        width: CGFloat = 390,
        height: CGFloat = 844,
        background: String? = "#e5e7eb",
        geometryFlipped: Int? = 0,
        gyroEnabled: Bool? = false
    ) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
        self.background = background
        self.geometryFlipped = geometryFlipped
        self.gyroEnabled = gyroEnabled
    }
}
struct ProjectDocs: Codable {
    var background: CADocument
    var floating: CADocument
    var wallpaper: CADocument

    init(
        background: CADocument = .empty,
        floating: CADocument = .empty,
        wallpaper: CADocument = .empty
    ) {
        self.background = background
        self.floating = floating
        self.wallpaper = wallpaper
    }
}
