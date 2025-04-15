import SwiftUI

struct TermsOfAgreementView: View {
    @Binding var isAccepted: Bool  // Binding to track whether user accepts the terms
    @Environment(\.dismiss) private var dismiss
    @State private var isChecked: Bool = false
    @State private var showingAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 使用可重用的漸變背景視圖
                GradientBackgroundView()
                
                VStack(spacing: 0) {
                    // 標題
                    Text("terms_title".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.6))
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                    
                    // 條款內容
                    ScrollView {
                        Text("terms_content".localized)
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                            .padding()
                            .frame(width: geometry.size.width - 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .frame(height: geometry.size.height * 0.7)
                    
                    Spacer()
                    
                    // 勾選框
                    HStack {
                        Button(action: {
                            isChecked.toggle()
                        }) {
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                                    .foregroundColor(isChecked ? Color(red: 0.2, green: 0.5, blue: 0.9) : .secondary)
                                    .font(.system(size: 20))
                                
                                Text("i_agree".localized)
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    
                    // 下一步按鈕
                    Button(action: {
                        if isChecked {
                            UserDefaults.standard.set(true, forKey: "TermsAccepted")
                            isAccepted = true
                            dismiss()
                        } else {
                            showingAlert = true
                        }
                    }) {
                        HStack(spacing: 15) {
                            Text("next".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isChecked ? Color(red: 0.2, green: 0.5, blue: 0.9) : Color.gray.opacity(0.6),
                                    isChecked ? Color(red: 0.3, green: 0.6, blue: 1.0) : Color.gray.opacity(0.5)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: isChecked ? Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.3) : Color.clear, radius: 5, x: 0, y: 3)
                    }
                    .disabled(!isChecked)
                    .padding(.vertical, 20)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text("請先閱讀並勾選同意條款才能繼續"),
                    dismissButton: .default(Text("確定"))
                )
            }
        }
    }
}
