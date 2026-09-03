import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'systems/save_manager.dart';
import 'systems/ads_manager.dart';
import 'ui/screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI to immersive cartoon style & portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize persistence and ads architecture
  await SaveManager.init();
  AdsManager.init();

  runApp(const KissAndRunApp());
}

class KissAndRunApp extends StatelessWidget {
  const KissAndRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiss & Run',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF4081),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'sans-serif',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4081),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}
