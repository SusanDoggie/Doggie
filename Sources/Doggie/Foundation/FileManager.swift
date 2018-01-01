//
//  FileManager.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

extension FileManager {
    
    func fileUrls<S : Sequence>(_ urls: S) -> Set<URL> where S.Element == URL {
        
        var result: Set<URL> = []
        
        var checked: Set<URL> = []
        var searchPaths = Array(urls)
        
        while let url = searchPaths.popLast()?.standardized.resolvingSymlinksInPath() {
            
            guard !checked.contains(url) else { continue }
            guard let enumerator = self.enumerator(at: url, includingPropertiesForKeys: nil, options: [], errorHandler: nil) else { continue }
            
            checked.insert(url)
            
            for url in enumerator {
                
                guard let url = url as? URL else { continue }
                
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
                    
                    guard let resourceValues = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .isAliasFileKey]) else { continue }
                    
                    if resourceValues.isAliasFile == true {
                        
                        guard let _url = try? URL(resolvingAliasFileAt: url) else { continue }
                        searchPaths.append(_url)
                        
                    } else if resourceValues.isSymbolicLink == true {
                        
                        searchPaths.append(url)
                        
                    } else if resourceValues.isRegularFile == true {
                        
                        result.insert(url)
                    }
                    
                #else
                    
                    guard let resourceValues = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey]) else { continue }
                    
                    if resourceValues.isSymbolicLink == true {
                        
                        searchPaths.append(url)
                        
                    } else if resourceValues.isRegularFile == true {
                        
                        result.insert(url)
                    }
                    
                #endif
            }
        }
        
        return result
    }
}

