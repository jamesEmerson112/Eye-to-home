//
//  ContentView.swift
//  Phase1
//
//  Created by James Emerson Vo on 4/19/25.
//

import SwiftUI
import RealityKit
import UIKit

/*------------------------------------------------------------
 * ContentView
 * The main SwiftUI view for the app. Displays a RealityKit scene
 * with cubes and spheres, each with a static, bright color.
 *
 * Conforms to
 * -----------
 *   View – SwiftUI protocol for UI components.
 *----------------------------------------------------------*/
struct ContentView: View {
    // The main SwiftUI view body, embedding the AR view with colored shapes.
    var body: some View {
        StaticColorRealityView()
            .edgesIgnoringSafeArea(.all) // Ignore safe area for full AR experience.
    }
}

// MARK: - StaticColorRealityView: UIViewRepresentable for ARView with static-color entities

struct StaticColorRealityView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        // Start timing: record the current time before creating ARView and shapes.
        let startTime = CFAbsoluteTimeGetCurrent()
        let arView = ARView(frame: .zero) // Main AR view

        print("hello James")

        // Create a horizontal plane anchor (4x4 meters) for placing shapes.
        let anchor = AnchorEntity(
            .plane(
                .horizontal,
                classification: .any,
                minimumBounds: SIMD2<Float>(4.0, 4.0)
            )
        )

        // Helper to generate a random bright color (random hue, full saturation and brightness)
        func randomBrightColor() -> UIColor {
            let hue = CGFloat.random(in: 0...1)
            return UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }

        // Create 20 shapes (randomly cubes or spheres).
        for _ in 0..<8 {
            let mesh: MeshResource
            let yOffset: Float
            if Bool.random() {
                // Create a cube with size 0.3m and rounded corners.
                mesh = MeshResource.generateBox(size: 0.3, cornerRadius: 0.02)
                yOffset = 0.15 // Half the box height (so it sits on the plane)
            } else {
                // Create a sphere with radius 0.4m.
                mesh = MeshResource.generateSphere(radius: 0.4)
                yOffset = 0.15 // Center of the sphere (adjust as needed for your visual preference)
            }

            // Assign a random bright color to each shape.
            let material = SimpleMaterial(
                color: randomBrightColor(),
                roughness: 0.15,
                isMetallic: true
            )
            let entity = ModelEntity(mesh: mesh, materials: [material])
            // Place at a random position within the anchor's bounds.
            entity.position = [
                -4, // - number is North, + number is South
                1,  // Random y position in [1, 5] meters (height above plane)
                Float.random(in: -3...3)  // Random z position in [-3, 3] meters
            ]
            anchor.addChild(entity)
        }

        // Add the anchor (with all shapes) to the AR scene.
        arView.scene.addAnchor(anchor)

        // End timing: record the time after all shapes are added.
        let endTime = CFAbsoluteTimeGetCurrent()
        // Print the elapsed time to the Xcode console for profiling.
        print("DEBUG: Time to create ARView and shapes: \(endTime - startTime) seconds")

        return arView
    }

    // No update needed for UIViewRepresentable in this case.
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// Provides a preview of ContentView for Xcode's canvas.
#Preview {
    ContentView()
}
