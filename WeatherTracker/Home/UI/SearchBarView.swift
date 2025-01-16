import SwiftUI

struct SearchBarView: View {
  let query: Binding<String>

  var body: some View {
    HStack {
      TextField(
        "Search Location",
        text: query
      )

      Spacer()

      Image(.searchIcon)
    }
    .padding()
    .lightGrayBackground()
  }
}

#Preview {
  @Previewable @State var query: String = ""

  SearchBarView(query: $query)
}
