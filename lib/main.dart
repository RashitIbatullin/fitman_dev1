import 'package:fitman_app/screens/login_screen.dart';
import 'package:fitman_app/utils/my_custom_scroll_behavior.dart';
import 'package:fitman_app/widgets/auth_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitman_app/services/api_service.dart';

// Global key for the navigator
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment from --dart-define, defaulting to 'dev'
  const env = String.fromEnvironment('env', defaultValue: 'dev');
  print('--- [Fitman Build] Evironment selected: $env');

  await dotenv.load(fileName: "packages/fitman_app/.env.$env");
  print('--- [Fitman Build] Attempted to load .env.$env');
  print('--- [Fitman Build] Loaded BASE_URL: ${dotenv.env['BASE_URL']}');

  await initializeDateFormatting('ru', null);
  await ApiService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitman MVP2',
      navigatorKey: navigatorKey, // Assign the global key
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 16.0),
          titleMedium: TextStyle(fontSize: 14.0),
          labelLarge: TextStyle(fontSize: 14.0),
        ),
      ),
      scrollBehavior: MyCustomScrollBehavior(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', ''), // Russian
      ],
      // The LoginScreen is now the base route.
      home: const LoginScreen(),
      // The AuthNavigator sits above the navigator and handles auth-based navigation.
      builder: (context, child) {
        return AuthNavigator(navigatorKey: navigatorKey, child: child!);
      },
    );
  }
}