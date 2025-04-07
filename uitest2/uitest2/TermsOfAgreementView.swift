import SwiftUI

struct TermsOfAgreementView: View {
    @Binding var isAccepted: Bool  // Binding to track whether user accepts the terms
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ScrollView {
                Text("""
                    \("terms_title".localized)

                    \("terms_content".localized)
                    """)
                    .padding()
            }
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "TermsAccepted")
                isAccepted = true
                dismiss()
            }) {
                Text("i_agree".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.white)
    }
}
