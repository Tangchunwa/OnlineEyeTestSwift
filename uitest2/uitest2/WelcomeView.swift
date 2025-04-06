import SwiftUI

struct WelcomeView: View {
    @State private var username: String = ""
    @State private var shouldShowTerms = false
    @State private var isTermsAccepted = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("username") private var savedUsername = ""
    @AppStorage("TermsAccepted") private var termsAccepted = false
    
    // 使用 LocalizationManager 替代本地語言枚舉
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 25) {
            Text("welcome_title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                Text("welcome_intro".localized)
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                Text("welcome_testing_intro".localized)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            TextField("enter_name".localized, text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Picker("Language", selection: $localizationManager.currentLanguage) {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Text(language.rawValue).tag(language)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Button(action: {
                if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    savedUsername = "no user name"
                } else {
                    savedUsername = username
                }
                shouldShowTerms = true
            }) {
                Text("start".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .sheet(isPresented: $shouldShowTerms, onDismiss: {
            if isTermsAccepted {
                termsAccepted = true
                hasCompletedOnboarding = true
            }
        }) {
            TermsOfAgreementView(isAccepted: $isTermsAccepted)
        }
    }
} 