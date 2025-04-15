import SwiftUI

struct TestTransitionView: View {
    let completedTest: String
    let nextTest: String
    let onContinue: () -> Void
    
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
                    
                    // 繼續按鈕 - 使用 GradientButton 替換原來的按鈕
                    GradientButton(
                        text: "continue_next_test".localized,
                        icon: "arrow.right.circle.fill",
                        action: onContinue
                    )
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
    }
} 