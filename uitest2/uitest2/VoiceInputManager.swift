//import Speech
//import SwiftUI
//
//class VoiceInputManager: ObservableObject {
//    private var audioEngine: AVAudioEngine?
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    
//    @Published var transcript: String = ""
//    @Published var isListening: Bool = false
//    
//    func requestAuthorization() {
//        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
//            DispatchQueue.main.async {
//                if authStatus == .authorized {
//                    print("Speech recognition authorized")
//                } else {
//                    print("Speech recognition not authorized. Status: \(authStatus)")
//                }
//            }
//        }
//    }
//    
//    func startListening() {
//        isListening = true
//        audioEngine = AVAudioEngine()
//        guard let audioEngine = audioEngine else { return }
//        
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else { return }
//        recognitionRequest.shouldReportPartialResults = true
//        
//        do {
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//            
//            let inputNode = audioEngine.inputNode
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
//            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//                recognitionRequest.append(buffer)
//            }
//            
//            audioEngine.prepare()
//            try audioEngine.start()
//            
//            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//                guard let self = self else { return }
//                if let result = result {
//                    self.transcript = result.bestTranscription.formattedString
//                }
//                if let error = error {
//                    print("Speech recognition error: \(error.localizedDescription)")
//                    self.stopListening()
//                }
//            }
//        } catch {
//            print("Error starting speech recognition: \(error)")
//            stopListening()
//        }
//    }
//    
//    func stopListening() {
//        isListening = false
//        audioEngine?.stop()
//        audioEngine?.inputNode.removeTap(onBus: 0)
//        recognitionRequest?.endAudio()
//        recognitionTask?.cancel()
//    }
//    
//    func resetTranscript() {
//        transcript = ""
//    }
//}
