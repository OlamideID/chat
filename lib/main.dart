import 'package:chat/providers/theme_provider.dart';
import 'package:chat/services/auth/auth_gate.dart';
import 'package:chat/firebase_options.dart';
import 'package:chat/themes/light.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
         final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      themeMode: themeMode,
      // darkTheme: ,
      home: const AuthGate(),
    );
  }
}
