# Contributing to VeloMap

Thank you for your interest in contributing to VeloMap! 🚴‍♂️

VeloMap is an open-source Flutter application for exploring cycling routes across Europe. We welcome contributions from developers of all skill levels.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Architecture Guidelines](#architecture-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)
- [Code Style](#code-style)
- [Areas for Contribution](#areas-for-contribution)

---

## Code of Conduct

Please be respectful and constructive in all interactions. We're building a welcoming community for cyclists and developers alike.

**Our standards:**
- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Focus on what's best for the community
- Show empathy towards other contributors

---

## Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or higher
- A valid Mapbox API key (get one at [mapbox.com](https://mapbox.com))
- Git
- Android Studio and/or Xcode (depending on target platform)

### Fork & Clone

1. **Fork the repository** on GitHub
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/VeloMap.git
   cd VeloMap/mobile/client/velo_map_app
   ```

3. **Add upstream remote:**
   ```bash
   git remote add upstream https://github.com/VeloFactory/VeloMap.git
   ```

### Environment Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   ```
   Add your Mapbox key to `.env`:
   ```
   MAPBOX_KEY=your_mapbox_api_key_here
   ```

3. **Run code generation** (for Freezed models):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Verify setup:**
   ```bash
   flutter run
   ```

---

## Development Workflow

### Branch Naming

Create a feature branch from `master`:

```bash
git checkout master
git pull upstream master
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring

### Commit Messages

Use clear, descriptive commit messages:

```
type: short description

Longer explanation if needed (optional)
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting (no code change)
- `refactor:` - Code refactoring
- `test:` - Adding tests

**Examples:**
```
feat: add route sharing functionality
fix: correct camera bounds calculation for multi-stage routes
docs: update README with new setup instructions
```

### Before Submitting

Always run these checks before pushing:

```bash
# Format code
dart format .

# Run static analysis
flutter analyze --fatal-infos

# Run tests (if applicable)
flutter test
```

---

## Architecture Guidelines

### Key Principles

1. **Layered Architecture:**
   ```
   Presentation → Domain ← Data
   ```
   - **Presentation:** UI widgets, BLoC/Cubit, screens
   - **Domain:** Entities, business logic, repository interfaces
   - **Data:** DTOs, datasources, repository implementations

2. **Feature Module Structure:**
   ```
   lib/features/your_feature/
   ├── your_feature.dart      # Barrel file (exports)
   ├── data/
   │   ├── datasources/
   │   ├── models/
   │   └── repositories/
   ├── domain/
   │   ├── entities/
   │   └── services/
   └── presentation/
       ├── bloc/  (or cubit/)
       └── widgets/
   ```

3. **State Management:**
   - Use **BLoC** for complex features with multiple events
   - Use **Cubit** for simple state toggles
   - Use **Freezed** for immutable state classes

4. **Error Handling:**
   - Use `Either<Failure, T>` from dartz for repository returns
   - Define failure types in `lib/core/errors/`

### Adding New Features

1. Create feature folder following the structure above
2. Create barrel file (`your_feature.dart`) for exports
3. Register BLoC/Cubit in `lib/app/app.dart`
4. Add route in `lib/app/router.dart` if needed

---

## Pull Request Process

### Before Creating a PR

- [ ] Code follows the architecture guidelines
- [ ] Code is formatted with `dart format .`
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Tests pass (if applicable)
- [ ] Documentation updated (if needed)
- [ ] Meaningful commit messages

### Creating a Pull Request

1. **Push your branch:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub** targeting the `master` branch

3. **Fill in the PR template:**
   - Clear description of changes
   - Screenshots/videos for UI changes
   - Related issue numbers
   - Breaking changes (if any)

### Review Process

- A maintainer will review your PR
- Address review feedback promptly
- Keep discussions constructive
- Once approved, a maintainer will merge

---

## Issue Guidelines

### Reporting Bugs

Please include:
- **Device/OS:** (e.g., iPhone 14, iOS 17.2)
- **Flutter version:** (run `flutter --version`)
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Screenshots/logs** if applicable

### Feature Requests

Please include:
- **Problem description:** What problem does this solve?
- **Proposed solution:** How should it work?
- **Alternatives considered:** Other approaches you thought of
- **Mockups** (if UI-related)

### Labels

- `good first issue` - Great for newcomers
- `help wanted` - Extra attention needed
- `bug` - Something isn't working
- `enhancement` - New feature request
- `documentation` - Documentation improvements

---

## Code Style

### Dart Formatting

- Use `dart format .` before committing
- Line length: 80 characters (default)

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `RouteEntity`, `RoutesBloc` |
| Variables | camelCase | `selectedRoute`, `isLoading` |
| Constants | camelCase | `defaultZoom`, `minSheetSize` |
| Files | snake_case | `route_entity.dart`, `routes_bloc.dart` |
| Private members | `_prefix` | `_mapController`, `_onLoad()` |

### Documentation

- Document public APIs with `///` doc comments
- Include examples for complex functions
- Keep comments up-to-date with code changes

```dart
/// Unified method to update map display based on current state.
/// 
/// Handles race conditions by cancelling stale operations using
/// operation ID tracking.
///
/// - [mode]: What to display on the map
/// - [allRoutes]: Required for [MapDisplayMode.allRoutes]
Future<void> updateMapDisplay({
  required MapDisplayMode mode,
  List<RouteEntity>? allRoutes,
}) async {
  // ...
}
```

---

## Areas for Contribution

### Good First Issues

Look for issues labeled `good first issue`:
- Documentation improvements
- UI/UX polish
- Bug fixes with clear reproduction steps
- Adding city names to route data

### Current Roadmap

We're actively working on:

1. **Turn-by-turn Navigation** (`lib/features/navigation/`)
   - Voice guidance
   - Off-route detection
   - Re-routing

2. **POI Layers**
   - Hotels near routes
   - Campings
   - Bike repair shops
   - Restaurants

3. **Offline Support**
   - Downloadable route data
   - Offline map tiles

4. **User Accounts**
   - Save favorite routes
   - Track completed routes
   - Share routes

### Other Ways to Help

- **Translations:** Help internationalize the app
- **Testing:** Report bugs and edge cases
- **Documentation:** Improve guides and API docs
- **Design:** UI/UX improvements and icons

---

## Questions?

- Open a [GitHub Discussion](https://github.com/VeloFactory/VeloMap/discussions)
- Check existing issues before creating new ones

Thank you for contributing to VeloMap! 🚴‍♀️🗺️
