import Foundation

extension WeatherAPIClient {
  enum APIError: Error {
    case unableToFormURL
    case notHTTPResponse
    case failedToDecode
    case apiError(Int, String)
    case unknownServerError
  }

  static func live(apiKey: String) -> WeatherAPIClient {
    let session = URLSession.shared
    let basePath = URL(string: "https://api.weatherapi.com/v1")!
    let decoder = JSONDecoder()
    let locale = Locale.current

    return .init(
      searchWeather: { query in
        guard var components = URLComponents(
          url: basePath.appending(path: "current.json"),
          resolvingAgainstBaseURL: true
        ) else {
          throw APIError.unableToFormURL
        }

        components.queryItems = [
          URLQueryItem(name: "key", value: apiKey),
          URLQueryItem(name: "q", value: query),
          URLQueryItem(name: "lang", value: locale.region?.identifier)
        ]

        guard let url = components.url else {
          throw APIError.unableToFormURL
        }

        let (data, response) = try await session.data(from: url)

        guard let response = response as? HTTPURLResponse else {
          throw APIError.notHTTPResponse
        }

        switch response.statusCode {
        case 200..<400:
          do {
            let response = try decoder.decode(WeatherAPISearchResponse.self, from: data)

            return .init(
              cityName: response.location.name,
              temperature: .init(
                value: response.current.temperatureCelsius,
                unit: .celsius
              ),
              feelsLikeTemperature: .init(
                value: response.current.feelsLikeTemperatureCelsius,
                unit: .celsius
              ),
              conditionIcon: URL(string: "https:\(response.current.condition.icon)"),
              humidity: response.current.humidity,
              uvIndex: response.current.uvIndex
            )
          } catch {
            throw APIError.failedToDecode
          }

        case 400..<500:
          if let errorResponse = try? decoder.decode(WeatherAPIErrorResponse.self, from: data) {
            throw APIError.apiError(errorResponse.error.code, errorResponse.error.message)
          } else {
            throw APIError.unknownServerError
          }

        default:
          throw APIError.unknownServerError
        }
      }
    )
  }
}

private struct WeatherAPISearchResponse: Codable {
  struct Location: Codable {
    let name: String
  }

  struct Weather: Codable {
    struct Condition: Codable {
      let icon: String
    }

    let temperatureCelsius: Double
    let feelsLikeTemperatureCelsius: Double
    let condition: Condition
    let humidity: Double
    let uvIndex: Double

    enum CodingKeys: String, CodingKey {
      case temperatureCelsius = "temp_c"
      case feelsLikeTemperatureCelsius = "feelslike_c"
      case condition
      case humidity
      case uvIndex = "uv"
    }
  }

  let location: Location
  let current: Weather
}

private struct WeatherAPIErrorResponse: Codable {
  struct Info: Codable {
    let code: Int
    let message: String
  }
  let error: Info
}
