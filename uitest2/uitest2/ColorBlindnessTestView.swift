import SwiftUI

struct ColorBlindnessTestView: View {
    @State private var currentPhotoIndex = 0
    @State private var result = ""
    @State private var score = 0
    @State private var userAnswers: [String] = []
    @State private var isTransitioning = false
    var onComplete: (() -> Void)?
    
    
    let photos = [
        (image: "Ishihara_Tests-03", correctAnswer: "12"),
        (image: "Ishihara_Tests-04", correctAnswer: "8"),
        (image: "Ishihara_Tests-05", correctAnswer: "29"),
        (image: "Ishihara_Tests-06", correctAnswer: "5"),
        (image: "Ishihara_Tests-07", correctAnswer: "3"),
        (image: "Ishihara_Tests-08", correctAnswer: "15"),
        (image: "Ishihara_Tests-09", correctAnswer: "74"),
        (image: "Ishihara_Tests-10", correctAnswer: "6"),
        (image: "Ishihara_Tests-11", correctAnswer: "45"),
        (image: "Ishihara_Tests-12", correctAnswer: "5"),
        (image: "Ishihara_Tests-13", correctAnswer: "7"),
        (image: "Ishihara_Tests-14", correctAnswer: "16"),
        (image: "Ishihara_Tests-15", correctAnswer: "73"),
        (image: "Ishihara_Tests-16", correctAnswer: "No number"),
        (image: "Ishihara_Tests-17", correctAnswer: "No number")
    ]
    
    let choices = [
        ["29", "8", "12", "17", "No number"],
        ["3", "6", "15", "8", "No number"],
        ["12", "29", "74", "45", "No number"],
        ["6", "3", "5", "8", "No number"],
        ["8", "7", "3", "5", "No number"],
        ["15", "13", "12", "17", "No number"],
        ["23", "29", "74", "45", "No number"],
        ["5", "6", "3", "8", "No number"],
        ["45", "17", "74", "29", "No number"],
        ["3", "7", "5", "6", "No number"],
        ["7", "9", "12", "2", "No number"],
        ["16", "15", "12", "19", "No number"],
        ["62", "73", "45", "29", "No number"],
        ["6", "17", "5", "19", "No number"],
        ["45", "53", "4", "72", "No number"]
    ]
    
    var body: some View {
        if isTransitioning {
            // 过渡画面保持不变…
            ZStack {
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

                    Text("all_tests_completed".localized)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.6))
                        .padding(.top, 10)

                    Text("preparing_results".localized)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete?()
                }
            }
        } else {
            VStack {
                // 标题
                Text("color_test".localized)  // 或直接 "Color Blindness Test"
                    .font(.system(size: 34, weight: .bold))
                    .padding()

                if currentPhotoIndex < photos.count {
                    // 图像
                    Image(photos[currentPhotoIndex].image)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFill()
                        .frame(width: 280, height: 280)
                        .clipped()
                        .padding()

                    // 问题
                    Text("What number do you see in the image?".localized)
                        .font(.system(size: 28))
                        .padding()

                    // 拆分选项
                    let currentChoices = choices[currentPhotoIndex]
                    let optionChoices = currentChoices.filter { $0 != "No number" }
                    let noNumberChoice = currentChoices.first(where: { $0 == "No number" })

                    // 选项网格
                    VStack(spacing: 16) {
                        ForEach(0..<optionChoices.count/2, id: \.self) { row in
                            HStack(spacing: 16) {
                                let leftIndex = row * 2
                                let rightIndex = leftIndex + 1

                                Button(action: {
                                    checkAnswer(optionChoices[leftIndex])
                                }) {
                                    Text(optionChoices[leftIndex])
                                        .font(.system(size: 42))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }

                                Button(action: {
                                    checkAnswer(optionChoices[rightIndex])
                                }) {
                                    Text(optionChoices[rightIndex])
                                        .font(.system(size: 42))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // “No number” 单独一行
                        if let noNum = noNumberChoice {
                            Button(action: {
                                checkAnswer(noNum)
                            }) {
                                Text(noNum)
                                    .font(.system(size: 42))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                } else {
                    // 如果用 isTransitioning 处理“完成”逻辑，这里可留空
                }
            }
            .padding()
            .background(Color.white)
        }
    }
    
    func checkAnswer(_ selectedAnswer: String) {
        userAnswers.append(selectedAnswer)
        
        if selectedAnswer == photos[currentPhotoIndex].correctAnswer {
            score += 1
        }
        
        currentPhotoIndex += 1
        
        if currentPhotoIndex == photos.count {
            calculateResult()
        }
    }
    
    func calculateResult() {
        let answer14 = userAnswers.indices.contains(13) ? userAnswers[13] : ""
        let answer15 = userAnswers.indices.contains(14) ? userAnswers[14] : ""
        let redGreenFlag = (answer14 == "5" || answer15 == "45")
        let isChinese = LocalizationManager.shared.currentLanguage == .chinese
        
        if redGreenFlag {
            result = isChinese ?
                "您的答案顯示可能存在紅綠色覺缺陷。請諮詢眼科專業人員。" :
                "Your answers suggest possible red-green color vision deficiency. Please consult an eye care professional."
        } else if score >= 15 {
            result = isChinese ?
                "您的色覺正常。" :
                "Your color vision appears normal."
        } else if score <= 9 {
            result = isChinese ?
                "您可能有色覺缺陷。請諮詢眼科專業人員。" :
                "You may have a color vision deficiency. Please consult an eye care professional."
        } else {
            result = isChinese ?
                "您的結果不確定。建議進一步專業測試。" :
                "Your results are inconclusive. Further testing with a professional is recommended."
        }
        
        // 保存結果到 UserDefaults
        UserDefaults.standard.set(score, forKey: "ColorTestScore")
        UserDefaults.standard.set(photos.count, forKey: "ColorTestTotal")
        UserDefaults.standard.set(result, forKey: "ColorTestResult")
        
        // 直接設置 isTransitioning 為 true，跳過中間過渡畫面
        isTransitioning = true
    }
}


    #Preview {
        ColorBlindnessTestView(onComplete: {
            print("Test completed")
        })
    }

    // Or using the traditional PreviewProvider style:
    struct ColorBlindnessTestView_Previews: PreviewProvider {
        static var previews: some View {
            ColorBlindnessTestView(onComplete: {
                print("Test completed")
            })
        }
        
    

}
