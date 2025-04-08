import SwiftUI

struct TestResultsView: View {
    @AppStorage("username") private var username = ""
    @State private var showingReportCard = false
    
    // 從 UserDefaults 獲取黃斑部測試結果
    private var macularTestOption: String {
        UserDefaults.standard.string(forKey: "MacularTestOption") ?? "未完成"
    }
    
    private var macularTestResult: String {
        UserDefaults.standard.string(forKey: "MacularTestResult") ?? "無結果數據"
    }
    
    // 從 UserDefaults 獲取色盲測試結果
    private var colorTestScore: Int {
        UserDefaults.standard.integer(forKey: "ColorTestScore")
    }
    
    private var colorTestTotal: Int {
        UserDefaults.standard.integer(forKey: "ColorTestTotal")
    }
    
    private var colorTestResult: String {
        UserDefaults.standard.string(forKey: "ColorTestResult") ?? "無結果數據"
    }
    // Convert LogMAR to decimal acuity
    private func getDecimalAcuity(from logMAR: Double) -> Double {
        return pow(10, -logMAR)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("\("test_results_for".localized) \(username)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 1. Vision Test Results
                VisionTestResultView(
                    rightEyeLogMAR: VisionTestManager.rightEyeLogMAR,
                    leftEyeLogMAR: VisionTestManager.leftEyeLogMAR
                )
                
                // 2. Macular Test Results
                TestCard(title: "macular_test".localized) {
                    VStack(alignment: .leading, spacing: 10) {
                        if macularTestOption != "未完成" {
                            Text("\("your_selection".localized) \(macularTestOption)")
                                .font(.subheadline)
                            
                            Text("\("result".localized) ")
                                .font(.headline) +
                            Text(macularTestResult)
                                .font(.body)
                                .foregroundColor(macularTestOption == "All lines appear straight" ? .green : .orange)
                        } else {
                            Text("no_data".localized)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 3. Color Test Results
                TestCard(title: "color_test".localized) {
                    VStack(alignment: .leading, spacing: 10) {
                        if colorTestTotal > 0 {
                            Text("\("your_score".localized) \(colorTestScore) \("out_of".localized) \(colorTestTotal)")
                                .font(.subheadline)
                            
                            HStack {
                                Text("\("performance".localized) ")
                                    .font(.headline)
                                
                                if colorTestScore == colorTestTotal {
                                    Text("excellent".localized)
                                        .foregroundColor(.green)
//                                } else if colorTestScore >= colorTestTotal / 2 {
//                                    Text("acceptable".localized)
//                                        .foregroundColor(.blue)
                                } else {
                                    Text("needs_attention".localized)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Text(colorTestResult)
                                .font(.body)
                                .padding(.top, 5)
                        } else {
                            Text("no_data".localized)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 4. 測試說明資訊
                VStack(alignment: .leading, spacing: 15) {
                    Text("understanding_results".localized)
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    InfoRow(
                        title: "LogMAR Test",
                        description: "decimal_acuity_explanation".localized
                    )
                    
                    InfoRow(
                        title: "Macular Test",
                        description: "macular_explanation".localized
                    )
                    
                    InfoRow(
                        title: "Color Test",
                        description: "color_explanation".localized
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
                
                // 5. 測試信息和日期
                VStack(alignment: .leading, spacing: 10) {
                    Text("test_information".localized)
                        .font(.headline)
                    
                    Text("\("test_date".localized) \(formatDate(Date()))")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // 6. 建議
                VStack(spacing: 15) {
                    Text("recommendations".localized)
                        .font(.headline)
                    
                    Text("consultation_advice".localized)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .padding()
                
                // 保存結果按鈕
                Button(action: {
                    showingReportCard = true
                }) {
                    Text("save_results".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                // 重新測試按鈕
                Button(action: {
                    // Reset and start over
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    
                    // 清除所有測試結果
                    UserDefaults.standard.removeObject(forKey: "MacularTestOption")
                    UserDefaults.standard.removeObject(forKey: "MacularTestResult")
                    UserDefaults.standard.removeObject(forKey: "ColorTestScore")
                    UserDefaults.standard.removeObject(forKey: "ColorTestTotal")
                    UserDefaults.standard.removeObject(forKey: "ColorTestResult")
                }) {
                    Text("start_new_test".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.white)
        .sheet(isPresented: $showingReportCard) {
            ReportCardView(
                username: username,
                rightEyeAcuity: getDecimalAcuity(from: VisionTestManager.rightEyeLogMAR),
                leftEyeAcuity: getDecimalAcuity(from: VisionTestManager.leftEyeLogMAR),
                macularTestOption: macularTestOption,
                macularTestResult: macularTestResult,
                colorTestScore: colorTestScore,
                colorTestTotal: colorTestTotal,
                colorTestResult: colorTestResult,
                isPresented: $showingReportCard
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TestCard<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
            
            content()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

//extension VisionTestManager {
//    static let shared = VisionTestManager()
//}

// 照片保存協調器，處理 UIKit 回調
class ImageSaver: NSObject {
    var completionHandler: ((Bool, Error?) -> Void)?
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completionHandler?(error == nil, error)
    }
}

struct ReportCardView: View {
    let username: String
    let rightEyeAcuity: Double
    let leftEyeAcuity: Double
    let macularTestOption: String
    let macularTestResult: String
    let colorTestScore: Int
    let colorTestTotal: Int
    let colorTestResult: String
    @Binding var isPresented: Bool
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var showingShareSheet = false
    @State private var reportImage: UIImage? = nil
    @State private var showingSaveAlert = false
    @State private var saveError: String? = nil
    @State private var isSaving = false
    // 保持 ImageSaver 的引用
    @State private var imageSaver = ImageSaver()
    
    var body: some View {
        VStack(spacing: 0) {
            // 工具欄
            HStack {
                Button("close".localized) {
                    isPresented = false
                }
                Spacer()
                Button(action: {
                    if !isSaving {
                        saveReportAsImage()
                    }
                }) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("save_image".localized)
                    }
                }
                .disabled(isSaving)
            }
            .padding()
            
            // 報告卡片
            reportCard
                .background(Color.white)
        }
        .alert(isPresented: $showingSaveAlert) {
            if let error = saveError {
                return Alert(
                    title: Text("save_error".localized),
                    message: Text(error),
                    dismissButton: .default(Text("OK"))
                )
            } else {
                return Alert(
                    title: Text("save_success".localized),
                    message: Text("image_saved_to_photos".localized),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // 報告卡片視圖
    private var reportCard: some View {
        VStack(spacing: 20) {
            // 標題和日期
            VStack(spacing: 5) {
                Text("vision_test_report".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(formatDate(Date()))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(username)
                    .font(.headline)
            }
            .padding(.top)
            
            Divider()
            
            // 視力測試結果摘要
            VStack(alignment: .leading, spacing: 10) {
                Text("vision_test".localized)
                    .font(.headline)
                
                HStack {
                    Text("\("right_eye".localized):  \(rightEyeAcuity <= 0.33 ? "N/A" : String(format: "%.2f", rightEyeAcuity))")
                    Spacer()
                    StatusIndicator(value: rightEyeAcuity, threshold: 0.5)
                }

                HStack {
                    Text("\("left_eye".localized):  \(leftEyeAcuity <= 0.33 ? "N/A" : String(format: "%.2f", leftEyeAcuity))")
                    Spacer()
                    StatusIndicator(value: leftEyeAcuity, threshold: 0.5)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // 黃斑部測試結果摘要
            VStack(alignment: .leading, spacing: 10) {
                Text("macular_test".localized)
                    .font(.headline)
                
                if macularTestOption != "未完成" {
                    Text("\("result".localized) \(macularTestResult)")
                        .foregroundColor(macularTestOption == "All lines appear straight" ? .green : .orange)
                } else {
                    Text("no_data".localized)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // 色盲測試結果摘要
            VStack(alignment: .leading, spacing: 10) {
                Text("color_test".localized)
                    .font(.headline)
                
                if colorTestTotal > 0 {
                    Text("\("score".localized): \(colorTestScore)/\(colorTestTotal)")
                    
                    HStack {
                        if colorTestScore == colorTestTotal {
                            Circle().fill(Color.green).frame(width: 10, height: 10)
                            Text("excellent".localized)
//                        } else if colorTestScore < colorTestTotal / 2 {
//                            Circle().fill(Color.blue).frame(width: 10, height: 10)
//                            Text("acceptable".localized)
                        } else {
                            Circle().fill(Color.red).frame(width: 10, height: 10)
                            Text("needs_attention".localized)
                        }
                    }
                } else {
                    Text("no_data".localized)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            // 免責聲明
            Text("disclaimer".localized)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40, height: 600)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
    
    // 保存報告為圖片
    private func saveReportAsImage() {
        isSaving = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 650))
            
            let image = renderer.image { context in
                // 轉換 SwiftUI 視圖為 UIView
                let hostingController = UIHostingController(rootView: reportCard.background(Color.white))
                hostingController.view.frame = renderer.format.bounds
                hostingController.view.backgroundColor = .white
                hostingController.view.drawHierarchy(in: renderer.format.bounds, afterScreenUpdates: true)
            }
            
            // 更新狀態以便分享
            self.reportImage = image
            
            // 設置完成處理程序
            imageSaver.completionHandler = { success, error in
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.showingSaveAlert = true
                    
                    if let error = error {
                        self.saveError = error.localizedDescription
                    } else {
                        self.saveError = nil
                    }
                }
            }
            
            // 保存圖片到相冊，使用我們的回調
            UIImageWriteToSavedPhotosAlbum(image, imageSaver, #selector(ImageSaver.saveCompleted), nil)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// 狀態指示器組件
struct StatusIndicator: View {
    let value: Double
    let threshold: Double
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { i in
                Circle()
                    .fill(self.circleColor(for: i))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private func circleColor(for index: Int) -> Color {
        // Normalize value between 0 and 1
        let normalizedValue = min(1.0, max(0.0, value))
        
        // Calculate how many circles should be filled
        let filledCircles = (normalizedValue * 4.0).rounded() + 1  // Multiply by 4 since we want 5 steps (0, 0.25, 0.5, 0.75, 1.0)
        
        // First determine if the circle should be filled
        let shouldBeFilled = Double(index) < filledCircles
        
        if shouldBeFilled {
            // If the value is below threshold, use red; otherwise use green
            return normalizedValue < threshold ? .red : .green
        } else {
            return .gray
        }
    }
}
