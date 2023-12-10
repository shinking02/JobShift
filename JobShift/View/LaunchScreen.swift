import SwiftUI

struct LaunchScreen: View {
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            ZStack {
                Color("Primary")
                    .ignoresSafeArea() // fill all screen
                Image(systemName: "person.2")
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
