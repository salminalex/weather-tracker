import Dependencies

struct WeatherPersistenceClient: Sendable {
  var storeWeather: @Sendable (CityWeather) -> Void
  var retrieveCachedWeather: @Sendable () -> CityWeather?
}

extension WeatherPersistenceClient: TestDependencyKey {
  static var testValue = WeatherPersistenceClient(
    storeWeather: { _ in
      reportIssue("WeatherPersistenceClient.storeWeather unimplemented")
    },
    retrieveCachedWeather: {
      reportIssue("WeatherPersistenceClient.retrieveCachedWeather unimplemented")
      return nil
    }
  )

  static var previewValue: WeatherPersistenceClient = .init(
    storeWeather: { _ in },
    retrieveCachedWeather: { return nil }
  )
}

extension DependencyValues {
  var weatherPersistenceClient: WeatherPersistenceClient {
    get { self[WeatherPersistenceClient.self] }
    set { self[WeatherPersistenceClient.self] = newValue }
  }
}
