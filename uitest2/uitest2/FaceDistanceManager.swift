import ARKit
import AVFoundation

class FaceDistanceManager: NSObject, ObservableObject, ARSessionDelegate {
    @Published var distance: Float = 0.0
    @Published var isInIdealRange: Bool = false
    
    private let minIdealDistance: Float = 0.55 // 55 cm
    private let maxIdealDistance: Float = 0.60 // 60 cm
    private let smoothingFactor: Float = 0.1  // Smooth out sudden changes
    
    private var arSession: ARSession?
    private var lastDistance: Float = 1.0
    private var audioPlayer: AVAudioPlayer?
    private var lastAudioPlayTime: Date?
    
    override init() {
        super.init()
        setupAudioPlayer()
        setupARSession()
    }
    
    /// Setup ARKit session for face tracking
    private func setupARSession() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return
        }
        
        arSession = ARSession()
        arSession?.delegate = self
        
        let configuration = ARFaceTrackingConfiguration()
        arSession?.run(configuration, options: [])
    }
    
    /// Called when ARKit updates face tracking data
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
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
        
        if !isInIdealRange {
            playWarningAudio()
        }
    }
    
    /// Setup warning audio
    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "too_close", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
        }
    }
    
    /// Play warning sound when the user is too close or too far
    private func playWarningAudio() {
        let currentTime = Date()
        
        if let lastPlayTime = lastAudioPlayTime,
           currentTime.timeIntervalSince(lastPlayTime) < 3 {
            return
        }
        
        audioPlayer?.play()
        lastAudioPlayTime = currentTime
    }
}
