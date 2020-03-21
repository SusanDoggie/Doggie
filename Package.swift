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

import PackageDescription

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
            path: "./Dependencies/brotli/c",
            sources: [
                "common",
                "dec",
                "enc",
                "include",
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
