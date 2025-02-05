import SwiftUI

struct ColorBlindnessTestView: View {
    @State private var currentPhotoIndex = 0
    @State private var result = ""
    @State private var score = 0
    
    let photos = [
        (image: "colorblind_test_1", correctAnswer: "74"),
        (image: "colorblind_test_2", correctAnswer: "26"),
        (image: "colorblind_test_3", correctAnswer: "12")
    ]
    
    let choices = [
        ["74", "21", "45", "78", "No number"],
        ["6", "8", "3", "26", "No number"],
        ["12", "17", "11", "51", "No number"]
    ]
    
    var body: some View {
        VStack {
            Text("Color Blindness Test")
                .font(.largeTitle)
            
            if currentPhotoIndex < photos.count {
                Image(photos[currentPhotoIndex].image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                Text("What number do you see in the image?")
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
                Text("Test Complete")
                    .font(.title)
                    .padding()
                
                Text("Your score: \(score) out of \(photos.count)")
                    .font(.headline)
                
                Text(result)
                    .padding()
                
                Button("Restart Test") {
                    restartTest()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
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
            result = "Your color vision appears normal."
        } else if score >= photos.count / 2 {
            result = "You may have mild color vision deficiency. Please consult an eye care professional."
        } else {
            result = "You may have significant color vision deficiency. Please consult an eye care professional."
        }
    }
    
    func restartTest() {
        currentPhotoIndex = 0
        score = 0
        result = ""
    }
}