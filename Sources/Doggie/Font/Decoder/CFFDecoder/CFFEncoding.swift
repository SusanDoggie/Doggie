//
//  CFFEncoding.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

private let CFFStandardEncoding: [UInt16] = [
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    1,   2,   3,   4,   5,   6,   7,   8,
    9,  10,  11,  12,  13,  14,  15,  16,
    17,  18,  19,  20,  21,  22,  23,  24,
    25,  26,  27,  28,  29,  30,  31,  32,
    33,  34,  35,  36,  37,  38,  39,  40,
    41,  42,  43,  44,  45,  46,  47,  48,
    49,  50,  51,  52,  53,  54,  55,  56,
    57,  58,  59,  60,  61,  62,  63,  64,
    65,  66,  67,  68,  69,  70,  71,  72,
    73,  74,  75,  76,  77,  78,  79,  80,
    81,  82,  83,  84,  85,  86,  87,  88,
    89,  90,  91,  92,  93,  94,  95,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,  96,  97,  98,  99, 100, 101, 102,
    103, 104, 105, 106, 107, 108, 109, 110,
    0, 111, 112, 113, 114,   0, 115, 116,
    117, 118, 119, 120, 121, 122,   0, 123,
    0, 124, 125, 126, 127, 128, 129, 130,
    131,   0, 132, 133,   0, 134, 135, 136,
    137,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0, 138,   0, 139,   0,   0,   0,   0,
    140, 141, 142, 143,   0,   0,   0,   0,
    0, 144,   0,   0,   0, 145,   0,   0,
    146, 147, 148, 149,   0,   0,   0,   0
]

private let CFFExpertEncoding: [UInt16] = [
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    1, 229, 230,   0, 231, 232, 233, 234,
    235, 236, 237, 238,  13,  14,  15,  99,
    239, 240, 241, 242, 243, 244, 245, 246,
    247, 248,  27,  28, 249, 250, 251, 252,
    0, 253, 254, 255, 256, 257,   0,   0,
    0, 258,   0,   0, 259, 260, 261, 262,
    0,   0, 263, 264, 265,   0, 266, 109,
    110, 267, 268, 269,   0, 270, 271, 272,
    273, 274, 275, 276, 277, 278, 279, 280,
    281, 282, 283, 284, 285, 286, 287, 288,
    289, 290, 291, 292, 293, 294, 295, 296,
    297, 298, 299, 300, 301, 302, 303,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0, 304, 305, 306,   0,   0, 307, 308,
    309, 310, 311,   0, 312,   0,   0, 312,
    0,   0, 314, 315,   0,   0, 316, 317,
    318,   0,   0,   0, 158, 155, 163, 319,
    320, 321, 322, 323, 324, 325,   0,   0,
    326, 150, 164, 169, 327, 328, 329, 330,
    331, 332, 333, 334, 335, 336, 337, 338,
    339, 340, 341, 342, 343, 344, 345, 346,
    347, 348, 349, 350, 351, 352, 353, 354,
    355, 356, 357, 358, 359, 360, 361, 362,
    363, 364, 365, 366, 367, 368, 369, 370,
    371, 372, 373, 374, 375, 376, 377, 378
]

struct CFFEncoding: ByteDecodable {

    var format: UInt8

    var nCodes: UInt8
    var code: Data

    var nRanges: UInt8
    var range: Data

    var nSups: UInt8
    var supplement: Data

    init(from data: inout Data) throws {

        self.format = try data.decode(UInt8.self)

        self.nCodes = 0
        self.code = Data()
        self.nRanges = 0
        self.range = Data()
        self.nSups = 0
        self.supplement = Data()

        switch format & 0x7F {
        case 0:

            self.nCodes = try data.decode(UInt8.self)
            self.code = data.popFirst(Int(nCodes))
            guard self.code.count == Int(nCodes) else { throw ByteDecodeError.endOfData }

        case 1:

            self.nRanges = try data.decode(UInt8.self)
            self.range = data.popFirst(Int(nRanges) << 1)
            guard self.range.count == Int(nRanges) << 1 else { throw ByteDecodeError.endOfData }

        default: throw FontCollection.Error.InvalidFormat("Invalid CFF Encoding format.")
        }

        if format & 0x80 != 0 {
            self.nSups = try data.decode(UInt8.self)
            self.supplement = data.popFirst(Int(nSups) * 3)
            guard self.supplement.count == Int(nSups) * 3 else { throw ByteDecodeError.endOfData }
        }
    }

    struct Range1 {

        var first: UInt8
        var nLeft: UInt8
    }
}
