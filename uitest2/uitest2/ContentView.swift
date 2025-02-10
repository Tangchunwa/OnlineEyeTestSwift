import SwiftUI

struct ContentView: View {
    @State private var isAccepted = UserDefaults.standard.bool(forKey: "TermsAccepted")

    var body: some View {
        if isAccepted {
            MainNavigationView()
        } else {
            TermsOfAgreementView(isAccepted: $isAccepted)
        }
    }
}

// MARK: - Main App View (Your Original ContentView)
struct MainNavigationView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: VisionTestView()) {
                    Label("Vision Test", systemImage: "eye")
                }
                NavigationLink(destination: LogMARTestView()) {
                    Label("New Vision Test", systemImage: "eye")
                }
                NavigationLink(destination: MacularDegenerationTestView()) {
                    Label("Macular Test", systemImage: "eye.trianglebadge.exclamationmark")
                }
                NavigationLink(destination: ColorBlindnessTestView()) {
                    Label("Color Test", systemImage: "eyedropper.halffull")
                }
            }
            .navigationBarTitle("Visual Tests")
        }
        .preferredColorScheme(.light)
    }
}


