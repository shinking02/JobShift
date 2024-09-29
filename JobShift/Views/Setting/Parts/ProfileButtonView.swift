import CachedAsyncImage
import SwiftUI

struct ProfileButtonView: View {
    let imageURL: URL?
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            CachedAsyncImage(url: imageURL) { image in
                image.resizable()
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
            .frame(width: 34, height: 34)
        }
    }
}
