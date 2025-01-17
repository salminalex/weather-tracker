import SwiftUI
import ComposableArchitecture

@main
struct WeatherTrackerApp: App {

  var body: some Scene {
    WindowGroup {
      rootView(
        mvvm: true,
        apiClient: .live(apiKey: "YOUR_API_KEY")
      )
    }
  }

  @ViewBuilder
  func rootView(
    mvvm: Bool,
    apiClient: WeatherAPIClient
  ) -> some View {
    if mvvm {
      MVVMHomeView(
        viewModel: .init(
          apiClient: apiClient,
          persistenceClient: .liveValue,
          clock: ContinuousClock()
        )
      )
    } else {
      TCAHomeView(
        store: .init(
          initialState: HomeFeature.State(),
          reducer: {
            HomeFeature()
              .dependency(\.weatherAPIClient, apiClient)
          }
        )
      )
    }
  }
}
