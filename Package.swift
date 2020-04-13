// swift-tools-version:5.1
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import PackageDescription

let project_dir = "\(#file)".dropLast("/Package.swift".count)

let package = Package(
    name: "Doggie",
    products: [
        .library(name: "SDFoundation", targets: ["SDFoundation"]),
        .library(name: "SDCompression", targets: ["SDCompression"]),
        .library(name: "SDGeometry", targets: ["SDGeometry"]),
        .library(name: "SDGraphics", targets: ["SDGraphics"]),
        .library(name: "Doggie", targets: ["Doggie"]),
    ],
    targets: [
        .target(
            name: "zlib_c",
            dependencies: [],
            linkerSettings: [.linkedLibrary("z")]
        ),
        .target(
            name: "brotli_c",
            dependencies: [],
            path: "./dependencies/brotli/c",
            exclude: [
                "common/dictionary.bin",
                "common/dictionary.bin.br",
            ],
            sources: [
                "common",
                "dec",
                "enc",
                "include",
            ]
        ),
        .target(
            name: "libwebp",
            dependencies: [],
            path: "./dependencies/libwebp",
            exclude: {
                guard var files = try? FileManager.default.subpathsOfDirectory(atPath: "\(project_dir)/dependencies/libwebp/src") else { return [] }
                files = files.filter { $0.contains(".") && !$0.hasSuffix(".h") && !$0.hasSuffix(".c") }
                files = files.map { "src/\($0)" }
                return files
            }(),
            sources: [
                "src",
            ],
            publicHeadersPath: "src/webp",
            cSettings: [
                .headerSearchPath("./"),
            ]
        ),
        .target(
            name: "libjpeg",
            dependencies: [],
            cSettings: [
                .headerSearchPath("include/libjpeg"),
                .unsafeFlags(["-I\(project_dir)/dependencies/libjpeg-turbo"]),
            ]
        ),
        .target(name: "SDFoundation", dependencies: []),
        .target(name: "SDCompression", dependencies: [
            "zlib_c",
            "brotli_c",
        ]),
        .target(name: "SDGeometry", dependencies: [
            "SDFoundation",
        ]),
        .target(name: "SDGraphics", dependencies: [
            "SDFoundation",
            "SDGeometry",
            "SDCompression",
            "libwebp",
            "libjpeg",
        ]),
        .target(name: "Doggie", dependencies: [
            "SDFoundation",
            "SDGeometry",
            "SDGraphics",
        ]),
        .testTarget(name: "DoggieTests", dependencies: [
            "Doggie",
        ]),
    ]
)
