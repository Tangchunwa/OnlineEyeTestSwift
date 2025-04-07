import SwiftUI
import Speech
import AVFoundation

class PermissionManager: ObservableObject {
    @Published var isSpeechAuthorized = false
    @Published var isCameraAuthorized = false
    
    var allPermissionsGranted: Bool {
        isSpeechAuthorized && isCameraAuthorized
    }
    
    init() {
        checkSpeechPermission()
        checkCameraPermission()
    }
    
    func checkSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isSpeechAuthorized = status == .authorized
            }
        }
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isCameraAuthorized = granted
                }
            }
        default:
            isCameraAuthorized = false
        }
    }
}

struct PermissionRequestView: View {
    @ObservedObject var permissionManager: PermissionManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("permission_required".localized)
                .font(.title)
                .fontWeight(.bold)
            
            Text("app_needs_access".localized)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: permissionManager.isSpeechAuthorized ? "checkmark.circle.fill" : "mic.circle.fill")
                        .foregroundColor(permissionManager.isSpeechAuthorized ? .green : .blue)
                    Text("speech_recognition".localized)
                }
                
                HStack {
                    Image(systemName: permissionManager.isCameraAuthorized ? "checkmark.circle.fill" : "camera.circle.fill")
                        .foregroundColor(permissionManager.isCameraAuthorized ? .green : .blue)
                    Text("camera".localized)
                }
            }
            .font(.body)
            
            if !permissionManager.allPermissionsGranted {
                Button(action: {
                    permissionManager.checkSpeechPermission()
                    permissionManager.checkCameraPermission()
                }) {
                    Text("grant_permissions".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            
            Text("permission_explanation".localized)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(Color.white)
    }
} 