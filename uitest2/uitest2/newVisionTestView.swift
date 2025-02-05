import SwiftUI
import Speech
import AVFoundation

struct LogMARTestView: View {
    @StateObject private var viewModel = newVoiceInputManager()
    @StateObject private var faceDistanceManager = FaceDistanceManager()
    
    var body: some View {
        if !viewModel.testCompleted {
            VStack(spacing: 20) {
                // Title and current level
                VStack {
                    Text("Vision Test")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Level \(viewModel.currentLevel + 1)/5")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Test letters display area with distance check
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .frame(height: 200)
                    
                    Text(viewModel.currentLetters)
                        .font(.system(size: viewModel.getCurrentFontSize()))
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
                        .foregroundColor(viewModel.timeRemaining <= 3 ? .red : .blue)
                    Text("\(viewModel.timeRemaining)s")
                        .fontWeight(.semibold)
                }
                
                // Recording status and control button
                VStack(spacing: 15) {
                    if viewModel.isRecording {
                        // Recording animation indicator
                        HStack(spacing: 5) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .opacity(viewModel.recordingAnimationOpacity[index])
                                    .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.2 * Double(index)), value: viewModel.recordingAnimationOpacity[index])
                            }
                        }
                        Text("Listening...")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        viewModel.toggleRecording()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            Text(viewModel.isRecording ? "Stop Voice Input" : "Start Voice Input")
                        }
                        .font(.title2)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(viewModel.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Debug information area
                VStack(alignment: .leading, spacing: 10) {
                    Text("Debug")
                        .font(.headline)
                    TextField("Enter letters", text: $viewModel.userInput)
                    Button("Confirm Answer") {
                        viewModel.processInputText()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Result: \(viewModel.recognizedText)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            .onAppear {
                viewModel.checkPermissions()
            }
        } else {// show result
            VisionTestResultView(logMarValue: viewModel.LogMarValue)
            Button(action: {
                viewModel.restartTest()
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
    
    // Helper function to get distance message
    private func getDistanceMessage() -> String {
        if faceDistanceManager.distance < 0.55 {
            return "Please move back\nIdeal distance: 55-60cm"
        } else {
            return "Please move closer\nIdeal distance: 55-60cm"
        }
    }
}


