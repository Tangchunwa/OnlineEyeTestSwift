import SwiftUI
import Speech
import AVFoundation

struct LogMARTestView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var testManager = VisionTestManager()
    @StateObject private var faceDistanceManager = FaceDistanceManager()
    @State private var showingInstructions = true
    var onComplete: (() -> Void)?
    
    var body: some View {
        if showingInstructions {
            EyeTestInstructionsView(showingInstructions: $showingInstructions)
                .onDisappear {
                    // Start camera when instructions disappear (test starts)
                    faceDistanceManager.startCameraDetection()
                }
        } else if !testManager.testCompleted {
            VStack(spacing: 20) {
                
                // Title and current eye/level information
                VStack {
                    Text("vision_test".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(testManager.currentEye.description) \("eye".localized) - \("level".localized) \(testManager.currentLevel + 1)/5")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    // Eye coverage reminder
                    if(testManager.currentEye == .right){//test right eye first
                        EyeCoverageReminderView(currentEye: testManager.currentEye).onDisappear(
                            perform: {
                                //first close camera ,then set distance to 0,then send alert switch to right eye then open camera
                                faceDistanceManager.stopCameraDetection()
                                faceDistanceManager.distance=0
                                let alert = UIAlertController(title: "switch_to_left_eye".localized, message: "please_cover_right_eye".localized, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                    faceDistanceManager.startCameraDetection()
                                }))
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                        )}
                    else{EyeCoverageReminderView(currentEye: testManager.currentEye)
                        
                        
                        
                    }
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
                    Text("\("current_distance".localized): \(String(format: "%.2f", faceDistanceManager.distance))m")
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
                    if testManager.isRecording {
                        // Recording animation indicator
                        Text("listening".localized)
                            .foregroundColor(.red)
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
                    }
                }
                
                // Recording status and control button
                VStack(spacing: 15) {
      
                    
                    Button(action: {
                        testManager.toggleRecording()
                    }) {
                        HStack {
                            Image(systemName: testManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            Text(testManager.isRecording ? "stop_voice_input".localized : "start_voice_input".localized)
                        }
                        .font(.title2)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(testManager.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                
                // 提取 recognized 部分並單獨顯示，使其更加明顯
                if !testManager.recognizedText.isEmpty {
                    VStack(alignment: .center, spacing: 10) {
                        Text("recognized".localized)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text(testManager.recognizedText)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
                
                //Spacer()
                
                //Debug information area
                // VStack(alignment: .leading, spacing: 10) {
                //     Text("input_letters".localized)
                //         .font(.headline)
                //     TextField("enter_letters".localized, text: $testManager.userInput)
                //         .textFieldStyle(RoundedBorderTextFieldStyle())
                //         .autocapitalization(.allCharacters)
                    
                //     Button("confirm_answer".localized) {
                //         testManager.processInputText()
                //         testManager.userInput=""
                //     }
                //     .buttonStyle(.bordered)
                //     .disabled(testManager.userInput.isEmpty)
                // }
                // .padding()
                // .background(Color.gray.opacity(0.1))
                // .cornerRadius(10)

            }
            .padding()
            .onAppear {
                testManager.checkPermissions()
                testManager.updateCurrentLetters() 
            }
            .onDisappear{
                faceDistanceManager.stopCameraDetection()
                testManager.stopRecording()
            }
        } else {
            // When test is completed, immediately call onComplete
            ZStack {
                // 使用漸變背景代替純白色背景
                GradientBackgroundView()
                
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                        .padding(.bottom, 10)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    
                    Text("preparing_next_test".localized)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.6))
                        .padding(.top, 10)
                        
                    Text("processing_results".localized)
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
                // 停止相機和錄音
                faceDistanceManager.stopCameraDetection()
                testManager.stopRecording()
                
                // 短暫延遲後調用 onComplete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete?()
                }
            }
        }
    }
    
    private func getDistanceMessage() -> String {
        if faceDistanceManager.distance < 0.55 {
            return "please_move_back".localized
        } else {
            return "please_move_closer".localized
        }
    }
}

// New Instructions View
struct EyeTestInstructionsView: View {
    @Binding var showingInstructions: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 使用可重用的漸變背景視圖
                GradientBackgroundView()
                
                // 主內容
                VStack(spacing: 30) {
                    Text("vision_test_instructions".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.6))
                    
                    VStack(alignment: .leading, spacing: 20) {
                        InstructionStep(
                            number: 1,
                            title: "prepare_environment".localized,
                            description: "find_well_lit_room".localized
                        )
                        
                        InstructionStep(
                            number: 2,
                            title: "distance".localized,
                            description: "position_distance".localized
                        )
                        
                        InstructionStep(
                            number: 3,
                            title: "right_eye_test".localized,
                            description: "cover_left_eye".localized
                        )
                        
                        InstructionStep(
                            number: 4,
                            title: "left_eye_test".localized,
                            description: "after_right_eye".localized
                        )
                        
                        InstructionStep(
                            number: 5,
                            title: "voice_input".localized,
                            description: "speak_letters".localized
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
                        HStack(spacing: 15) {
                            Text("start_test".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .frame(minWidth: 220, minHeight: 55)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.5, blue: 0.9),
                                    Color(red: 0.3, green: 0.6, blue: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
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
            
            Text(currentEye == .right ? "please_cover_left_eye".localized : "please_cover_right_eye".localized)
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
