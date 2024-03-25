import Observation

@Observable final class OnboardingViewModel {
    var closingOnboarding = false
    var showingOnboarding = false
    private let ONBORDING_VERSION = "0.2"
    private let appState = AppState.shared
    func onAppear() {
        if appState.lastSeenOnboardingVersion != ONBORDING_VERSION {
            showingOnboarding = true
        }
    }
    func onDisappear() {
        appState.lastSeenOnboardingVersion = ONBORDING_VERSION
        showingOnboarding = false
    }
    func startButtonTap() {
        appState.lastSeenOnboardingVersion = ONBORDING_VERSION
        showingOnboarding = false
    }
}
