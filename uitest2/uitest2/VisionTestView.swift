import SwiftUI
import AVFoundation
import Speech

struct VisionTestView: View {
    @StateObject private var faceDistanceManager = FaceDistanceManager()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var currentRow = 0
    @State private var result = ""
    @State private var distance: Float = 0.0
    @State private var isTooClose = false
    @State private var isListening = false
    
    // LogMAR chart configuration
    let logMarRows = [
        ("6/60", 1.0, ["E"]),
        ("6/48", 0.9, ["P"]),
        ("6/38", 0.8, ["F", "P"]),
        ("6/30", 0.7, ["T", "O", "Z"]),
        ("6/24", 0.6, ["L", "P", "E", "D"]),
        ("6/19", 0.5, ["P", "E", "C", "F", "D"]),
        ("6/15", 0.4, ["E", "D", "F", "C", "Z", "P"]),
        ("6/12", 0.3, ["F", "E", "L", "O", "P", "Z", "D"]),
        ("6/9.5", 0.2, ["D", "E", "F", "P", "O", "T", "E", "C"]),
        ("6/7.5", 0.1, ["L", "E", "F", "O", "D", "P", "C", "T", "Z"])
    ]
    
    // Reference size for iPhone 12 mini
    let referenceWidth: CGFloat = 375
    let referenceHeight: CGFloat = 812
    
    func scaledSize(_ size: CGFloat, for geometry: GeometryProxy) -> CGFloat {
        let widthRatio = geometry.size.width / referenceWidth
        let heightRatio = geometry.size.height / referenceHeight
        let scaleFactor = min(widthRatio, heightRatio)
        return size * scaleFactor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                FaceDistanceView(distance: $distance, faceDistanceManager: faceDistanceManager)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("LogMAR Vision Test")
                        .font(.system(size: scaledSize(30, for: geometry), weight: .bold))
                        .padding(.top, geometry.safeAreaInsets.top + 20)
                    
                    Spacer()
                    
                    if currentRow < logMarRows.count {
                        Text(logMarRows[currentRow].2.joined(separator: " "))
                            .font(.system(size: scaledSize(100, for: geometry) * CGFloat(logMarRows[currentRow].1)))
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                    }
                    
                    if distance < 0.4 {
                        Text("You are too close!")
                            .foregroundColor(.red)
                            .font(.system(size: scaledSize(24, for: geometry), weight: .semibold))
                    }
                    
                    HStack(spacing: 20) {
                        Button("I can see") {
                            print("DEBUG: User pressed 'I can see' button")
                            nextRow()
                        }
                        .buttonStyle(CustomButtonStyle(color: .green, geometry: geometry))
                        
                        Button("I cannot see") {
                            print("DEBUG: User pressed 'I cannot see' button")
                            finishTest()
                        }
                        .buttonStyle(CustomButtonStyle(color: .red, geometry: geometry))
                    }
                    .disabled(distance < 0.4 || currentRow >= logMarRows.count)
                    
                    Button(isListening ? "Stop Voice Input" : "Start Voice Input") {
                        if isListening {
                            stopListening()
                        } else {
                            startListening()
                        }
                    }
                    .buttonStyle(CustomButtonStyle(color: isListening ? .orange : .blue, geometry: geometry))
                    .disabled(distance < 0.4 || currentRow >= logMarRows.count)
                    
                    Text(result)
                        .font(.system(size: scaledSize(24, for: geometry), weight: .medium))
                    
                    Text("Distance: \(String(format: "%.2f", distance)) meters")
                        .font(.system(size: scaledSize(20, for: geometry)))
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Spacer()
                }
                .padding()
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            faceDistanceManager.toggleCameraVisibility()
                        }) {
                            Text(faceDistanceManager.isCameraHidden ? "Show Camera" : "Hide Camera")
                                .font(.system(size: scaledSize(16, for: geometry)))
                                .padding(8)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                        }
                        .padding(.top, geometry.safeAreaInsets.top)
                        .padding(.trailing, 16)
                    }
                    Spacer()
                }
            }
        }
        .onChange(of: distance) { newValue in
            if newValue < 0.4 {
                faceDistanceManager.playTooCloseAudio()
            }
            //print("DEBUG: Distance changed to \(newValue) meters")
        }
        .onAppear {
            faceDistanceManager.setupAudioPlayer()
            speechRecognizer.transcribe()
            print("DEBUG: VisionTestView appeared")
        }
        .onDisappear {
            speechRecognizer.stopTranscribing()
            print("DEBUG: VisionTestView disappeared")
        }
    }
    
    private func startListening() {
        isListening = true
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        print("DEBUG: Started listening for voice input")
    }
    
    private func stopListening() {
        isListening = false
        speechRecognizer.stopTranscribing()
        checkUserInput()
        print("DEBUG: Stopped listening for voice input")
    }
    
    private func checkUserInput() {
        let userInput = speechRecognizer.transcript.uppercased().replacingOccurrences(of: " ", with: "")
        let correctInput = logMarRows[currentRow].2.joined(separator: "")
        
        print("DEBUG: User said: \(userInput)")
        print("DEBUG: Correct input: \(correctInput)")
        
        if userInput == correctInput {
            nextRow()
        } else {
            finishTest()
        }
    }
    
    private func nextRow() {
        if currentRow < logMarRows.count - 1 {
            currentRow += 1
            result = "Correct! Next row."
            print("DEBUG: Moving to next row: \(currentRow)")
        } else {
            result = "Your vision is excellent! (6/7.5)"
            print("DEBUG: Test completed with excellent vision")
        }
    }
    
    private func finishTest() {
        result = "Test completed. Your vision score is \(logMarRows[currentRow].0)"
        print("DEBUG: Test completed with score: \(logMarRows[currentRow].0)")
    }
}

class SpeechRecognizer: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    @Published var transcript: String = ""
    
    func transcribe() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("DEBUG: Speech recognition authorized")
                } else {
                    print("DEBUG: Speech recognition not authorized. Status: \(authStatus)")
                }
            }
        }
    }
    
    func startTranscribing() {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                if let result = result {
                    self.transcript = result.bestTranscription.formattedString
                    print("DEBUG: Recognized speech: \(self.transcript)")
                }
                if let error = error {
                    print("DEBUG: Speech recognition error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("DEBUG: Error starting speech recognition: \(error)")
        }
    }
    
    func stopTranscribing() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        print("DEBUG: Stopped transcribing")
    }
    
    func resetTranscript() {
        transcript = ""
        print("DEBUG: Reset transcript")
    }
}

struct CustomButtonStyle: ButtonStyle {
    let color: Color
    let geometry: GeometryProxy
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: scaledSize(22, for: geometry), weight: .semibold))
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
    
    func scaledSize(_ size: CGFloat, for geometry: GeometryProxy) -> CGFloat {
        let referenceWidth: CGFloat = 375
        let referenceHeight: CGFloat = 812
        let widthRatio = geometry.size.width / referenceWidth
        let heightRatio = geometry.size.height / referenceHeight
        let scaleFactor = min(widthRatio, heightRatio)
        return size * scaleFactor
    }
}
class FaceDistanceManager: ObservableObject {
    @Published var isCameraHidden = true
    
    var audioPlayer: AVAudioPlayer?
    var lastAudioPlayTime: Date?
    
    func toggleCameraVisibility() {
        isCameraHidden.toggle()
    }
    
    func setupAudioPlayer() {
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
    
    func playTooCloseAudio() {
        let currentTime = Date()
        
        // Check if 3 seconds have passed since the last audio play
        if let lastPlayTime = lastAudioPlayTime,
           currentTime.timeIntervalSince(lastPlayTime) < 3 {
            return
        }
        
        audioPlayer?.play()
        lastAudioPlayTime = currentTime
    }
}

struct MacularDegenerationTestView: View {
    @State private var result = ""
    @State private var showResult = false
    @State private var selectedOption: String?
    
    let options = [
        "All lines appear straight",
        "Some lines appear wavy",
        "Some lines are missing",
        "I see dark or blurry areas",
        "The lines look distorted"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Macular Degeneration Test")
                .font(.title)
                .multilineTextAlignment(.center)
            
            if !showResult {
                Image("amsler_grid")  // Replace "amsler_grid" with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                
                Text("How do the grid lines appear to you?")
                    .font(.headline)
                
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        checkResult(option)
                        showResult = true
                    }) {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Text("Test Complete")
                    .font(.title)
                    .padding()
                
                Text(result)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Button("Take Test Again") {
                    resetTest()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func checkResult(_ selectedOption: String) {
        switch selectedOption {
        case "All lines appear straight":
            result = "Your test result appears normal. However, regular eye check-ups are still recommended."
        default:
            result = "Based on your selection, it's advisable to consult an eye care professional for a comprehensive evaluation. Changes in how you see the Amsler grid can be a sign of macular degeneration or other eye conditions."
        }
    }
    
    func resetTest() {
        selectedOption = nil
        result = ""
        showResult = false
    }
}

struct ColorBlindnessTestView: View {
    @State private var currentPhotoIndex = 0
    @State private var result = ""
    @State private var score = 0
    
    let photos = [
        (image: "colorblind_test_1", correctAnswer: "74"),
        (image: "colorblind_test_2", correctAnswer: "26"),
        (image: "colorblind_test_3", correctAnswer: "12")
    ]
    
    let choices = [
        ["74", "21", "45", "78", "No number"],
        ["6", "8", "3", "26", "No number"],
        ["12", "17", "11", "51", "No number"]
    ]
    
    var body: some View {
        VStack {
            Text("Color Blindness Test")
                .font(.largeTitle)
            
            if currentPhotoIndex < photos.count {
                Image(photos[currentPhotoIndex].image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                Text("What number do you see in the image?")
                    .padding()
                
                ForEach(choices[currentPhotoIndex], id: \.self) { choice in
                    Button(action: {
                        checkAnswer(choice)
                    }) {
                        Text(choice)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("Test Complete")
                    .font(.title)
                    .padding()
                
                Text("Your score: \(score) out of \(photos.count)")
                    .font(.headline)
                
                Text(result)
                    .padding()
                
                Button("Restart Test") {
                    restartTest()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    func checkAnswer(_ selectedAnswer: String) {
        if selectedAnswer == photos[currentPhotoIndex].correctAnswer {
            score += 1
        }
        
        currentPhotoIndex += 1
        
        if currentPhotoIndex == photos.count {
            calculateResult()
        }
    }
    
    func calculateResult() {
        if score == photos.count {
            result = "Your color vision appears normal."
        } else if score >= photos.count / 2 {
            result = "You may have mild color vision deficiency. Please consult an eye care professional."
        } else {
            result = "You may have significant color vision deficiency. Please consult an eye care professional."
        }
    }
    
    func restartTest() {
        currentPhotoIndex = 0
        score = 0
        result = ""
    }
}
