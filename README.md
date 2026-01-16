# SkinCare App

A Flutter mobile app that helps users build a personalized skincare routine. The app blends a short quiz, curated product recommendations, daily routine planning, and local weather insights to support better skincare decisions.

## Features
- **Authentication & profiles** with email and social sign-in options.
- **Skin quiz** to collect preferences and tailor recommendations.
- **Product recommendations** with filtering by brand, label/type, and price range.
- **Routine builder** for morning and night routines with customizable steps.
- **Weather dashboard** using geolocation to show local conditions, temperature, and humidity.
- **Notifications** to keep routines on schedule.

## Tech stack
- **Flutter / Dart**
- **Firebase** (core/auth)
- **WeatherAPI** for weather data
- **Geolocator/Geocoding** for location lookup
- **Local notifications** for reminders

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A configured iOS/Android device or emulator
- (Optional) Firebase project for authentication
- WeatherAPI key

### Configuration

```bash
WEATHER_API_KEY=your_key_here
```

If you are using Firebase authentication, follow the FlutterFire setup steps for your platform and add the generated configuration files to the project.

### Install dependencies

```bash
flutter pub get
```
```bash
flutter run
```

## Project structure

```
lib/
  main.dart                # App entrypoint and routes
  pages/                   # Screens (login, quiz, routine, products, weather, profile)
  services/                # API clients, caching, notifications
  models/                  # Data models
  utils/                    # Helpers and constants
```

## Notes

- The weather screen uses device location permissions to determine the current city.
- The product and routine experiences are designed to work together: the quiz seeds recommendations and the routine builder lets users select products by step.

