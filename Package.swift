// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MusicBoxd", // Assuming this is the project name, adjust if needed
    platforms: [
        .iOS(.v15) // Specify appropriate iOS version for the project
    ],
    products: [
        // Define products if this package were to be used as a library.
        // For an app, this might be less critical unless you have library targets.
        // Adding a dummy library product to make the package valid.
        .library(
            name: "MusicBoxdAppLibrary",
            targets: ["MusicBoxdAppTarget"]) // A placeholder target name
    ],
    dependencies: [
        // Add Kingfisher as a dependency
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0")
    ],
    targets: [
        // Define a placeholder target.
        // In a real scenario, you'd map this to your app's source files
        // or specific modules if you refactor into a Swift Package structure.
        // For just adding a dependency to an existing .xcodeproj, this target
        // definition is more of a formality for Package.swift structure.
        .target(
            name: "MusicBoxdAppTarget", // Placeholder target
            dependencies: [
                "Kingfisher" // Make this placeholder target depend on Kingfisher
            ],
            path: "MusicBoxd" // Point to the main source directory
                              // This assumes your app sources are directly in "MusicBoxd/"
                              // Adjust if you have a more nested structure like "MusicBoxd/Source"
        )
        // If you have test targets, they could be defined here as well.
        // .testTarget(
        //     name: "MusicBoxdTests",
        //     dependencies: ["MusicBoxdAppTarget"],
        //     path: "MusicBoxdTests"
        // ),
    ]
)
