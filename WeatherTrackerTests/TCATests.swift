import Testing
@testable import WeatherTracker
import ComposableArchitecture

@Suite("TCA tests")
@MainActor
struct WeatherTrackerTCATests {
  @Test
  func checkNoWeatherRestoration() async throws {
    let testStore = TestStore(
      initialState: HomeFeature.State(),
      reducer: { HomeFeature() },
      withDependencies: {
        $0.weatherPersistenceClient.retrieveCachedWeather = { nil }
      }
    )
    await testStore.send(.restoreCachedWeather)
  }

  @Test
  func checkWeatherRestoration() async throws {
    let testStore = TestStore(
      initialState: HomeFeature.State(),
      reducer: { HomeFeature() },
      withDependencies: {
        $0.weatherPersistenceClient.retrieveCachedWeather = { .test  }
      }
    )
    await testStore.send(.restoreCachedWeather)
    await testStore.receive(.updateContent(.weather(.test))) {
      $0.content = .weather(.test)
    }
  }

  @Test
  func searchWeatherSuccess() async throws {
    let testStore = TestStore(
      initialState: HomeFeature.State(content: .noResults),
      reducer: { HomeFeature() },
      withDependencies: {
        $0.weatherAPIClient.searchWeather = { _ in .test }
        $0.continuousClock = ImmediateClock()
      }
    )
    await testStore.send(.queryChanged("foo")) {
      $0.searchQuery = "foo"
    }
    await testStore.receive(.updateContent(.searching(.test))) {
      $0.content = .searching(.test)
    }
  }

  @Test
  func searchWeatherNoResult() async throws {
    let testStore = TestStore(
      initialState: HomeFeature.State(content: .empty),
      reducer: { HomeFeature() },
      withDependencies: {
        $0.weatherAPIClient.searchWeather = { _ in throw WeatherAPIClient.APIError.apiError(1006, "No results")
        }
        $0.continuousClock = ImmediateClock()
      }
    )
    await testStore.send(.queryChanged("non-existing-city-name")) {
      $0.searchQuery = "non-existing-city-name"
    }
    await testStore.receive(.updateContent(.noResults)) {
      $0.content = .noResults
    }
  }

  @Test
  func searchWeatherError() async throws {
    let testStore = TestStore(
      initialState: HomeFeature.State(content: .empty),
      reducer: { HomeFeature() },
      withDependencies: {
        $0.weatherAPIClient.searchWeather = { _ in throw WeatherAPIClient.APIError.unknownServerError
        }
        $0.continuousClock = ImmediateClock()
      }
    )
    await testStore.send(.queryChanged("bar")) {
      $0.searchQuery = "bar"
    }
    await testStore.receive(.presentError("Something went wrong...")) {
      $0.alert = .init(
        title: { TextState("Error") },
        message: { TextState("Something went wrong...") }
      )
    }
  }

  @Test
  func checkCitySelection() async throws {
    let storeExpectation = LockIsolated<CityWeather?>(nil)
    let testStore = TestStore(
      initialState: HomeFeature.State(searchQuery: "foo", content: .searching(.test)),
      reducer: { HomeFeature() },
      withDependencies: {
        $0.weatherPersistenceClient.storeWeather = { w in storeExpectation.setValue(w) }
      }
    )
    await testStore.send(.searchResultTapped(.test)) {
      $0.content = .weather(.test)
    }
    #expect(storeExpectation.value == .test)
  }
}

extension CityWeather {
  static let test = CityWeather(
    cityName: "Test",
    temperature: .init(value: 10, unit: .celsius),
    feelsLikeTemperature: .init(value: 20, unit: .celsius),
    conditionIcon: nil,
    humidity: 50,
    uvIndex: 1
  )
}
