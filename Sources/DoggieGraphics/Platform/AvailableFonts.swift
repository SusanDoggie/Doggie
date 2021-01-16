//
//  AvailableFonts.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

#if canImport(Darwin)

extension FontCollection {
    
    public static var availableFonts: FontCollection {
        
        var files = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask).map { URL(fileURLWithFileSystemRepresentation: "Fonts/", isDirectory: true, relativeTo: $0) }
        
        #if os(iOS) || os(tvOS) || os(watchOS)
        
        if let fonts = Bundle.main.object(forInfoDictionaryKey: "UIAppFonts") as? [String] {
            for font in fonts {
                if let url = Bundle.main.url(forResource: font, withExtension: nil) {
                    files.append(url)
                }
            }
        }
        
        #endif
        
        return FontCollection(urls: files)
    }
    
}

#elseif os(Linux)

extension FontCollection {
    
    public static var availableFonts: FontCollection {
        
        let urls = [
            URL(fileURLWithPath: "/usr/share/fonts", isDirectory: true),
            URL(fileURLWithPath: "/usr/local/share/fonts", isDirectory: true),
            URL(fileURLWithFileSystemRepresentation: ".fonts/", isDirectory: true, relativeTo: FileManager.default.homeDirectoryForCurrentUser),
            ]
        
        return FontCollection(urls: urls)
    }
}

#endif
