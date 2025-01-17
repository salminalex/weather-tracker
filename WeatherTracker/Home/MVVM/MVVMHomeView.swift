import SwiftUI

struct MVVMHomeView: View {
  @State var viewModel: HomeViewModel

  enum Content: Equatable {
    case empty
    case noResults
    case searching(CityWeather)
    case weather(CityWeather)
  }

  var body: some View {
    VStack {
      SearchBarView(query: $viewModel.searchQuery)

      switch viewModel.content {
      case .empty:
        Spacer()
        VStack {
          Text("No city selected")
            .font(.system(size: 30, weight: .bold))
          Text("Please search for a city")
            .font(.system(size: 15, weight: .semibold))
        }
        Spacer()

      case .noResults:
        Spacer()

      case .searching(let weather):
        SearchItemView(weather: weather)
          .onTapGesture {
            viewModel.searchResultTapped(weather)
          }
        Spacer()

      case let .weather(weather):
        Spacer()
        CityWeatherView(weather: weather)
        Spacer()
      }
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 44)
    .alert(
      "Error",
      isPresented: .init(
        get: { viewModel.errorMessage != nil },
        set: { _ in viewModel.errorMessage = nil }
      ),
      actions: { Button("OK") { } },
      message: { Text(viewModel.errorMessage ?? "") }
    )
    .onAppear { viewModel.restoreCachedWeather() }
  }
}

#Preview {
  MVVMHomeView(
    viewModel: .init(
      apiClient: .previewValue,
      persistenceClient: .previewValue,
      clock: ContinuousClock()
    )
  )
}
