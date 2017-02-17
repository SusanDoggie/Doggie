//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let doc = DGDocument(root: 0, table: [
    0: [
        "Pages": [.indirect(1), .indirect(2), .indirect(3)],
        "HHH": 0
    ],
    1: nil,
    2: ", ",
    3: 0.7
    ])

let data = doc.data

print(String(data: data, encoding: .utf8) ?? "")

do {
    
    let document = try DGDocument.Parse(data: data)
    
    print(document)

} catch let DGDocument.ParserError.invalidFormat(msg) {
    print("invalid format:", msg)
} catch let DGDocument.ParserError.unknownToken(pos) {
    print("unknown token:", pos)
} catch DGDocument.ParserError.unexpectedEOF {
    print("unexpected EOF")
}
