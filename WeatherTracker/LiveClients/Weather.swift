import Dependencies
import Foundation

extension WeatherPersistenceClient: DependencyKey {
  static let liveValue: WeatherPersistenceClient = {
    let userDefaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let key = "cached-city-weather"
    
    return WeatherPersistenceClient(
      storeWeather: { weather in
        if let data = try? encoder.encode(weather) {
          userDefaults.set(data, forKey: key)
        }
      },
      retrieveCachedWeather: {
        if let rawData = userDefaults.data(forKey: key) {
          return try? decoder.decode(CityWeather.self, from: rawData)
        } else {
          return nil
        }
      }
    )
  }()
}

extension UserDefaults: @unchecked @retroactive Sendable {}
