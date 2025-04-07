import SwiftUI

struct TestTransitionView: View {
    let completedTest: String
    let nextTest: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
                .padding()

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
            
            // 繼續按鈕
            Button(action: onContinue) {
                Text("continue_next_test".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 230, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom, 50)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
} 