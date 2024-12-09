import 'package:chat/firebase_options.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:chat/services/auth/auth_gate.dart';
import 'package:chat/themes/dark.dart';
import 'package:chat/themes/light.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tb3Vzb2RoaWl4cnFneWNtYnBtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE5NDUzNjMsImV4cCI6MjA0NzUyMTM2M30.JsIsGFOsqXHN1wQDBBpKd5yqG5Q7wOMNp0zHzTGbv7c',
    url: 'https://omousodhiixrqgycmbpm.supabase.co/',
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return DevicePreview(
      backgroundColor: Colors.white,
      enabled: !kReleaseMode, // Only enable device preview in debug mode
      availableLocales: const [
        Locale('en', 'US'),
      ],
      builder: (context) => MaterialApp(
        // ignore: deprecated_member_use
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: dark,
        themeMode: theme,
        home: const AuthGate(),
      ),
    );
  }
}
