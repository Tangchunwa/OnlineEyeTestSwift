import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("TermsAccepted") private var isTermsAccepted = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            WelcomeView()
                .preferredColorScheme(.light)
        } else if !isTermsAccepted {
            TermsOfAgreementView(isAccepted: $isTermsAccepted)
                .preferredColorScheme(.light)
        } else {
            TestFlowView()
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - Test Flow View
struct TestFlowView: View {
    @StateObject private var permissionManager = PermissionManager()
    @State private var currentTestIndex = 0
    @State private var showingResults = false
    @State private var showingTransition = false
    @State private var completedTestName = ""
    @State private var nextTestName = ""
    
    var body: some View {
        if !permissionManager.allPermissionsGranted {
            PermissionRequestView(permissionManager: permissionManager)
        } else {
            NavigationView {
                Group {
                    if showingResults {
                        TestResultsView()
                    } else if showingTransition {
                        TestTransitionView(
                            completedTest: completedTestName,
                            nextTest: nextTestName,
                            onContinue: {
                                showingTransition = false
                                currentTestIndex += 1
                            }
                        )
                    } else {
                        switch currentTestIndex {
                        case 0:
                            LogMARTestView(onComplete: { 
                                completeTest(testName: "vision_test".localized, nextTest: "macular_test".localized)
                            })
                        case 1:
                            MacularDegenerationTestView(onComplete: { 
                                completeTest(testName: "macular_test".localized, nextTest: "color_test".localized)
                            })
                        case 2:
                            ColorBlindnessTestView(onComplete: { 
                                showingResults = true 
                            })
                        default:
                            EmptyView()
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func completeTest(testName: String, nextTest: String) {
        completedTestName = testName
        nextTestName = nextTest
        showingTransition = true
    }
}

// MARK: - Main App View
struct MainNavigationView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: LogMARTestView()) {
                    Label("vision_test".localized, systemImage: "eye")
                }
                NavigationLink(destination: MacularDegenerationTestView()) {
                    Label("macular_test".localized, systemImage: "eye.trianglebadge.exclamationmark")
                }
                NavigationLink(destination: ColorBlindnessTestView()) {
                    Label("color_test".localized, systemImage: "eyedropper.halffull")
                }
            }
            .navigationBarTitle("Visual Tests")
        }
        .preferredColorScheme(.light)
    }
}


