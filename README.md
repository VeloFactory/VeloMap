# VeloMap 🚴

[![Flutter CI](https://github.com/VeloFactory/VeloMap/actions/workflows/ci.yml/badge.svg)](https://github.com/VeloFactory/VeloMap/actions/workflows/ci.yml)

A mobile application for exploring EuroVelo cycling routes across Europe.

## 🎯 Features

- 🗺️ Interactive Mapbox map with 17 EuroVelo routes
- 🔍 Search routes by city
- 📍 User location tracking
- 📊 Route details with stages, distance, and elevation profiles
- 🏨 POI layers (hotels, campings, restaurants)
- 📤 GPX export functionality
- 🎨 Route development status indicators

## 📁 Project Structure

```
VeloMap/
├── mobile/
│   └── client/
│       └── velo_map_app/    # Flutter mobile app
├── web/                      # Web application (future)
└── .github/
    └── workflows/
        └── ci.yml           # CI/CD pipeline
```

## 🚀 Getting Started

See the [mobile app documentation](mobile/client/velo_map_app/README.md) for setup instructions.

### Quick Start

```bash
cd mobile/client/velo_map_app
cp .env.example .env
# Add your MAPBOX_KEY to .env
flutter pub get
flutter run
```

## 🛠️ Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Mapbox Maps** - Interactive map rendering
- **flutter_bloc** - State management
- **Freezed** - Immutable data classes

## 🤝 Contributing

We welcome contributions from developers of all skill levels! Whether you're fixing bugs, adding features, or improving documentation, your help is appreciated.

Check out our [Contributing Guide](CONTRIBUTING.md) for:
- Development workflow and setup
- Architecture guidelines
- Pull request process
- Good first issues to get started

## 📄 License

This project is licensed under the MIT License.
