//
//  CTFont.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    
    extension FontCollection {
        
        @available(OSX 10.11, iOS 9.0, *)
        public static var availableFonts: FontCollection {
            
            var availableFonts = FontCollection()
            
            var searchPaths = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask).map { URL(fileURLWithPath: "Fonts", relativeTo: $0) }
            
            while let url = searchPaths.popLast() {
                
                if let enumerator = FileManager.default.enumerator(at: url.resolvingSymlinksInPath(), includingPropertiesForKeys: nil, options: [], errorHandler: nil) {
                    
                    for url in enumerator {
                        
                        if let url = url as? URL, let resourceValues = try? url.resourceValues(forKeys: [.isAliasFileKey]) {
                            
                            if resourceValues.isAliasFile == true {
                                
                                if let url = try? URL(resolvingAliasFileAt: url) {
                                    searchPaths.append(url)
                                }
                                
                            } else if url.isFileURL {
                                
                                if let data = try? Data(contentsOf: url, options: .alwaysMapped), let fonts = try? FontCollection(data: data) {
                                    availableFonts.formUnion(fonts)
                                }
                            }
                        }
                        
                    }
                }
            }
            
            return availableFonts
        }
        
    }
    
#endif
