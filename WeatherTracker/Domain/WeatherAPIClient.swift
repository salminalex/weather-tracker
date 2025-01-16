import Dependencies

struct WeatherAPIClient: Sendable {
  var searchWeather: @Sendable (String) async throws -> CityWeather
}

extension WeatherAPIClient: TestDependencyKey {
  static var testValue: WeatherAPIClient {
    return .init(
      searchWeather: { _ in
        reportIssue(#"Unimplemented: @Dependency(\.weatherClient.searchWeather)"#)
        throw UnimplementedFailure(description: "searchWeather endpoint unimplemented")
      }
    )
  }

  static var previewValue: WeatherAPIClient = .init(
    searchWeather: { _ in return .preview }
  )
}

extension DependencyValues {
  var weatherAPIClient: WeatherAPIClient {
    get { self[WeatherAPIClient.self] }
    set { self[WeatherAPIClient.self] = newValue }
  }
}
