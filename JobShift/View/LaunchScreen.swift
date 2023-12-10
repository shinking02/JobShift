import SwiftUI

struct LaunchScreen: View {
    @State private var isLoading = true
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        if isLoading {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea() // fill all screen
                Image(colorScheme == .dark ? "icon_darkMode" : "icon_whiteMode")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } else {
            ContentView()
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
