//
//  HomeViewModel.swift
//  WeatherTracker
//
//  Created by Oleksii Salmin on 16.01.2025.
//

import Observation

@Observable
final class HomeViewModel {
  var searchQuery: String {
    didSet {
      self.queryChanged(searchQuery)
    }
  }
  var content: MVVMHomeView.Content
  var errorMessage: String?

  @ObservationIgnored
  private let apiClient: WeatherAPIClient
  @ObservationIgnored
  private let persistenceClient: WeatherPersistenceClient
  @ObservationIgnored
  private let clock: any Clock<Duration>
  @ObservationIgnored
  private var searchTask: Task<Void, Never>?

  init(
    searchQuery: String = "",
    content: MVVMHomeView.Content = .empty,
    errorMessage: String? = nil,
    apiClient: WeatherAPIClient,
    persistenceClient: WeatherPersistenceClient,
    clock: any Clock<Duration>
  ) {
    self.searchQuery = searchQuery
    self.content = content
    self.errorMessage = errorMessage
    self.apiClient = apiClient
    self.persistenceClient = persistenceClient
    self.clock = clock
  }

  func restoreCachedWeather() {
    if let cachedCityWeather = persistenceClient.retrieveCachedWeather() {
      content = .weather(cachedCityWeather)
    }
  }

  func queryChanged(_ query: String) {
    // restore cached weather if quit searching.
    guard !query.isEmpty else {
      self.searchTask?.cancel()
      self.restoreCachedWeather()
      return
    }

    self.searchTask?.cancel()
    searchTask = Task { [weak self] in
      guard let self else { return }
      // debounce search for a given query
      do {
        try await self.clock.sleep(for: .seconds(0.7))
        let weather = try await apiClient.searchWeather(query)
        self.content = .searching(weather)

      }
      // skip cancellation error
      catch is CancellationError {}
      // display/skip api error
      catch let apiError as WeatherAPIClient.APIError {
        switch apiError {
          /// 1006 code represents `No location found matching parameter query`
          /// https://www.weatherapi.com/docs/
        case .apiError(1006, _):
          self.content = .empty

        case let .apiError(_, message):
          self.errorMessage = message

        default:
          self.errorMessage = "Something went wrong..."
        }
      }
      // fall back to default error
      catch {
        self.errorMessage = "Something went wrong..."
      }
    }
  }

  func searchResultTapped(_ weather: CityWeather) {
    content = .weather(weather)
    persistenceClient.storeWeather(weather)
  }
}
