import SwiftUI
import Combine

struct WelcomeView: View {
    @State private var username: String = ""
    @State private var shouldShowTerms = false
    @State private var isTermsAccepted = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("username") private var savedUsername = ""
    @AppStorage("TermsAccepted") private var termsAccepted = false
    
    // 使用 LocalizationManager 替代本地語言枚舉
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    // 鍵盤相關狀態
    @State private var showElements = false
    @State private var keyboardHeight: CGFloat = 0
    
    // 鍵盤顯示/隱藏通知處理
    private let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height }
    
    private let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 使用可重用背景視圖
                GradientBackgroundView()
                
                // 主內容區 - 不再使用 ScrollView
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.02)
                    
                    // 標誌和標題區域
                    VStack(spacing: 10) {
                        // 更新眼睛圖標的樣式
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 0.1, green: 0.4, blue: 0.8), Color(red: 0.4, green: 0.7, blue: 0.9)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.blue.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "eye.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.white)
                        }
                        .opacity(showElements ? 1 : 0)
                        .scaleEffect(showElements ? 1 : 0.6)
                        
                        Text("welcome_title".localized)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.6))
                            .multilineTextAlignment(.center)
                            .opacity(showElements ? 1 : 0)
                            .offset(y: showElements ? 0 : 20)
                    }
                    
                    // 介紹文本區 - 精簡內容
                    VStack(spacing: 15) {
                        Text("welcome_intro".localized)
                            .font(.body)
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .opacity(showElements ? 1 : 0)
                            .fixedSize(horizontal: false, vertical: true)
                            .offset(y: showElements ? 0 : 10)
                        
                        // 更新資訊框設計 - 在小屏幕上可能隱藏
                        if geometry.size.height > 700 {
                            Text("welcome_testing_intro".localized)
                                .font(.callout)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.7))
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .opacity(showElements ? 1 : 0)
                                .offset(y: showElements ? 0 : 10)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.03)
                    
                    // 用戶輸入區
                    VStack(spacing: 20) {
                        // 更新輸入框樣式
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.8))
                                .font(.headline)
                            
                            TextField("enter_name".localized, text: $username)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                )
                                .onTapGesture {
                                    // 點擊輸入框時自動隱藏鍵盤
                                    hideKeyboard()
                                }
                        }
                        .padding(.horizontal)
                        .opacity(showElements ? 1 : 0)
                        .offset(y: showElements ? 0 : 10)
                        
                        // 語言選擇
                        VStack(alignment: .leading, spacing: 5) {
                            Text("選擇語言 / Select Language")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                            
                            Picker("Language", selection: $localizationManager.currentLanguage) {
                                ForEach(AppLanguage.allCases, id: \.self) { language in
                                    Text(language.rawValue).tag(language)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(3)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                            )
                        }
                        .padding(.horizontal)
                        .opacity(showElements ? 1 : 0)
                        .offset(y: showElements ? 0 : 10)
                    }
                    
                    Spacer()
                    
                    // 使用通用按鈕組件
                    GradientButton(
                        text: "start".localized,
                        icon: "arrow.right.circle.fill",
                        action: {
                            if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                savedUsername = "no user name"
                            } else {
                                savedUsername = username
                            }
                            shouldShowTerms = true
                        }
                    )
                    .opacity(showElements ? 1 : 0)
                    .scaleEffect(showElements ? 1 : 0.9)
                    .padding(.bottom, geometry.size.height * 0.05)
                }
                .padding()
                // 調整整個內容區垂直位置，根據鍵盤高度
                .offset(y: -keyboardHeight/3)
                .animation(.easeOut(duration: 0.16), value: keyboardHeight)
            }
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear {
                // 顯示元素動畫
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.5)) {
                    showElements = true
                }
            }
        }
        .sheet(isPresented: $shouldShowTerms, onDismiss: {
            if isTermsAccepted {
                termsAccepted = true
                hasCompletedOnboarding = true
            }
        }) {
            TermsOfAgreementView(isAccepted: $isTermsAccepted)
        }
        .onReceive(keyboardWillShow) { height in
            self.keyboardHeight = height
        }
        .onReceive(keyboardWillHide) { _ in
            self.keyboardHeight = 0
        }
    }
}

// 擴展 View 以隱藏鍵盤
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 