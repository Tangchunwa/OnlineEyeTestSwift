import SwiftUI

struct MacularDegenerationTestView: View {
    @State private var result = ""
    @State private var showResult = false
    @State private var selectedOption: String?
    
    let options = [
        "All lines appear straight",
        "Some lines appear wavy",
        "Some lines are missing",
        "I see dark or blurry areas",
        "The lines look distorted"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Macular Degeneration Test")
                .font(.title)
                .multilineTextAlignment(.center)
            
            if !showResult {
                Image("amsler_grid")  // Replace "amsler_grid" with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                
                Text("How do the grid lines appear to you?")
                    .font(.headline)
                
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        checkResult(option)
                        showResult = true
                    }) {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Text("Test Complete")
                    .font(.title)
                    .padding()
                
                Text(result)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Button("Take Test Again") {
                    resetTest()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func checkResult(_ selectedOption: String) {
        switch selectedOption {
        case "All lines appear straight":
            result = "Your test result appears normal. However, regular eye check-ups are still recommended."
        default:
            result = "Based on your selection, it's advisable to consult an eye care professional for a comprehensive evaluation. Changes in how you see the Amsler grid can be a sign of macular degeneration or other eye conditions."
        }
    }
    
    func resetTest() {
        selectedOption = nil
        result = ""
        showResult = false
    }
}
