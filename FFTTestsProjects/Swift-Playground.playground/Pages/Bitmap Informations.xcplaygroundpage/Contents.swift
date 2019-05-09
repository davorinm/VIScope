import AppKit

let gray = [#Image(imageLiteral: "gray.png")#]

let bitmapImageRep = gray.representations[0] as! NSBitmapImageRep

// Basic information
bitmapImageRep.bitsPerSample
bitmapImageRep.planar
bitmapImageRep.samplesPerPixel
bitmapImageRep.bitsPerPixel
bitmapImageRep.bytesPerRow
bitmapImageRep.bytesPerPlane
bitmapImageRep.numberOfPlanes
bitmapImageRep.bitmapFormat
bitmapImageRep.size
bitmapImageRep.pixelsHigh
bitmapImageRep.pixelsWide

// Color aciton

bitmapImageRep.colorAtX(0, y: 0)
bitmapImageRep.colorizeByMappingGray(0.3, toColor: NSColor.whiteColor(), blackMapping: NSColor.blackColor(), whiteMapping: NSColor.whiteColor())

// Pixel action
var p = [Int](count: bitmapImageRep.samplesPerPixel, repeatedValue: 0)
bitmapImageRep.getPixel(&p, atX: 0, y: 0)
print(p)

p[0] = 255
bitmapImageRep.setPixel(&p, atX: bitmapImageRep.pixelsWide/2 , y: bitmapImageRep.pixelsHigh/2)

for x in 0 ..< bitmapImageRep.pixelsHigh {
    for y in 0 ..< bitmapImageRep.pixelsWide {
        p[0] = x * 15
        p[1] = y * 15
        p[2] = (x+y)/2*15
        p[3] = 255
        bitmapImageRep.setPixel(&p, atX: x, y: y)
    }
}

bitmapImageRep


// without Alpha
bitmapImageRep.alpha = false
var q = [Int](count: bitmapImageRep.samplesPerPixel, repeatedValue: 0)
bitmapImageRep.getPixel(&q, atX: 0, y: 0)
print(q)
