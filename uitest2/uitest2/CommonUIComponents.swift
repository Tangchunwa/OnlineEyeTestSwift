import SwiftUI

// 可重用的漸變背景視圖
struct GradientBackgroundView: View {
    @State private var animateCircles = false
    
    var body: some View {
        ZStack {
            // 靜態背景漸變
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.99, green: 0.99, blue: 0.99),
                    Color(red: 0.85, green: 0.9, blue: 0.98),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // 動態背景元素 - 只有圓形在動
            VStack {
                HStack {
                    // 左上角圓形
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.1),
                                    Color.blue.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .offset(x: animateCircles ? -25 : -40, y: animateCircles ? -15 : -30)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    // 右下角圓形
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.3, green: 0.6, blue: 0.9).opacity(0.15),
                                    Color(red: 0.4, green: 0.7, blue: 0.9).opacity(0.25)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 150)
                        .offset(x: animateCircles ? 40 : 55, y: animateCircles ? 35 : 20)
                }
            }
            .animation(
                Animation.easeInOut(duration: 7)
                    .repeatForever(autoreverses: true),
                value: animateCircles
            )
            .onAppear {
                // 啟動圓形動畫
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    animateCircles = true
                }
            }
        }
    }
}

// 通用的漸變按鈕樣式
struct GradientButton: View {
    var text: String
    var icon: String? = nil
    var action: () -> Void
    var disabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
            }
            .frame(minWidth: 220, minHeight: 55)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        disabled ? Color.gray.opacity(0.6) : Color(red: 0.2, green: 0.5, blue: 0.9),
                        disabled ? Color.gray.opacity(0.5) : Color(red: 0.3, green: 0.6, blue: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: disabled ? Color.clear : Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(disabled)
    }
}
