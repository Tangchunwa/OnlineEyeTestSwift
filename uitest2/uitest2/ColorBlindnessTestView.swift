import SwiftUI

struct ColorBlindnessTestView: View {
    @State private var currentPhotoIndex = 0
    @State private var result = ""
    @State private var score = 0
    @State private var isTransitioning = false
    var onComplete: (() -> Void)?
    
    let photos = [
        (image: "colorblind_test_1", correctAnswer: "74"),
        (image: "colorblind_test_2", correctAnswer: "26"),
        (image: "colorblind_test_3", correctAnswer: "12")
    ]
    
    var choices: [[String]] {
        let noNumber = "No number".localized
        return [
            ["74", "21", "45", "78", noNumber],
            ["6", "8", "3", "26", noNumber],
            ["12", "17", "11", "51", noNumber]
        ]
    }
    
    var body: some View {
        if isTransitioning {
            // 顯示過渡畫面
            Color.white.overlay(
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    
                    Text("all_tests_completed".localized)
                        .font(.headline)
                        .padding()
                }
            )
            .onAppear {
                // 短暫延遲後调用 onComplete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete?()
                }
            }
        } else {
            VStack(spacing: 20) {
                Text("color_test".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if currentPhotoIndex < photos.count {
                    Image(photos[currentPhotoIndex].image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                    
                    Text("What number do you see in the image?".localized)
                        .padding()
                    
                    ForEach(choices[currentPhotoIndex], id: \.self) { choice in
                        Button(action: {
                            checkAnswer(choice)
                        }) {
                            Text(choice)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // 顯示過渡畫面
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        
                        Text("processing_results".localized)
                            .font(.headline)
                            .padding()
                    }
                    .onAppear {
                        // 自動進入結果頁面
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isTransitioning = true
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
        }
    }
    
    func checkAnswer(_ selectedAnswer: String) {
        if selectedAnswer == photos[currentPhotoIndex].correctAnswer {
            score += 1
        }
        
        currentPhotoIndex += 1
        
        if currentPhotoIndex == photos.count {
            calculateResult()
        }
    }
    
    func calculateResult() {
        if score == photos.count {
            result = LocalizationManager.shared.currentLanguage == .chinese ? 
                "正常色覺。您能夠正確識別所有圖像，無明顯色盲/色弱跡象。" : 
                "Your color vision appears normal."
        } else if score >= photos.count / 2 {
            result = LocalizationManager.shared.currentLanguage == .chinese ? 
                "輕度色弱。您未能識別所有圖像，可能有輕度色覺異常。" : 
                "You may have mild color vision deficiency. Please consult an eye care professional."
        } else {
            result = LocalizationManager.shared.currentLanguage == .chinese ? 
                "明顯色盲/色弱。您識別正確的圖像較少，表明可能存在色覺問題。建議尋求專業檢查。" : 
                "You may have significant color vision deficiency. Please consult an eye care professional."
        }
        
        // 保存結果到 UserDefaults
        UserDefaults.standard.set(score, forKey: "ColorTestScore")
        UserDefaults.standard.set(photos.count, forKey: "ColorTestTotal")
        UserDefaults.standard.set(result, forKey: "ColorTestResult")
    }
}