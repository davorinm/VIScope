import UIKit
import SceneKit
import QuartzCore
import XCPlayground

class MyScene : SCNScene  {
    
    let camera:SCNNode
    let model:SCNNode
    var spin:CGFloat
    
    override init() {
        
        camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(x: 0, y: 0, z: 10)
        
        
        model = SCNNode(geometry: SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0.5))
        
        spin = 0
        
        super.init()
        
        rootNode.addChildNode(camera)
        rootNode.addChildNode(model)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

var sceneView = SCNView(frame: CGRectMake(0, 0, 450, 800))
var scene = MyScene()
sceneView.scene = scene

let ambientLightNode = SCNNode()
ambientLightNode.light = SCNLight()
ambientLightNode.light?.type = SCNLightTypeAmbient
ambientLightNode.light?.color = UIColor(white: 0.67, alpha: 1.0)
scene.rootNode.addChildNode(ambientLightNode)

scene.background.contents = [#Image(imageLiteral: "IMG_4124.jpg")#]
scene.background.contentsTransform = SCNMatrix4MakeScale(450/800, 1, 1)
sceneView.pointOfView = scene.camera

XCPlaygroundPage.currentPage.liveView = sceneView
