//
//  StateTransition.swift
//  CAPlayground
//
//  Created by CAPlayground iOS Conversion
//

/// Manages state transitions and their animations.
/// This file consolidates state transition logic for the editor.
import Foundation

/// Default spring animation configuration matching the web app.
struct StateTransitionManager {

    /// Build transitions for a given set of state names and overrides.
    /// Mirrors the `buildTransitions` function from editor-context.tsx
    static func buildTransitions(
        stateNames: [String],
        overrides: [String: [CAStateOverride]]?
    ) -> [CAStateTransition] {
        var result: [CAStateTransition] = []
        guard let overrides = overrides else { return result }

        let allowedKeyPaths: Set<String> = ["opacity", "cornerRadius", "zPosition"]
        let names = stateNames.filter { $0 != "Base State" && !$0.isEmpty }

        for state in names {
            let stateOverrides = overrides[state] ?? []
            let filteredOverrides = stateOverrides.filter { allowedKeyPaths.contains($0.keyPath) }

            let elements = filteredOverrides.map { override -> CAStateTransitionElement in
                let animation = CAStateTransitionAnim(
                    type: "CASpringAnimation",
                    damping: 50,
                    mass: 2,
                    stiffness: 300,
                    velocity: 0,
                    duration: 0.8,
                    fillMode: "backwards",
                    keyPath: override.keyPath
                )
                return CAStateTransitionElement(
                    targetId: override.targetId,
                    keyPath: override.keyPath,
                    animation: animation
                )
            }

            // Add bidirectional transitions
            result.append(CAStateTransition(fromState: "*", toState: state, elements: elements))
            result.append(CAStateTransition(fromState: state, toState: "*", elements: elements))
        }

        return result
    }

    /// Get the base state name from a variant state name.
    /// e.g., "Locked Light" -> "Locked"
    static func baseStateName(from stateName: String) -> String {
        stateName
            .replacingOccurrences(of: " Light", with: "")
            .replacingOccurrences(of: " Dark", with: "")
    }

    /// Check if a state name is a variant (has Light or Dark suffix).
    static func isVariantState(_ stateName: String) -> Bool {
        stateName.hasSuffix(" Light") || stateName.hasSuffix(" Dark")
    }

    /// Get the appearance mode from a state name.
    static func appearanceMode(from stateName: String) -> AppearanceMode? {
        if stateName.hasSuffix(" Light") {
            return .light
        } else if stateName.hasSuffix(" Dark") {
            return .dark
        }
        return nil
    }

    /// Generate variant state name.
    static func variantStateName(baseName: String, appearance: AppearanceMode) -> String {
        "\(baseName) \(appearance == .light ? "Light" : "Dark")"
    }
}
struct DefaultSpringAnimation {
    static let damping: CGFloat = 50
    static let mass: CGFloat = 2
    static let stiffness: CGFloat = 300
    static let velocity: CGFloat = 0
    static let duration: CGFloat = 0.8
    static let fillMode = "backwards"

    static var config: CAStateTransitionAnim {
        CAStateTransitionAnim(
            type: "CASpringAnimation",
            damping: damping,
            mass: mass,
            stiffness: stiffness,
            velocity: velocity,
            duration: duration,
            fillMode: fillMode
        )
    }
}
