// swift-tools-version:5.3
//
//  Package.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import PackageDescription

let package = Package(
    name: "Doggie",
    products: [
        .library(name: "DoggieCore", targets: ["DoggieCore"]),
        .library(name: "DoggieGeometry", targets: ["DoggieGeometry"]),
        .library(name: "DoggieGraphics", targets: ["DoggieGraphics"]),
        .library(name: "Doggie", targets: ["Doggie"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SusanDoggie/brotli.git", .branch("master")),
        .package(url: "https://github.com/SusanDoggie/libwebp.git", .branch("master")),
        .package(url: "https://github.com/SusanDoggie/libjpeg.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "zlib_c",
            dependencies: [],
            linkerSettings: [.linkedLibrary("z")]
        ),
        .target(
            name: "DoggieCore",
            dependencies: [
                "zlib_c",
                "brotli",
            ]
        ),
        .target(
            name: "DoggieGeometry",
            dependencies: [
                "DoggieCore",
            ]
        ),
        .target(
            name: "DoggieGraphics",
            dependencies: [
                "DoggieCore",
                "DoggieGeometry",
                "libwebp",
                "libjpeg",
            ]
        ),
        .target(
            name: "Doggie",
            dependencies: [
                "DoggieCore",
                "DoggieGeometry",
                "DoggieGraphics",
            ]
        ),
        .testTarget(
            name: "DoggieTests",
            dependencies: [
                "Doggie",
            ],
            resources: [
                .copy("images"),
            ]
        ),
    ]
)
