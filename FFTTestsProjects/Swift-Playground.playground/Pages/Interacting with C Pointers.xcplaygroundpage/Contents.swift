//: https://developer.apple.com/swift/blog/?id=6

//: A traditional way for multiple return values. Pointers as In/Out Parameters

import AppKit

var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

let color = NSColor.cyan
color.getRed(&r, green: &g, blue: &b, alpha: &a)

print(r, g, b, a)

import Accelerate

let c: [Float] = [1,2,3,4]
let d: [Float] = [0.5, 0.25, 0.125, 0.0625]
var result: [Float] = [0,0,0,0]

vDSP_vadd(c, 1, d, 1, &result, 1, 4)

print(result)
