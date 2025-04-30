import SwiftUI
import Speech
import AVFoundation


class ColorBlindness_SpeechRecognitionManager: ObservableObject {
    @Published var isListening = false
    @Published var currentHighlightedOption: String?
    @Published var recognizedText = ""
    
    private let letterMappings: [String: String] = [
        "唉": "A", "誃": "A",
        "必": "B", "嗶": "B", "bee": "B",
        "是": "C", "施": "C", "詩": "C", "see": "C",
        "的": "D", "啲": "D", "笛": "D", "讀": "D", "d": "D",
        "二": "E", "依": "E", "醫": "E", "伊": "E", "衣": "E", "yee": "E"
    ]
    
    private let audioEngine = AVAudioEngine()
    // 移除這行
    // private let speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var speechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-HK"))
    }
    
    func requestSpeechAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    completion(true)
                default:
                    print("Speech recognition authorization denied")
                    completion(false)
                }
            }
        }
    }
    
    func startListening(onOptionRecognized: @escaping (String) -> Void) {
           guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }
           
           // 停止之前的監聽（如果有的話）
           stopListening()
           
           let audioSession = AVAudioSession.sharedInstance()
           do {
               try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
               try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
               
               // 創建新的 request
               speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
               guard let speechRecognitionRequest = speechRecognitionRequest else { return }
               
               let inputNode = audioEngine.inputNode
               speechRecognitionRequest.shouldReportPartialResults = true
               
               speechRecognitionTask = recognizer.recognitionTask(with: speechRecognitionRequest) { [weak self] result, error in
                   guard let self = self else { return }
                   if let result = result {
                       let recognizedText = result.bestTranscription.formattedString
                       DispatchQueue.main.async {
                           self.recognizedText = recognizedText
                           self.processRecognizedSpeech(recognizedText, onOptionRecognized: onOptionRecognized)
                       }
                   }
               }
               
               let recordingFormat = inputNode.outputFormat(forBus: 0)
               inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                   self.speechRecognitionRequest?.append(buffer)
               }
               
               audioEngine.prepare()
               try audioEngine.start()
               isListening = true
               recognizedText = "" // Clear previous text
               
           } catch {
               print("Audio engine error: \(error.localizedDescription)")
           }
       }
       
       func stopListening() {
           audioEngine.stop()
           audioEngine.inputNode.removeTap(onBus: 0)
           speechRecognitionRequest?.endAudio()
           speechRecognitionTask?.cancel()
           speechRecognitionRequest = nil  // 清除 request
           speechRecognitionTask = nil     // 清除 task
           isListening = false
           recognizedText = "" // Clear text when stopping
       }
   
    
    private func processRecognizedSpeech(_ speech: String, onOptionRecognized: @escaping (String) -> Void) {
        let upperSpeech = speech.uppercased()
        if upperSpeech.contains("A") || upperSpeech.contains("B") ||
            upperSpeech.contains("C") || upperSpeech.contains("D") ||
            upperSpeech.contains("E") {
            if let letter = upperSpeech.first(where: { "ABCDE".contains($0) }) {
                currentHighlightedOption = String(letter)
                onOptionRecognized(String(letter))
                return
            }
        }
        
        for character in speech {
            if let mappedLetter = letterMappings[String(character)] {
                currentHighlightedOption = mappedLetter
                onOptionRecognized(mappedLetter)
                return
            }
        }
    }
}

struct ColorBlindnessTestView: View {
    @State private var currentPhotoIndex = 0
    @State private var result = ""
    @State private var score = 0
    @State private var userAnswers: [String] = []
    @State private var isTransitioning = false
    @State private var selectedOption: String?
    @State private var isProcessingAnswer = false
    @StateObject private var speechManager = ColorBlindness_SpeechRecognitionManager()
    
    var onComplete: (() -> Void)?
    
    let photos = [
        (image: "Ishihara_Tests-03", correctAnswer: "12"),
        (image: "Ishihara_Tests-04", correctAnswer: "8"),
        (image: "Ishihara_Tests-05", correctAnswer: "29"),
        (image: "Ishihara_Tests-06", correctAnswer: "5"),
        (image: "Ishihara_Tests-07", correctAnswer: "3"),
        (image: "Ishihara_Tests-08", correctAnswer: "15"),
        (image: "Ishihara_Tests-09", correctAnswer: "74"),
        (image: "Ishihara_Tests-10", correctAnswer: "6"),
        (image: "Ishihara_Tests-11", correctAnswer: "45"),
        (image: "Ishihara_Tests-12", correctAnswer: "5"),
        (image: "Ishihara_Tests-13", correctAnswer: "7"),
        (image: "Ishihara_Tests-14", correctAnswer: "16"),
        (image: "Ishihara_Tests-15", correctAnswer: "73"),
        (image: "Ishihara_Tests-16", correctAnswer: "No number"),
        (image: "Ishihara_Tests-17", correctAnswer: "No number")
    ]
    
    let choices: [[String]] = [
        ["29", "8", "12", "17", "No number"],
        ["3", "6", "15", "8", "No number"],
        ["12", "29", "74", "45", "No number"],
        ["6", "3", "5", "8", "No number"],
        ["8", "7", "3", "5", "No number"],
        ["15", "13", "12", "17", "No number"],
        ["23", "29", "74", "45", "No number"],
        ["5", "6", "3", "8", "No number"],
        ["45", "17", "74", "29", "No number"],
        ["3", "7", "5", "6", "No number"],
        ["7", "9", "12", "2", "No number"],
        ["16", "15", "12", "19", "No number"],
        ["62", "73", "45", "29", "No number"],
        ["6", "17", "5", "19", "No number"],
        ["45", "53", "4", "72", "No number"]
    ]
    
    var body: some View {
        if isTransitioning {
            TransitionView(result: result, onComplete: onComplete)
        } else {
            VStack {
                Text("color_test".localized)
                    .font(.system(size: 34, weight: .bold))
                    .padding()
                
                if currentPhotoIndex < photos.count {
                    Image(photos[currentPhotoIndex].image)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFill()
                        .frame(width: 280, height: 280)
                        .clipped()
                        .padding()
                    
                    Text("what_number".localized)
                        .font(.system(size: 26))
                        .padding()
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: speechManager.isListening ? "waveform.circle.fill" : "mic.circle.fill")
                                .foregroundColor(speechManager.isListening ? .blue : .green)
                                .font(.system(size: 24))
                            
                            Text(speechManager.isListening ? "listening".localized : "Recog_success".localized)
                                .foregroundColor(speechManager.isListening ? .blue : .green)
                        }
                        
                    }
                    .padding()
                    
//                    if isProcessingAnswer {
//                        VStack {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle())
//                                .scaleEffect(1.5)
//                            Text("processing".localized)
//                                .foregroundColor(.gray)
//                                .padding(.top, 8)
//                        }
//                        .padding()
//                    }
                    
                    VStack(spacing: 20) {
                        // Grid for options A-D
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(getOptionsForCurrentPhoto().prefix(4), id: \.self) { option in
                                newOptionView(
                                    option: option,
                                    isSelected: selectedOption.map { option.hasPrefix($0) } ?? false
                                )
                            }
                        }
                        
                        // Option E centered below
                        if let lastOption = getOptionsForCurrentPhoto().last {
                            newOptionView(
                                option: lastOption,
                                isSelected: selectedOption.map { lastOption.hasPrefix($0) } ?? false
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isProcessingAnswer)
                }
            }
            .padding()
            .background(Color.white)
            .onAppear {
                setupSpeechRecognition()
            }
            .onDisappear {
                speechManager.stopListening()
            }
        }
    }
    
    private func getOptionsForCurrentPhoto() -> [String] {
        let currentChoices = choices[currentPhotoIndex]
        var optionLabels: [String] = []
        
        for (index, choice) in currentChoices.enumerated() {
            let letter = String(Character(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(index))!))
            optionLabels.append("\(letter): \(choice)")
        }
        
        return optionLabels
    }
    
    private func setupSpeechRecognition() {
        speechManager.requestSpeechAuthorization { authorized in
            if authorized {
                speechManager.startListening { recognizedOption in
                    handleOptionSelection(recognizedOption)
                }
            }
        }
    }
    
    private func handleOptionSelection(_ letter: String) {
        guard !isProcessingAnswer else { return }
        
        let currentChoices = choices[currentPhotoIndex]
        let index = letter.first!.asciiValue! - Character("A").asciiValue!
        if index >= 0 && index < currentChoices.count {
            isProcessingAnswer = true
            selectedOption = letter
            speechManager.stopListening()
            
            let selectedAnswer = currentChoices[Int(index)]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                checkAnswer(selectedAnswer)
                selectedOption = nil
                isProcessingAnswer = false
                
                if currentPhotoIndex < photos.count {
                    setupSpeechRecognition()
                }
            }
        }
    }
    
    func checkAnswer(_ selectedAnswer: String) {
        userAnswers.append(selectedAnswer)
        
        if selectedAnswer == photos[currentPhotoIndex].correctAnswer {
            score += 1
        }
        
        currentPhotoIndex += 1
        
        if currentPhotoIndex == photos.count {
            calculateResult()
        }
    }
    
    func calculateResult() {
        let answer14 = userAnswers.indices.contains(13) ? userAnswers[13] : ""
        let answer15 = userAnswers.indices.contains(14) ? userAnswers[14] : ""
        let redGreenFlag = (answer14 == "5" || answer15 == "45")
        let isChinese = LocalizationManager.shared.currentLanguage == .chinese
        
        if redGreenFlag {
            result = isChinese ?
            "您的答案顯示可能存在紅綠色覺缺陷。請諮詢眼科專業人員。" :
            "Your answers suggest possible red-green color vision deficiency. Please consult an eye care professional."
        } else if score >= 15 {
            result = isChinese ?
            "您的色覺正常。" :
            "Your color vision appears normal."
        } else if score <= 9 {
            result = isChinese ?
            "您可能有色覺缺陷。請諮詢眼科專業人員。" :
            "You may have a color vision deficiency. Please consult an eye care professional."
        } else {
            result = isChinese ?
            "您的結果不確定。建議進一步專業測試。" :
            "Your results are inconclusive. Further testing with a professional is recommended."
        }
        
        UserDefaults.standard.set(score, forKey: "ColorTestScore")
        UserDefaults.standard.set(photos.count, forKey: "ColorTestTotal")
        UserDefaults.standard.set(result, forKey: "ColorTestResult")
        
        isTransitioning = true
    }
}
// Modify the newOptionView struct:
struct newOptionView: View {
    let option: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .green : .gray)
                .imageScale(.large) // Make the icon larger
            
            Text(option)
                .font(.system(size: 24, weight: .medium)) // Larger font size
                .foregroundColor(isSelected ? .green : .primary)
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.white)
        .cornerRadius(10)
    }
}
