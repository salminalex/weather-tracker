import ComposableArchitecture
import Foundation

@Reducer
struct HomeFeature {
  @ObservableState
  struct State: Equatable {
    enum Content: Equatable {
      case empty
      case noResults
      case searching(CityWeather)
      case weather(CityWeather)
    }

    var searchQuery = ""
    var content = Content.empty
    @Presents var alert: AlertState<Never>?
  }

  enum Action: Equatable {
    case updateContent(State.Content)
    case presentError(String)
    case alert(PresentationAction<Never>)

    case restoreCachedWeather
    case queryChanged(String)
    case searchResultTapped(CityWeather)
  }

  @Dependency(\.weatherAPIClient) var apiClient
  @Dependency(\.weatherPersistenceClient) var persistenceClient
  @Dependency(\.continuousClock) var clock

  private struct SearchCancelID: Hashable, Sendable {}

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .updateContent(content):
        state.content = content
        return .none
      case let .presentError(message):
        state.alert = .init(
          title: { TextState("Error") },
          message: { TextState(message) }
        )
        return .none

      case .restoreCachedWeather:
        return .run { send in
          if let cachedCityWeather = persistenceClient.retrieveCachedWeather() {
            await send(.updateContent(.weather(cachedCityWeather)))
          }
        }

      case let .queryChanged(query):
        state.searchQuery = query

        // restore cached weather if quit searching.
        guard !query.isEmpty else {
          Task.cancel(id: SearchCancelID())
          return .send(.restoreCachedWeather)
        }

        // debounce search for a given query
        return .run { send in
          try await withTaskCancellation(id: SearchCancelID()) {

            try await clock.sleep(for: .seconds(0.7))
            let weather = try await apiClient.searchWeather(query)
            await send(.updateContent(.searching(weather)))
          }
        }
        // errors handling
        catch: { error, send in
          guard let apiError = error as? WeatherAPIClient.APIError else {
            await send(.presentError("Something went wrong..."))
            return
          }

          switch apiError {
            /// 1006 code represents `No location found matching parameter query`
            /// https://www.weatherapi.com/docs/
          case .apiError(1006, _):
            await send(.updateContent(.empty))

          case let .apiError(_, message):
            await send(.presentError(message))

          default:
            await send(.presentError("Something went wrong..."))
          }
        }

      case .searchResultTapped(let cityWeather):
        state.content = .weather(cityWeather)
        return .run { send in
          persistenceClient.storeWeather(cityWeather)
        }

      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}
