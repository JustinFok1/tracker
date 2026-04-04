import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'models/vial.dart';
import 'models/schedule.dart';
import 'data/dose_log_store.dart';
import 'data/vial_inventory_store.dart';
import 'data/theme_store.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(VialAdapter());
  Hive.registerAdapter(ScheduleAdapter());

  await Hive.openBox<Vial>('vials');
  await Hive.openBox<Schedule>('schedules');
  await Hive.openBox<bool>('dose_logs');
  await Hive.openBox<bool>('settings');
  await DoseLogStore.instance.init();
  await VialInventoryStore.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ThemeStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ThemeStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeStore.instance.themeMode,
      home: Hive.box<bool>('settings').get('onboarding_done', defaultValue: false)!
          ? const MainScreen()
          : const OnboardingScreen(),
    );
  }
}
