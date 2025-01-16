import SwiftUI
import ComposableArchitecture

struct HomeView: View {
  @Bindable var store: StoreOf<HomeFeature>

  var body: some View {
    VStack {
      SearchBarView(query: $store.searchQuery.sending(\.queryChanged))

      switch store.content {
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
            store.send(.searchResultTapped(weather))
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
    .alert($store.scope(state: \.alert, action: \.alert))
    .onAppear { store.send(.restoreCachedWeather) }
  }
}

#Preview {
  HomeView(
    store: .init(
      initialState: HomeFeature.State(content: .empty),
      reducer: { HomeFeature() }
    )
  )
}
