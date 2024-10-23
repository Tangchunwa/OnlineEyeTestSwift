import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: VisionTestView()) {
                    Label("Vision Test", systemImage: "eye")
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
