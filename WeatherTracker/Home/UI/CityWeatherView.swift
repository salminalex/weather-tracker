import SwiftUI

struct CityWeatherView: View {
  let weather: CityWeather
  
  var body: some View {
    VStack(spacing: 35) {
      VStack {
        AsyncImage(url: weather.conditionIcon) {
          $0.resizable()
        } placeholder: {
          ProgressView()
        }
        .frame(width: 150, height: 150)
        
        HStack {
          Text(weather.cityName)
            .font(.system(size: 30, weight: .bold))
          Image(.location)
        }
        
        Text(weather.temperature.formatted())
          .font(.system(size: 70, weight: .bold))
      }
      .foregroundColor(.mainFont)
      
      HStack(alignment: .firstTextBaseline, spacing: 56) {
        gridItem(
          name: "Humidity",
          value: "\(weather.humidity)%"
        )
        
        gridItem(
          name: "UV",
          value: "\(weather.uvIndex)"
        )
        
        gridItem(
          name: "Feels Like",
          value: weather.feelsLikeTemperature.formatted()
        )
      }
      .padding()
      .lightGrayBackground()
    }
  }
  
  func gridItem(name: String, value: String) -> some View {
    VStack {
      Text(name)
        .font(.system(size: 12))
        .foregroundColor(.font2)
      
      Text(value)
        .font(.system(size: 15, weight: .semibold))
        .foregroundColor(.font1)
    }
  }
}
#Preview {
  CityWeatherView(weather: .preview)
}
