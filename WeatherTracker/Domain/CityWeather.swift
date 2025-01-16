import Foundation
import SwiftUI

struct CityWeather: Hashable, Codable {
  let cityName: String
  let temperature: Measurement<UnitTemperature>
  let feelsLikeTemperature: Measurement<UnitTemperature>
  let conditionIcon: URL?
  let humidity: Double
  let uvIndex: Double
}

extension CityWeather {
  static let preview = CityWeather(
    cityName: "Hyderabad",
    temperature: .init(value: 31, unit: .celsius),
    feelsLikeTemperature: .init(value: 38, unit: .celsius),
    conditionIcon: URL(string: "https://cdn.weatherapi.com/weather/64x64/day/113.png"),
    humidity: 20,
    uvIndex: 4
  )
}
