//: This is a demo drawing out history using weight and rep based on Joule to view training progress quickly.

import SpriteKit
import XCPlayground

struct Record {
    var date: NSDate
    var rep: Int
    var kg: Double
    var lb: Double
}


let history = [#FileReference(fileReferenceLiteral: "reps-2015-12.csv")#]

guard let text = try? String(contentsOfURL: history) else { exit(-1) }

let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "dd/MM/yyyy"

let lines = text.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n"))

var benchPress = Array<Record>()
for var line in lines {
    let rows = line.componentsSeparatedByString(",")
    if ( rows.count>3 && rows[3] == "Bench Press") {
        let d = dateFormatter.dateFromString(rows[0])!

        let r = Record(date: d, rep: Int(rows[6])!, kg: Double(rows[9])!, lb: Double(rows[10])!)
        benchPress.append(r)
    }
}

let view = SKView(frame: NSRect(x: 0, y: 0, width: 1024, height: 768))

XCPlaygroundPage.currentPage.liveView = view

var scene = SKScene(size: CGSize(width: 1024, height: 768))
view.presentScene(scene)

var currentDate = NSDate(); 

var x:Int = 0
let offset = 10
for b in benchPress {
    var bar = SKSpriteNode(color: NSColor.whiteColor(), size: CGSize(width: Double(b.rep), height: b.lb))
    
    if currentDate != b.date {
        x = x + offset
        currentDate = b.date
    }
    bar.anchorPoint = CGPoint(x: 0, y: 0)
    bar.position = CGPoint(x: x, y: 100)
    x = x+2+b.rep
    scene.addChild(bar)
    
}
