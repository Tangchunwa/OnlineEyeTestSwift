import ARKit
import AVFoundation

class FaceDistanceManager: NSObject, ObservableObject, ARSessionDelegate {
    @Published var distance: Float = 0.0
    @Published var isInIdealRange: Bool = false
    @Published var isTracking: Bool = false
    
    private let minIdealDistance: Float = 0.55 // 55 cm
    private let maxIdealDistance: Float = 0.60 // 60 cm
    private let smoothingFactor: Float = 0.1  // Smooth out sudden changes
    
    private var arSession: ARSession?
    private var lastDistance: Float = 1.0
    private var audioPlayer: AVAudioPlayer?
    private var lastAudioPlayTime: Date?
    
    override init() {
        super.init()
        // Don't automatically start AR session on init
        arSession = ARSession()
        arSession?.delegate = self
    }
    
    // Function to start camera detection
    func startCameraDetection() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return
        }
        
        let timestamp = getCurrentTimestamp()
        print("Camera detection started at: \(timestamp)")
        
        let configuration = ARFaceTrackingConfiguration()
        arSession?.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        isTracking = true
    }
    
    // Function to stop camera detection
    func stopCameraDetection() {
        let timestamp = getCurrentTimestamp()
        print("Camera detection stopped at: \(timestamp)")
        
        arSession?.pause()
        isTracking = false
        
        // Reset values
        distance = 0.0
        isInIdealRange = false
        lastDistance = 1.0
    }
    
    /// Setup ARKit session for face tracking
    private func setupARSession() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        arSession?.run(configuration, options: [])
    }
    
    /// Called when ARKit updates face tracking data
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard isTracking else { return } // Only process updates if tracking is active
        
        if let faceAnchor = frame.anchors.compactMap({ $0 as? ARFaceAnchor }).first {
            let facePosition = faceAnchor.transform.columns.3
            let newDistance = sqrt(facePosition.x * facePosition.x +
                                   facePosition.y * facePosition.y +
                                   facePosition.z * facePosition.z)
            
            let smoothedDistance = lastDistance + (newDistance - lastDistance) * smoothingFactor
            lastDistance = smoothedDistance
            
            DispatchQueue.main.async {
                self.updateDistance(smoothedDistance)
            }
        }
    }
    
    /// Update the distance and check if it's in the ideal range
    func updateDistance(_ newDistance: Float) {
        distance = newDistance
        isInIdealRange = (newDistance >= minIdealDistance && newDistance <= maxIdealDistance)
    }
    
    // Helper function to get current timestamp
    private func getCurrentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: Date())
    }
    
    // Handle session errors
    func session(_ session: ARSession, didFailWithError error: Error) {
        let timestamp = getCurrentTimestamp()
        print("AR Session failed at \(timestamp) with error: \(error.localizedDescription)")
    }
    
    // Handle session interruption
    func sessionWasInterrupted(_ session: ARSession) {
        let timestamp = getCurrentTimestamp()
        print("AR Session was interrupted at: \(timestamp)")
    }
    
    // Handle session interruption ended
    func sessionInterruptionEnded(_ session: ARSession) {
        let timestamp = getCurrentTimestamp()
        print("AR Session interruption ended at: \(timestamp)")
        if isTracking {
            setupARSession() // Restart tracking if it was active
        }
    }
}
