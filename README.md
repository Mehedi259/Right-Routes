# Right Routes 🗺️📍

Right Routes is a comprehensive, feature-rich Flutter application designed for advanced routing, navigation, and location tracking. It integrates interactive map visualization, real-time GPS tracking, secure authentication (including biometrics), and voice command features.

## 🌟 Key Features

- **Interactive Maps & Navigation:** Powered by `maplibre_gl` for smooth and customizable map rendering.
- **Location Services:** Real-time GPS tracking and geocoding using `geolocator` and `geocoding`.
- **Voice Commands:** Hands-free interaction via `speech_to_text` and visual feedback with `avatar_glow`.
- **Robust Authentication:** Secure user authentication featuring Biometric login (Touch ID/Face ID) via `local_auth`.
- **Subscription Plans:** Built-in flows for different subscription tiers and team management.
- **State Management:** Efficient and reactive state management powered by `GetX`.
- **Secure Data Storage:** Safe storage of sensitive data using `flutter_secure_storage` and `shared_preferences`.
- **Responsive Design:** Beautiful, adaptive UI built with `flutter_screenutil` tailored for all screen sizes.

## 🛠 Tech Stack & Dependencies

- **Framework:** [Flutter](https://flutter.dev/) (SDK >=3.0.0 <4.0.0)
- **State Management:** GetX (`get: ^4.7.2`)
- **Networking:** Dio (`dio: ^5.9.2`) & HTTP
- **Mapping:** MapLibre GL (`maplibre_gl: ^0.26.1`)
- **Location:** Geolocator, Geocoding
- **Security:** Local Auth, Flutter Secure Storage
- **Voice:** Speech to Text

## 📂 Project Structure

\`\`\`text
lib/
├── core/             # Core constants, routes, and services
├── features/         # Feature-specific domains (e.g., Auth Repository)
├── global_widgets/   # Reusable UI components across the app
├── models/           # Data models
├── utils/            # Helper functions and utilities
├── views/            # UI screens
│   ├── account/              # User profile & account management
│   ├── authentication/       # Login, Registration, OTP, Policies
│   ├── home/                 # Main map, routing, history, team manager
│   ├── splash_screen/        # Initial app loading screen
│   └── subscription_plans/   # Subscription & plan management
└── main.dart         # Entry point of the application
\`\`\`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed on your machine.
- An IDE such as Android Studio, VS Code, or IntelliJ.
- iOS Simulator / Android Emulator or a physical device.
- CocoaPods (for iOS build) — install via `sudo gem install cocoapods`.
- **iOS 15.0 or later** (minimum deployment target).
- **Xcode 15+** (required for iOS 15+ simulator support).

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/Mehedi259/Right-Routes.git
   cd Right-Routes
   \`\`\`

2. **Install Flutter Dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **iOS Setup (required when running on iOS)**
   \`\`\`bash
   cd ios
   pod install
   cd ..
   \`\`\`

   > ⚠️ **Note:** This project requires a minimum iOS deployment target of **15.0**. If you encounter `IPHONEOS_DEPLOYMENT_TARGET` errors during build, see the [Troubleshooting](#-troubleshooting) section below.

4. **Run the App**
   \`\`\`bash
   flutter run
   \`\`\`

## 🛡️ Permissions Required
To use all features of the app, ensure the following permissions are granted:
- **Location:** For routing and GPS tracking.
- **Microphone:** For voice-to-text features.
- **Biometrics:** For secure quick login.

## 🐛 Troubleshooting

### iOS Build Fails — `IPHONEOS_DEPLOYMENT_TARGET` Error
If you see errors like:
\`\`\`
The iOS Simulator deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to X.0,
but the range of supported deployment target versions is 15.0 to 27.0.x.
\`\`\`

**Fix:**

1. Open `ios/Podfile` and make sure this line is **uncommented**:
   \`\`\`ruby
   platform :ios, '15.0'
   \`\`\`

2. Ensure the `post_install` block in `ios/Podfile` looks like this:
   \`\`\`ruby
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       flutter_additional_ios_build_settings(target)
       target.build_configurations.each do |config|
         if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
           config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
         end
       end
     end
   end
   \`\`\`

3. Reinstall pods:
   \`\`\`bash
   cd ios && pod install && cd ..
   \`\`\`

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the issues page.
