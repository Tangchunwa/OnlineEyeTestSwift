import SwiftUI
import Speech
import AVFoundation

class VisionTestManager: ObservableObject {
    // Published properties
    @Published var currentLevel = 0
    let Level_limit = 5
    
    @Published var currentLetters = ""
    @Published var userInput = ""
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var timeRemaining = 10
    @Published var statusMessage = "Ready to start"
    @Published var recordingAnimationOpacity = [1.0, 1.0, 1.0]
    @Published var timeoutCount = 0
    @Published var testCompleted = false
    
    // Added properties for handling both eyes
    @Published var currentEye: Eye = .right
    @Published var rightEyeLogMAR = 0.4
    @Published var leftEyeLogMAR = 0.4
    @Published var bothEyesCompleted = false
    
    enum Eye {
        case left
        case right
        
        var description: String {
            switch self {
            case .left: return "Left"
            case .right: return "Right"
            }
        }
    }
    
    // Private properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-HK"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var timer: Timer?
    
    // LogMAR test available letters
    private let availableLetters = [
        "A", "B", "C", "D", "E", "F", "G", "H",
        "K", "N", "P", "R", "S", "T", "U", "V", "Z"
    ]
    
    // Store test letter sequences for both eyes
    private var rightEyeLevelLetters: [[String]] = []
    private var leftEyeLevelLetters: [[String]] = []
    
    // Store results for both eyes
    private var rightEyeResults: [Int: Bool] = [:]
    private var leftEyeResults: [Int: Bool] = [:]
    
    // Initialization
    init() {
        generateAllLevelsForBothEyes()
    }
    
    // Generate different letter sequences for both eyes
    private func generateAllLevelsForBothEyes() {
        rightEyeLevelLetters = [
            generateLettersForLevel(count: 3), // Level 1
            generateLettersForLevel(count: 3), // Level 2
            generateLettersForLevel(count: 4), // Level 3
            generateLettersForLevel(count: 4), // Level 4
            generateLettersForLevel(count: 5)  // Level 5
        ]
        
        leftEyeLevelLetters = [
            generateLettersForLevel(count: 3), // Level 1
            generateLettersForLevel(count: 3), // Level 2
            generateLettersForLevel(count: 4), // Level 3
            generateLettersForLevel(count: 4), // Level 4
            generateLettersForLevel(count: 5)  // Level 5
        ]
        
        // Set initial letters for right eye
        updateCurrentLetters()
    }
    
    // Update current letters based on current eye and level
    public func updateCurrentLetters() {
        let currentLevelLetters = getCurrentLevelLetters()
        if currentLevel < currentLevelLetters.count {
            currentLetters = currentLevelLetters[currentLevel].joined(separator: " ")
        }
    }
    // Get current level letters based on which eye is being tested
    private func getCurrentLevelLetters() -> [[String]] {
        return currentEye == .right ? rightEyeLevelLetters : leftEyeLevelLetters
    }
    
    // Generate random letters for a single level
    private func generateLettersForLevel(count: Int) -> [String] {
        let letters = availableLetters.shuffled()
        return Array(letters.prefix(count))
    }
    
    // Get current level font size
    func getCurrentFontSize() -> CGFloat {
        let baseFontSize: CGFloat = 100
        let scaleFactor: CGFloat = 0.7
        return baseFontSize * pow(scaleFactor, CGFloat(currentLevel))
    }
    
   
    // Regenerate current level letters
    private func regenerateCurrentLevel() {
        let count = getCurrentLevelLetters()[currentLevel].count
        let newLetters = generateLettersForLevel(count: count)
        
        if currentEye == .right {
            rightEyeLevelLetters[currentLevel] = newLetters
        } else {
            leftEyeLevelLetters[currentLevel] = newLetters
        }
        
        updateCurrentLetters()
    }
    
    // Switch to testing the other eye
        private func switchEye() {
            if currentEye == .right {
                currentEye = .left
                currentLevel = 0
                timeoutCount = 0
                statusMessage = "Switching to Left Eye"
                leftEyeLogMAR = 0.4
                updateCurrentLetters() // Generate new letters for left eye
            } else {
                bothEyesCompleted = true
                testCompleted = true
                statusMessage = "Both eyes tested!"
            }
        }
        
    
    // Check permissions
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.statusMessage = "Speech recognition authorized"
                case .denied:
                    self?.statusMessage = "Speech recognition permission denied"
                case .restricted:
                    self?.statusMessage = "Speech recognition restricted on this device"
                case .notDetermined:
                    self?.statusMessage = "Speech recognition permission not determined"
                @unknown default:
                    self?.statusMessage = "Unknown authorization status"
                }
            }
        }
    }
    
    // Recording functions (keep the same as in original code)
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    let recognizedText = result.bestTranscription.formattedString.uppercased()
                    DispatchQueue.main.async {
                        self.recognizedText = recognizedText
                        self.processRecognizedText(recognizedText)
                    }
                }
            }
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecording = true
            updateCurrentLetters()
            startTimer()
            startRecordingAnimation()
            
        } catch {
            statusMessage = "Recording setup failed: \(error.localizedDescription)"
        }
    }
    
    // Process recognized text
    private func processRecognizedText(_ text: String) {
        if text.contains("RETRY") {
            statusMessage = "Detected 'RETRY', restarting"
            regenerateCurrentLevel()
            restartCurrentLevel()
            return
        }
        
        let currentLevelLetters = getCurrentLevelLetters()
        if currentLevel >= currentLevelLetters.count { return }
        
        let success = currentLevelLetters[currentLevel].allSatisfy { text.contains($0) }
        
        if success {
            if currentEye == .right {
                rightEyeResults[currentLevel] = true
            } else {
                leftEyeResults[currentLevel] = true
            }
            moveToNextLevel()
        }
    }
    func processInputText() {
           let userInputLetters = userInput.uppercased().filter { !$0.isWhitespace }
           let correctSequence = getCurrentLevelLetters()[currentLevel].joined()
           let success = userInputLetters == correctSequence
           
           if success {
               if currentEye == .right {
                   rightEyeResults[currentLevel] = true
               } else {
                   leftEyeResults[currentLevel] = true
               }
               moveToNextLevel()
           } else {
               if currentEye == .right {
                   rightEyeResults[currentLevel] = false
                   switchEye()
               } else {
                   leftEyeResults[currentLevel] = false
                   testCompleted = true
               }
           }
       }
        
    
    func restartTest() {
          stopRecording()
          generateAllLevelsForBothEyes()
          currentLevel = 0
          currentEye = .right
          currentLetters = ""
          userInput = ""
          recognizedText = ""
          timeRemaining = 10
          statusMessage = "Ready to start with Right Eye"
          timeoutCount = 0
          testCompleted = false
          bothEyesCompleted = false
          rightEyeLogMAR = 0.4
          leftEyeLogMAR = 0.4
          rightEyeResults.removeAll()
          leftEyeResults.removeAll()
        
          updateCurrentLetters()
      }
    
    // Move to next level
    private func moveToNextLevel() {
        currentLevel += 1
        if currentLevel < Level_limit {
            statusMessage = "Success! Entering level \(currentLevel + 1) for \(currentEye.description) Eye"
            timeoutCount = 0
            
            // Update LogMAR value for the current eye
            if currentEye == .right {
                rightEyeLogMAR -= 0.1
            } else {
                leftEyeLogMAR -= 0.1
            }
            
            restartRecording()
        } else {
            switchEye()
            if !bothEyesCompleted {
                restartRecording()
            } else {
                stopRecording()
            }
        }
    }
    
    // Stop recording
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        isRecording = false
        timer?.invalidate()
        timeRemaining = 10
    }
    
    // Toggle recording state
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    // Restart current level
    private func restartCurrentLevel() {
        stopRecording()
        startRecording()
    }
    
    // Restart recording
    private func restartRecording() {
        stopRecording()
        sleep(1)
        startRecording()
    }
    
    // Start timer
    private func startTimer() {
        timeRemaining = 10
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.statusMessage = "Time's up, restarting"
                timeoutCount += 1
                if self.timeoutCount >= 3 {
                    testCompleted = true
                }
                self.restartCurrentLevel()
            }
        }
    }
    
    // Recording animation
    private func startRecordingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.isRecording else { return }
            
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    self.recordingAnimationOpacity[i] = self.recordingAnimationOpacity[i] == 1.0 ? 0.3 : 1.0
                }
            }
        }
    }
}
