import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/splash_screen.dart';
import 'models/agenda_adapter.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  tz.initializeTimeZones();
  await NotificationService().initNotification();
  await Hive.initFlutter();
  Hive.registerAdapter(AgendaAdapter());

  await Hive.openBox('myAgenda');
  await Hive.openBox('appSettings');
  await Hive.openBox('categories');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = _themeMode.value == ThemeMode.dark;
    await prefs.setBool('isDarkMode', !isDarkMode);
    _themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Agenda',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.brown.shade100,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.brown.shade100,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: currentThemeMode,
          home: SplashScreen(
            onToggleTheme: _toggleTheme,
          ),
        );
      },
    );
  }
}
