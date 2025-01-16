import SwiftUI
import ComposableArchitecture

@main
struct WeatherTrackerApp: App {
  var body: some Scene {
    WindowGroup {
      HomeView(
        store: .init(
          initialState: HomeFeature.State(content: .empty),
          reducer: {
            HomeFeature()
              .dependency(\.weatherAPIClient, .live(apiKey: "YOUR_API_KEY"))
          }
        )
      )
    }
  }
}
