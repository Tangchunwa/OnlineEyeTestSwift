import SwiftUI
import Speech
import AVFoundation

struct LogMARTestView: View {
    @StateObject private var testManager = VisionTestManager()
    @StateObject private var faceDistanceManager = FaceDistanceManager()
    @State private var showingInstructions = true
    @State private var showingSwitchEyesAlert = false
    
    var body: some View {
        if showingInstructions {
            EyeTestInstructionsView(showingInstructions: $showingInstructions)
        } else if !testManager.testCompleted {
            VStack(spacing: 20) {
                // Title and current eye/level information
                VStack {
                    Text("Vision Test")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(testManager.currentEye.description) Eye - Level \(testManager.currentLevel + 1)/5")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    // Eye coverage reminder
                    EyeCoverageReminderView(currentEye: testManager.currentEye)
                }
                
               // Spacer()
                
                // Test letters display area with distance check
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .frame(height: 200)
                    
                    Text(testManager.currentLetters)
                        .font(.custom("OpticianSans-Regular", size: testManager.getCurrentFontSize()))
                        .fontWeight(.bold)
                        .tracking(10) // Letter spacing
                    
                    // Add overlay when not in ideal range
                    if !faceDistanceManager.isInIdealRange {
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 200)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: faceDistanceManager.isInIdealRange)
                            .overlay(
                                VStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 30))
                                    
                                    Text(getDistanceMessage())
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                }
                            )
                    }
                }
                .padding()
                
                // Distance indicator
                VStack(spacing: 5) {
                    Text("Current Distance: \(String(format: "%.2f", faceDistanceManager.distance))m")
                        .font(.subheadline)
                        .foregroundColor(faceDistanceManager.isInIdealRange ? .green : .red)
                    
                    // Progress bar for distance
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 8)
                                .opacity(0.3)
                                .foregroundColor(.gray)
                            
                            Rectangle()
                                .frame(width: min(geometry.size.width, geometry.size.width * CGFloat(faceDistanceManager.distance)), height: 8)
                                .foregroundColor(faceDistanceManager.isInIdealRange ? .green : .red)
                                .animation(.linear, value: faceDistanceManager.distance)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                
                // Timer and status display
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(testManager.timeRemaining <= 3 ? .red : .blue)
                    Text("\(testManager.timeRemaining)s")
                        .fontWeight(.semibold)
                }
                
                // Recording status and control button
                VStack(spacing: 15) {
                    if testManager.isRecording {
                        // Recording animation indicator
                        HStack(spacing: 5) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .opacity(testManager.recordingAnimationOpacity[index])
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .repeatForever()
                                            .delay(0.2 * Double(index)),
                                        value: testManager.recordingAnimationOpacity[index]
                                    )
                            }
                        }
                        Text("Listening...")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        testManager.toggleRecording()
                    }) {
                        HStack {
                            Image(systemName: testManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            Text(testManager.isRecording ? "Stop Voice Input" : "Start Voice Input")
                        }
                        .font(.title2)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(testManager.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Debug information area
                VStack(alignment: .leading, spacing: 10) {
                    Text("Debug")
                        .font(.headline)
                    TextField("Enter letters", text: $testManager.userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.allCharacters)
                    
                    Button("Confirm Answer") {
                        testManager.processInputText()
                    }
                    .buttonStyle(.bordered)
                    .disabled(testManager.userInput.isEmpty)
                    
                    VStack(alignment: .leading) {
                        Text("Recognized: \(testManager.recognizedText)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            .onAppear {
                testManager.checkPermissions()
            }
//            .alert(isPresented: .constant(testManager.currentEye == .left && !testManager.testCompleted)) {
//                Alert(
//                    title: Text("Switch Eyes"),
//                    message: Text("Please cover your RIGHT eye now to test your LEFT eye."),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
        } else {
            VStack(spacing: 20) {
                VisionTestResultView(
                    rightEyeLogMAR: testManager.rightEyeLogMAR,
                    leftEyeLogMAR: testManager.leftEyeLogMAR
                )
                
                Button(action: {
                    testManager.restartTest()
                    showingInstructions = true
                }) {
                    Text("Restart Test")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func getDistanceMessage() -> String {
        if faceDistanceManager.distance < 0.55 {
            return "Please move back\nIdeal distance: 55-60cm"
        } else {
            return "Please move closer\nIdeal distance: 55-60cm"
        }
    }
}

// New Instructions View
struct EyeTestInstructionsView: View {
    @Binding var showingInstructions: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Vision Test Instructions")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 20) {
                InstructionStep(
                    number: 1,
                    title: "Prepare Your Environment",
                    description: "Find a well-lit room and ensure you're in a comfortable position."
                )
                
                InstructionStep(
                    number: 2,
                    title: "Distance",
                    description: "Position yourself 55-60cm from the screen."
                )
                
                InstructionStep(
                    number: 3,
                    title: "Right Eye Test",
                    description: "Cover your LEFT eye completely with your palm or an eye patch."
                )
                
                InstructionStep(
                    number: 4,
                    title: "Left Eye Test",
                    description: "After completing the right eye test, you'll be prompted to cover your RIGHT eye."
                )
                
                InstructionStep(
                    number: 5,
                    title: "Voice Input",
                    description: "Speak the letters you see clearly and confidently."
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
            
            Button(action: {
                showingInstructions = false
            }) {
                Text("Start Test")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

// Helper view for instruction steps
struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(Color.blue)
                .frame(width: 30, height: 30)
                .overlay(
                    Text("\(number)")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

// Eye Coverage Reminder View
struct EyeCoverageReminderView: View {
    let currentEye: VisionTestManager.Eye
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "eye.fill")
                .foregroundColor(.red)
            
            Text("Please cover your \(currentEye == .right ? "LEFT" : "RIGHT") eye")
                .font(.headline)
                .foregroundColor(.red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.red.opacity(0.1))
        )
    }
}



struct Content_Previews: PreviewProvider {
    static var previews: some View {
        LogMARTestView()
    }
}
