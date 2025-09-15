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
    // State variable to control when to spawn objects
    @State private var spawnObjects = false
    @State private var showSaveAlert = false
    @State private var saveError: String?
    @State private var takeScreenshotTrigger = 0

    var body: some View {
        ZStack {
            StaticColorRealityView(
                spawnObjects: $spawnObjects,
                takeScreenshotTrigger: $takeScreenshotTrigger,
                onScreenshot: { image in
                    if let image = image {
                        saveImageToDownloadFolder(image: image)
                    } else {
                        saveError = "Failed to capture screenshot."
                        showSaveAlert = true
                    }
                }
            )
            .edgesIgnoringSafeArea(.all) // Ignore safe area for full AR experience.
            VStack {
                Spacer()
                // Temporarily hide the "Take Picture" button
                /*
                Button(action: {
                    takeScreenshotTrigger += 1
                }) {
                    Text("Take Picture")
                        .font(.title2)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom, 10)
                */
                Button(action: {
                    spawnObjects = true
                    print("Balloons are spawning")
                }) {
                    Text("Spawn Fun")
                        .font(.title2)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom, 40)
                .disabled(spawnObjects)
            }
            .alert(isPresented: $showSaveAlert) {
                if let error = saveError {
                    return Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
                } else {
                    return Alert(title: Text("Saved"), message: Text("Screenshot saved to download folder."), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    // Save image to "download" folder in app's Documents directory
    func saveImageToDownloadFolder(image: UIImage) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            saveError = "Could not access documents directory."
            showSaveAlert = true
            return
        }
        let downloadURL = documentsURL.appendingPathComponent("download")
        if !fileManager.fileExists(atPath: downloadURL.path) {
            do {
                try fileManager.createDirectory(at: downloadURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                saveError = "Failed to create download folder: \(error.localizedDescription)"
                showSaveAlert = true
                return
            }
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = "screenshot_\(formatter.string(from: Date())).jpg"
        let fileURL = downloadURL.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.95) else {
            saveError = "Failed to convert screenshot to JPEG."
            showSaveAlert = true
            return
        }
        do {
            try data.write(to: fileURL)
            saveError = nil
        } catch {
            saveError = "Failed to save screenshot: \(error.localizedDescription)"
        }
        showSaveAlert = true
    }
}

// MARK: - StaticColorRealityView: UIViewRepresentable for ARView with static-color entities

struct StaticColorRealityView: UIViewRepresentable {
    @Binding var spawnObjects: Bool
    @Binding var takeScreenshotTrigger: Int
    var onScreenshot: (UIImage?) -> Void

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // Store anchor in coordinator for later use
        let anchor = AnchorEntity(
            .plane(
                .horizontal,
                classification: .any,
                minimumBounds: SIMD2<Float>(4.0, 4.0)
            )
        )
        arView.scene.addAnchor(anchor)
        context.coordinator.anchor = anchor
        context.coordinator.arView = arView

        // Spawn 2 spheres for initialization (no offset)
        context.coordinator.spawnInitialSpheres()

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Only spawn objects if spawnObjects is true and we haven't spawned yet
        if spawnObjects && !context.coordinator.didSpawn {
            context.coordinator.didSpawn = true
            context.coordinator.spawnObjects {
                // After spawning, allow button to be pressed again
                DispatchQueue.main.async {
                    self.spawnObjects = false
                    context.coordinator.didSpawn = false
                }
            }
        }
        // Take screenshot if trigger changed
        if context.coordinator.lastScreenshotTrigger != takeScreenshotTrigger {
            context.coordinator.lastScreenshotTrigger = takeScreenshotTrigger
            context.coordinator.takeScreenshot(onScreenshot: onScreenshot)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var didSpawn = false
        var anchor: AnchorEntity?
        var arView: ARView?
        var spawnCount = 0
        var numToSpawn = 5
        var lastScreenshotTrigger: Int = 0

        func spawnInitialSpheres() {
            guard let anchor = anchor else { return }
            print("Spawning 2 initialization balloons...")
            func randomBrightColor() -> UIColor {
                let hue = CGFloat.random(in: 0...1)
                return UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            }
            // Spawn 2 spheres at startup, no offset
            for _ in 0..<2 {
                let mesh = MeshResource.generateSphere(radius: 0.8)
                let material = SimpleMaterial(
                    color: randomBrightColor(),
                    roughness: 0.15,
                    isMetallic: true
                )
                let entity = ModelEntity(mesh: mesh, materials: [material])
                entity.position = [
                    Float.random(in: -5...5),
                    Float.random(in: 3...10),
                    Float.random(in: -5...5)
                ]
                anchor.addChild(entity)
            }
        }

        func spawnObjects(completion: (() -> Void)? = nil) {
            guard let anchor = anchor else { return }

            // Increment spawn count for each batch
            spawnCount += 1

            // Calculate offset for this batch (circular pattern)
            let angle = Double(spawnCount) * .pi / 4
            let offsetDistance: Double = 3.0 * Double(spawnCount)
            let offsetX = cos(angle) * offsetDistance
            let offsetZ = sin(angle) * offsetDistance

            func randomBrightColor() -> UIColor {
                let hue = CGFloat.random(in: 0...1)
                return UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            }

            // Spheres
            print("spawning")
            for _ in 0..<numToSpawn {
                let mesh = MeshResource.generateSphere(radius: 0.8)
                let material = SimpleMaterial(
                    color: randomBrightColor(),
                    roughness: 0.15,
                    isMetallic: true
                )
                let entity = ModelEntity(mesh: mesh, materials: [material])
                entity.position = [
                    Float.random(in: -5...5) + Float(offsetX),
                    Float.random(in: 3...10),
                    Float.random(in: -5...5) + Float(offsetZ)
                ]
                anchor.addChild(entity)
            }

            // Increment the number of spheres to spawn for next press
            numToSpawn += 1

            // Call completion after spawning is done
            completion?()

            // Cubes
            /*
            for _ in 0..<4 {
                let mesh = MeshResource.generateBox(size: 0.5, cornerRadius: 0.02)
                let material = SimpleMaterial(
                    color: randomBrightColor(),
                    roughness: 0.15,
                    isMetallic: true
                )
                let entity = ModelEntity(mesh: mesh, materials: [material])
                entity.position = [
                    Float.random(in: -3...3),
                    Float.random(in: 0...3),
                    Float.random(in: -3...3)
                ]
                let textMesh = MeshResource.generateText(
                    "Hello James",
                    extrusionDepth: 0.02,
                    font: .systemFont(ofSize: 0.15),
                    containerFrame: .zero,
                    alignment: .center,
                    lineBreakMode: .byWordWrapping
                )
                let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
                let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
                textEntity.position = [0, 0.5, 0]
                entity.addChild(textEntity)
                anchor.addChild(entity)
            }
            */
        }

        func takeScreenshot(onScreenshot: @escaping (UIImage?) -> Void) {
            guard let arView = arView else {
                onScreenshot(nil)
                return
            }
            arView.snapshot(saveToHDR: false) { image in
                onScreenshot(image)
            }
        }
    }
}

#Preview {
    ContentView()
}
