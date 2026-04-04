import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/theme_store.dart';
import 'home_screen.dart';
import 'track_screen.dart';
import '../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profile",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.purpleAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Appearance",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(isDark ? "Dark mode" : "Light mode",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (_) => ThemeStore.instance.toggle(),
                      activeColor: Colors.purpleAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final screens = [
    const HomeScreen(),
    const TrackScreen(),
    const _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: screens[currentIndex]),

            Padding(
              padding: const EdgeInsets.all(16),
              child: BottomNav(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() => currentIndex = index);
                },
              ),
            ),
          ],
        ),
      ),


    );
  }
}