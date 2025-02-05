import SwiftUI
import Speech
import AVFoundation

class newVoiceInputManager: ObservableObject {
    // Published properties
    @Published var currentLevel = 0
    @Published var currentLetters = ""
    @Published var userInput = ""
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var timeRemaining = 10
    @Published var statusMessage = "Ready to start"
    @Published var recordingAnimationOpacity = [1.0, 1.0, 1.0]
    @Published var timeoutCount = 0
    @Published var testCompleted = false
    @Published var LogMarValue = 0.4
    
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
    
    // Store current test letter sequence
    private var currentLevelLetters: [[String]] = []
    
    // Initialization
    init() {
        generateAllLevels()
    }
    
    // Generate all levels of letters
    private func generateAllLevels() {
        currentLevelLetters = [
            generateLettersForLevel(count: 3), // Level 1
            generateLettersForLevel(count: 3), // Level 2
            generateLettersForLevel(count: 4), // Level 3
            generateLettersForLevel(count: 4), // Level 4
            generateLettersForLevel(count: 5)  // Level 5
        ]
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
        let count = currentLevelLetters[currentLevel].count
        currentLevelLetters[currentLevel] = generateLettersForLevel(count: count)
        currentLetters = currentLevelLetters[currentLevel].joined(separator: " ")
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
    
    // Start recording
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
            currentLetters = currentLevelLetters[currentLevel].joined(separator: " ")
            startTimer()
            startRecordingAnimation()
            
        } catch {
            statusMessage = "Recording setup failed: \(error.localizedDescription)"
        }
    }
    
    // Process recognized text
    private func processRecognizedText(_ text: String) {
        if text.contains("AGAIN") {
            statusMessage = "Detected 'AGAIN', restarting"
            regenerateCurrentLevel()
            restartCurrentLevel()
            return
        }
        if currentLevel >= currentLevelLetters.count { return } // Bug fix (out of index)
        let currentLevelLetters = self.currentLevelLetters[currentLevel]
        let success = currentLevelLetters.allSatisfy { text.contains($0) }
        
        if success {
            //AudioServicesPlaySystemSound(1004) // Success sound
            moveToNextLevel()
        }
    }
    func processInputText() {
        let userInputLetters = userInput.uppercased().filter { !$0.isWhitespace }
               
       // Get current level's correct sequence
        let correctSequence = currentLevelLetters[currentLevel].joined()
       
       // Check for exact sequence match
        let success = userInputLetters == correctSequence
        
        if success {
            moveToNextLevel()
        }
        else{
            testCompleted=true
        }
    }
    
    func restartTest() {
        stopRecording()
        generateAllLevels()
        currentLevel = 0
        currentLetters = ""
        userInput = ""
        //isRecording = false
        recognizedText = ""
        timeRemaining = 10
        statusMessage = "Ready to start"
        timeoutCount = 0
        testCompleted = false
        LogMarValue = 0.4
        // Reset other necessary properties
    }
    
    // Move to next level
    private func moveToNextLevel() {
        currentLevel += 1
        if currentLevel < currentLevelLetters.count {
            statusMessage = "Success! Entering level \(currentLevel + 1)"
            timeoutCount = 0
            LogMarValue -= 0.1
            restartRecording()
        } else {
            statusMessage = "Test completed!"
            stopRecording()
            testCompleted = true
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
