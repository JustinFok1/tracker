import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'screens/main_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/onboarding_screen.dart';
import 'data/vial_store.dart';
import 'data/schedule_store.dart';
import 'data/dose_log_store.dart';
import 'data/body_metric_store.dart';
import 'data/vial_inventory_store.dart';
import 'data/theme_store.dart';

// Hive adapters must still be registered (generated code references them).
import 'models/vial.dart';
import 'models/schedule.dart';
import 'models/body_metric.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive — settings only (onboarding flag, theme, etc.)
  await Hive.initFlutter();
  Hive.registerAdapter(VialAdapter());
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(BodyMetricAdapter());
  await Hive.openBox<bool>('settings');

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// null  = still waiting for first auth event (show splash)
  /// false = no signed-in user (show sign-in screen)
  /// true  = signed in + stores ready (show main app)
  bool? _ready;

  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    ThemeStore.instance.addListener(_refresh);
    _authSub =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  @override
  void dispose() {
    ThemeStore.instance.removeListener(_refresh);
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      if (mounted) setState(() => _ready = false);
      return;
    }
    // New sign-in or app restart with existing session — init all stores.
    await Future.wait([
      VialStore.instance.init(user.uid),
      ScheduleStore.instance.init(user.uid),
      DoseLogStore.instance.init(user.uid),
      BodyMetricStore.instance.init(user.uid),
      VialInventoryStore.instance.init(user.uid),
    ]);
    if (mounted) setState(() => _ready = true);
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeStore.instance.themeMode,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_ready == null) return const _SplashScreen();
    if (_ready == false) return const SignInScreen();
    return Hive.box<bool>('settings')
            .get('onboarding_done', defaultValue: false)!
        ? const MainScreen()
        : const OnboardingScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child:
                  const Icon(Icons.science, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.purpleAccent,
            ),
          ],
        ),
      ),
    );
  }
}
