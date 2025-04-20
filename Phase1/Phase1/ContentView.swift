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
 * with a cube anchored to a horizontal plane.
 *
 * Conforms to
 * -----------
 *   View – SwiftUI protocol for UI components.
 *----------------------------------------------------------*/
struct ContentView : View {

    // The main content and layout of the view.
    var body: some View {
        RealityView { content in

            // Create a horizontal plane anchor with minimum bounds of 4 x 4 meters.
            let anchor = AnchorEntity(
                .plane(
                    .horizontal,
                    classification: .any,
                    minimumBounds: SIMD2<Float>(4.0, 4.0)
                )
            )

            // Spawn 10 cubes at random positions
            for _ in 0..<10 {
                let model = Entity()
                // Generate a box mesh with size 1.0 meters (1m x 1m x 1m)
                let mesh = MeshResource.generateBox(size: 0.8, cornerRadius: 0.005)
                // Assign a random color to each cube using UIColor
                let material = SimpleMaterial(
                    color: UIColor.random(),
                    roughness: 0.15,
                    isMetallic: true
                )
                model.components.set(ModelComponent(mesh: mesh, materials: [material]))
                // Set the position: x and z random in [-2, 2], y = 0.5 so the cube sits on the plane
                model.position = [
                    Float.random(in: -4.0...4.0),
                    Float.random(in: 0...2.0),
                    Float.random(in: -4.0...4.0)
                ]
                anchor.addChild(model)
            }

            // Add the anchor (with all cubes) to the RealityKit scene.
            content.add(anchor)

            // Set the camera mode to spatial tracking.
            content.camera = .spatialTracking

        }
        // Extend the view to ignore safe area insets on all edges.
        .edgesIgnoringSafeArea(.all)
    }

}

extension UIColor {
    /// Returns a random UIColor.
    static func random() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}

// Provides a preview of ContentView for Xcode's canvas.
#Preview {
    ContentView() // Instantiate ContentView for preview.
}
