import SwiftUI

struct ColorBlindnessTestView: View {
    @State private var currentPhotoIndex = 0
    @State private var result = ""
    @State private var score = 0
    @State private var userAnswers: [String] = []
    
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
        VStack {
            Text("Color Blindness Test")
                .font(.system(size: 34, weight: .bold))
                .padding()
            
            if currentPhotoIndex < photos.count {
                Image(photos[currentPhotoIndex].image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFill()
                    .frame(width: 280, height: 280)
                    .clipped()
                    .padding()
                
                Text("What number do you see in the image?")
                    .font(.system(size: 28))
                    .padding()
                
                // 將目前的選項拆分為一般選項與 "No number"
                let currentChoices = choices[currentPhotoIndex]
                let optionChoices = currentChoices.filter { $0 != "No number" }
                let noNumberChoice = currentChoices.first(where: { $0 == "No number" })
                
                VStack(spacing: 16) {
                    // 每列放置兩個選項
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
                    
                    // 將 "No number" 按鈕作為單獨一列全寬顯示
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
                VStack(spacing: 16) {
                    Text("Test Complete")
                        .font(.system(size: 34, weight: .bold))
                        .padding()
                    
                    Text("Your score: \(score) out of \(photos.count)")
                        .font(.system(size: 28))
                    
                    Text(result)
                        .font(.system(size: 28))
                        .padding()
                    
                    Button("Restart Test") {
                        restartTest()
                    }
                    .font(.system(size: 28))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
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
        let answer14 = userAnswers.indices.contains(11) ? userAnswers[11] : ""
        let answer15 = userAnswers.indices.contains(12) ? userAnswers[12] : ""
        let redGreenFlag = (answer14 == "5" && answer15 == "45")
        
        if redGreenFlag {
            result = "Your answers suggest possible red-green color vision deficiency. Please consult an eye care professional."
        } else if score >= 13 {
            result = "Your color vision appears normal."
        } else if score <= 9 {
            result = "You may have a color vision deficiency. Please consult an eye care professional."
        } else {
            result = "Your results are inconclusive. Further testing with a professional is recommended."
        }
    }
    
    func restartTest() {
        currentPhotoIndex = 0
        score = 0
        result = ""
        userAnswers = []
    }
}
