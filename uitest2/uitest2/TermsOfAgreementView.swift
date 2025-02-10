import SwiftUI

struct TermsOfAgreementView: View {
    @Binding var isAccepted: Bool  // Binding to track whether user accepts the terms

    var body: some View {
        VStack {
            ScrollView {
                Text("""
                    Terms of Agreement

                    By using this application, you agree to the following terms and conditions.
                    [Add your detailed terms here...]

                    Please read carefully before proceeding.
                    """)
                    .padding()
            }
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "TermsAccepted")
                isAccepted = true
            }) {
                Text("I Agree")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
