import SwiftUI

struct OTJobAddView: View {
    @State var newOTJob = OneTimeJob()
    
    var body: some View {
        List {
            OTJobDetailView(newOTJob)
        }
        .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        
                    }
                }
            }
        }
    }
}

struct OTJobAddView_Previews: PreviewProvider {
    static var previews: some View {
        OTJobAddView()
    }
}
