import SwiftUI

struct TestTransitionView: View {
    let completedTest: String
    let nextTest: String
    let onContinue: () -> Void
    
    // Add state for countdown timer
    @State private var timeRemaining: Int = 5
    @State private var isTimerRunning: Bool = true
    
    // Timer setup
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 使用可重用的漸變背景視圖
                GradientBackgroundView()
                
                // 主內容
                VStack(spacing: 30) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                        .padding(.top, 100)

                    // 標題與恭喜文字
                    Text("\("congratulations".localized) \(completedTest)!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                    
                    // 說明文字
                    VStack(spacing: 15) {
                        Text("\("next_test".localized) \(nextTest).")
                            .font(.headline)
                        
                        Text("transition_explanation".localized)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Countdown timer display
                    VStack(spacing: 10) {
                        Text("Starting next test in")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("\(timeRemaining)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 60)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.85))
                        .shadow(radius: 10)
                )
                .padding(.horizontal, 20)
            }
        }
        .onReceive(timer) { _ in
            if isTimerRunning {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    isTimerRunning = false
                    onContinue()
                }
            }
        }
    }
} 
