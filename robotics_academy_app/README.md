# AI Robotics & Automation Academy — Flutter App (Android)

This is a real Flutter app (not a website) matching your poster's design:
dark navy background, blue/purple accents, gold certificate badges.

Screens included and working:
- Splash screen
- Home / Dashboard (progress ring, quick actions, continue learning, categories, popular courses)
- Courses list (filter by level & category)
- Course Detail (modules, lessons, projects)
- **AI Tutor** — real chat wired to the Anthropic API (see setup step 3 below)
- Quiz — scored, 4 questions, instant feedback
- Profile — stats + menu
- Certificates — earned certificate list

## 1. Get the Flutter "skeleton" folders (android/ios/etc.)

I've given you all the `lib/` Dart code and `pubspec.yaml`, but not the
`android/`, `ios/` native scaffolding — those are auto-generated and it's
much safer to let Flutter generate them itself rather than hand-write them.

In VS Code or a terminal, inside this project folder, run:

```bash
flutter create . --org com.roboticsacademy --project-name robotics_academy_app
```

This will generate `android/`, `ios/`, `web/`, etc. **without touching**
your existing `lib/` folder or `pubspec.yaml` (answer "yes" if it asks to
overwrite `pubspec.yaml` — just re-copy the one I gave you afterward if it
gets overwritten, since it only differs by the dependencies list below).

## 2. Install dependencies

```bash
flutter pub get
```

## 3. (Optional but recommended) Add your Anthropic API key for the AI Tutor

Open `lib/services/ai_service.dart` and replace:

```dart
const String kAnthropicApiKey = 'YOUR_API_KEY_HERE';
```

with your real key from https://console.anthropic.com

Without a key, the AI Tutor still works — it just returns a placeholder
reply instead of a real AI answer, so you can demo the app immediately.

**Security note:** never ship a real API key inside a public app binary —
anyone can extract it. For a real launch, route AI Tutor requests through
your own backend server that holds the key, instead of calling the
Anthropic API directly from the app.

## 4. Run it

Plug in an Android phone (with USB debugging on) or start an emulator in
Android Studio, then:

```bash
flutter run
```

Or press the ▶️ Run button in Android Studio / VS Code with a device selected.

## 5. Build an installable APK

```bash
flutter build apk --release
```

The installable file will be at:
`build/app/outputs/flutter-apk/app-release.apk`

Copy that to your phone and install it directly.

---

## Project structure

```
lib/
  main.dart                  # App entry point
  theme/app_theme.dart       # Colors, fonts, shared decorations
  models/models.dart         # Course, Category, Certificate, Quiz, Chat data classes
  data/mock_data.dart        # Sample courses / categories / certificates / quiz questions
  services/ai_service.dart   # Calls Anthropic API for the AI Tutor
  widgets/shared_widgets.dart# Bottom nav, progress ring, course card, pills, badges
  screens/
    splash_screen.dart
    main_shell.dart          # Bottom-nav tab container
    home_screen.dart
    courses_screen.dart
    course_detail_screen.dart
    tutor_screen.dart
    quiz_screen.dart
    profile_screen.dart
    certificates_screen.dart
```

## Next phases (from your original roadmap)

Not built yet — these need real backend infrastructure (database, auth,
video streaming, robot hardware links) beyond a front-end app:
- User accounts that persist (needs a backend + database)
- 3D/VR simulations & real robot lab booking
- Community forum
- Admin panel
- Payments

Happy to help wire up a FastAPI/Node backend next so login, progress, and
certificates actually save.
