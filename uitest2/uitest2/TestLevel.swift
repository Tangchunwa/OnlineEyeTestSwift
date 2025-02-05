import Foundation

struct TestLevel {
    static let logMarLetters = ["C", "D", "H", "K", "N", "O", "R", "S", "V", "Z"]
    
    let level: Int
    let letters: [String]
    let fontSize: CGFloat
    
    static func generateLevels() -> [TestLevel] {
        return (1...10).map { level in
            let letterCount: Int
            switch level {
            case 1, 2: letterCount = 1
            case 3, 4: letterCount = 2
            case 5, 6: letterCount = 3
            case 7, 8: letterCount = 4
            case 9, 10: letterCount = 5
            default: letterCount = 1
            }
            
            let letters = (0..<letterCount).map { _ in
                logMarLetters.randomElement()!
            }
            
            // Font size decreases as level increases
            // Starting from 100pt at level 1 down to 40pt at level 10
            let fontSize = 100.0 - (Double(level - 1) * 6.0)
            
            return TestLevel(level: level, letters: letters, fontSize: fontSize)
        }
    }
    
    var displayText: String {
        letters.joined(separator: " ")
    }
    
    var answer: String {
        letters.joined()
    }
}
