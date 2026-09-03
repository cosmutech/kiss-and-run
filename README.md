# 💋 Kiss & Run — Mobile Game

A hilarious, fast-paced, consequence-driven cartoon runner developed with **Flutter & Custom 60 FPS Game Loop** for Android and Google Play.

---

## 🎯 Gameplay Loop
```
APPROACH ➔ CHOOSE CHARACTER ➔ 💋 KISS ➔ REACTION ➔ CONSEQUENCE ➔ ESCAPE / RUN ➔ SCORE ➔ NEXT ENCOUNTER
```

Every reaction has real consequences:
* **Positive Reactions**: Love (+Coins, Speed Boost), Kiss Back (+Bonus, Combo), Heart Gift, Join Squad.
* **Neutral Reactions**: Laugh (Nearby NPCs alerted), Blushing Escape (Chase for bonus), Freeze (Slow-mo), Selfie Flash.
* **Negative Reactions**: Cartoon Slap (-1 Heart, Stun), Furious Chase (Pursuit), Call Friends (Squad backup), Call Police (Patrol sirens), Handbag Throw (Hazard projectile), Crowd Surrounding (Exit blocked).
* **Chain Reactions**: Chasers knock into innocent NPCs, crash into food carts, spill hot dogs/drinks, causing domino chaos!

---

## 📁 Project Architecture
```
kiss_and_run/
├── android/                   # Native Android wrapper & Gradle config
├── lib/
│   ├── data/
│   │   ├── funny_dialogues.dart    # Comic quotes for kisses, slaps, police
│   │   ├── level_definitions.dart  # Configurations for Levels 1–10 + Endless
│   │   ├── npc_definitions.dart    # 15 NPC personalities & probability weights
│   │   ├── reaction_definitions.dart# 15 Reactions, scores, consequences
│   │   └── shop_catalog.dart       # Cosmetic catalog & Heart Coin prices
│   ├── models/
│   │   ├── achievement_model.dart  # Achievements tracking
│   │   ├── level_model.dart        # Level attributes & environment themes
│   │   ├── npc_model.dart          # NPC state, position, velocity, reaction
│   │   ├── obstacle_model.dart     # Banana peels, coffee spills, carts
│   │   ├── player_model.dart       # Player state, health, buffs, customization
│   │   ├── powerup_model.dart      # Shields, Speed, Magnet, Slowmo, Angel
│   │   └── reaction_model.dart     # Consequence enums & definitions
│   ├── rendering/
│   │   ├── character_painter.dart  # 2D cartoon character renderer & speech bubbles
│   │   ├── game_world_painter.dart # Sidewalks, roads, scenery, objects, juice
│   │   └── particle_system.dart    # Hearts, stars, anger puffs, sparkles
│   ├── systems/
│   │   ├── ads_manager.dart        # Rewarded & Interstitial AdMob architecture
│   │   ├── chain_reaction_manager.dart # Domino collision cascade engine
│   │   ├── daily_reward_manager.dart   # 7-Day calendar & streak rewards
│   │   ├── game_controller.dart    # 60 FPS update loop, physics & collision
│   │   ├── save_manager.dart       # Local persistence via SharedPreferences
│   │   └── sound_manager.dart      # Sound effects, haptics & audio toggles
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── customize_screen.dart   # Dressing room with live avatar preview
│   │   │   ├── daily_reward_dialog.dart# 7-Day daily gift claim modal
│   │   │   ├── game_screen.dart        # Viewport with 60 FPS Ticker
│   │   │   ├── leaderboard_screen.dart # Records & achievements tab
│   │   │   ├── level_select_screen.dart# 10 Stages map with unlocks
│   │   │   ├── main_menu_screen.dart   # Comic title logo, buttons & coins
│   │   │   └── settings_dialog.dart    # Audio, vibration, privacy & reset
│   │   └── widgets/
│   │       ├── game_hud.dart           # D-pad, hearts, score, combo, 💋 KISS
│   │       ├── game_over_dialog.dart   # "YOU GOT CAUGHT! 😂" & stats
│   │       └── victory_dialog.dart     # Level cleared, star rating & next stage
│   └── main.dart              # Entrypoint & portrait screen lock
├── store_listing/             # Google Play Store copy & graphics guidelines
└── pubspec.yaml               # Dependencies & assets configuration
```

---

## 🚀 How to Run and Test

### 1. Run on Connected Device / Emulator / Windows
```bash
flutter run
```

### 2. Run Automated Unit & Smoke Tests
```bash
flutter test
```

### 3. Build Android Debug APK
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### 4. Build Production Google Play Bundle (.AAB)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 🔑 Generating a Production Keystore for Google Play
1. Generate key:
```powershell
keytool -genkey -v -keystore kiss-and-run-release.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias kissandrun
```
2. Place `key.properties` inside `android/` with:
```properties
storePassword=yourStorePassword
keyPassword=yourKeyPassword
keyAlias=kissandrun
storeFile=../kiss-and-run-release.jks
```

---

## 📢 Configuring Google AdMob
In `android/app/src/main/AndroidManifest.xml`, add your Google AdMob App ID inside the `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/> <!-- Test ID -->
```
In `lib/systems/ads_manager.dart`, replace the rewarded and interstitial callbacks with the official `google_mobile_ads` SDK calls when ready to launch with production ad units.

---

## 🛡️ Privacy & Compliance
* Requires **zero** invasive permissions.
* Fully compliant with Google Play Families & IARC ratings.
* All data is stored locally on device.
