# Songify 🎵

A juicy, physics-based music aggregator app built with Flutter + Python.

> **Portfolio project** — demonstrates hybrid Flutter/Python architecture, elastic micro-animations, Spotify API integration, and YouTube audio streaming via yt-dlp.

---

## Architecture

```
Flutter (UI)  ⟵  MethodChannel  ⟵  Python Engine (yt-dlp)
     ↕                                      ↕
Spotify Web API                       YouTube Audio Streams
```

## Project Structure

```
songify/
├── lib/
│   ├── main.dart              # Entry point
│   ├── app.dart               # Root widget
│   ├── core/                  # Theme, routing, utils
│   ├── models/                # Freezed data classes
│   ├── services/              # Spotify API + Python bridge
│   ├── state/                 # Riverpod providers
│   ├── features/              # Screen + widget tree
│   └── shared/                # Reusable widgets
├── python_engine/             # yt-dlp Python code
└── assets/                    # Fonts, images, Python bundle
```

---

## Setup Instructions

### 1. Flutter Dependencies

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 2. Spotify Credentials

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create an app → copy **Client ID** and **Client Secret**
3. Open `lib/core/constants/api_constants.dart` and replace:
   ```dart
   static const String spotifyClientId = 'YOUR_SPOTIFY_CLIENT_ID';
   static const String spotifyClientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
   ```

### 3. Python Engine (serious_python)

**Prerequisites:** Python 3.11+ installed locally.

```bash
# Install Python dependencies
cd python_engine
pip install -r requirements.txt

# Test locally
python main.py '{"query": "Blinding Lights The Weeknd"}'
```

**Bundle for Flutter (Android):**

```bash
# Install serious_python CLI
pip install serious-python

# Package the engine
serious_python package python_engine -o assets/python/engine.zip
```

Then in `main.dart`, uncomment:
```dart
await SeriousPython.run('assets/python/engine.zip');
```

### 4. Run the App

```bash
flutter run
```

---

## Key Packages

| Package | Purpose |
|---|---|
| `flutter_animate` | Elastic micro-animations |
| `serious_python` | Embedded Python engine |
| `just_audio` | HTTP stream audio playback |
| `riverpod` | State management |
| `go_router` | Navigation |
| `sliding_up_panel2` | Physics-driven sliding player |
| `cached_network_image` | Spotify artwork |
| `hive_flutter` | Favorites persistence |

---

## Animation Design System

All interactive elements use a **3-tier animation hierarchy**:

1. **Micro** — Tap interactions use `Curves.elasticOut` (squash → overshoot → settle)
2. **Macro** — Sliding panel uses `sliding_up_panel2` physics
3. **Entrance** — Track lists use `StaggeredList` (cascade with `Curves.elasticOut`)

---

## License

MIT — for portfolio/educational use.
