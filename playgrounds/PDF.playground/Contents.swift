//: Playground - noun: a place where people can play

import Cocoa
import Doggie

extension PDFDocument {
    
    public enum ParserError: Error {
        case invalidFormat
    }
    
    public static func Parse(data: Data) throws {
        
        guard Array(data[0..<5]) == [37, 80, 68, 70, 45] else {
            throw ParserError.invalidFormat
        }
        
        print(Array(zip(Array(data[0..<20]),
        (String(data: Data(data[0..<20]), encoding: .ascii) ?? "").characters)))
        String(data: Data([48, 49, 50, 57]), encoding: .ascii)
    }
    
    private static func version(data: Data) -> (Int, Int) {
        
        var major = 0
        var minor = 0
        var flag = false
        
        for d in data.dropFirst(5) {
            
            if 48...57 ~= d {
                
            }
            
            if flag {
                
            }
            
        }
        
        return (major, minor)
    }
}

if let url = Bundle.main.url(forResource: "test", withExtension: "pdf"), let data = try? Data(contentsOf: url) {
    
    print(String(data: data, encoding: .ascii) ?? "")
    
    try PDFDocument.Parse(data: data)
    
    
}

