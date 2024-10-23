import SwiftUI
import ARKit

struct FaceDistanceView: UIViewControllerRepresentable {
    @Binding var distance: Float
    @ObservedObject var faceDistanceManager: FaceDistanceManager
    
    func makeUIViewController(context: Context) -> FaceDistanceViewController {
        let controller = FaceDistanceViewController()
        controller.distanceUpdated = { newDistance in
            self.distance = newDistance
        }
        controller.faceDistanceManager = faceDistanceManager
        return controller
    }
    
    func updateUIViewController(_ uiViewController: FaceDistanceViewController, context: Context) {}
}

class FaceDistanceViewController: UIViewController, ARSessionDelegate {
    var sceneView: ARSCNView!
    var arSession: ARSession!
    var lastDistance: Float = 1.0
    let smoothingFactor: Float = 0.1
    var distanceUpdated: ((Float) -> Void)?
    var faceDistanceManager: FaceDistanceManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.isHidden = true  // Hide the camera image by default
        self.view.addSubview(sceneView)
        
        arSession = ARSession()
        sceneView.session = arSession
        arSession.delegate = self
        
        let configuration = ARFaceTrackingConfiguration()
        arSession.run(configuration, options: [])
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let faceAnchor = frame.anchors.compactMap({ $0 as? ARFaceAnchor }).first {
            let facePosition = faceAnchor.transform.columns.3
            let distance = sqrt(facePosition.x * facePosition.x +
                                facePosition.y * facePosition.y +
                                facePosition.z * facePosition.z)
            
            let smoothedDistance = lastDistance + (distance - lastDistance) * smoothingFactor
            lastDistance = smoothedDistance
            
            DispatchQueue.main.async {
                self.distanceUpdated?(smoothedDistance)
                self.updateFaceGeometry(faceAnchor: faceAnchor)
            }
        }
    }
    
    func updateFaceGeometry(faceAnchor: ARFaceAnchor) {
        let faceNode = SCNNode(geometry: ARSCNFaceGeometry(device: sceneView.device!)!)
        faceNode.geometry?.firstMaterial?.fillMode = .lines
        faceNode.simdTransform = faceAnchor.transform
        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        sceneView.scene.rootNode.addChildNode(faceNode)
        
        sceneView.isHidden = faceDistanceManager?.isCameraHidden ?? true
    }
}
