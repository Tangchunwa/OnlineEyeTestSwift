import SwiftUI
import Combine

// 支持的語言
enum AppLanguage: String, CaseIterable {
    case english = "English"
    case chinese = "繁體中文"
    
    var code: String {
        switch self {
        case .english: return "en"
        case .chinese: return "zh"
        }
    }
}

// 語言管理器
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }
    
    private init() {
        // 從 UserDefaults 讀取語言設置，如果沒有設置，則默認為英文
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language") ?? AppLanguage.english.rawValue
        currentLanguage = AppLanguage(rawValue: savedLanguage) ?? .english
    }
    
    // 獲取翻譯文本
    func localized(_ key: String) -> String {
        return LocalizedStringKey.localizedStringDictionary[currentLanguage.code]?[key] ?? key
    }
}

// 存儲所有翻譯的字典
struct LocalizedStringKey {
    // 英文翻譯
    static let english: [String: String] = [
        // Welcome Page
        "welcome_title": "Visual Test",
        "welcome_intro": "This is an eye test application developed in collaboration with HKUST and hospitals.",
        "welcome_testing_intro": "You will take three tests: Vision Test (LogMAR), Macular Test, and Color Test, which can be completed in about 10 minutes.",
        "enter_name": "Enter your name",
        "start": "Start",
        
        // Terms
        "terms_title": "Terms of Agreement",
        "terms_content": "By using this application, you agree to the following terms and conditions:\n\n1. **Acceptance of Terms**: By accessing or using this application, you agree to be bound by these Terms of Agreement and any updates posted within the application.\n\n2. **User Conduct**: You agree to use the application only for lawful purposes. You will not engage in any activity that disrupts or interferes with the application's functionality or security.\n\n3. **Intellectual Property**: All content, logos, and materials within the application are owned by or licensed to us. You may not reproduce, distribute, or modify any content without prior written consent.\n\n4. **Privacy**: Your use of the application is subject to our Privacy Policy, which outlines how we collect, use, and protect your data.\n\n5. **Termination**: We reserve the right to suspend or terminate your access to the application at any time, with or without notice, for any violation of these terms.\n\n6. **Disclaimer**: The application is provided 'as is' without warranties of any kind. We are not liable for any damages arising from your use of the application.\n\n7. **Changes to Terms**: We may update these terms from time to time. Continued use of the application after changes constitutes acceptance of the new terms.\n\nPlease read carefully before proceeding.",
        "i_agree": "I have read and agree to the Terms of Agreement and Privacy Policy",
        "next": "Next",
        
        // Permissions
        "permission_required": "Permission Required",
        "app_needs_access": "This app needs access to:",
        "speech_recognition": "Speech Recognition",
        "camera": "Camera",
        "grant_permissions": "Grant Permissions",
        "permission_explanation": "These permissions are required to perform the vision tests accurately.",
        
        // Transitions
        "congratulations": "Congratulations on completing the",
        "next_test": "Next, you will take the",
        "transition_explanation": "Please follow the instructions for the next test to help assess your visual health comprehensively.",
        "continue_next_test": "Continue to Next Test",
        "preparing_next_test": "Preparing for the next test...",
        "processing_results": "Processing your results...",
        "preparing_results": "Preparing your final report...",
        "analyzing_color_vision": "Analyzing your color vision test results...",
        "all_tests_completed": "All tests completed, processing results...",
        
        // Test Names
        "vision_test": "Vision Test",
        "macular_test": "Macular Test",
        "color_test": "Color Test",
        
        // Results
        "test_results_for": "Test Results for",
        "your_selection": "Your selection:",
        "result": "Result:",
        "your_score": "Your score:",
        "out_of": "out of",
        "performance": "Performance:",
        "excellent": "Excellent",
        "acceptable": "Acceptable",
        "needs_attention": "Needs Attention",
        "no_data": "No data available",
        
        // Understanding Results
        "understanding_results": "Understanding Your Results",
        "logmar_explanation": "Measures visual acuity. Lower values indicate better vision. Normal vision has a LogMAR value close to 0.",
        "decimal_acuity_explanation": "Represents visual acuity in decimal form. A value of 1.0 indicates normal vision , while lower values indicate poorer vision.",
        "macular_explanation": "Detects early signs of macular degeneration. If grid lines appear bent or distorted, further examination may be needed.",
        "color_explanation": "Assesses color vision ability. Inability to identify specific numbers may indicate color blindness or deficiency.",
        
        // Test Info
        "test_information": "Test Information",
        "test_date": "Test Date:",
        
        // Recommendations
        "recommendations": "Recommendations",
        "consultation_advice": "Please consult with an eye care professional for a comprehensive examination if any issues were detected.",
        
        // Buttons
        "start_new_test": "Start New Test",
        "continue": "Continue",
        "view_results": "View Results",
        
        // Color Blindness Test
        "What number do you see in the image?": "What number do you see in the image?",
        "your_answer": "Your answer",
        "No number": "No number",
        
        // Vision Test View
        "eye": "Eye",
        "level": "Level",
        "switch_to_left_eye": "Switch to Left Eye",
        "please_cover_right_eye": "Please cover your RIGHT eye",
        "please_cover_left_eye": "Please cover your LEFT eye",
        "current_distance": "Current Distance",
        "listening": "Listening",
        "start_voice_input": "Start Voice Input",
        "stop_voice_input": "Stop Voice Input",
        "input_letters": "Input letters:",
        "enter_letters": "Enter letters",
        "confirm_answer": "Confirm Answer",
        "recognized": "Recognized",
        "please_move_back": "Please move back\nIdeal distance: 55-60cm",
        "please_move_closer": "Please move closer\nIdeal distance: 55-60cm",
        
        // Vision Test Instructions
        "vision_test_instructions": "Vision Test Instructions",
        "prepare_environment": "Prepare Your Environment",
        "find_well_lit_room": "Find a well-lit room and ensure you're in a comfortable position.",
        "distance": "Distance",
        "position_distance": "Position yourself 55-60cm from the screen.",
        "right_eye_test": "Right Eye Test",
        "cover_left_eye": "Cover your LEFT eye completely with your palm or an eye patch.",
        "left_eye_test": "Left Eye Test",
        "after_right_eye": "After completing the right eye test, you'll be prompted to cover your RIGHT eye.",
        "voice_input": "Voice Input",
        "speak_letters": "Speak the letters you see clearly and confidently.",
        "start_test": "Start Test",
        
        // Vision Test Results
        "vision_test_results": "Vision Test Results",
        "right_eye": "Right Eye",
        "left_eye": "Left Eye",
        "logmar_value": "LogMAR Value",
        "decimal_acuity": "Decimal Acuity",
        "snellen_notation": "Snellen Notation",
        "vision_quality": "Vision Quality",
        "normal_or_better": "Normal or Better",
        "mild_vision_loss": "Mild Vision Loss",
        "moderate_vision_loss": "Moderate Vision Loss",
        "severe_vision_loss": "Severe Vision Loss",
        "invalid": "Invalid",
        
        // Report Card
        "save_results": "Save Results",
        "close": "Close",
        "save_image": "Save Image",
        "vision_test_report": "Vision Test Report",
        "score": "Score",
        "disclaimer": "This report is for informational purposes only and does not constitute medical advice. Please consult with an eye care professional for a comprehensive examination.",
        "save_success": "Success",
        "save_error": "Error",
        "image_saved_to_photos": "Image saved to Photos"
    ]
    
    // 中文翻譯
    static let chinese: [String: String] = [
        // 歡迎頁面
        "welcome_title": "視力測試",
        "welcome_intro": "這是香港科技大學和醫院合作的應用程式，用於眼睛測試。",
        "welcome_testing_intro": "您將參與三項測試：視力測試(LogMAR)、黃斑部測試和色盲測試，整個過程約10分鐘即可完成。",
        "enter_name": "請輸入您的姓名",
        "start": "開始",
        
        // 條款
        "terms_title": "使用條款",
        "terms_content": "使用本應用程式即表示您同意以下條款與條件：\n\n1. **接受條款**：一旦您訪問或使用本應用程式，即表示您同意遵守本使用條款及其在應用程式內發布的任何更新。\n\n2. **用戶行為**：您同意僅將本應用程式用於合法目的，不得從事任何擾亂或干擾應用程式功能或安全性的活動。\n\n3. **智慧財產權**：應用程式內的所有內容、標誌和資料均屬我們所有或經我們授權許可。未經事先書面同意，您不得複製、分發或修改任何內容。\n\n4. **隱私權**：您使用本應用程式須遵守我們的隱私政策，該政策說明了我們如何收集、使用和保護您的資料。\n\n5. **終止服務**：我們保留隨時暫停或終止您對本應用程式的訪問權利的權利，無需事先通知，且適用於任何違反本條款的情況。\n\n6. **免責聲明**：本應用程式按「現狀」提供，不提供任何形式的擔保。我們對您使用本應用程式所產生的任何損害不承擔責任。\n\n7. **條款變更**：我們可能會不時更新本條款。您在條款變更後繼續使用本應用程式即表示接受新條款。\n\n請在使用前仔細閱讀。",
        "i_agree": "我已閱讀並同意使用條款和隱私政策",
        "next": "下一步",
        
        // 權限
        "permission_required": "需要權限",
        "app_needs_access": "本應用需要以下訪問權限：",
        "speech_recognition": "語音識別",
        "camera": "相機",
        "grant_permissions": "授予權限",
        "permission_explanation": "這些權限對於準確執行視力測試是必需的。",
        
        // 過渡
        "congratulations": "恭喜您完成了",
        "next_test": "接下來將進行",
        "transition_explanation": "請按照指示進行下一個測試，這將幫助全面評估您的視覺健康狀況。",
        "continue_next_test": "繼續下一項測試",
        "preparing_next_test": "正在準備下一個測試...",
        "processing_results": "正在處理您的結果...",
        "preparing_results": "正在準備您的最終報告...",
        "analyzing_color_vision": "正在分析您的色覺測試結果...",
        "all_tests_completed": "所有測試已完成，正在處理結果...",
        
        // 測試名稱
        "vision_test": "視力測試",
        "macular_test": "黃斑部測試",
        "color_test": "色盲測試",
        
        // 結果
        "test_results_for": "測試結果 - ",
        "your_selection": "您的選擇：",
        "result": "結果：",
        "your_score": "您的分數：",
        "out_of": "滿分",
        "performance": "表現：",
        "excellent": "優秀",
        "acceptable": "良好",
        "needs_attention": "需注意",
        "no_data": "無可用數據",
        
        // 理解結果
        "understanding_results": "了解您的測試結果",
        "logmar_explanation": "測量視力敏銳度。數值越低表示視力越好。正常視力的LogMAR值接近0。",
        "decimal_acuity_explanation": "以小數形式表示視力敏銳度。值為1.0表示正常視力，而較低的值表示視力較差。",
        "macular_explanation": "檢測黃斑部退化的早期徵兆。如果格線出現彎曲或扭曲，可能表示需要進一步檢查。",
        "color_explanation": "評估色彩識別能力。無法識別特定數字可能表示色盲或色弱。",
        
        // 測試信息
        "test_information": "測試信息",
        "test_date": "測試日期：",
        
        // 建議
        "recommendations": "建議",
        "consultation_advice": "如果檢測到任何問題，請諮詢眼科專業人士進行全面檢查。",
        
        // 按鈕
        "start_new_test": "開始新測試",
        "continue": "繼續",
        "view_results": "查看結果",
        
        // 色盲測試
        "What number do you see in the image?": "您在圖像中看到什麼數字？",
        "your_answer": "您的答案",
        "No number": "沒有數字",
        
        // 視力測試視圖
        "eye": "眼睛",
        "level": "級別",
        "switch_to_left_eye": "切換到左眼",
        "please_cover_right_eye": "請遮住您的右眼",
        "please_cover_left_eye": "請遮住您的左眼",
        "current_distance": "當前距離",
        "listening": "正在聆聽",
        "start_voice_input": "開始語音輸入",
        "stop_voice_input": "停止語音輸入",
        "input_letters": "輸入字母：",
        "enter_letters": "輸入字母",
        "confirm_answer": "確認答案",
        "recognized": "已識別",
        "please_move_back": "請向後移動\n理想距離：55-60厘米",
        "please_move_closer": "請靠近一點\n理想距離：55-60厘米",
        
        // 視力測試指示
        "vision_test_instructions": "視力測試說明",
        "prepare_environment": "準備環境",
        "find_well_lit_room": "找一個光線充足的房間並確保您處於舒適的位置。",
        "distance": "距離",
        "position_distance": "將自己放置在距離螢幕55-60厘米的位置。",
        "right_eye_test": "右眼測試",
        "cover_left_eye": "用手掌或眼罩完全遮住您的左眼。",
        "left_eye_test": "左眼測試",
        "after_right_eye": "在完成右眼測試後，系統會提示您遮住右眼。",
        "voice_input": "語音輸入",
        "speak_letters": "清晰自信地說出您看到的字母。",
        "start_test": "開始測試",
        
        // 視力測試結果
        "vision_test_results": "視力測試結果",
        "right_eye": "右眼",
        "left_eye": "左眼",
        "logmar_value": "LogMAR值",
        "decimal_acuity": "十進制視力",
        "snellen_notation": "斯內倫記號",
        "vision_quality": "視力品質",
        "normal_or_better": "正常或更好",
        "mild_vision_loss": "輕度視力損失",
        "moderate_vision_loss": "中度視力損失",
        "severe_vision_loss": "嚴重視力損失",
        "invalid": "無效",
        
        // 報告卡片
        "save_results": "保存結果",
        "close": "關閉",
        "save_image": "保存圖片",
        "vision_test_report": "視力測試報告",
        "score": "分數",
        "disclaimer": "本報告僅供參考，不構成醫療建議。請諮詢眼科專業人士進行全面檢查。",
        "save_success": "成功",
        "save_error": "錯誤",
        "image_saved_to_photos": "圖片已保存到照片"
    ]
    
    // 語言字典
    static let localizedStringDictionary: [String: [String: String]] = [
        "en": english,
        "zh": chinese
    ]
}

// 簡化翻譯使用的擴展
extension String {
    var localized: String {
        return LocalizationManager.shared.localized(self)
    }
} 
