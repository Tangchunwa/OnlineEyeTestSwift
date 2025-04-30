import SwiftUI
import Speech
import AVFoundation

class macular_SpeechRecognitionManager: ObservableObject {
    @Published var isListening = false
    @Published var currentHighlightedOption: String?
    @Published var recognizedText = ""
    
    // Cantonese phonetic mappings for letters
    private let letterMappings: [String: String] = [
        // A mappings (啊, 亞, 唉...)
        "唉": "A", "誃": "A",
        // B mappings (比, 必, 畢...)
        "必": "B", "嗶": "B", "bee": "B",
        // C mappings (西, 施, 詩, 死...)
        "是": "C","施": "C", "詩": "C", "see": "C",
        // D mappings
        "的": "D", "啲": "D", "笛": "D", "讀": "D", "d": "D",
        // E mappings (意, 醫, 伊...)
        "二": "E","依": "E", "醫": "E", "伊": "E", "衣": "E", "yee": "E"
    ]
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?
    
    init() {
        // Use Cantonese recognition
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
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
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
                self.speechRecognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
            
        } catch {
            print("Audio engine error: \(error.localizedDescription)")
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        speechRecognitionRequest.endAudio()
        speechRecognitionTask?.cancel()
        isListening = false
    }
    
    private func processRecognizedSpeech(_ speech: String, onOptionRecognized: @escaping (String) -> Void) {
        // Check for direct letter matches first
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
        
        // Check for Cantonese phonetic matches
        for character in speech {
            if let mappedLetter = letterMappings[String(character)] {
                currentHighlightedOption = mappedLetter
                onOptionRecognized(mappedLetter)
                return
            }
        }
    }
}

struct MacularDegenerationTestView: View {
    @State private var result = ""
    @State private var selectedOption: String?
    @State private var isTransitioning = false
    @StateObject private var speechManager = macular_SpeechRecognitionManager()
    
    var onComplete: (() -> Void)?
    
    var options: [String] {
        if LocalizationManager.shared.currentLanguage == .chinese {
            return [
                "A:所有線條都是直的",
                "B:部分線條出現彎曲",
                "C:部分線條缺失",
                "D:我看到暗淡或模糊的區域",
                "E:線條看起來變形"
            ]
        } else {
            return [
                "A:All lines appear straight",
                "B:Some lines appear wavy",
                "C:Some lines are missing",
                "D:I see dark or blurry areas",
                "E:The lines look distorted"
            ]
        }
    }
    
    var body: some View {
        if isTransitioning {
            // Transition view remains the same...
            TransitionView(result: result, onComplete: onComplete)
        } else {
            VStack(spacing: 20) {
                Text("macular_test".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                ZStack {
                    Image("amsler_grid")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }
                .padding(.vertical)
                
                // Voice recognition status and recognized text
                VStack(spacing: 5) {
                    HStack {
                        Image(systemName: speechManager.isListening ? "waveform.circle.fill" : "mic.circle.fill")
                            .foregroundColor(speechManager.isListening ? .blue : .green)
                            .font(.system(size: 24))
                        
                        Text(speechManager.isListening ? "listening".localized : "Recog_success".localized)
                            .foregroundColor(speechManager.isListening ? .blue : .green)
                    }
                
                }
                .padding()
                
                // Options list
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(options, id: \.self) { option in
                        OptionView(
                            option: option,
                            
                            isHighlighted: speechManager.currentHighlightedOption.map { option.hasPrefix($0) } ?? false
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
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
        if let option = options.first(where: { $0.hasPrefix(letter) }) {
            selectedOption = option
            
            // 準備結果
            result = LocalizationManager.shared.currentLanguage == .chinese ?
                (letter == "A" ? "正常，未檢測到黃斑部問題。" : "可能有黃斑部問題，建議進一步檢查。") :
                (letter == "A" ? "Normal, no macular issues detected." : "Possible macular issues, further examination recommended.")
            
            // 保存結果
            UserDefaults.standard.set(option, forKey: "MacularTestOption")
            UserDefaults.standard.set(result, forKey: "MacularTestResult")
            
            // 停止語音識別
            speechManager.stopListening()
            
            // 添加 2 秒延遲
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isTransitioning = true
            }
        }
    }
}

struct OptionView: View {
    let option: String
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isHighlighted ? "waveform.circle.fill" : "circle")
                .foregroundColor(isHighlighted ? .blue : .gray)
            
            Text(option)
                .font(.body)
                .foregroundColor(isHighlighted ? .blue : .primary)
            
            Spacer()
        }
        .padding(.vertical, 5)
        .background(isHighlighted ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .animation(.easeInOut, value: isHighlighted)
    }
}

struct TransitionView: View {
    let result: String
    var onComplete: (() -> Void)?
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.green)
                    .padding(.bottom, 10)
                
                Text(result)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(radius: 10)
            )
            .padding(.horizontal, 30)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete?()
            }
        }
    }
}
