import SwiftUI

struct SearchItemView: View {
  let weather: CityWeather

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(weather.cityName)
          .font(.system(size: 20, weight: .semibold))
        Text(weather.temperature.formatted())
          .font(.system(size: 40, weight: .bold))
      }
      .foregroundColor(.mainFont)

      Spacer()

      AsyncImage(url: weather.conditionIcon) {
        $0.resizable().scaledToFit()
      } placeholder: {
        ProgressView()
      }
      .frame(width: 80, height: 80)
    }
    .padding()
    .lightGrayBackground()
  }
}

#Preview {
  SearchItemView(weather: .preview)
    .padding()
}
