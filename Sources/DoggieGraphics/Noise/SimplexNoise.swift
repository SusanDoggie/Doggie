//
//  SimplexNoise.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

/* Copyright (c) 2007-2012 Eliot Eshelman
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */


public func SimplexNoise(_ octaves: Int, _ persistence: Double, _ scale: Double, _ x: Double, _ y: Double) -> Double {
    
    var total = 0.0
    var frequency = scale
    var amplitude = 1.0
    
    var maxAmplitude = 0.0
    
    for _ in 0..<octaves {
        total += raw_noise(x * frequency, y * frequency) * amplitude
        frequency *= 2
        maxAmplitude += amplitude
        amplitude *= persistence
    }
    
    return 0.5 * total / maxAmplitude + 0.5
}

public func SimplexNoise(_ octaves: Int, _ persistence: Double, _ scale: Double, _ x: Double, _ y: Double, _ z: Double) -> Double {
    
    var total = 0.0
    var frequency = scale
    var amplitude = 1.0
    
    var maxAmplitude = 0.0
    
    for _ in 0..<octaves {
        total += raw_noise(x * frequency, y * frequency, z * frequency) * amplitude
        frequency *= 2
        maxAmplitude += amplitude
        amplitude *= persistence
    }
    
    return 0.5 * total / maxAmplitude + 0.5
}

public func SimplexNoise(_ octaves: Int, _ persistence: Double, _ scale: Double, _ x: Double, _ y: Double, _ z: Double, _ w: Double) -> Double {
    
    var total = 0.0
    var frequency = scale
    var amplitude = 1.0
    
    var maxAmplitude = 0.0
    
    for _ in 0..<octaves {
        total += raw_noise(x * frequency, y * frequency, z * frequency, w * frequency) * amplitude
        frequency *= 2
        maxAmplitude += amplitude
        amplitude *= persistence
    }
    
    return 0.5 * total / maxAmplitude + 0.5
}

private let perm: [Int] = [
    151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,
    8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,
    35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,
    134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,
    55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208, 89,
    18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,
    250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,
    189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,
    172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,
    228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,
    107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,
    
    151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,
    8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,
    35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,
    134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,
    55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208, 89,
    18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,
    250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,
    189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,
    172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,
    228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,
    107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
]

private let grad3: [[Int]] = [
    [1,1,0], [-1,1,0], [1,-1,0], [-1,-1,0],
    [1,0,1], [-1,0,1], [1,0,-1], [-1,0,-1],
    [0,1,1], [0,-1,1], [0,1,-1], [0,-1,-1]
]
private let grad4: [[Int]] = [
    [0,1,1,1],  [0,1,1,-1],  [0,1,-1,1],  [0,1,-1,-1],
    [0,-1,1,1], [0,-1,1,-1], [0,-1,-1,1], [0,-1,-1,-1],
    [1,0,1,1],  [1,0,1,-1],  [1,0,-1,1],  [1,0,-1,-1],
    [-1,0,1,1], [-1,0,1,-1], [-1,0,-1,1], [-1,0,-1,-1],
    [1,1,0,1],  [1,1,0,-1],  [1,-1,0,1],  [1,-1,0,-1],
    [-1,1,0,1], [-1,1,0,-1], [-1,-1,0,1], [-1,-1,0,-1],
    [1,1,1,0],  [1,1,-1,0],  [1,-1,1,0],  [1,-1,-1,0],
    [-1,1,1,0], [-1,1,-1,0], [-1,-1,1,0], [-1,-1,-1,0]
]

private let simplex: [[Int]] = [
    [0,1,2,3],[0,1,3,2],[0,0,0,0],[0,2,3,1],[0,0,0,0],[0,0,0,0],[0,0,0,0],[1,2,3,0],
    [0,2,1,3],[0,0,0,0],[0,3,1,2],[0,3,2,1],[0,0,0,0],[0,0,0,0],[0,0,0,0],[1,3,2,0],
    [0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],
    [1,2,0,3],[0,0,0,0],[1,3,0,2],[0,0,0,0],[0,0,0,0],[0,0,0,0],[2,3,0,1],[2,3,1,0],
    [1,0,2,3],[1,0,3,2],[0,0,0,0],[0,0,0,0],[0,0,0,0],[2,0,3,1],[0,0,0,0],[2,1,3,0],
    [0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],
    [2,0,1,3],[0,0,0,0],[0,0,0,0],[0,0,0,0],[3,0,1,2],[3,0,2,1],[0,0,0,0],[3,1,2,0],
    [2,1,0,3],[0,0,0,0],[0,0,0,0],[0,0,0,0],[3,1,0,2],[0,0,0,0],[3,2,0,1],[3,2,1,0]
]

private func fastfloor(_ x: Double) -> Int {
    return x > 0 ? Int(x) : Int(x - 1)
}

private func dot(_ g: [Int], _ x: Double) -> Double {
    return Double(g[0]) * x
}
private func dot(_ g: [Int], _ x: Double, _ y: Double) -> Double {
    return Double(g[0]) * x + Double(g[1]) * y
}
private func dot(_ g: [Int], _ x: Double, _ y: Double, _ z: Double) -> Double {
    return Double(g[0]) * x + Double(g[1]) * y + Double(g[2]) * z
}
private func dot(_ g: [Int], _ x: Double, _ y: Double, _ z: Double, _ w: Double) -> Double {
    return Double(g[0]) * x + Double(g[1]) * y + Double(g[2]) * z + Double(g[3]) * w
}

private func raw_noise(_ x: Double, _ y: Double) -> Double {
    
    let n0, n1, n2: Double
    
    let F2 = 0.5 * (sqrt(3.0) - 1.0)
    
    let s = (x + y) * F2
    let i = fastfloor(x + s)
    let j = fastfloor(y + s)
    
    let G2 = (3.0 - sqrt(3.0)) / 6.0
    let t = Double(i + j) * G2
    
    let X0 = Double(i) - t
    let Y0 = Double(j) - t
    
    let x0 = x - X0
    let y0 = y - Y0
    
    let i1, j1: Int
    if x0>y0 {
        i1 = 1
        j1 = 0
    } else {
        i1 = 0
        j1 = 1
    }
    
    let x1 = x0 - Double(i1) + G2
    let y1 = y0 - Double(j1) + G2
    let x2 = x0 - 1.0 + 2.0 * G2
    let y2 = y0 - 1.0 + 2.0 * G2
    
    let ii = i & 255
    let jj = j & 255
    let gi0 = perm[ii + perm[jj]] % 12
    let gi1 = perm[ii + i1 + perm[jj + j1]] % 12
    let gi2 = perm[ii + 1 + perm[jj + 1]] % 12
    
    var t0 = 0.5 - x0 * x0 - y0 * y0
    if t0 < 0 {
        n0 = 0.0
    } else {
        t0 *= t0
        n0 = t0 * t0 * dot(grad3[gi0], x0, y0)
    }
    
    var t1 = 0.5 - x1 * x1 - y1 * y1
    if t1 < 0 {
        n1 = 0.0
    } else {
        t1 *= t1
        n1 = t1 * t1 * dot(grad3[gi1], x1, y1)
    }
    
    var t2 = 0.5 - x2 * x2 - y2 * y2
    if t2 < 0 {
        n2 = 0.0
    } else {
        t2 *= t2
        n2 = t2 * t2 * dot(grad3[gi2], x2, y2)
    }
    
    return 70.0 * (n0 + n1 + n2)
}

private func raw_noise(_ x: Double, _ y: Double, _ z: Double) -> Double {
    
    let n0, n1, n2, n3: Double
    
    let F3 = 1.0 / 3.0
    let s = (x + y + z) * F3
    let i = fastfloor(x + s)
    let j = fastfloor(y + s)
    let k = fastfloor(z + s)
    
    let G3 = 1.0 / 6.0
    let t = Double(i + j + k) * G3
    let X0 = Double(i) - t
    let Y0 = Double(j) - t
    let Z0 = Double(k) - t
    let x0 = x - X0
    let y0 = y - Y0
    let z0 = z - Z0
    
    let i1, j1, k1: Int
    let i2, j2, k2: Int
    
    if x0 >= y0 {
        if y0 >= z0 {
            (i1, j1, k1) = (1, 0, 0)
            (i2, j2, k2) = (1, 1, 0)
        } else if x0 >= z0 {
            (i1, j1, k1) = (1, 0, 0)
            (i2, j2, k2) = (1, 0, 1)
        } else {
            (i1, j1, k1) = (0, 0, 1)
            (i2, j2, k2) = (1, 0, 1)
        }
    } else {
        if y0 < z0 {
            (i1, j1, k1) = (0, 0, 1)
            (i2, j2, k2) = (0, 1, 1)
        } else if x0 < z0 {
            (i1, j1, k1) = (0, 1, 0)
            (i2, j2, k2) = (0, 1, 1)
        } else {
            (i1, j1, k1) = (0, 1, 0)
            (i2, j2, k2) = (1, 1, 0)
        }
    }
    
    let x1 = x0 - Double(i1) + G3
    let y1 = y0 - Double(j1) + G3
    let z1 = z0 - Double(k1) + G3
    let x2 = x0 - Double(i2) + 2.0 * G3
    let y2 = y0 - Double(j2) + 2.0 * G3
    let z2 = z0 - Double(k2) + 2.0 * G3
    let x3 = x0 - 1.0 + 3.0 * G3
    let y3 = y0 - 1.0 + 3.0 * G3
    let z3 = z0 - 1.0 + 3.0 * G3
    
    let ii = i & 255
    let jj = j & 255
    let kk = k & 255
    let gi0 = perm[ii + perm[jj + perm[kk]]] % 12
    let gi1 = perm[ii + i1 + perm[jj + j1 + perm[kk + k1]]] % 12
    let gi2 = perm[ii + i2 + perm[jj + j2 + perm[kk + k2]]] % 12
    let gi3 = perm[ii + 1 + perm[jj + 1 + perm[kk + 1]]] % 12
    
    var t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0
    if t0 < 0 {
        n0 = 0.0
    } else {
        t0 *= t0
        n0 = t0 * t0 * dot(grad3[gi0], x0, y0, z0)
    }
    
    var t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1
    if t1 < 0 {
        n1 = 0.0
    } else {
        t1 *= t1
        n1 = t1 * t1 * dot(grad3[gi1], x1, y1, z1)
    }
    
    var t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2
    if t2 < 0 {
        n2 = 0.0
    } else {
        t2 *= t2
        n2 = t2 * t2 * dot(grad3[gi2], x2, y2, z2)
    }
    
    var t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3
    if t3 < 0 {
        n3 = 0.0
    } else {
        t3 *= t3
        n3 = t3 * t3 * dot(grad3[gi3], x3, y3, z3)
    }
    
    return 32.0 * (n0 + n1 + n2 + n3)
}

private func raw_noise(_ x: Double, _ y: Double, _ z: Double, _ w: Double) -> Double {
    
    let F4 = (sqrt(5.0) - 1.0) / 4.0
    let G4 = (5.0 - sqrt(5.0)) / 20.0
    
    let n0, n1, n2, n3, n4: Double
    
    let s = (x + y + z + w) * F4
    let i = fastfloor(x + s)
    let j = fastfloor(y + s)
    let k = fastfloor(z + s)
    let l = fastfloor(w + s)
    let t = Double(i + j + k + l) * G4
    let X0 = Double(i) - t
    let Y0 = Double(j) - t
    let Z0 = Double(k) - t
    let W0 = Double(l) - t
    
    let x0 = x - X0
    let y0 = y - Y0
    let z0 = z - Z0
    let w0 = w - W0
    
    let c1 = x0 > y0 ? 32 : 0
    let c2 = x0 > z0 ? 16 : 0
    let c3 = y0 > z0 ? 8 : 0
    let c4 = x0 > w0 ? 4 : 0
    let c5 = y0 > w0 ? 2 : 0
    let c6 = z0 > w0 ? 1 : 0
    let c = c1 + c2 + c3 + c4 + c5 + c6
    
    let i1, j1, k1, l1: Int
    let i2, j2, k2, l2: Int
    let i3, j3, k3, l3: Int
    
    i1 = simplex[c][0] >= 3 ? 1 : 0
    j1 = simplex[c][1] >= 3 ? 1 : 0
    k1 = simplex[c][2] >= 3 ? 1 : 0
    l1 = simplex[c][3] >= 3 ? 1 : 0
    
    i2 = simplex[c][0] >= 2 ? 1 : 0
    j2 = simplex[c][1] >= 2 ? 1 : 0
    k2 = simplex[c][2] >= 2 ? 1 : 0
    l2 = simplex[c][3] >= 2 ? 1 : 0
    
    i3 = simplex[c][0] >= 1 ? 1 : 0
    j3 = simplex[c][1] >= 1 ? 1 : 0
    k3 = simplex[c][2] >= 1 ? 1 : 0
    l3 = simplex[c][3] >= 1 ? 1 : 0
    
    let x1 = x0 - Double(i1) + G4
    let y1 = y0 - Double(j1) + G4
    let z1 = z0 - Double(k1) + G4
    let w1 = w0 - Double(l1) + G4
    let x2 = x0 - Double(i2) + 2.0 * G4
    let y2 = y0 - Double(j2) + 2.0 * G4
    let z2 = z0 - Double(k2) + 2.0 * G4
    let w2 = w0 - Double(l2) + 2.0 * G4
    let x3 = x0 - Double(i3) + 3.0 * G4
    let y3 = y0 - Double(j3) + 3.0 * G4
    let z3 = z0 - Double(k3) + 3.0 * G4
    let w3 = w0 - Double(l3) + 3.0 * G4
    let x4 = x0 - 1.0 + 4.0 * G4
    let y4 = y0 - 1.0 + 4.0 * G4
    let z4 = z0 - 1.0 + 4.0 * G4
    let w4 = w0 - 1.0 + 4.0 * G4
    
    let ii = i & 255
    let jj = j & 255
    let kk = k & 255
    let ll = l & 255
    let gi0 = perm[ii + perm[jj + perm[kk + perm[ll]]]] % 32
    let gi1 = perm[ii + i1 + perm[jj + j1 + perm[kk + k1 + perm[ll + l1]]]] % 32
    let gi2 = perm[ii + i2 + perm[jj + j2 + perm[kk + k2 + perm[ll + l2]]]] % 32
    let gi3 = perm[ii + i3 + perm[jj + j3 + perm[kk + k3 + perm[ll + l3]]]] % 32
    let gi4 = perm[ii + 1 + perm[jj + 1 + perm[kk + 1 + perm[ll + 1]]]] % 32
    
    var t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0 - w0 * w0
    if t0 < 0 {
        n0 = 0.0
    } else {
        t0 *= t0
        n0 = t0 * t0 * dot(grad4[gi0], x0, y0, z0, w0)
    }
    
    var t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1 - w1 * w1
    if t1 < 0 {
        n1 = 0.0
    } else {
        t1 *= t1
        n1 = t1 * t1 * dot(grad4[gi1], x1, y1, z1, w1)
    }
    
    var t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2 - w2 * w2
    if t2 < 0 {
        n2 = 0.0
    } else {
        t2 *= t2
        n2 = t2 * t2 * dot(grad4[gi2], x2, y2, z2, w2)
    }
    
    var t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3 - w3 * w3
    if t3 < 0 {
        n3 = 0.0
    } else {
        t3 *= t3
        n3 = t3 * t3 * dot(grad4[gi3], x3, y3, z3, w3)
    }
    
    var t4 = 0.6 - x4 * x4 - y4 * y4 - z4 * z4 - w4 * w4
    if t4 < 0 {
        n4 = 0.0
    } else {
        t4 *= t4
        n4 = t4 * t4 * dot(grad4[gi4], x4, y4, z4, w4)
    }
    
    return 27.0 * (n0 + n1 + n2 + n3 + n4)
}
