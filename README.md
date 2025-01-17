# Weather Tracker

Demo weather app that demonstrates TCA & MVVM approaches. The app allows users to search for a city and display its weather on the home screen. It also persists the selected city across launches. The app uses [WeatherAPI](https://www.weatherapi.com/docs/) to retrieve weather information.

## Features

- Search for a city and view detailed weather information:
  - City name
  - Temperature
  - Weather condition (with icon)
  - Humidity (%)
  - UV index
  - "Feels like" temperature
- Persist selected city using local storage (UserDefaults).
- Fetch real-time weather data from [WeatherAPI.com](https://www.weatherapi.com/).
- Demonstrates both TCA and MVVM architectural approaches with clean, modular, and testable code.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/salminalex/weather-tracker.git
   cd weather-tracker
   ```

2. Open the project in Xcode:
   ```bash
   open WeatherTracker.xcodeproj
   ```

3. Wait dependencies resolution.

4. Set up WeatherAPI:
   - Sign up at [WeatherAPI.com](https://www.weatherapi.com/) to obtain an API key.
   - Add the API key to the project:
     - Navigate to `App.swift`.
     - Replace `YOUR_API_KEY` with your actual WeatherAPI key.

5. Build and run the app:
   - Select a simulator or connect a physical device.
   - Press `Cmd + R` to build and run.

## Achitecture selection
Switch `mvvm` boolean flag in `App.swift` in oeder to switch app architecture.

## Requirements
- Xcode 16 or later
- iOS 17 or later
- Swift 5.9 or later
