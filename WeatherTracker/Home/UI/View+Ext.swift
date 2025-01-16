import SwiftUI

extension View {
  func lightGrayBackground() -> some View {
    background {
      RoundedRectangle(cornerRadius: 16)
        .foregroundColor(.lightGrayBackground)
    }
  }
}
