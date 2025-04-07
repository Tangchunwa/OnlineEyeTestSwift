import SwiftUI

struct MacularDegenerationTestView: View {
    @State private var result = ""
    @State private var selectedOption: String?
    @State private var isTransitioning = false
    var onComplete: (() -> Void)?
    
    // 這裡應該同時提供英文和中文的選項，根據當前語言選擇
    var options: [String] {
        if LocalizationManager.shared.currentLanguage == .chinese {
            return [
                "所有線條都是直的",
                "部分線條出現彎曲",
                "部分線條缺失",
                "我看到暗淡或模糊的區域",
                "線條看起來變形"
            ]
        } else {
            return [
                "All lines appear straight",
                "Some lines appear wavy",
                "Some lines are missing",
                "I see dark or blurry areas",
                "The lines look distorted"
            ]
        }
    }
    
    var body: some View {
        if isTransitioning {
            // 顯示過渡畫面
            Color.white.overlay(
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    
                    Text("preparing_next_test".localized)
                        .font(.headline)
                        .padding()
                }
            )
            .onAppear {
                // 短暫延遲後調用 onComplete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete?()
                }
            }
        } else {
            VStack(spacing: 25) {
                Text("macular_test".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Amsler Grid Test")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                // Amsler 格線圖像
                ZStack {
                    Image("amsler_grid")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }
                .padding(.vertical)
                
                Text("macular_explanation".localized)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // 選項列表
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(options, id: \.self) { option in
                        HStack {
                            Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedOption == option ? .blue : .gray)
                            
                            Text(option)
                                .font(.body)
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        .onTapGesture {
                            handleOptionTap(option)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
        }
    }
    
    private func handleOptionTap(_ option: String) {
        selectedOption = option
        
        // 根據選擇設置結果
        if option == options[0] { // 所有線條都是直的 / All lines appear straight
            result = LocalizationManager.shared.currentLanguage == .chinese ? 
                "正常，未檢測到黃斑部問題。" : 
                "Normal, no macular issues detected."
        } else {
            result = LocalizationManager.shared.currentLanguage == .chinese ? 
                "可能有黃斑部問題，建議進一步檢查。" : 
                "Possible macular issues, further examination recommended."
        }
        
        // 保存測試選擇和結果
        UserDefaults.standard.set(option, forKey: "MacularTestOption")
        UserDefaults.standard.set(result, forKey: "MacularTestResult")
        
        // 設置過渡
        isTransitioning = true
    }
}
