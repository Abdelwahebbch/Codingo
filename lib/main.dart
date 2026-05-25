import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/services/Auth/auth_repository.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_repository.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/services/Data/party_data_provider.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/onboarding/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final AppwriteService appwriteService = AppwriteService();

  runApp(
    MultiProvider(
      providers: [
        // ── Infrastructure ────────────────────────────────────────────────
        Provider<AppwriteService>(create: (_) => appwriteService),
        Provider<AuthRepository>(
          create: (context) =>
              AuthRepository(appwriteService: context.read<AppwriteService>()),
        ),
        Provider<DataRepository>(
          create: (context) =>
              DataRepository(appwriteService: context.read<AppwriteService>()),
        ),

        // ── Theme ─────────────────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => ThemeManager()),

        // ── Auth ──────────────────────────────────────────────────────────
        // `..init()` fires the async session check immediately.
        // SplashScreen awaits `authProvider.initialized` before routing.
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(authRepository: context.read<AuthRepository>())
                ..init(),
        ),

        // ── Data ──────────────────────────────────────────────────────────
        // DataProvider attaches an internal listener to AuthProvider inside
        // its constructor.  It calls its own init() automatically once auth
        // resolves to `authenticated`, so we do NOT call init() here.
        ChangeNotifierProvider<DataProvider>(
          create: (context) => DataProvider(
            dataRepository: context.read<DataRepository>(),
            authProvider: context.read<AuthProvider>(),
          ),
        ),

        // ── Party ─────────────────────────────────────────────────────────
        ChangeNotifierProvider<PartyDataProvider>(
          create: (context) => PartyDataProvider(
            appwriteService: context.read<AppwriteService>(),
            dataRepository: context.read<DataRepository>(),
            authProvider: context.read<AuthProvider>(),
            progress: context.read<DataProvider>().progress,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: true);

    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior()
          .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      title: 'AI Tutor: Software Engineering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeManager.themeMode,
      home: const SplashScreen(),
    );
  }
}