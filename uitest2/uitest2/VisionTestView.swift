//import SwiftUI
//import AVFoundation
//import Speech
//
//struct VisionTestView: View {
//    @StateObject private var faceDistanceManager = FaceDistanceManager()
//    @StateObject private var voiceInputManager = VoiceInputManager()
//    
//    @State private var currentLevel = 0
//    @State private var levels: [TestLevel] = []
//    @State private var userInput = ""
//    @State private var showConfirmation = false
//    @State private var result = ""
//    @State private var isTestComplete = false
//    
//    // Reference size for scaling
//    let referenceWidth: CGFloat = 375
//    let referenceHeight: CGFloat = 812
//    
//    func scaledSize(_ size: CGFloat, for geometry: GeometryProxy) -> CGFloat {
//        let widthRatio = geometry.size.width / referenceWidth
//        let heightRatio = geometry.size.height / referenceHeight
//        let scaleFactor = min(widthRatio, heightRatio)
//        return size * scaleFactor
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack(spacing: 20) {
//
//                Text("Vision Test")
//                    .font(.system(size: scaledSize(30, for: geometry), weight: .bold))
//                    .padding(.top, geometry.safeAreaInsets.top + 20)
//                
//                Spacer()
//                
//                if !isTestComplete && currentLevel < levels.count {
//                    // Test letters display
//                    Text(levels[currentLevel].displayText)
//                        .font(.system(size: levels[currentLevel].fontSize))
//                        .blur(radius: faceDistanceManager.isInIdealRange ? 0 : 10)
//                        .animation(.easeInOut(duration: 0.3), value: faceDistanceManager.isInIdealRange)
//                    
//                    // Distance indicator
//                    Text(String(format: "Distance: %.2f m", faceDistanceManager.distance))
//                        .foregroundColor(faceDistanceManager.isInIdealRange ? .green : .red)
//                        .font(.system(size: scaledSize(20, for: geometry)))
//                    
//                    if !faceDistanceManager.isInIdealRange {
//                        Text("Please maintain 55-60 cm distance")
//                            .foregroundColor(.red)
//                            .font(.system(size: scaledSize(18, for: geometry)))
//                    }
//                    
//                    // User input section
//                    VStack(spacing: 15) {
//                        TextField("Enter letters", text: $userInput)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .font(.system(size: scaledSize(20, for: geometry)))
//                            .multilineTextAlignment(.center)
//                            .textInputAutocapitalization(.characters)
//                        
//                        // Voice input button
//                        Button(voiceInputManager.isListening ? "Stop Voice Input" : "Start Voice Input") {
//                            if voiceInputManager.isListening {
//                                voiceInputManager.stopListening()
//                                userInput = voiceInputManager.transcript.uppercased()
//                            } else {
//                                voiceInputManager.resetTranscript()
//                                voiceInputManager.startListening()
//                            }
//                        }
//                        .buttonStyle(CustomButtonStyle(color: voiceInputManager.isListening ? .red : .blue, geometry: geometry))
//                        .disabled(!faceDistanceManager.isInIdealRange)
//                        
//                        // Confirm answer button
//                        Button("Confirm Answer") {
//                            showConfirmation = true
//                        }
//                        .buttonStyle(CustomButtonStyle(color: .green, geometry: geometry))
//                        .disabled(!faceDistanceManager.isInIdealRange || userInput.isEmpty)
//                    }
//                    .padding()
//                } else if isTestComplete {
//                    VStack(spacing: 20) {
//                        Text("Test Complete")
//                            .font(.system(size: scaledSize(30, for: geometry), weight: .bold))
//                        
//                        Text(result)
//                            .font(.system(size: scaledSize(20, for: geometry)))
//                            .multilineTextAlignment(.center)
//                        
//                        Button("Restart Test") {
//                            restartTest()
//                        }
//                        .buttonStyle(CustomButtonStyle(color: .blue, geometry: geometry))
//                    }
//                }
//                
//                Spacer()
//            }
//            .padding()
//            .alert("Confirm Answer", isPresented: $showConfirmation) {
//                Button("Cancel", role: .cancel) {}
//                Button("Confirm") {
//                    checkAnswer()
//                }
//            } message: {
//                Text("Is '\(userInput)' your final answer?")
//            }
//        }
//        .onAppear {
//            setupTest()
//        }
//    }
//    
//    private func setupTest() {
//        levels = TestLevel.generateLevels()
//        voiceInputManager.requestAuthorization()
//        currentLevel = 0
//        isTestComplete = false
//        result = ""
//    }
//    
//    private func checkAnswer() {
//        let currentAnswer = levels[currentLevel].answer
//        if userInput.uppercased() == currentAnswer {
//            if currentLevel < levels.count - 1 {
//                currentLevel += 1
//                userInput = ""
//                voiceInputManager.resetTranscript()
//            } else {
//                completeTest(success: true)
//            }
//        } else {
//            completeTest(success: false)
//        }
//    }
//    
//    private func completeTest(success: Bool) {
//        isTestComplete = true
//        if success {
//            result = "Excellent! You completed all levels successfully."
//        } else {
//            result = "Test completed at level \(currentLevel + 1) of 10.\nYour vision score: \(calculateScore())"
//        }
//    }
//    
//    private func calculateScore() -> String {
//        let scores = ["6/60", "6/48", "6/38", "6/30", "6/24", "6/19", "6/15", "6/12", "6/9.5", "6/7.5"]
//        return scores[currentLevel]
//    }
//    
//    private func restartTest() {
//        setupTest()
//    }
//}
//
//struct CustomButtonStyle: ButtonStyle {
//    let color: Color
//    let geometry: GeometryProxy
//    
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: scaledSize(20, for: geometry)))
//            .padding()
//            .frame(minWidth: 200)
//            .background(color)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            .scaleEffect(configuration.isPressed ? 0.95 : 1)
//    }
//    
//    private func scaledSize(_ size: CGFloat, for geometry: GeometryProxy) -> CGFloat {
//        let referenceWidth: CGFloat = 375
//        let referenceHeight: CGFloat = 812
//        let widthRatio = geometry.size.width / referenceWidth
//        let heightRatio = geometry.size.height / referenceHeight
//        let scaleFactor = min(widthRatio, heightRatio)
//        return size * scaleFactor
//    }
//}
