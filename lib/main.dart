import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'models/vial.dart';
import 'models/schedule.dart';
import 'data/dose_log_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(VialAdapter());
  Hive.registerAdapter(ScheduleAdapter());

  await Hive.openBox<Vial>('vials');
  await Hive.openBox<Schedule>('schedules');
  await Hive.openBox<bool>('dose_logs');
  await DoseLogStore.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MainScreen(),
    );
  }
}